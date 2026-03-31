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
    required this.quarter,
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Column(
          children: [
            /// TOP IMAGE / ILLUSTRATION AREA
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative background blobs
                  Positioned(
                    left: -20,
                    top: -10,
                    child: Container(
                      width: 100,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -15,
                    bottom: -15,
                    child: Container(
                      width: 110,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Main centered icon
                  Center(
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 52,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  // Floating star top-right
                  Positioned(
                    right: 24,
                    top: 14,
                    child: Icon(
                      Icons.star,
                      size: 18,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  // Small star bottom-left
                  Positioned(
                    left: 20,
                    bottom: 14,
                    child: Icon(
                      Icons.star_border,
                      size: 14,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            /// BOTTOM CONTENT ROW
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          "Viewed 1",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const Text(
                          "Best Score 50",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.arrow_forward, size: 18),
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