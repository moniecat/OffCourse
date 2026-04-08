import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/quarter_chip.dart';
import '../widgets/module_card.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/menu_drawer.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedQuarter = 0;
  String _displayName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = AuthService().currentUser;
    if (user == null) return;

    // First use Firebase Auth display name for a fast load
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      setState(() => _displayName = user.displayName!);
    }

    // Then fetch Firestore to get the most up-to-date name
    try {
      final doc = await FirestoreService().getUser(user.uid);
      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;
        final name = data['name'] as String?;
        if (name != null && name.isNotEmpty) {
          setState(() => _displayName = name);
        }
      }
    } catch (_) {
      // If Firestore fails, keep Auth display name
    }
  }

  void _openMenu(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.4),
        pageBuilder: (_, _, _) => const MenuDrawer(),
        transitionsBuilder: (_, animation, _, child) {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
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

                  // Menu Icon
                  GestureDetector(
                    onTap: () => _openMenu(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      color: Colors.transparent,
                      alignment: Alignment.centerRight,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 26,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 26,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            /// QUARTERS LIST
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: 10,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  return QuarterChip(
                    label: "Quarter ${index + 1}",
                    isActive: index == _selectedQuarter,
                    onTap: () => setState(() => _selectedQuarter = index),
                  );
                },
              ),
            ),

            /// MODULE LIST
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                itemCount: 4,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (_, index) {
                  const modules = [
                    ("Brainstorming", Colors.teal),
                    ("Module 2", Colors.amber),
                    ("Module 3", Colors.teal),
                    ("Module 4", Colors.amber),
                  ];
                  final (title, color) = modules[index];
                  return ModuleCard(
                    title: title,
                    color: color,
                    quarter: _selectedQuarter + 1,
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