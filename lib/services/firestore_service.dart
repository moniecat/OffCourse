import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

class FirestoreService {
  // --- USERS ---
  Future<void> addUser(String id, String name, String email) async {
    await db.collection('users').doc(id).set({
      'name': name,
      'email': email,
      'joinedAt': Timestamp.now(),
    });
  }

  Future<DocumentSnapshot> getUser(String id) async {
    return await db.collection('users').doc(id).get();
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