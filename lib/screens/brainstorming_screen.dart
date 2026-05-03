import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/question_model.dart';
import '../providers/theme_provider.dart';
import '../services/question_service.dart';
import '../widgets/answer_option.dart';
import 'result_screen.dart';
import '../services/result_service.dart';

class BrainstormingScreen extends StatefulWidget {
  final String moduleName;
  final String courseId; 
  final String moduleId;
  final int courseIndex;
  final bool isCustom;       
  final int? maxQuestions;

  const BrainstormingScreen({
    super.key,
    required this.moduleName,
    required this.courseId,
    required this.moduleId,
    required this.courseIndex,
    this.isCustom = false,    
    this.maxQuestions, 
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

  // ── Count-up timer ────────────────────────────────────────────
  int _elapsedSeconds = 0;
  Timer? _timer;

  // Theme-aware color getters
  Color get _borderColor => Theme.of(context).colorScheme.onSurface;
  Color get _backgroundColor => Theme.of(context).scaffoldBackgroundColor;
  Color get _cardBackground => Theme.of(context).cardColor;
  Color get _textColor => Theme.of(context).colorScheme.onSurface;
  Color get _hintColor => Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

  // Accent colors (branding - keep as-is)
  final Color themeTeal = const Color(0xFF249780);
  final Color themeYellow = const Color(0xFFFBB017);
  final Color errorRed = const Color(0xFFE74C3C);

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSeconds++);
    });
  }

  String get _formattedTime {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await QuestionService.loadForModule(
        widget.moduleName,
        widget.courseId,
      );
      questions.shuffle();
      if (!mounted) return;
      setState(() {
        _questions = widget.maxQuestions != null
            ? questions.take(widget.maxQuestions!).toList()
            : questions;
        _isLoading = false;
      });
      _startTimer();
    } catch (e) {
      if (!mounted) return;
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

  Future<void> _nextQuestion() async {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _currentSelection = null;
      });
    } else {
      _timer?.cancel();

      // Logic for ending the session
      if (!widget.isCustom) {
        try {
          await ResultService.saveResult(
            courseId:       widget.courseId,
            moduleId:       widget.moduleId,
            score:          _score,
            total:          _questions.length,
            elapsedSeconds: _elapsedSeconds, 
          );
        } catch (e) {
          debugPrint('❌ Error saving result: $e');
        }
      }

      // Check mounted before navigating after an await
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score:          _score,
            total:          _questions.length,
            courseId:       widget.courseId,
            moduleId:       widget.moduleId,
            courseIndex:    widget.courseIndex,
            isCustom:       widget.isCustom,
            elapsedSeconds: _elapsedSeconds, 
          ),
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
    
    if (label == _currentSelection) return AnswerState.selected; 
    return AnswerState.idle;
  }

  @override
  Widget build(BuildContext context) {
    // Watch theme changes
    context.watch<ThemeProvider>().isDarkMode;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(child: CircularProgressIndicator(color: _borderColor)),
      );
    }

    if (_error != null || _questions.isEmpty) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              _error ?? "No questions found for this module.",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: _textColor),
            ),
          ),
        ),
      );
    }

    final currentQuestion = _questions[_currentIndex];
    final bool isAnswered = _userAnswers.containsKey(_currentIndex);
    final bool isCorrect = isAnswered && currentQuestion.isCorrect(_userAnswers[_currentIndex]!);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        child: Column(
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 20),
                            _buildProgressBar(),
                            const SizedBox(height: 16),
                            _buildTimerBadge(),
                            const SizedBox(height: 14),
                            _buildQuestionCard(currentQuestion, isAnswered),
                          ],
                        ),
                      ),
                    ),
                  ),
                  isAnswered ? _buildFeedbackOverlay(isCorrect) : _buildControlButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Timer badge (only new widget) ────────────────────────────
  Widget _buildTimerBadge() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: _cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor, width: 2.5),
            boxShadow: [BoxShadow(color: _borderColor, offset: const Offset(3, 3))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer_outlined, size: 18, color: _hintColor),
              const SizedBox(width: 6),
              Text(
                _formattedTime,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── All original widgets below, untouched ────────────────────

  Widget _buildTopBar() {
    return Column(
      children: [
        if (widget.isCustom)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: const Color(0xFFFFF3CD),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 16, color: Color(0xFF856404)),
                const SizedBox(width: 6),
                Text(
                  'Practice Mode — Score not recorded',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF856404),
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
          child: Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _cardBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _borderColor, width: 2.5),
                  boxShadow: [BoxShadow(color: _borderColor, offset: const Offset(3, 3))],
                ),
                child: Icon(Icons.close, size: 20, color: _borderColor),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Text(
      widget.moduleName.toUpperCase(),
      textAlign: TextAlign.center,
      style: GoogleFonts.montserrat(
        fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -1, color: _textColor,
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentIndex + 1) / _questions.length;
    return Column(
      children: [
        Container(
          height: 14,
          width: 300,
          decoration: BoxDecoration(
            color: _cardBackground,
            border: Border.all(color: _borderColor, width: 2.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              color: themeYellow,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Question ${_currentIndex + 1} of ${_questions.length}",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 13, color: _hintColor),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(QuestionModel question, bool isAnswered) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderColor, width: 3),
        boxShadow: [BoxShadow(color: _borderColor, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  question.question,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 18, fontWeight: FontWeight.w800, height: 1.3, color: _textColor,
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
          color: isCorrect ? themeTeal : errorRed,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: _borderColor, width: 4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isCorrect ? Icons.check_circle : Icons.error, color: Colors.white, size: 32),
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
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800,
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
        child: Container(
          height: 65,
          width: double.infinity,
          decoration: BoxDecoration(
            color: !canCheck ? _hintColor : themeYellow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: canCheck ? _borderColor : _hintColor,
              width: 3,
            ),
            boxShadow: canCheck ? [BoxShadow(color: _borderColor, offset: const Offset(0, 6))] : null,
          ),
          child: Center(
            child: Text(
              "CHECK ANSWER",
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w900, fontSize: 18,
                color: canCheck ? _borderColor : _hintColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}