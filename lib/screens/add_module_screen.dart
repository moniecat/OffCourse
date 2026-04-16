import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/course.dart';
import '../services/firestore_service.dart';

class AddModuleScreen extends StatefulWidget {
  const AddModuleScreen({super.key});

  @override
  State<AddModuleScreen> createState() => _AddModuleScreenState();
}

class _AddModuleScreenState extends State<AddModuleScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _orderController = TextEditingController(text: '0');
  bool _isLoading = false;
  bool _loadingCourses = true;
  List<Course> _courses = [];
  Course? _selectedCourse;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _orderController.dispose();
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
      }
    } catch (e) {
      if (mounted) setState(() => _loadingCourses = false);
    }
  }

  Future<void> _saveModule() async {
    final course = _selectedCourse;
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final order = int.tryParse(_orderController.text.trim()) ?? 0;

    if (course == null) {
      _showMessage('Please select a course.');
      return;
    }
    if (title.isEmpty) {
      _showMessage('Module title is required.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirestoreService().addModule(course.id, title, description, order);
      _showMessage('Module added successfully.');
      Navigator.pop(context);
    } catch (e) {
      _showMessage('Failed to add module.');
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
        title: Text('Add Module', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900)),
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
                        setState(() => _selectedCourse = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_titleController, 'Module title'),
                    const SizedBox(height: 16),
                    _buildTextField(_descriptionController, 'Module description', maxLines: 4),
                    const SizedBox(height: 16),
                    _buildTextField(_orderController, 'Display order', keyboardType: TextInputType.number),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: _isLoading ? null : _saveModule,
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
                                  'Save Module',
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
