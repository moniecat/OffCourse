class QuestionModel {
  final String module;
  final int course;
  final String questionType;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer; // "A", "B", "C", or "D"

  const QuestionModel({
    required this.module,
    required this.course,
    required this.questionType,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
  });

  /// Returns the answer text for a given label (A/B/C/D)
  String getOptionText(String label) {
    switch (label.toUpperCase()) {
      case 'A':
        return optionA;
      case 'B':
        return optionB;
      case 'C':
        return optionC;
      case 'D':
        return optionD;
      default:
        return '';
    }
  }

  bool isCorrect(String selected) =>
      selected.toUpperCase() == correctAnswer.toUpperCase();

  factory QuestionModel.fromCsvRow(List<dynamic> row) {
    return QuestionModel(
      module: row[0].toString().trim(),
      course: int.tryParse(row[1].toString().trim()) ?? 1,
      questionType: row[2].toString().trim(),
      question: row[3].toString().trim(),
      optionA: row[4].toString().trim(),
      optionB: row[5].toString().trim(),
      optionC: row[6].toString().trim(),
      optionD: row[7].toString().trim(),
      correctAnswer: row[8].toString().trim(),
    );
  }
}