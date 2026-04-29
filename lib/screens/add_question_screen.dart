import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/theme_provider.dart';
import '../services/firestore_service.dart';

class AddQuestionScreen extends StatefulWidget {
  const AddQuestionScreen({super.key});

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _optionAController = TextEditingController();
  final TextEditingController _optionBController = TextEditingController();
  final TextEditingController _optionCController = TextEditingController();
  final TextEditingController _optionDController = TextEditingController();
  
  String _correctAnswer = 'A';
  bool _isLoading = false;
  bool _loadingCourses = true;
  bool _loadingModules = false;

  List<Course> _courses = [];
  Course? _selectedCourse;
  List<Map<String, dynamic>> _modules = [];
  Map<String, dynamic>? _selectedModule;

  // Styling Constants - using theme-aware getters
  Color get _borderColor => Theme.of(context).colorScheme.onSurface;
  Color get _backgroundColor => Theme.of(context).scaffoldBackgroundColor;
  Color get _textColor => Theme.of(context).colorScheme.onSurface;
  Color get _hintColor => Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4);

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await FirestoreService().getCourses();
      if (mounted) {
        setState(() {
          _courses = courses;
          _selectedCourse = courses.isNotEmpty ? courses.first : null;
          _loadingCourses = false;
        });
        if (_selectedCourse != null) {
          await _loadModules(_selectedCourse!.id);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _loadingCourses = false);
    }
  }

  Future<void> _loadModules(String courseId) async {
    if (!mounted) return;
    setState(() {
      _loadingModules = true;
      _modules = [];
      _selectedModule = null;
    });
    try {
      final modules = await FirestoreService().getModules(courseId);
      if (mounted) {
        setState(() {
          _modules = modules;
          _selectedModule = modules.isNotEmpty ? modules.first : null;
          _loadingModules = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingModules = false);
    }
  }

  Future<void> _saveQuestion() async {
    final course = _selectedCourse;
    final module = _selectedModule;
    final question = _questionController.text.trim();
    final optionA = _optionAController.text.trim();
    final optionB = _optionBController.text.trim();
    final optionC = _optionCController.text.trim();
    final optionD = _optionDController.text.trim();

    if (course == null || module == null) {
      _showMessage('Please select course and module.');
      return;
    }
    if (question.isEmpty || optionA.isEmpty || optionB.isEmpty || optionC.isEmpty || optionD.isEmpty) {
      _showMessage('All fields must be filled out.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirestoreService().addQuestion(
        courseId: course.id,
        moduleId: module['id'] as String,
        questionType: 'multiple_choice',
        question: question,
        optionA: optionA,
        optionB: optionB,
        optionC: optionC,
        optionD: optionD,
        correctAnswer: _correctAnswer,
      );

      if (!mounted) return;
      _showMessage('Question added successfully.');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Failed to add question.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _borderColor,
        content: Text(message, style: GoogleFonts.montserrat()),
      ),
    );
  }

  /// Styled Back Button from your provided image
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: _backgroundColor,
          border: Border.all(color: _borderColor, width: 2.5),
          boxShadow: [BoxShadow(color: _borderColor, offset: const Offset(4, 4))],
        ),
        child: Icon(Icons.arrow_back, color: _borderColor, size: 26),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch theme changes
    context.watch<ThemeProvider>().isDarkMode;
    
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        toolbarHeight: 90,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 24, top: 12),
            child: Row(children: [_buildBackButton()]),
          ),
        ),
      ),
      body: _loadingCourses
          ? Center(child: CircularProgressIndicator(color: _borderColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add\nQuestion',
                    style: GoogleFonts.montserrat(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      letterSpacing: -1.5,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Course Selection
                  _buildLabel('SELECT COURSE'),
                  const SizedBox(height: 10),
                  _buildNeoDropdown<Course>(
                    value: _selectedCourse,
                    items: _courses.map((c) => DropdownMenuItem(value: c, child: Text(c.title))).toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => _selectedCourse = val);
                      _loadModules(val.id);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Module Selection
                  _buildLabel('SELECT MODULE'),
                  const SizedBox(height: 10),
                  _loadingModules
                      ? LinearProgressIndicator(color: _borderColor, backgroundColor: _backgroundColor)
                      : _buildNeoDropdown<Map<String, dynamic>>(
                          value: _selectedModule,
                          items: _modules.map((m) => DropdownMenuItem(value: m, child: Text(m['title'] as String? ?? 'Untitled'))).toList(),
                          onChanged: (val) => setState(() => _selectedModule = val),
                        ),
                  const SizedBox(height: 24),

                  // Question Text
                  _buildNeoTextField(controller: _questionController, label: 'QUESTION', hint: 'Type your question here...', maxLines: 3),
                  const SizedBox(height: 24),

                  // Options
                  Row(
                    children: [
                      Expanded(child: _buildNeoTextField(controller: _optionAController, label: 'OPTION A', hint: 'Choice 1')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildNeoTextField(controller: _optionBController, label: 'OPTION B', hint: 'Choice 2')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildNeoTextField(controller: _optionCController, label: 'OPTION C', hint: 'Choice 3')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildNeoTextField(controller: _optionDController, label: 'OPTION D', hint: 'Choice 4')),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Correct Answer
                  _buildLabel('CORRECT ANSWER'),
                  const SizedBox(height: 10),
                  _buildNeoDropdown<String>(
                    value: _correctAnswer,
                    items: const [
                      DropdownMenuItem(value: 'A', child: Text('A')),
                      DropdownMenuItem(value: 'B', child: Text('B')),
                      DropdownMenuItem(value: 'C', child: Text('C')),
                      DropdownMenuItem(value: 'D', child: Text('D')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _correctAnswer = val);
                    },
                  ),
                  const SizedBox(height: 40),

                  // Save Button
                  GestureDetector(
                    onTap: _isLoading ? null : _saveQuestion,
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3),
                        boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.onSurface, offset: const Offset(4, 4))],
                      ),
                      child: Center(
                        child: _isLoading
                            ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary)
                            : Text(
                                'SAVE QUESTION',
                                style: GoogleFonts.montserrat(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2),
    );
  }

  Widget _buildNeoDropdown<T>({required T? value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 2.5),
        boxShadow: [BoxShadow(color: _borderColor, offset: const Offset(4, 4))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: _borderColor),
          style: GoogleFonts.montserrat(color: _textColor, fontWeight: FontWeight.w700, fontSize: 16),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildNeoTextField({required TextEditingController controller, required String label, required String hint, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor, width: 2.5),
            boxShadow: [BoxShadow(color: _borderColor, offset: const Offset(4, 4))],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: _textColor),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.montserrat(color: _hintColor),
              contentPadding: const EdgeInsets.all(20),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}