import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const CourseChip({
    super.key,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  static const Color brandYellow = Color(0xFFFFBC1F);
  static const Color brandTeal = Color(0xFF00CBA9);
  static const Color starOutlineColor = Color(0xFF1A1C1E); // Fixed dark color for star outline
  static const double thickness = 3.0;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isActive ? brandYellow : brandTeal;
    final Color starColor = isActive ? brandTeal : brandYellow;
    final double size = isActive ? 68 : 62;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

// ... rest of the imports and class definition

    final double labelWidth =
        (MediaQuery.of(context).size.width / 3.4).clamp(90.0, 130.0);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The Box (Keep as is)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: isDarkMode ? Colors.white : starOutlineColor, width: thickness),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode ? Colors.white : starOutlineColor,
                    offset: Offset(0, isActive ? 6 : 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.star_rounded,
                        color: starOutlineColor, size: isActive ? 48 : 42),
                    Icon(Icons.star_rounded,
                        color: starColor, size: isActive ? 36 : 30),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: labelWidth,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: isActive ? 11 : 10,
                  fontWeight: FontWeight.w900,
                  color: isDarkMode ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  height: 1.0,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
