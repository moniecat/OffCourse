import '../models/question_model.dart';
import 'firestore_service.dart';

class QuestionService {
  /// Fetches questions from Firestore filtered by moduleId and courseId.
  static Future<List<QuestionModel>> loadForModule(
    String moduleName,
    String courseId,
  ) async {
    final snapshot = await db
        .collection('courses')
        .doc(courseId)
        .collection('modules')
        .where('title', isEqualTo: moduleName)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return [];

    final moduleId = snapshot.docs.first.id;

    final questionsSnapshot = await db
        .collection('courses')
        .doc(courseId)
        .collection('modules')
        .doc(moduleId)
        .collection('questions')
        .get();

    return questionsSnapshot.docs
        .map((doc) => QuestionModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  static Future<int> getTotalQuestions(String courseId, String moduleId) async {
    final snapshot = await db
        .collection('courses')
        .doc(courseId)
        .collection('modules')
        .doc(moduleId)
        .collection('questions')
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}