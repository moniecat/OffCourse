import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/firestore_service.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _orderController = TextEditingController(text: '0');
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final order = int.tryParse(_orderController.text.trim()) ?? 0;

    if (title.isEmpty) {
      _showMessage('Course title is required.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirestoreService().addCourse(title, description, order);
      
      // FIX: Guard with mounted check before using BuildContext across async gaps
      if (!mounted) return;

      _showMessage('Course added successfully.');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Failed to add course.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return; // Extra safety check
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D23),
        title: Text('Add Course', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: SingleChildScrollView( // Added to prevent overflow when keyboard appears
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(_titleController, 'Course title'),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Course description', maxLines: 4),
              const SizedBox(height: 16),
              _buildTextField(_orderController, 'Display order', keyboardType: TextInputType.number),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: _isLoading ? null : _saveCourse,
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
                            'Save Course',
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