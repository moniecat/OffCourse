import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../services/question_service.dart';
import '../widgets/answer_option.dart';
import 'result_screen.dart';

class BrainstormingScreen extends StatefulWidget {
  final String moduleName;
  final int quarter;

  const BrainstormingScreen({
    super.key,
    required this.moduleName,
    required this.quarter,
  });

  @override
  State<BrainstormingScreen> createState() => _BrainstormingScreenState();
}

class _BrainstormingScreenState extends State<BrainstormingScreen> {
  List<QuestionModel> _questions = [];
  bool _isLoading = true;
  String? _error;

  int _currentIndex = 0;
  String? _selectedAnswer;   // label: A/B/C/D
  bool _answered = false;
  int _score = 0;

  final List<String> _labels = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await QuestionService.loadForModule(
        widget.moduleName,
        widget.quarter,
      );
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _selectAnswer(String label) {
    if (_answered) return;
    final current = _questions[_currentIndex];
    final isCorrect = current.isCorrect(label);
    setState(() {
      _selectedAnswer = label;
      _answered = true;
      if (isCorrect) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      // Quiz finished
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: _score,
            total: _questions.length,
          ),
        ),
      );
    }
  }

  void _prevQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _selectedAnswer = null;
        _answered = false;
      });
    }
  }

  AnswerState _stateFor(String label) {
    if (!_answered || _selectedAnswer == null) return AnswerState.idle;
    final correct = _questions[_currentIndex].correctAnswer.toUpperCase();
    if (label == correct) return AnswerState.correct;
    if (label == _selectedAnswer) return AnswerState.wrong;
    return AnswerState.idle;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('Error: $_error')),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text('No questions found for ${widget.moduleName}.'),
        ),
      );
    }

    final current = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// TITLE
              Text(
                widget.moduleName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// PROGRESS BAR
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Row(
                  children: [
                    Expanded(
                      flex: (progress * 100).round(),
                      child: Container(height: 10, color: Colors.amber),
                    ),
                    Expanded(
                      flex: 100 - (progress * 100).round(),
                      child: Container(height: 10, color: Colors.teal),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              /// QUESTION COUNTER
              Text(
                "Question ${_currentIndex + 1} of ${_questions.length}",
                style: const TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 20),

              Text(
                "Pre-Test",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// QUESTION CARD
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          current.questionType,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        /// QUESTION BOX
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black),
                          ),
                          child: Text(
                            current.question,
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// OPTIONS
                        ...List.generate(_labels.length, (i) {
                          final label = _labels[i];
                          return AnswerOption(
                            label: label,
                            text: current.getOptionText(label),
                            state: _stateFor(label),
                            onTap: _answered ? null : () => _selectAnswer(label),
                          );
                        }),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.info_outline),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// NAV BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// PREVIOUS
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.black),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _currentIndex > 0 ? _prevQuestion : null,
                      child: const Text("Previous"),
                    ),
                  ),

                  /// EXIT
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.black),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Exit"),
                    ),
                  ),

                  /// NEXT
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.black),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _answered ? _nextQuestion : null,
                      child: Text(
                        _currentIndex < _questions.length - 1
                            ? "Next"
                            : "Finish",
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}