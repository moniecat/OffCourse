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

  // Styling Constants
  static const Color darkBorder = Color(0xFF1A1C1E);

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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: darkBorder,
        content: Text(message, style: GoogleFonts.montserrat()),
      ),
    );
  }

  /// Recreating the exact button from your image
  Widget _buildBackButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2A2D2E) : Colors.white;
    final iconColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: iconColor, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: iconColor,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_back,
          color: iconColor,
          size: 26,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1A1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : darkBorder;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        toolbarHeight: 90,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 24, top: 12),
            child: Row(
              children: [
                _buildBackButton(),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Add\nCourse',
              style: GoogleFonts.montserrat(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                height: 1.0,
                letterSpacing: -1.5,
                color: textColor,
              ),
            ),
            const SizedBox(height: 32),

            _buildNeoTextField(
              controller: _titleController,
              label: 'COURSE TITLE',
              hint: 'e.g. Science 101',
            ),
            const SizedBox(height: 24),

            _buildNeoTextField(
              controller: _descriptionController,
              label: 'DESCRIPTION',
              hint: 'Brief summary...',
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

            GestureDetector(
              onTap: _isLoading ? null : _saveCourse,
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: textColor, width: 3),
                  boxShadow: [
                    BoxShadow(color: textColor, offset: const Offset(4, 4)),
                  ],
                ),
                child: Center(
                  child: _isLoading
                      ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary)
                      : Text(
                          'SAVE COURSE',
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

  Widget _buildNeoTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2A2D2E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final hintColor = isDark ? Colors.white30 : Colors.black26;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 1.2,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: textColor, width: 2.5),
            boxShadow: [
              BoxShadow(color: textColor, offset: const Offset(4, 4)),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: textColor),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.montserrat(color: hintColor),
              contentPadding: const EdgeInsets.all(20),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}