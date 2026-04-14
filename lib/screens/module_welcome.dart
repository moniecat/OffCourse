import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/brainstorming_screen.dart';

class ModuleOneScreen extends StatelessWidget {
  final String moduleName;
  final int course;

  const ModuleOneScreen({
    super.key,
    required this.moduleName,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    const Color themeYellow = Color(0xFFFFC01D);
    const Color themeTeal = Color(0xFF32C6AD);
    const Color darkBorder = Color(0xFF1A1C1E);

    return Scaffold(
      backgroundColor: themeYellow,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // --- Header Row ---
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title on the left
                  Text(
                    'Module $course',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: darkBorder,
                    ),
                  ),
                  
                  // The "X" Button on the right with the exact style from your image
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12), // Rounded square
                        border: Border.all(color: darkBorder, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: darkBorder,
                            offset: Offset(4, 4), // Hard offset shadow
                            blurRadius: 0,
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.close, 
                        size: 24, 
                        color: darkBorder,
                        weight: 700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // --- Main Info Card ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: darkBorder, width: 3.5),
                  boxShadow: const [
                    BoxShadow(
                      color: darkBorder,
                      offset: Offset(0, 8),
                    )
                  ],
                ),
                child: Text(
                  'Inquiries, Investigation\nand Immersion\nCourse $course',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    color: darkBorder,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // --- Module Title and Name ---
              Column(
                children: [
                  Text(
                    'MODULE $course',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w900,
                      color: darkBorder.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    moduleName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 32, // Larger for better impact
                      fontWeight: FontWeight.w900,
                      color: darkBorder,
                      height: 1.1,
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 3),

              // --- Bottom Start Button ---
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BrainstormingScreen(
                        moduleName: moduleName,
                        course: course,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 65,
                  margin: const EdgeInsets.only(bottom: 30),
                  decoration: BoxDecoration(
                    color: themeTeal,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: darkBorder, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: darkBorder, 
                        offset: Offset(0, 6),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Start',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 24,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}