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
  final String currentScreen;

  const MenuDrawer({
    super.key, 
    this.isAdmin = false,
    this.currentScreen = 'Home',
    });

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  // Style Constants
  static const Color activeGold = Color(0xFFFFBC1F); 
  static const Color logoutRed = Color(0xFFE53935); 
  
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    final items = _menuItems;
    final idx = items.indexWhere((item) => item.label == widget.currentScreen);
    _activeIndex = idx == -1 ? -1 : idx;
  }

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end, 
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
                                color: Theme.of(context).colorScheme.onSurface,
                                borderRadius: BorderRadius.circular(2)
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 22, 
                              height: 4.5, 
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.onSurface,
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
                      final isActive = index == _activeIndex && _activeIndex != -1;
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
                              color: isActive ? activeGold : Theme.of(context).colorScheme.onSurface,
                              // Shadow logic: Black sharp shadow only if active
                              shadows: isActive ? [
                                const Shadow(
                                  color: Colors.black, 
                                  offset: Offset(3, 3),
                                  blurRadius: 0, 
                                )
                              ] : null,
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                    
                    // Logout Button (No shadow because it is not the "active" screen)
                    GestureDetector(
                      onTap: () => _navigateToLogout(context),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Text(
                          'Logout',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.montserrat(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -2,
                            color: logoutRed,
                            shadows: null, // Flat style to match inactive items
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