import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/question_model.dart';
import '../services/question_service.dart';
import '../widgets/answer_option.dart';
import 'result_screen.dart';
import '../services/result_service.dart';

class BrainstormingScreen extends StatefulWidget {
  final String moduleName;
  final String courseId; // ← was: int course

  const BrainstormingScreen({
    super.key,
    required this.moduleName,
    required this.courseId, // ← was: int course
  });

  @override
  State<BrainstormingScreen> createState() => _BrainstormingScreenState();
}

class _BrainstormingScreenState extends State<BrainstormingScreen> {
  List<QuestionModel> _questions = [];
  final Map<int, String> _userAnswers = {};
  String? _currentSelection;
  bool _isLoading = true;
  String? _error;
  int _currentIndex = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await QuestionService.loadForModule(
        widget.moduleName,
        widget.courseId, // ← was: widget.course
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

  void _onOptionTap(String label) {
    if (_userAnswers.containsKey(_currentIndex)) return;
    setState(() => _currentSelection = label);
  }

  void _confirmAnswer() {
    if (_currentSelection == null || _userAnswers.containsKey(_currentIndex)) return;
    setState(() {
      _userAnswers[_currentIndex] = _currentSelection!;
      if (_questions[_currentIndex].isCorrect(_currentSelection!)) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _currentSelection = null;
      });
    } else {
      // Save result before navigating
      ResultService.saveResult(
        courseId: widget.courseId,
        moduleId: _questions.first.moduleId,
        score:    _score,
        total:    _questions.length,
      ).then((_) {
        print('✅ Result saved successfully');
      }).catchError((e) {
        print('❌ Error saving result: $e');
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(score: _score, total: _questions.length),
        ),
      );
    }
  }

  AnswerState _stateFor(String label) {
    final confirmedAnswer = _userAnswers[_currentIndex];
    if (confirmedAnswer != null) {
      final correctLabel = _questions[_currentIndex].correctAnswer.toUpperCase();
      if (label == correctLabel) return AnswerState.correct;
      if (label == confirmedAnswer) return AnswerState.wrong;
      return AnswerState.idle;
    }
    if (label == _currentSelection) return AnswerState.correct;
    return AnswerState.idle;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(child: Center(child: Text('Error: $_error'))),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'No questions found for\n${widget.moduleName}.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentIndex];
    final bool isAnswered = _userAnswers.containsKey(_currentIndex);
    final bool isCorrect = isAnswered && currentQuestion.isCorrect(_userAnswers[_currentIndex]!);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 20),
                              _buildProgressBar(),
                              const SizedBox(height: 30),
                              _buildQuestionCard(currentQuestion, isAnswered),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            isAnswered ? _buildFeedbackOverlay(isCorrect) : _buildControlButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
      child: Align(
        alignment: Alignment.topRight,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: _buildNeobrutalistBox(child: const Icon(Icons.close, size: 20)),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      widget.moduleName.toUpperCase(),
      textAlign: TextAlign.center,
      style: GoogleFonts.montserrat(
        fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -1,
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentIndex + 1) / _questions.length;
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        children: [
          Container(
            height: 14,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.transparent,
                color: const Color(0xFFFBB017),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Question ${_currentIndex + 1} of ${_questions.length}",
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionModel question, bool isAnswered) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(0, 8))],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF249780),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              border: Border(bottom: BorderSide(color: Colors.black, width: 3)),
            ),
            child: Text(
              question.questionType.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  question.question,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 18, fontWeight: FontWeight.w800, height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),
                ...['A', 'B', 'C', 'D'].map((label) {
                  final text = question.getOptionText(label);
                  if (text.isEmpty) return const SizedBox.shrink();
                  return AnswerOption(
                    label: label,
                    text: text,
                    state: _stateFor(label),
                    onTap: isAnswered ? null : () => _onOptionTap(label),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackOverlay(bool isCorrect) {
    return GestureDetector(
      onTap: _nextQuestion,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: BoxDecoration(
          color: isCorrect ? const Color(0xFF249780) : const Color(0xFFE74C3C),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: const Border(top: BorderSide(color: Colors.black, width: 4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isCorrect ? Icons.check_circle : Icons.error,
                    color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Text(
                  isCorrect ? "EXCELLENT!" : "NOT QUITE!",
                  style: GoogleFonts.montserrat(
                    color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              "TAP TO CONTINUE",
              style: GoogleFonts.montserrat(
                color: Colors.white, fontSize: 13,
                fontWeight: FontWeight.w800, letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    final bool canCheck = _currentSelection != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: GestureDetector(
        onTap: canCheck ? _confirmAnswer : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 65,
          width: double.infinity,
          decoration: BoxDecoration(
            color: !canCheck ? Colors.grey[300] : const Color(0xFFFBB017),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: canCheck
                ? [const BoxShadow(color: Colors.black, offset: Offset(0, 6))]
                : null,
          ),
          child: Center(
            child: Text(
              "CHECK ANSWER",
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w900, fontSize: 18,
                color: canCheck ? Colors.black : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeobrutalistBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2.5),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(3, 3))],
      ),
      child: child,
    );
  }
}