//import 'package:flutter/foundation.dart';
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
  String _userRole = 'student';

  bool get _isAdmin => _userRole == 'admin';

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

  /// Fetch modules for the selected course
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
      debugPrint('Error loading modules: $e');
      if (mounted) setState(() => _loadingModules = false);
    }
  }

  /// Fetch all courses
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
      debugPrint('Error loading courses: $e');
      if (mounted) setState(() => _loadingCourses = false);
    }
  }

  /// Load user name from Auth/Firestore
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
        final role = data['role'] as String?;
        if (name != null && name.isNotEmpty) {
          setState(() => _displayName = getFirstName(name));
        }
        if (role != null && role.isNotEmpty) {
          setState(() => _userRole = role);
        }
      }
    } catch (_) {}
  }

  /// Side Menu Animation
  void openDrawer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black26,
        pageBuilder: (_, ___, __) => MenuDrawer(isAdmin: _isAdmin),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          );
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
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 2. HEADER
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome,",
                                style: GoogleFonts.montserrat(
                                  fontSize: 28,
                                  color: const Color(0xFF1A1D23),
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                '$_displayName!',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -2.5,
                                  color: const Color(0xFF1A1D23),
                                  height: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Variable-width Menu Icon
          GestureDetector(
            onTap: () => openDrawer(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      width: 30,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 6),
                  Container(
                      width: 30,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(2))),
                ],
              ),
          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 3. HORIZONTAL COURSE SELECTOR
                  SizedBox(
                    height: 110, // Set to handle wrapping text + shadow from your CourseChip
                    child: _loadingCourses
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _courses.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
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

                  const SizedBox(height: 15),

                  /// 4. VERTICAL MODULE LIST
                Expanded(
                  child: _loadingModules
                      ? const Center(child: CircularProgressIndicator())
                      : _modules.isEmpty
                          ? const Center(child: Text("No modules available"))
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              // Increased bottom padding to 120 to ensure 
                              // the last card's shadow isn't cut off by the nav bar
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120), 
                              itemCount: _modules.length,
                              // CHANGE: Increased height from 16 to 25
                              separatorBuilder: (_, __) => const SizedBox(height: 25), 
                              itemBuilder: (_, index) {
                                final colors = [const Color(0xFF00CBA9), const Color(0xFFFFBC1F)];
                                return ModuleCard(
                                  title: _modules[index]['title'] as String,
                                  color: colors[index % colors.length],
                                  courseId: _courses[_selectedIndex].id,
                                  moduleId: _modules[index]['id'] as String,
                                  courseName: _courses[_selectedIndex].title,
                                );
                              },
                            ),
                ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}