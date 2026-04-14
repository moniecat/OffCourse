class QuestionModel {
  final String id;
  final String courseId;
  final String moduleId;
  final String questionType;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String correctAnswer;

  const QuestionModel({
    required this.id,
    required this.courseId,
    required this.moduleId,
    required this.questionType,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    required this.correctAnswer,
  });

  String getOptionText(String label) {
    switch (label.toUpperCase()) {
      case 'A': return optionA;
      case 'B': return optionB;
      case 'C': return optionC;
      case 'D': return optionD;
      default:  return '';
    }
  }

  bool isCorrect(String selected) =>
      selected.toUpperCase() == correctAnswer.toUpperCase();

  factory QuestionModel.fromMap(String id, Map<String, dynamic> data) {
    return QuestionModel(
      id:           id,
      courseId:     data['courseId']      as String? ?? '',
      moduleId:     data['moduleId']      as String? ?? '',
      questionType: data['questionType']  as String? ?? '',
      question:     data['question']      as String? ?? '',
      optionA:      data['optionA']       as String? ?? '',
      optionB:      data['optionB']       as String? ?? '',
      optionC:      data['optionC']       as String? ?? '',
      optionD:      data['optionD']       as String? ?? '',
      correctAnswer: data['correctAnswer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'courseId':      courseId,
    'moduleId':      moduleId,
    'questionType':  questionType,
    'question':      question,
    'optionA':       optionA,
    'optionB':       optionB,
    'optionC':       optionC,
    'optionD':       optionD,
    'correctAnswer': correctAnswer,
  };
}