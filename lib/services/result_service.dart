import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/best_score.dart';

class ResultService {
  static final _db = FirebaseFirestore.instance;

  /// Saves (or updates) the best score for a user + module.
  /// Updates if: better score, OR same score but faster time.
  static Future<void> saveResult({
    required String courseId,
    required String moduleId,
    required int score,
    required int total,
    int elapsedSeconds = 0,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final existing = await _db
        .collection('bestScores')
        .where('userId', isEqualTo: uid)
        .where('moduleId', isEqualTo: moduleId)
        .limit(1)
        .get();

    final now = DateTime.now();

    if (existing.docs.isEmpty) {
      await _db.collection('bestScores').add({
        'userId':         uid,
        'courseId':       courseId,
        'moduleId':       moduleId,
        'score':          score,
        'total':          total,
        'elapsedSeconds': elapsedSeconds,
        'updatedAt':      Timestamp.fromDate(now),
      });
      return;
    }

    final doc = existing.docs.first;
    final data = doc.data();
    final existingScore = data['score'] as int? ?? 0;
    final existingTime  = data['elapsedSeconds'] as int? ?? 0;

    final betterScore     = score > existingScore;
    final sameScoreFaster = score == existingScore && elapsedSeconds < existingTime;

    if (betterScore || sameScoreFaster) {
      await doc.reference.update({
        'score':          score,
        'total':          total,
        'elapsedSeconds': elapsedSeconds,
        'updatedAt':      Timestamp.fromDate(now),
      });
    }
  }

  /// Returns the best score record for a user + module, or null if none exists.
  static Future<BestScoreModel?> getBestScore({
    required String userId,
    required String moduleId,
  }) async {
    final snap = await _db
        .collection('bestScores')
        .where('userId', isEqualTo: userId)
        .where('moduleId', isEqualTo: moduleId)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return BestScoreModel.fromMap(doc.id, doc.data());
  }
}