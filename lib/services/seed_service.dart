import 'dart:convert';
import 'package:flutter/foundation.dart'; // Added for debugPrint
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';

class SeedService {
  final FirebaseFirestore db;

  SeedService({FirebaseFirestore? firestore})
      : db = firestore ?? FirebaseFirestore.instance;

  Future<void> seedAll() async {
    final coursesJson    = await rootBundle.loadString('assets/data/courses.json');
    final modulesJson    = await rootBundle.loadString('assets/data/modules.json');
    final questionsJson  = await rootBundle.loadString('assets/data/questions.json');

    final courses   = List<Map<String, dynamic>>.from(jsonDecode(coursesJson));
    final modules   = List<Map<String, dynamic>>.from(jsonDecode(modulesJson));
    final questions = List<Map<String, dynamic>>.from(jsonDecode(questionsJson));

    // Step 1: Seed courses
    final Map<String, String> courseTitleToId = {};
    for (final course in courses) {
      final existing = await db
          .collection('courses')
          .where('title', isEqualTo: course['title'])
          .limit(1)
          .get();

      String courseId;
      if (existing.docs.isNotEmpty) {
        courseId = existing.docs.first.id;
      } else {
        final ref = await db.collection('courses').add({
          ...course,
          'createdAt': Timestamp.now(),
        });
        courseId = ref.id;
      }
      courseTitleToId[course['title'] as String] = courseId;
    }

    // Step 2: Seed modules
    final Map<String, String> moduleTitleToId = {};
    for (final module in modules) {
      final courseTitle = module['courseTitle'] as String;
      final courseId    = courseTitleToId[courseTitle];
      if (courseId == null) {
        debugPrint('⚠️  Course not found for module: ${module['title']}'); // Fixed: avoid_print
        continue;
      }

      final moduleData = {
        'title': module['title'],
        'order': module['order'],
        'description': module['description'] ?? '', 
      };

      final existing = await db
          .collection('courses')
          .doc(courseId)
          .collection('modules')
          .where('title', isEqualTo: module['title'])
          .limit(1)
          .get();

      String moduleId;
      if (existing.docs.isNotEmpty) {
        moduleId = existing.docs.first.id;
        await db                                   
          .collection('courses')
          .doc(courseId)
          .collection('modules')
          .doc(moduleId)
          .update({'description': module['description'] ?? ''});
      } else {
        final ref = await db
            .collection('courses')
            .doc(courseId)
            .collection('modules')
            .add(moduleData);
        moduleId = ref.id;
      }
      moduleTitleToId['$courseId::${module['title']}'] = moduleId;
    }

    // Step 3: Seed questions
    for (final question in questions) {
      final courseTitle  = question['courseTitle'] as String;
      final moduleTitle  = question['moduleTitle'] as String;
      final courseId     = courseTitleToId[courseTitle];

      if (courseId == null) {
        debugPrint('⚠️  Course not found for question: ${question['question']}'); // Fixed: avoid_print
        continue;
      }

      final moduleId = moduleTitleToId['$courseId::$moduleTitle'];
      if (moduleId == null) {
        debugPrint('⚠️  Module not found for question: ${question['question']}'); // Fixed: avoid_print
        continue;
      }

      final questionData = {
        'courseId':      courseId,
        'moduleId':      moduleId,
        'questionType':  question['questionType'],
        'question':      question['question'],
        'optionA':       question['optionA'],
        'optionB':       question['optionB'],
        'optionC':       question['optionC'],
        'optionD':       question['optionD'],
        'correctAnswer': question['correctAnswer'],
      };

      final existing = await db
          .collection('courses')
          .doc(courseId)
          .collection('modules')
          .doc(moduleId)
          .collection('questions')
          .where('question', isEqualTo: question['question'])
          .limit(1)
          .get();

      if (existing.docs.isEmpty) {
        await db
            .collection('courses')
            .doc(courseId)
            .collection('modules')
            .doc(moduleId)
            .collection('questions')
            .add(questionData);
      }
    }

    debugPrint('✅ Seeding complete.'); // Fixed: avoid_print
  }
}