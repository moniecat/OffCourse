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

  // Styling Constants
  static const Color darkBorder = Color(0xFF1A1C1E);

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
      if (!mounted) return;
      
      _showMessage('Module added successfully.');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Failed to add module.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: darkBorder,
        content: Text(message, style: GoogleFonts.montserrat()),
      ),
    );
  }

  /// Back button style from the image provided
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2.5),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4)),
          ],
        ),
        child: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          ? const Center(child: CircularProgressIndicator(color: darkBorder))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Add\nModule',
                    style: GoogleFonts.montserrat(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      letterSpacing: -1.5,
                      color: darkBorder,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Dropdown Field
                  _buildLabel('SELECT COURSE'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black, width: 2.5),
                      boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Course>(
                        value: _selectedCourse,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        items: _courses.map((course) {
                          return DropdownMenuItem(
                            value: course,
                            child: Text(course.title),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedCourse = value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildNeoTextField(
                    controller: _titleController,
                    label: 'MODULE TITLE',
                    hint: 'e.g. Intro to Biology',
                  ),
                  const SizedBox(height: 24),

                  _buildNeoTextField(
                    controller: _descriptionController,
                    label: 'DESCRIPTION',
                    hint: 'Details about the module...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

                  _buildNeoTextField(
                    controller: _orderController,
                    label: 'DISPLAY ORDER',
                    hint: '0',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 40),

                  // Save Button
                  GestureDetector(
                    onTap: _isLoading ? null : _saveModule,
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        color: darkBorder,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 3),
                        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'SAVE MODULE',
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
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
      style: GoogleFonts.montserrat(
        fontWeight: FontWeight.w900,
        fontSize: 13,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildNeoTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 2.5),
            boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.montserrat(color: Colors.black26),
              contentPadding: const EdgeInsets.all(20),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}