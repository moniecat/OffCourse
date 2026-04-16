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
  static const Color darkBorder = Color(0xFF1A1C1E);
  static const double borderWidth = 3.0;
  static const Offset shadowOffset = Offset(4, 4);

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
      final modules = await FirestoreService().getModules(_courses[_selectedCourseIndex].id);
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
    } catch (e) {
      if (mounted) setState(() => _loadingLeaderboard = false);
    }
  }

  void _openDrawer(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        pageBuilder: (_, ___, __) => const MenuDrawer(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      extendBody: true,
      bottomNavigationBar: const CustomBottomNav(selectedIndex: 0),
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 10),
                  _buildCourseSelector(),
                  const SizedBox(height: 15),
                  _buildModuleDropdown(),
                  const SizedBox(height: 20),
                  _buildMainContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Leaderboard',
            style: GoogleFonts.montserrat(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
              color: darkBorder,
            ),
          ),
          // Called the custom button here to fix the "unused_element" warning
          _buildMenuButton(),
        ],
      ),
    );
  }

  Widget _buildMenuButton() {
    return GestureDetector(
      onTap: () => _openDrawer(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white, // Fixed: undefined 'white'
          border: Border.all(color: darkBorder, width: 3), // Fixed: undefined 'black'
          boxShadow: const [
            BoxShadow(color: darkBorder, offset: Offset(3, 3)) // Fixed: undefined 'black'
          ],
        ),
        child: const Icon(Icons.menu, color: darkBorder, size: 30), // Fixed: undefined 'black'
      ),
    );
  }

  Widget _buildCourseSelector() {
    return SizedBox(
      height: 110,
      child: _loadingCourses
          ? const Center(child: CircularProgressIndicator(color: darkBorder))
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _courses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) => CourseChip(
                label: _courses[index].title,
                isActive: index == _selectedCourseIndex,
                onTap: () {
                  setState(() => _selectedCourseIndex = index);
                  _loadModules();
                },
              ),
            ),
    );
  }

  Widget _buildModuleDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _loadingModules
          ? const LinearProgressIndicator(color: darkBorder)
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: darkBorder, width: borderWidth),
                boxShadow: const [BoxShadow(color: darkBorder, offset: shadowOffset)],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedModuleId,
                  hint: Text("Select a Module", style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
                  items: _modules
                      .map((m) => DropdownMenuItem(
                            value: m['id'] as String,
                            child: Text(m['title'], style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 14)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedModuleId = val);
                      _loadLeaderboard(val);
                    }
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildMainContent() {
    if (_selectedModuleId == null) {
      return Expanded(child: Center(child: Text("Select a module to see rankings", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600))));
    }
    if (_loadingLeaderboard) {
      return const Expanded(child: Center(child: CircularProgressIndicator(color: darkBorder)));
    }
    if (_entries.isEmpty) {
      return Expanded(child: Center(child: Text("No scores recorded yet", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600))));
    }

    return Expanded(
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        children: [
          _buildPodium(),
          const SizedBox(height: 30),
          ..._buildRestList(),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    final top = _entries.take(3).toList();
    List<LeaderboardEntry?> ordered = [
      top.length > 1 ? top[1] : null,
      top.isNotEmpty ? top[0] : null,
      top.length > 2 ? top[2] : null,
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: ordered.map((entry) {
        if (entry == null) return Expanded(child: Container());

        int actualRank = _entries.indexOf(entry) + 1;
        bool isCurrentUser = entry.userId == _currentUid;

        double blockHeight = actualRank == 1 ? 130 : (actualRank == 2 ? 90 : 70);
        double avatarSize = actualRank == 1 ? 95 : (actualRank == 2 ? 80 : 70);

        Color podiumColor = actualRank == 1
            ? const Color(0xFFFFC21C)
            : actualRank == 2
                ? const Color(0xFFD1D5DB)
                : const Color(0xFFFF8C42);

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCurrentUser)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                  child: Text("YOU", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                ),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: isCurrentUser ? const Color(0xFF249780) : darkBorder, width: borderWidth),
                      boxShadow: const [BoxShadow(color: darkBorder, offset: Offset(3, 3))],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        (entry.profileImage != null && entry.profileImage!.isNotEmpty) ? entry.profileImage! : "https://api.dicebear.com/7.x/avataaars/png?seed=${entry.name}",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.network("https://api.dicebear.com/7.x/avataaars/png?seed=${entry.name}"),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(color: darkBorder, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white, width: 1)),
                      child: Text(
                        actualRank == 1 ? "1ST" : actualRank == 2 ? "2ND" : "3RD",
                        style: GoogleFonts.montserrat(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.name.split(' ')[0],
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 14, color: isCurrentUser ? const Color(0xFF249780) : darkBorder),
                overflow: TextOverflow.ellipsis,
              ),
              Text('${entry.score}/${entry.total}', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Container(
                height: blockHeight,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: podiumColor,
                  border: Border.all(color: darkBorder, width: borderWidth),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                  boxShadow: const [BoxShadow(color: darkBorder, offset: Offset(4, 0))],
                ),
                child: Center(
                  child: Icon(
                    actualRank == 1 ? Icons.star : (actualRank == 2 ? Icons.military_tech : Icons.emoji_events),
                    color: darkBorder.withValues(alpha: 0.15),
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildRestList() {
    final rest = _entries.skip(3).toList();
    return rest.asMap().entries.map((item) {
      int index = item.key;
      var entry = item.value;
      bool isCurrentUser = entry.userId == _currentUid;

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser ? const Color(0xFFE0F7F4) : Colors.white,
          border: Border.all(color: isCurrentUser ? const Color(0xFF249780) : darkBorder, width: borderWidth),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: isCurrentUser ? const Color(0xFF249780) : darkBorder, offset: shadowOffset)],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text('${index + 4}', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 16, color: darkBorder.withValues(alpha: 0.4))),
            ),
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: darkBorder, width: 2), color: Colors.white),
              child: ClipOval(
                child: Image.network(
                  (entry.profileImage != null && entry.profileImage!.isNotEmpty) ? entry.profileImage! : "https://api.dicebear.com/7.x/avataaars/png?seed=${entry.name}",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.network("https://api.dicebear.com/7.x/avataaars/png?seed=${entry.name}"),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(child: Text(entry.name, style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 16), overflow: TextOverflow.ellipsis)),
            Text('${entry.score}/${entry.total}', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
      );
    }).toList();
  }
}