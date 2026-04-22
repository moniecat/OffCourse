import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';

final db = FirebaseFirestore.instance;

class FirestoreService {
  // --- USERS ---

  Future<void> addUser(String id, String name, String email, {String role = 'student'}) async {
    await db.collection('users').doc(id).set(
      {
        'name': name,
        'email': email,
        'role': role,
        'joinedAt': Timestamp.now(),
      },
      SetOptions(merge: true),
    );
  }

  Future<DocumentSnapshot> getUser(String id) async {
    return await db.collection('users').doc(id).get();
  }

  Future<String?> getUserRole(String id) async {
    final doc = await getUser(id);
    if (!doc.exists) return null;
    return (doc.data() as Map<String, dynamic>?)?['role'] as String?;
  }

  Future<void> updateUserProfile(
    String uid, {
    String? name,
    String? bio,
    String? lrn,
    String? profileImage,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (bio != null) data['bio'] = bio;
    if (lrn != null) data['lrn'] = lrn;
    if (profileImage != null) data['profileImage'] = profileImage;
    if (data.isEmpty) return;
    await db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  // --- COURSES ---

  Future<void> addCourse(String title, String description, int order) async {
    await db.collection('courses').add({
      'title': title,
      'description': description,
      'order': order,
      'createdAt': Timestamp.now(),
    });
  }

  Future<List<Course>> getCourses() async {
    final snapshot = await db
        .collection('courses')
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => Course.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<Course>> watchCourses() {
    return db
        .collection('courses')
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Course.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<Course?> getCourse(String courseId) async {
    final doc = await db.collection('courses').doc(courseId).get();
    if (doc.exists) {
      return Course.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  // --- MODULES ---

  Future<void> addModule(
    String courseId,
    String title,
    String description,
    int order,
  ) async {
    await db.collection('courses').doc(courseId).collection('modules').add({
      'title': title,
      'description': description,
      'order': order,
      'createdAt': Timestamp.now(),
    });
  }

  Future<List<Map<String, dynamic>>> getModules(String courseId) async {
    final snapshot = await db
        .collection('courses')
        .doc(courseId)
        .collection('modules')
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
  }

  Stream<List<Map<String, dynamic>>> watchModules(String courseId) {
    return db
        .collection('courses')
        .doc(courseId)
        .collection('modules')
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  // --- QUESTIONS ---

  Future<void> addQuestion({
    required String courseId,
    required String moduleId,
    required String questionType,
    required String question,
    required String optionA,
    required String optionB,
    required String optionC,
    required String optionD,
    required String correctAnswer,
  }) async {
    await db
        .collection('courses')
        .doc(courseId)
        .collection('modules')
        .doc(moduleId)
        .collection('questions')
        .add({
      'courseId': courseId,
      'moduleId': moduleId,
      'questionType': questionType,
      'question': question,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'correctAnswer': correctAnswer,
      'createdAt': Timestamp.now(),
    });
  }

  /// Stream that emits real‑time stats: number of courses, modules, and questions.
  Stream<Map<String, int>> watchStats() async* {
    // Listen to courses collection changes
    await for (final coursesSnapshot in db.collection('courses').snapshots()) {
      int courseCount = coursesSnapshot.docs.length;
      int moduleCount = 0;
      int questionCount = 0;

      // For each course, fetch its modules and questions
      for (final courseDoc in coursesSnapshot.docs) {
        final courseId = courseDoc.id;
        // Get modules of this course
        final modulesSnapshot = await db
            .collection('courses')
            .doc(courseId)
            .collection('modules')
            .get();
        moduleCount += modulesSnapshot.docs.length;

        // For each module, count questions
        for (final moduleDoc in modulesSnapshot.docs) {
          final questionsSnapshot = await db
              .collection('courses')
              .doc(courseId)
              .collection('modules')
              .doc(moduleDoc.id)
              .collection('questions')
              .get();
          questionCount += questionsSnapshot.docs.length;
        }
      }

      yield {
        'courses': courseCount,
        'modules': moduleCount,
        'questions': questionCount,
      };
    }
  }

  // --- DELETE METHODS ---

  Future<void> deleteCourse(String courseId) async {
    final modulesSnapshot = await db
        .collection('courses')
        .doc(courseId)
        .collection('modules')
        .get();

    for (var moduleDoc in modulesSnapshot.docs) {
      await deleteModule(courseId, moduleDoc.id);
    }

    await db.collection('courses').doc(courseId).delete();
  }

  Future<void> deleteModule(String courseId, String moduleId) async {
    final questionsSnapshot = await db
        .collection('courses')
        .doc(courseId)
        .collection('modules')
        .doc(moduleId)
        .collection('questions')
        .get();

    for (var questionDoc in questionsSnapshot.docs) {
      await deleteQuestion(courseId, moduleId, questionDoc.id);
    }

    await db
        .collection('courses')
        .doc(courseId)
        .collection('modules')
        .doc(moduleId)
        .delete();
  }

  Future<void> deleteQuestion(String courseId, String moduleId, String questionId) async {
    await db
        .collection('courses')
        .doc(courseId)
        .collection('modules')
        .doc(moduleId)
        .collection('questions')
        .doc(questionId)
        .delete();
  }

  // --- SCHEDULES ---

  Future<void> addSchedule(String userId, String courseId, DateTime date) async {
    await db.collection('schedules').add({
      'userId': userId,
      'courseId': courseId,
      'date': Timestamp.fromDate(date),
      'status': 'pending',
    });
  }

  Future<QuerySnapshot> getUserSchedules(String userId) async {
    return await db
        .collection('schedules')
        .where('userId', isEqualTo: userId)
        .get();
  }

  Future<void> updateScheduleStatus(String scheduleId, String status) async {
    await db
        .collection('schedules')
        .doc(scheduleId)
        .update({'status': status});
  }

  // --- TASKS ---

  Future<void> addTask(String scheduleId, String title) async {
    await db.collection('tasks').add({
      'scheduleId': scheduleId,
      'title': title,
      'completed': false,
    });
  }

  Future<QuerySnapshot> getTasks(String scheduleId) async {
    return await db
        .collection('tasks')
        .where('scheduleId', isEqualTo: scheduleId)
        .get();
  }

  Future<void> updateTaskCompletion(String taskId, bool completed) async {
    await db
        .collection('tasks')
        .doc(taskId)
        .update({'completed': completed});
  }
}