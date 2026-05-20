import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';

class FirestoreService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // ===========================================================================
  // USERS
  // ===========================================================================

  /// Create or update a user document
  Future<void> addUser(String id, String name, String email, {String role = 'student'}) async {
    await db.collection('users').doc(id).set(
      {
        'name': name,
        'email': email,
        'role': role,
        'joinedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Get a single user document
  Future<DocumentSnapshot> getUser(String id) async {
    return await db.collection('users').doc(id).get();
  }

  /// Get just the role of a user
  Future<String?> getUserRole(String id) async {
    final doc = await getUser(id);
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>?;
    return data?['role'] as String?;
  }

  /// Update user profile details
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

  /// CRITICAL: Deletes the user document from Firestore.
  /// Prevents "ghost users" from appearing on leaderboards after account deletion.
  Future<void> deleteUserRecord(String uid) async {
    await db.collection('users').doc(uid).delete();
  }

  // ===========================================================================
  // COURSES
  // ===========================================================================

  Future<void> addCourse(String title, String description, int order) async {
    await db.collection('courses').add({
      'title': title,
      'description': description,
      'order': order,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Course>> getCourses() async {
    final snapshot = await db.collection('courses').orderBy('order').get();
    return snapshot.docs.map((doc) => Course.fromMap(doc.id, doc.data())).toList();
  }

  Stream<List<Course>> watchCourses() {
    return db.collection('courses').orderBy('order').snapshots().map((snap) =>
        snap.docs.map((doc) => Course.fromMap(doc.id, doc.data())).toList());
  }

  Future<Course?> getCourse(String courseId) async {
    final doc = await db.collection('courses').doc(courseId).get();
    if (doc.exists && doc.data() != null) {
      return Course.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  Future<void> updateCourse(String courseId, String title, String description, int order) async {
    await db.collection('courses').doc(courseId).update({
      'title': title,
      'description': description.isEmpty ? null : description,
      'order': order,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ===========================================================================
  // MODULES
  // ===========================================================================

  Future<void> addModule(String courseId, String title, String description, int order) async {
    await db.collection('courses').doc(courseId).collection('modules').add({
      'title': title,
      'description': description,
      'order': order,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getModules(String courseId) async {
    final snapshot = await db
        .collection('courses')
        .doc(courseId)
        .collection('modules')
        .orderBy('order')
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  Stream<List<Map<String, dynamic>>> watchModules(String courseId) {
    return db
        .collection('courses')
        .doc(courseId)
        .collection('modules')
        .orderBy('order')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  Future<void> updateModule(String courseId, String moduleId, String title, String description, int order) async {
    await db.collection('courses').doc(courseId).collection('modules').doc(moduleId).update({
      'title': title,
      'description': description.isEmpty ? null : description,
      'order': order,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ===========================================================================
  // QUESTIONS
  // ===========================================================================

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
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateQuestion({
    required String courseId,
    required String moduleId,
    required String questionId,
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
        .doc(questionId)
        .update({
      'questionType': questionType,
      'question': question,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'correctAnswer': correctAnswer,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ===========================================================================
  // STATS
  // ===========================================================================

  /// Stream that emits real‑time stats: number of courses, modules, and questions.
  Stream<Map<String, int>> watchStats() async* {
    await for (final coursesSnapshot in db.collection('courses').snapshots()) {
      int courseCount = coursesSnapshot.docs.length;
      int moduleCount = 0;
      int questionCount = 0;

      for (var courseDoc in coursesSnapshot.docs) {
        final modulesSnapshot = await db.collection('courses').doc(courseDoc.id).collection('modules').get();
        moduleCount += modulesSnapshot.docs.length;

        for (var moduleDoc in modulesSnapshot.docs) {
          final questionsSnapshot = await db
              .collection('courses')
              .doc(courseDoc.id)
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

  // ===========================================================================
  // DELETE METHODS (Recursive)
  // ===========================================================================

  Future<void> deleteCourse(String courseId) async {
    final modulesSnapshot = await db.collection('courses').doc(courseId).collection('modules').get();
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
    await db.collection('courses').doc(courseId).collection('modules').doc(moduleId).delete();
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

  // ===========================================================================
  // SCHEDULES & TASKS
  // ===========================================================================

  Future<void> addSchedule(String userId, String courseId, DateTime date) async {
    await db.collection('schedules').add({
      'userId': userId,
      'courseId': courseId,
      'date': Timestamp.fromDate(date),
      'status': 'pending',
    });
  }

  Future<QuerySnapshot> getUserSchedules(String userId) async {
    return await db.collection('schedules').where('userId', isEqualTo: userId).get();
  }

  Future<void> updateScheduleStatus(String scheduleId, String status) async {
    await db.collection('schedules').doc(scheduleId).update({'status': status});
  }

  Future<void> addTask(String scheduleId, String title) async {
    await db.collection('tasks').add({
      'scheduleId': scheduleId,
      'title': title,
      'completed': false,
    });
  }

  Future<QuerySnapshot> getTasks(String scheduleId) async {
    return await db.collection('tasks').where('scheduleId', isEqualTo: scheduleId).get();
  }

  Future<void> updateTaskCompletion(String taskId, bool completed) async {
    await db.collection('tasks').doc(taskId).update({'completed': completed});
  }
}