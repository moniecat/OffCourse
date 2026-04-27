import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  // DESIGN TOKENS (Sourced from your Profile design)
  static const Color brandYellow = Color(0xFFFFC21C);
  static const Color brandRed = Color(0xFFFF5C5C);
  static const Color textBlack = Color(0xFF000000);
  static const Color textGrey = Color(0xFF6B6B6B);
  static const Color bgWhite = Colors.white;
  static const double borderWeight = 2.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgWhite, // requested white background
      body: Stack(
        children: [
          // 1. SUBTLE DOT GRID (Matches Profile Screen texture)
          Positioned.fill(
            child: CustomPaint(painter: DotGridPainter()),
          ),
          
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 2. ICON CONTAINER
                  // Using the hard shadow logic from your Profile image
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: brandYellow, // Accent color to tie back to the brand
                      shape: BoxShape.circle,
                      border: Border.all(color: textBlack, width: borderWeight),
                      boxShadow: const [BoxShadow(color: textBlack, offset: Offset(0, 6))],
                    ),
                    child: const Icon(Icons.logout_rounded, size: 54, color: textBlack),
                  ),
                  const SizedBox(height: 48),

                  // 3. TEXT SECTION
                  Text(
                    "LOG OUT",
                    style: GoogleFonts.montserrat(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: textBlack,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "Are you sure you want to log out of your account? You will need to sign back in to access your data.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textGrey,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 4. LOG OUT BUTTON (The "Action" Button)
                  _buildNeoButton(
                    text: "LOG OUT",
                    color: brandRed,
                    textColor: Colors.white,
                    onTap: () async {
                      await AuthService().signOut();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // 5. CANCEL BUTTON (The "Safe" Button)
                  _buildNeoButton(
                    text: "CANCEL",
                    color: bgWhite,
                    textColor: textBlack,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Neo-Brutalist Button
  Widget _buildNeoButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: textBlack, width: borderWeight),
          borderRadius: BorderRadius.circular(12), // Matching your button radius
          boxShadow: const [BoxShadow(color: textBlack, offset: Offset(0, 5))],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

// Custom Painter for the background dots (Consistent with Profile screen)
class DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
// Modern syntax using withValues
      ..color = Colors.black.withValues(alpha: 0.06) // Very subtle dot grid
      ..strokeWidth = 2.0;

    const double gap = 25.0;
    for (double x = 0; x < size.width; x += gap) {
      for (double y = 0; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}