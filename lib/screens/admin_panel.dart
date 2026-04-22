import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/menu_drawer.dart';
import '../widgets/admin_widgets.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'add_course_screen.dart';
import 'add_module_screen.dart';
import 'add_question_screen.dart';
import 'manage_courses_screen.dart';
import 'manage_modules_screen.dart';
import 'manage_questions_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  static const Color darkBorder = Color(0xFF1A1C1E);
  static const double borderWidth = 3.0;

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 400;
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // Header
              Text(
                'Admin\nPanel',
                style: GoogleFonts.montserrat(
                  fontSize: isSmallScreen ? 36 : 48,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  letterSpacing: -1.5,
                  color: darkBorder,
                ),
              ),
              const SizedBox(height: 24),

              // Stats Section
              Text(
                'OVERVIEW',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              // Real‑time stats using StreamBuilder
              StreamBuilder<Map<String, int>>(
                stream: FirestoreService().watchStats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final stats = snapshot.data ?? {'courses': 0, 'modules': 0, 'questions': 0};
                  return GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.4,
                    children: [
                      AdminStatCard(
                        title: 'Courses',
                        value: stats['courses'].toString(),
                        icon: Icons.library_books_rounded,
                        color: const Color(0xFF00CBA9),
                      ),
                      AdminStatCard(
                        title: 'Modules',
                        value: stats['modules'].toString(),
                        icon: Icons.layers_rounded,
                        color: const Color(0xFFFFBC1F),
                      ),
                      AdminStatCard(
                        title: 'Questions',
                        value: stats['questions'].toString(),
                        icon: Icons.quiz_rounded,
                        color: const Color(0xFF00CBA9),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),

              // Content Management Section
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

              _AdminButton(
                label: 'Add Course',
                icon: Icons.library_add_rounded,
                color: const Color(0xFF00CBA9),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddCourseScreen()),
                ),
              ),
              const SizedBox(height: 20),
              _AdminButton(
                label: 'Add Module',
                icon: Icons.post_add_rounded,
                color: const Color(0xFFFFBC1F),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddModuleScreen()),
                ),
              ),
              const SizedBox(height: 20),
              _AdminButton(
                label: 'Add Question',
                icon: Icons.quiz_rounded,
                color: const Color(0xFF00CBA9),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddQuestionScreen()),
                ),
              ),
              const SizedBox(height: 48),

              // Manage Content Section
              Text(
                'MANAGE CONTENT',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Edit or delete existing courses, modules and questions.',
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              _AdminButton(
                label: 'Manage Courses',
                icon: Icons.folder_open_rounded,
                color: const Color(0xFF00CBA9),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageCoursesScreen()),
                ),
              ),
              const SizedBox(height: 20),
              _AdminButton(
                label: 'Manage Modules',
                icon: Icons.edit_rounded,
                color: const Color(0xFFFFBC1F),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageModulesScreen()),
                ),
              ),
              const SizedBox(height: 20),
              _AdminButton(
                label: 'Manage Questions',
                icon: Icons.help_outline_rounded,
                color: const Color(0xFF00CBA9),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageQuestionsScreen()),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _AdminButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _AdminButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
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
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(icon, color: color, size: 24),
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
              Icon(Icons.arrow_forward_ios_rounded, size: 18, color: color),
            ],
          ),
        ),
      ),
    );
  }
}