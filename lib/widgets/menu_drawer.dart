import 'package:flutter/material.dart';

class MenuDrawer extends StatefulWidget {
  const MenuDrawer({super.key});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  int _activeIndex = 0;

  final List<String> _menuItems = ['Home', 'FAQ', 'Setting', 'About'];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        // Prevent taps inside drawer from closing it
        onTap: () {},
        child: Container(
          width: MediaQuery.of(context).size.width * 0.65,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(color: Colors.black, width: 2),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Close / hamburger button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.menu, size: 28),
                  ),

                  const SizedBox(height: 40),

                  /// Menu items
                  ...List.generate(_menuItems.length, (index) {
                    final isActive = index == _activeIndex;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _activeIndex = index);
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 150),
                          style: TextStyle(
                            fontSize: isActive ? 28 : 24,
                            fontWeight: isActive
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isActive
                                ? const Color(0xFFF5C842)
                                : Colors.black,
                          ),
                          child: Text(_menuItems[index]),
                        ),
                      ),
                    );
                  }),

                  const Spacer(),

                  /// Logo mark at bottom
                  Center(
                    child: _LogoMark(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF3DBFA8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: const Center(
        child: Icon(
          Icons.menu_book_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}