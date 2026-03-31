import 'package:flutter/material.dart';
import '../widgets/quarter_chip.dart';
import '../widgets/module_card.dart';
import '../widgets/custom_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome,", style: TextStyle(fontSize: 18)),
                      Text(
                        "Jane Doe",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.menu, size: 28),
                ],
              ),

              const SizedBox(height: 20),

              /// QUARTERS
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    QuarterChip(title: "Quarter 1", color: Colors.amber),
                    SizedBox(width: 12),
                    QuarterChip(title: "Quarter 2", color: Colors.teal),
                    SizedBox(width: 12),
                    QuarterChip(title: "Quarter 3", color: Colors.teal),
                    SizedBox(width: 12),
                    QuarterChip(title: "Quarter 4", color: Colors.teal),
                    SizedBox(width: 12),
                    QuarterChip(title: "Quarter 5", color: Colors.teal),
                    SizedBox(width: 12),
                    QuarterChip(title: "Quarter 6", color: Colors.teal),
                    SizedBox(width: 12),
                    QuarterChip(title: "Quarter 7", color: Colors.teal),
                    SizedBox(width: 12),
                    QuarterChip(title: "Quarter 8", color: Colors.teal),
                    SizedBox(width: 12),
                    QuarterChip(title: "Quarter 9", color: Colors.teal),
                    SizedBox(width: 12),
                    QuarterChip(title: "Quarter 10", color: Colors.teal),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// MODULE LIST
              Expanded(
                child: ListView(
                  children: const [
                    ModuleCard(title: "Brainstorming", color: Colors.teal),
                    ModuleCard(title: "Module 2", color: Colors.amber),
                    ModuleCard(title: "Module 3", color: Colors.teal),
                    ModuleCard(title: "Module 4", color: Colors.amber),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}