import 'package:flutter/material.dart';
import '../screens/profile.dart';
import '../screens/leaderboard_screen.dart';
import '../screens/home.dart';

class CustomBottomNav extends StatefulWidget {
  final int selectedIndex;
  const CustomBottomNav({super.key, this.selectedIndex = 1}); // Defaults to Home (index 1)

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    // Removed the accidental URL paste here 👈
    _selectedIndex = widget.selectedIndex; 
  }

  void _onTap(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      _navigateTo(const LeaderboardScreen());
    } else if (index == 1) {
      _navigateTo(const HomeScreen());
    } else if (index == 2) {
      _navigateTo(const ProfileScreen());
    }

    setState(() => _selectedIndex = index);
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBorder = Color(0xFF1A1C1E);
    const double thickness = 3.5;

    return Container(
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
            _buildNavItem(0, Icons.leaderboard_rounded),
            _buildNavItem(1, Icons.home_rounded), 
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
        onTap: () => _onTap(index),
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
              size: isActive ? 32 : 30,
              color: darkBorder,
            ),
          ),
        ),
      ),
    );
  }
}