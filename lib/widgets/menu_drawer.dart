import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import for Montserrat
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
  int _activeIndex = 0; // "Home" is active by default

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end, // Right-aligned text
            children: [
              // Custom Two-Bar Menu Icon (Identical to picture)
              Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 28, height: 3.5, color: const Color(0xFF1D1D1B)),
                      const SizedBox(height: 6),
                      Container(width: 28, height: 3.5, color: const Color(0xFF1D1D1B)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80),

              // Menu Items
              ...List.generate(_menuItems.length, (index) {
                final isActive = index == _activeIndex;
                return GestureDetector(
                  onTap: () => _navigateTo(context, index),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: Text(
                      _menuItems[index].label,
                      style: GoogleFonts.montserrat(
                        fontSize: 54, // Very large as in the picture
                        fontWeight: FontWeight.w900, // Black weight
                        height: 1.1,
                        color: isActive 
                            ? const Color(0xFFF5C121) // Specific gold color
                            : const Color(0xFF1D1D1B), // Specific deep black
                      ),
                    ),
                  ),
                );
              }),

              // Logout Button (Included as requested)
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _navigateToLogout(context),
                child: Text(
                  'Logout',
                  style: GoogleFonts.montserrat(
                    fontSize: 32, // Slightly smaller to distinguish from main menu
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFE53935), // Red for logout
                  ),
                ),
              ),

              const Spacer(),

              // Centered Logo at bottom
              Center(
                child: Image.asset(
                  'assets/pics/logo2.png',
                  width: 55,
                  height: 55,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) => const Icon(
                    Icons.adjust_rounded,
                    size: 55,
                    color: Color(0xFF00BFA5),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String label;
  final Widget page;
  const _MenuItem({required this.label, required this.page});
}