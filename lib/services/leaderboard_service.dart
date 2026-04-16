import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String userId;
  final String name;
  final int score;
  final int total;
  final String? profileImage;

  const LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.score,
    required this.total,
    this.profileImage,
  });
}

class LeaderboardService {
  static final _db = FirebaseFirestore.instance;

  static Future<List<LeaderboardEntry>> getLeaderboard(String moduleId) async {
    final scoresSnap = await _db
        .collection('bestScores')
        .where('moduleId', isEqualTo: moduleId)
        .orderBy('score', descending: true)
        .limit(10)
        .get();

    if (scoresSnap.docs.isEmpty) return [];

    final entries = await Future.wait(
      scoresSnap.docs.map((doc) async {
        final data = doc.data();
        final userId = data['userId'] as String;
        final score = data['score'] as int? ?? 0;
        final total = data['total'] as int? ?? 0;

        String name = 'Unknown';
        String? profileImage;

        try {
          final userDoc = await _db.collection('users').doc(userId).get();
          if (userDoc.exists) {
            final userData = userDoc.data();
            name = userData?['name'] as String? ?? 'Student';
            profileImage = userData?['profileImage'] as String?;
          }
        } catch (_) {}

        return LeaderboardEntry(
          userId: userId,
          name: name,
          score: score,
          total: total,
          profileImage: profileImage,
        );
      }),
    );

    return entries;
  }
}