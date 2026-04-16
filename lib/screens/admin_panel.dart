import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'add_course_screen.dart';
import 'add_module_screen.dart';
import 'add_question_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D23),
        title: Text('Admin Panel', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Content Management',
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Create courses, modules and questions for the learning experience.',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              _AdminButton(
                label: 'Add Course',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCourseScreen()),
                ),
              ),
              const SizedBox(height: 20),
              _AdminButton(
                label: 'Add Module',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddModuleScreen()),
                ),
              ),
              const SizedBox(height: 20),
              _AdminButton(
                label: 'Add Question',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddQuestionScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AdminButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D23),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
