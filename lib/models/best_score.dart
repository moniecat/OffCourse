import 'package:cloud_firestore/cloud_firestore.dart';

class BestScoreModel {
  final String id;
  final String userId;
  final String courseId;
  final String moduleId;
  final int score;
  final int total;
  final DateTime updatedAt;

  const BestScoreModel({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.moduleId,
    required this.score,
    required this.total,
    required this.updatedAt,
  });

  factory BestScoreModel.fromMap(String id, Map<String, dynamic> data) {
    return BestScoreModel(
      id:        id,
      userId:    data['userId']    as String? ?? '',
      courseId:  data['courseId']  as String? ?? '',
      moduleId:  data['moduleId']  as String? ?? '',
      score:     data['score']     as int?    ?? 0,
      total:     data['total']     as int?    ?? 0,
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId':    userId,
    'courseId':  courseId,
    'moduleId':  moduleId,
    'score':     score,
    'total':     total,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}