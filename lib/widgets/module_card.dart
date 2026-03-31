import 'package:flutter/material.dart';
import '../screens/brainstorming_screen.dart';

class ModuleCard extends StatelessWidget {
  final String title;
  final Color color;
  final int quarter;

  const ModuleCard({
    super.key,
    required this.title,
    required this.color,
    this.quarter = 1,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BrainstormingScreen(
              moduleName: title,
              quarter: quarter,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black),
          color: Colors.white,
        ),
        child: Column(
          children: [
            /// TOP IMAGE AREA
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: const Center(
                child: Icon(Icons.menu_book, size: 50, color: Colors.white),
              ),
            ),

            /// BOTTOM CONTENT
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text("Viewed 1"),
                        const Text("Best Score 50"),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.arrow_forward),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}