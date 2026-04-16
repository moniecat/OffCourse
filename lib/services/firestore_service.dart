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

  Future<Course?> getCourse(String courseId) async {
    final doc = await db.collection('courses').doc(courseId).get();
    if (doc.exists) {
      return Course.fromMap(doc.id, doc.data()!);
    }
    return null;
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