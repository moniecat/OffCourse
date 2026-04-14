import 'package:flutter/services.dart';
import '../models/question_model.dart';

class QuestionService {
  static const String _csvPath = 'assets/data/questions.csv';

  /// Loads all questions from the CSV asset file.
  static Future<List<QuestionModel>> loadAll() async {
    final raw = await rootBundle.loadString(_csvPath);
    final lines = raw.trim().split('\n');

    // Skip header row
    return lines
        .skip(1)
        .where((line) => line.trim().isNotEmpty)
        .map((line) => QuestionModel.fromCsvRow(_parseCsvLine(line)))
        .toList();
  }

  /// Filters questions by module name and course number.
  static Future<List<QuestionModel>> loadForModule(
    String module,
    int course,
  ) async {
    final all = await loadAll();
    return all
        .where(
          (q) =>
              q.module.toLowerCase() == module.toLowerCase() &&
              q.course == course,
        )
        .toList();
  }

  /// Simple CSV line parser (handles basic comma-separated values).
  static List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    result.add(buffer.toString().trim());
    return result;
  }
}