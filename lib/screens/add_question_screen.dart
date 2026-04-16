import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course.dart';
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

    if (course == null) {
      _showMessage('Please select a course.');
      return;
    }
    if (module == null) {
      _showMessage('Please select a module.');
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
      _showMessage('Question added successfully.');
      Navigator.pop(context);
    } catch (e) {
      _showMessage('Failed to add question.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D23),
        title: Text('Add Question', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _loadingCourses
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<Course>(
                      value: _selectedCourse,
                      decoration: InputDecoration(
                        labelText: 'Select course',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      items: _courses
                          .map((course) => DropdownMenuItem(
                                value: course,
                                child: Text(course.title),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedCourse = value);
                        _loadModules(value.id);
                      },
                    ),
                    const SizedBox(height: 16),
                    _loadingModules
                        ? const Center(child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: CircularProgressIndicator(),
                          ))
                        : DropdownButtonFormField<Map<String, dynamic>>(
                            value: _selectedModule,
                            decoration: InputDecoration(
                              labelText: 'Select module',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            items: _modules
                                .map((module) => DropdownMenuItem(
                                      value: module,
                                      child: Text(module['title'] as String? ?? 'Untitled'),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedModule = value);
                            },
                          ),
                    const SizedBox(height: 16),
                    _buildTextField(_questionController, 'Question'),
                    const SizedBox(height: 16),
                    _buildTextField(_optionAController, 'Option A'),
                    const SizedBox(height: 12),
                    _buildTextField(_optionBController, 'Option B'),
                    const SizedBox(height: 12),
                    _buildTextField(_optionCController, 'Option C'),
                    const SizedBox(height: 12),
                    _buildTextField(_optionDController, 'Option D'),
                    const SizedBox(height: 16),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Correct answer',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _correctAnswer,
                          items: const [
                            DropdownMenuItem(value: 'A', child: Text('A')),
                            DropdownMenuItem(value: 'B', child: Text('B')),
                            DropdownMenuItem(value: 'C', child: Text('C')),
                            DropdownMenuItem(value: 'D', child: Text('D')),
                          ],
                          onChanged: (value) {
                            if (value != null) setState(() => _correctAnswer = value);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: _isLoading ? null : _saveQuestion,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1D23),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Save Question',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
