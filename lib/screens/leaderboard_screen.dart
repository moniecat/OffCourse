import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/course.dart';
import '../services/firestore_service.dart';
import '../services/leaderboard_service.dart';
import '../widgets/course_chip.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/menu_drawer.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Course> _courses = [];
  int _selectedCourseIndex = 0;
  List<Map<String, dynamic>> _modules = [];
  String? _selectedModuleId;
  List<LeaderboardEntry> _entries = [];
  bool _loadingCourses = true;
  bool _loadingModules = false;
  bool _loadingLeaderboard = false;
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadCourses();
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
    } catch (_) {
      if (mounted) setState(() => _loadingCourses = false);
    }
  }

  Future<void> _loadModules() async {
    if (_courses.isEmpty) return;
    setState(() {
      _loadingModules = true;
      _selectedModuleId = null;
      _entries = [];
    });
    try {
      final modules = await FirestoreService()
          .getModules(_courses[_selectedCourseIndex].id);
      if (mounted) {
        setState(() {
          _modules = modules;
          _loadingModules = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingModules = false);
    }
  }

  Future<void> _loadLeaderboard(String moduleId) async {
    setState(() => _loadingLeaderboard = true);
    try {
      final entries = await LeaderboardService.getLeaderboard(moduleId);
      if (mounted) {
        setState(() {
          _entries = entries;
          _loadingLeaderboard = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingLeaderboard = false);
    }
  }

  void _openDrawer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black26,
        pageBuilder: (_, ___, __) => const MenuDrawer(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBorder = Color(0xFF1A1C1E);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      extendBody: true,
      bottomNavigationBar: const CustomBottomNav(selectedIndex: 0),
      body: Column(
        children: [
          Container(height: 6, color: darkBorder),
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with hamburger
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Leaderboard',
                          style: GoogleFonts.montserrat(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -2,
                            color: darkBorder,
                            height: 1.0,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openDrawer(context),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                width: 30,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                width: 30,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Course chips
                  SizedBox(
                    height: 110,
                    child: _loadingCourses
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _courses.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (_, index) => CourseChip(
                              label: _courses[index].title,
                              isActive: index == _selectedCourseIndex,
                              onTap: () {
                                setState(
                                    () => _selectedCourseIndex = index);
                                _loadModules();
                              },
                            ),
                          ),
                  ),

                  const SizedBox(height: 15),

                  // Module dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _loadingModules
                        ? const Center(child: CircularProgressIndicator())
                        : Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border:
                                  Border.all(color: darkBorder, width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  color: darkBorder,
                                  offset: Offset(0, 4),
                                  blurRadius: 0,
                                )
                              ],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                hint: Text(
                                  'Select a module',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.w700,
                                    color:
                                        darkBorder.withValues(alpha: 0.5),
                                  ),
                                ),
                                value: _selectedModuleId,
                                items: _modules.map((m) {
                                  return DropdownMenuItem<String>(
                                    value: m['id'] as String,
                                    child: Text(
                                      m['title'] as String,
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: darkBorder,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(
                                      () => _selectedModuleId = value);
                                  _loadLeaderboard(value);
                                },
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Leaderboard content
                  Expanded(
                    child: _selectedModuleId == null
                        ? Center(
                            child: Text(
                              'Select a module\nto view rankings',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: darkBorder.withValues(alpha: 0.4),
                              ),
                            ),
                          )
                        : _loadingLeaderboard
                            ? const Center(
                                child: CircularProgressIndicator())
                            : _entries.isEmpty
                                ? Center(
                                    child: Text(
                                      'No scores yet\nfor this module',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: darkBorder
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    physics:
                                        const BouncingScrollPhysics(),
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 0, 20, 120),
                                    child: Column(
                                      children: [
                                        if (_entries.length >= 2)
                                          _buildTopThree(),
                                        const SizedBox(height: 20),
                                        ..._buildRestList(),
                                      ],
                                    ),
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

  Widget _buildTopThree() {
    const Color darkBorder = Color(0xFF1A1C1E);
    final top = _entries.take(3).toList();
    final ordered = [
      if (top.length >= 2) top[1],
      top[0],
      if (top.length >= 3) top[2],
    ];
    final heights = top.length >= 3
        ? [90.0, 120.0, 70.0]
        : [90.0, 120.0];
    final medals = ['🥈', '🥇', '🥉'];
    final colors = [
      const Color(0xFFB0BEC5),
      const Color(0xFFFFC107),
      const Color(0xFFFF8C42),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(ordered.length, (i) {
        final entry = ordered[i];
        final isCurrentUser = entry.userId == _currentUid;

        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(medals[i], style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(
                entry.name.split(' ').first,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isCurrentUser
                      ? const Color(0xFF249780)
                      : darkBorder,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.score}/${entry.total}',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: darkBorder.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: heights[i],
                decoration: BoxDecoration(
                  color: colors[i],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  border: Border.all(color: darkBorder, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: darkBorder,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    i == 1 ? '1st' : i == 0 ? '2nd' : '3rd',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _buildRestList() {
    const Color darkBorder = Color(0xFF1A1C1E);
    final rest = _entries.skip(3).toList();
    if (rest.isEmpty) return [];

    return List.generate(rest.length, (i) {
      final entry = rest[i];
      final rank = i + 4;
      final isCurrentUser = entry.userId == _currentUid;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? const Color(0xFFE0F7F4)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentUser
                ? const Color(0xFF249780)
                : darkBorder,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isCurrentUser
                  ? const Color(0xFF249780)
                  : darkBorder,
              offset: const Offset(0, 4),
              blurRadius: 0,
            )
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '#$rank',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: darkBorder.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.name,
                style: GoogleFonts.montserrat(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isCurrentUser
                      ? const Color(0xFF249780)
                      : darkBorder,
                ),
              ),
            ),
            Text(
              '${entry.score}/${entry.total}',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: darkBorder.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    });
  }
}