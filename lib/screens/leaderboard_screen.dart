import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/course.dart';
import '../services/firestore_service.dart';
import '../services/leaderboard_service.dart';
import '../services/auth_service.dart';
import '../widgets/course_chip.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/menu_drawer.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  // Styling Constants
  static const double borderWidth = 3.0;
  static const Offset shadowOffset = Offset(4, 4);

  // Admin/Role Logic
  String _userRole = 'student';
  bool get _isAdmin => _userRole == 'admin';

  // Data Variables
  List<Course> _courses = [];
  int _selectedCourseIndex = 0;
  List<Map<String, dynamic>> _modules = [];
  String? _selectedModuleId;
  List<LeaderboardEntry> _entries = [];
  
  // Loading States
  bool _loadingCourses = true;
  bool _loadingModules = false;
  bool _loadingLeaderboard = false;
  
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadCourses();
  }

  Future<void> _loadUserRole() async {
    final user = AuthService().currentUser;
    if (user == null) return;

    try {
      final doc = await FirestoreService().getUser(user.uid);
      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;
        final role = data['role'] as String?;
        if (role != null && role.isNotEmpty) {
          setState(() {
            _userRole = role;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading role: $e');
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
        // Start loading modules for the first course
        if (_courses.isNotEmpty) {
          _loadModules();
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loadingCourses = false);
    }
  }

  /// Fetches modules and automatically selects the first one
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
          
          // AUTO-SELECT LOGIC: Pre-select the first module if it exists
          if (_modules.isNotEmpty) {
            _selectedModuleId = _modules.first['id'] as String;
          }
        });

        // Immediately fetch rankings for the auto-selected module
        if (_selectedModuleId != null) {
          _loadLeaderboard(_selectedModuleId!);
        }
      }
    } catch (e) {
      debugPrint('Error loading modules: $e');
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
        barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.5),
        pageBuilder: (_, ___, __) => MenuDrawer(isAdmin: _isAdmin),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
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
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3),
          boxShadow: [
            BoxShadow(color: Theme.of(context).colorScheme.onSurface, offset: const Offset(3, 3))
          ],
        ),
        child: Icon(Icons.menu, color: Theme.of(context).colorScheme.onSurface, size: 30),
      ),
    );
  }

  Widget _buildCourseSelector() {
    return SizedBox(
      height: 110,
      child: _loadingCourses
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _courses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, index) => CourseChip(
                label: _courses[index].title,
                isActive: index == _selectedCourseIndex,
                onTap: () {
                  if (_selectedCourseIndex == index) return;
                  setState(() => _selectedCourseIndex = index);
                  _loadModules(); // This now handles auto-selection of the first module
                },
              ),
            ),
    );
  }

  Widget _buildModuleDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: _loadingModules
          ? LinearProgressIndicator(color: Theme.of(context).colorScheme.primary)
          : Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: borderWidth),
                boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.onSurface, offset: shadowOffset)],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedModuleId,
                  hint: Text("Select a Module", style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                  items: _modules
                      .map((m) => DropdownMenuItem(
                            value: m['id'] as String,
                            child: Text(m['title'], style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
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
    if (_loadingModules) {
       return const Expanded(child: Center(child: CircularProgressIndicator()));
    }
    if (_selectedModuleId == null) {
      return Expanded(child: Center(child: Text("Select a module to see rankings", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)))));
    }
    if (_loadingLeaderboard) {
      return Expanded(child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)));
    }
    if (_entries.isEmpty) {
      return Expanded(child: Center(child: Text("No scores recorded yet", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)))));
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
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(4)),
                  child: Text("YOU", style: GoogleFonts.montserrat(color: Theme.of(context).colorScheme.onPrimary, fontSize: 10, fontWeight: FontWeight.w900)),
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
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: isCurrentUser ? const Color(0xFF249780) : Theme.of(context).colorScheme.onSurface, width: borderWidth),
                      boxShadow: [BoxShadow(color: isCurrentUser ? const Color(0xFF249780) : Theme.of(context).colorScheme.onSurface, offset: const Offset(3, 3))],
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
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).cardColor, width: 1)),
                      child: Text(
                        actualRank == 1 ? "1ST" : actualRank == 2 ? "2ND" : "3RD",
                        style: GoogleFonts.montserrat(color: Theme.of(context).cardColor, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry.name.split(' ')[0],
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 14, color: isCurrentUser ? const Color(0xFF249780) : Theme.of(context).colorScheme.onSurface),
                overflow: TextOverflow.ellipsis,
              ),
              Text('${entry.score}/${entry.total}', style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
              const SizedBox(height: 10),
              Container(
                height: blockHeight,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: podiumColor,
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: borderWidth),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                  boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.onSurface, offset: const Offset(4, 0))],
                ),
                child: Center(
                  child: Icon(
                    actualRank == 1 ? Icons.star : (actualRank == 2 ? Icons.military_tech : Icons.emoji_events),
                    color: Colors.black.withValues(alpha: 0.3),
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
          color: isCurrentUser ? const Color(0xFFE0F7F4) : Theme.of(context).cardColor,
          border: Border.all(color: isCurrentUser ? const Color(0xFF249780) : Theme.of(context).colorScheme.onSurface, width: borderWidth),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: isCurrentUser ? const Color(0xFF249780) : Theme.of(context).colorScheme.onSurface, offset: shadowOffset)],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${index + 4}',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${index + 4}',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2), color: Theme.of(context).cardColor),
              child: ClipOval(
                child: Image.network(
                  (entry.profileImage != null && entry.profileImage!.isNotEmpty) ? entry.profileImage! : "https://api.dicebear.com/7.x/avataaars/png?seed=${entry.name}",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.network("https://api.dicebear.com/7.x/avataaars/png?seed=${entry.name}"),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(child: Text(entry.name, style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 16, color: isCurrentUser ? const Color(0xFF249780) : Theme.of(context).colorScheme.onSurface), overflow: TextOverflow.ellipsis)),
            Text('${entry.score}/${entry.total}', style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 16, color: isCurrentUser ? const Color(0xFF249780) : Theme.of(context).colorScheme.onSurface)),
          ],
        ),
      );
    }).toList();
  }
}