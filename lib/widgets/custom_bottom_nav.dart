import 'package:flutter/material.dart';

class CustomBottomNav extends StatefulWidget {
  const CustomBottomNav({super.key});

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black, width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            icon: Icons.menu_book_outlined,
            activeIcon: Icons.menu_book,
            isActive: _selectedIndex == 0,
            onTap: () => setState(() => _selectedIndex = 0),
          ),
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            isActive: _selectedIndex == 1,
            onTap: () => setState(() => _selectedIndex = 1),
          ),
          _NavItem(
            icon: Icons.school_outlined,
            activeIcon: Icons.school,
            isActive: _selectedIndex == 2,
            onTap: () => setState(() => _selectedIndex = 2),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isActive ? activeIcon : icon,
            key: ValueKey(isActive),
            size: 28,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}