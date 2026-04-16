import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
//import '../models/result.dart';
import '../models/best_score.dart';

class ResultService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> saveResult({
    required String courseId,
    required String moduleId,
    required int score,
    required int total,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // 1. Save raw result
    await _db.collection('results').add({
      'userId':   uid,
      'courseId': courseId,
      'moduleId': moduleId,
      'score':    score,
      'total':    total,
      'takenAt':  Timestamp.now(),
    });

    // 2. Check existing best score for this user + module
    final bestQuery = await _db
        .collection('bestScores')
        .where('userId',   isEqualTo: uid)
        .where('moduleId', isEqualTo: moduleId)
        .limit(1)
        .get();

    if (bestQuery.docs.isEmpty) {
      // No best score yet — create one
      await _db.collection('bestScores').add({
        'userId':    uid,
        'courseId':  courseId,
        'moduleId':  moduleId,
        'score':     score,
        'total':     total,
        'updatedAt': Timestamp.now(),
      });
      debugPrint('>>> SAVED new bestScore — moduleId: $moduleId, score: $score'); 
    } else {
      final doc          = bestQuery.docs.first;
      final existingBest = doc.data()['score'] as int? ?? 0;

      // Only update if new score is better
      if (score > existingBest) {
        await _db.collection('bestScores').doc(doc.id).update({
          'score':     score,
          'updatedAt': Timestamp.now(),
        });
      }
    }
  }

  static Future<BestScoreModel?> getBestScore({
    required String userId,
    required String moduleId,
  }) async {
    final query = await _db
        .collection('bestScores')
        .where('userId',   isEqualTo: userId)
        .where('moduleId', isEqualTo: moduleId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    return BestScoreModel.fromMap(doc.id, doc.data());
  }
}