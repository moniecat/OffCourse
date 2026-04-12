import 'package:flutter/material.dart';
import '../screens/profile.dart'; 

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  // Default to index 1 (Modules/Book icon) to match your home screen focus
  int _selectedIndex = 1;

  // Your Navigation Logic
  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const ProfileScreen(),
        transitionsBuilder: (_, animation, __, child) {
          // Slide up from bottom to top
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutQuart)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBorder = Color(0xFF1A1C1E);
    const double thickness = 3.5; // Bold lines to match your module cards

    return Container(
      // Outer height to ensure the "floating" icons don't get clipped
      height: 110, 
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: darkBorder, width: thickness),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(45),
            topRight: Radius.circular(45),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(0, Icons.home_rounded),
            _buildNavItem(1, Icons.menu_book_rounded),
            _buildNavItem(2, Icons.person_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon) {
    final bool isActive = _selectedIndex == index;
    const Color darkBorder = Color(0xFF1A1C1E);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (index == 2) {
            // Profile logic: Navigate to screen
            _openProfile(context);
          } else {
            // Home/Modules logic: Change selection
            setState(() => _selectedIndex = index);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: isActive
                ? BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: darkBorder, width: 3),
                    // Hard shadow to create the "Floating Sticker" look
                    boxShadow: const [
                      BoxShadow(
                        color: darkBorder,
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
                  )
                : null,
            child: Icon(
              icon,
              size: isActive ? 32 : 30, // Slight grow when active
              color: darkBorder,
            ),
          ),
        ),
      ),
    );
  }
}