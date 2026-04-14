import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/course_chip.dart';
import '../widgets/module_card.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/menu_drawer.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/course.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _displayName = 'User';
  List<Course> _courses = [];
  bool _loadingCourses = true;
  List<Map<String, dynamic>> _modules = [];
  bool _loadingModules = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadCourses();
  }

  Future<void> _loadModules() async {
    if (_courses.isEmpty) return;
    setState(() => _loadingModules = true);
    try {
      final modules = await FirestoreService().getModules(_courses[_selectedIndex].id);
      if (mounted) {
        setState(() {
          _modules = modules;
          _loadingModules = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingModules = false);
    }
  }

  Future<void> _loadCourses() async {
    try {
      final courses = await FirestoreService().getCourses();
      if (mounted) {
        setState(() {
          _courses = courses;
          _loadingCourses = false;
        });
        _loadModules();
      }
    } catch (e) {
      if (mounted) setState(() => _loadingCourses = false);
    }
  }

  Future<void> _loadUserName() async {
    final user = AuthService().currentUser;
    if (user == null) return;

    String getFirstName(String? fullName) {
      if (fullName == null || fullName.isEmpty) return 'User';
      return fullName.trim().split(' ').first;
    }

    if (user.displayName != null && user.displayName!.isNotEmpty) {
      setState(() => _displayName = getFirstName(user.displayName));
    }

    try {
      final doc = await FirestoreService().getUser(user.uid);
      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'] as String?;
        if (name != null && name.isNotEmpty) {
          setState(() => _displayName = getFirstName(name));
        }
      }
    } catch (_) {}
  }

  void _openMenu(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.4),
        pageBuilder: (_, ___, __) => const MenuDrawer(),
        transitionsBuilder: (_, animation, __, child) {
          final slide = Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));
          return SlideTransition(position: slide, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      extendBody: true,
      bottomNavigationBar: const CustomBottomNav(),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome,",
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            color: const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          _displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.8,
                            color: const Color(0xFF1A1A1A),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _openMenu(context),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(width: 26, height: 3, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(2))),
                        const SizedBox(height: 6),
                        Container(width: 26, height: 3, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(2))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// COURSES LIST (Horizontal)
            SizedBox(
              height: 155, // INCREASED height to fit 2 lines of text
              child: _loadingCourses
                  ? const Center(child: CircularProgressIndicator())
                  : _courses.isEmpty
                      ? const Center(child: Text("No courses available"))
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: _courses.length,
                          // Inside ListView.separated in home.dart
                          separatorBuilder: (_, __) => const SizedBox(width: 0), // REDUCED space between chips
                          itemBuilder: (_, index) {
                            return CourseChip(
                              label: _courses[index].title,
                              isActive: index == _selectedIndex,
                              onTap: () {
                                setState(() => _selectedIndex = index);
                                _loadModules();
                              },
                            );
                          },
                        ),
            ),

            /// MODULE LIST (Vertical)
            Expanded(
              child: _loadingModules
                  ? const Center(child: CircularProgressIndicator())
                  : _modules.isEmpty
                      ? const Center(child: Text("No modules available"))
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: _modules.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (_, index) {
                            final colors = [Colors.teal, Colors.amber];
                            return ModuleCard(
                              title: _modules[index]['title'] as String,
                              color: colors[index % colors.length],
                              courseId: _courses[_selectedIndex].id,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}