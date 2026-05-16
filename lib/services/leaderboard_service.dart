import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String userId;
  final String name;
  final int score;
  final int total;
  final int elapsedSeconds;
  final String? profileImage;

  const LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.score,
    required this.total,
    required this.elapsedSeconds,
    this.profileImage,
  });
}

class LeaderboardService {
  static final _db = FirebaseFirestore.instance;

  /// Records score ONLY if it's better than previous.
  /// Uses a unique ID (userId_moduleId) to prevent future duplicates.
  static Future<void> recordScore({
    required String userId,
    required String moduleId,
    required String courseId,
    required int score,
    required int elapsedSeconds,
  }) async {
    final docId = '${userId}_$moduleId';
    final docRef = _db.collection('bestScores').doc(docId);
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      final int existingScore = data['score'] ?? 0;
      final int existingTime = data['elapsedSeconds'] ?? 999999;

      // Update if current attempt is BETTER or EQUAL with faster time
      if (score > existingScore || (score == existingScore && elapsedSeconds < existingTime)) {
        await docRef.update({
          'score': score,
          'elapsedSeconds': elapsedSeconds,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } else {
      await docRef.set({
        'userId': userId,
        'moduleId': moduleId,
        'courseId': courseId,
        'score': score,
        'elapsedSeconds': elapsedSeconds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Fetches the user's historical best score for this module.
  static Future<int> getBestScore(String userId, String moduleId) async {
    final docId = '${userId}_$moduleId';
    final doc = await _db.collection('bestScores').doc(docId).get();
    if (!doc.exists) return 0;
    return doc.data()?['score'] ?? 0;
  }

  /// Fetches the leaderboard and REMOVES DUPLICATES.
  static Future<List<LeaderboardEntry>> getLeaderboard(String moduleId) async {
    // 1. Fetch all scores for this module, highest score first.
    final scoresSnap = await _db
        .collection('bestScores')
        .where('moduleId', isEqualTo: moduleId)
        .orderBy('score', descending: true)
        .get();

    if (scoresSnap.docs.isEmpty) return [];

    // 2. Get course info for question count.
    final firstDoc = scoresSnap.docs.first.data();
    final courseId = firstDoc['courseId'] as String;
    final totalSnap = await _db
        .collection('courses')
        .doc(courseId)
        .collection('modules')
        .doc(moduleId)
        .collection('questions')
        .count()
        .get();
    final currentTotal = totalSnap.count ?? 0;

    // 3. DEDUPLICATION LOGIC
    // We use a Map where Key = userId. 
    // Since scoresSnap is already ordered by score DESC, 
    // the FIRST time we see a userId, it is their best score.
    final Map<String, LeaderboardEntry> uniqueEntriesMap = {};

    for (var doc in scoresSnap.docs) {
      final data = doc.data();
      final userId = data['userId'] as String;

      // Only process this user if we haven't added them to the map yet
      if (!uniqueEntriesMap.containsKey(userId)) {
        try {
          final userDoc = await _db.collection('users').doc(userId).get();
          if (userDoc.exists) {
            final userData = userDoc.data();
            uniqueEntriesMap[userId] = LeaderboardEntry(
              userId: userId,
              name: userData?['name'] as String? ?? 'Student',
              score: data['score'] ?? 0,
              total: currentTotal,
              elapsedSeconds: data['elapsedSeconds'] ?? 0,
              profileImage: userData?['profileImage'] as String?,
            );
          }
        } catch (e) {
          //print("Error fetching user $userId: $e");
        }
      }
    }

    // Convert map values back to a list
    List<LeaderboardEntry> entries = uniqueEntriesMap.values.toList();

    // 4. TIE-BREAKER SORTING
    // Primary: Score (Descending)
    // Secondary: Time (Ascending - faster is better)
    entries.sort((a, b) {
      final scoreCmp = b.score.compareTo(a.score);
      if (scoreCmp != 0) return scoreCmp;
      return a.elapsedSeconds.compareTo(b.elapsedSeconds);
    });

    // Return only top 10 unique users
    return entries.take(10).toList();
  }
}