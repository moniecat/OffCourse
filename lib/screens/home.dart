import 'package:flutter/material.dart';
import '../widgets/quarter_chip.dart';
import '../widgets/module_card.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/menu_drawer.dart';
 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
 
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
 
class _HomeScreenState extends State<HomeScreen> {
  int _selectedQuarter = 0;

  void _openMenu(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.4),
        pageBuilder: (_, __, ___) => const MenuDrawer(),
        transitionsBuilder: (_, animation, __, child) {
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
      backgroundColor: Colors.grey[200],
      bottomNavigationBar: const CustomBottomNav(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
 
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome,",
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      Text(
                        "Jane Doe",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _openMenu(context),
                    child: const Icon(Icons.menu, size: 28),
                  ),
                ],
              ),
 
              const SizedBox(height: 20),
 
              /// QUARTERS
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: 10,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final isActive = index == _selectedQuarter;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedQuarter = index),
                      child: QuarterChip(
                        title: "Quarter ${index + 1}",
                        color: isActive ? Colors.amber : Colors.teal,
                        isActive: isActive,
                      ),
                    );
                  },
                ),
              ),
 
              const SizedBox(height: 20),
 
              /// MODULE LIST
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
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
 
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
 