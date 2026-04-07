import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

class FirestoreService {
  // --- USERS ---

  /// Creates a user document. Uses merge:true so it won't overwrite
  /// existing data when called on sign-in for an already-registered user.
  Future<void> addUser(String id, String name, String email) async {
    await db.collection('users').doc(id).set(
      {
        'name': name,
        'email': email,
        'joinedAt': Timestamp.now(),
      },
      SetOptions(merge: true), // <-- KEY FIX: don't blow away existing data
    );
  }

  Future<DocumentSnapshot> getUser(String id) async {
    return await db.collection('users').doc(id).get();
  }

  /// Update editable profile fields (name, bio, lrn)
  Future<void> updateUserProfile(
      String id, {
      String? name,
      String? bio,
      String? lrn,
    }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (bio != null) data['bio'] = bio;
    if (lrn != null) data['lrn'] = lrn;
    if (data.isEmpty) return;
    await db.collection('users').doc(id).update(data);
  }

  // --- COURSES ---
  Future<void> addCourse(String title, String description) async {
    await db.collection('courses').add({
      'title': title,
      'description': description,
      'createdAt': Timestamp.now(),
    });
  }

  Future<QuerySnapshot> getCourses() async {
    return await db.collection('courses').get();
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
    await db.collection('schedules').doc(scheduleId).update({'status': status});
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
    await db.collection('tasks').doc(taskId).update({'completed': completed});
  }
}
