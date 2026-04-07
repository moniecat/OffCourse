import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuarterChip extends StatelessWidget {
  final String label; // Ensure this is named 'label'
  final bool isActive;
  final VoidCallback? onTap;

  const QuarterChip({
    super.key,
    required this.label, 
    this.isActive = false,
    this.onTap,
  });

  static const Color brandYellow = Color(0xFFFFBC1F); 
  static const Color brandTeal = Color(0xFF00CBA9);   
  static const Color darkOutline = Color(0xFF1A1D23);
  static const double thickness = 3.0;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isActive ? brandYellow : brandTeal;
    final Color starColor = isActive ? brandTeal : brandYellow;
    final double size = isActive ? 68 : 62;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack, // FIX: Changed from backOut to easeOutBack
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: darkOutline, width: thickness),
                boxShadow: [
                  BoxShadow(
                    color: darkOutline,
                    offset: Offset(0, isActive ? 6 : 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: darkOutline,
                      size: isActive ? 48 : 42,
                    ),
                    Icon(
                      Icons.star_rounded,
                      color: starColor, 
                      size: isActive ? 36 : 30,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label, 
              style: GoogleFonts.montserrat(
                fontSize: isActive ? 16 : 14,
                fontWeight: FontWeight.w900,
                color: darkOutline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}