import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/menu_drawer.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'add_course_screen.dart';
import 'add_module_screen.dart';
import 'add_question_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  // Styling Constants
  static const Color darkBorder = Color(0xFF1A1C1E);
  static const double borderWidth = 3.0;

  // Role logic
  String _userRole = 'student';
  bool get _isAdmin => _userRole == 'admin';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = AuthService().currentUser;
    if (user == null) return;
    try {
      final doc = await FirestoreService().getUser(user.uid);
      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _userRole = data['role'] ?? 'student';
        });
      }
    } catch (_) {}
  }

  void _openDrawer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        pageBuilder: (_, __, ___) => MenuDrawer(isAdmin: _isAdmin),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildMenuButton() {
    return GestureDetector(
      onTap: () => _openDrawer(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: darkBorder, width: borderWidth),
          boxShadow: const [
            BoxShadow(color: darkBorder, offset: Offset(3, 3))
          ],
        ),
        child: const Icon(Icons.menu, color: darkBorder, size: 30),
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
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25, top: 10),
            child: _buildMenuButton(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          // Header using your Montserrat style
          Text(
            'Admin\nPanel',
            style: GoogleFonts.montserrat(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              height: 1.0,
              letterSpacing: -1.5,
              color: darkBorder,
            ),
          ),
          const SizedBox(height: 30),

          // Section Label
          Text(
            'CONTENT MANAGEMENT',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.black,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Create courses, modules and questions for the learning experience.',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Action Buttons
          _AdminButton(
            label: 'Add Course',
            icon: Icons.library_add_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCourseScreen()),
            ),
          ),
          const SizedBox(height: 20),
          _AdminButton(
            label: 'Add Module',
            icon: Icons.post_add_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddModuleScreen()),
            ),
          ),
          const SizedBox(height: 20),
          _AdminButton(
            label: 'Add Question',
            icon: Icons.quiz_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddQuestionScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _AdminButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(4, 4)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Icon(icon, color: Colors.black, size: 24),
              ),
              const SizedBox(width: 20),
              Text(
                label,
                style: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}