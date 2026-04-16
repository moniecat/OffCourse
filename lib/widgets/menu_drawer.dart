import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/admin_panel.dart';
import '../screens/home.dart';
import '../screens/faq.dart';
import '../screens/setting.dart';
import '../screens/about.dart';
import '../screens/logout.dart';

class MenuDrawer extends StatefulWidget {
  final bool isAdmin;

  const MenuDrawer({super.key, this.isAdmin = false});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  // Consistency Constants
  static const Color darkBorder = Color(0xFF1A1C1E);
  static const Color activeGold = Color(0xFFFFBC1F); // Matches ModuleCard yellow
  
  int _activeIndex = 0; 

  List<_MenuItem> get _menuItems {
    final items = <_MenuItem>[
      _MenuItem(label: 'Home', page: const HomeScreen()),
      _MenuItem(label: 'FAQ', page: const FAQPage()),
      _MenuItem(label: 'Setting', page: const SettingPage()),
      _MenuItem(label: 'About', page: const AboutPage()),
    ];
    if (widget.isAdmin) {
      items.insert(1, _MenuItem(label: 'Admin', page: const AdminPanelScreen()));
    }
    return items;
  }

  void _navigateTo(BuildContext context, int index) {
    setState(() => _activeIndex = index);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => _menuItems[index].page),
    );
  }

  void _navigateToLogout(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LogoutPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [

          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end, // Right-aligned text
                  children: [
                    // Styled "Back/Close" Icon
                    Align(
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32, 
                              height: 4.5, 
                              decoration: BoxDecoration(
                                color: darkBorder,
                                borderRadius: BorderRadius.circular(2)
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 22, // Shorter second bar for a stylized look
                              height: 4.5, 
                              decoration: BoxDecoration(
                                color: darkBorder,
                                borderRadius: BorderRadius.circular(2)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Menu Items
                    ...List.generate(_menuItems.length, (index) {
                      final isActive = index == _activeIndex;
                      return GestureDetector(
                        onTap: () => _navigateTo(context, index),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            _menuItems[index].label,
                            textAlign: TextAlign.right,
                            style: GoogleFonts.montserrat(
                              fontSize: 52, 
                              fontWeight: FontWeight.w900, 
                              height: 1.1,
                              letterSpacing: -2,
                              color: isActive ? activeGold : darkBorder,
                              // Added subtle text shadow for "pop"
                              shadows: isActive ? [
                                const Shadow(color: darkBorder, offset: Offset(2, 2))
                              ] : null,
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                    
                    // Logout Button
                    GestureDetector(
                      onTap: () => _navigateToLogout(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE5E5), // Light red tint
                          border: Border.all(color: const Color(0xFFE53935), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'LOGOUT',
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFE53935),
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Bottom Logo
                    Center(
                      child: Opacity(
                        opacity: 0.8,
                        child: Image.asset(
                          'assets/pics/logo2.png',
                          width: 60,
                          height: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stack) => const Icon(
                            Icons.adjust_rounded,
                            size: 60,
                            color: Color(0xFF00BFA5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final Widget page;
  const _MenuItem({required this.label, required this.page});
}