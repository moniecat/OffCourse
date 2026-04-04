import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total > 0 ? (score / total * 100).round() : 0;
    final bool isPassed = percent >= 75;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Matching dashboard background
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Chunky Title
                Text(
                  "QUIZ COMPLETE!",
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                
                const SizedBox(height: 40),

                // Main Result Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 8),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Teal Header Block (Matching Question Screen)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF249780), // Teal
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          border: Border(
                            bottom: BorderSide(color: Colors.black, width: 3),
                          ),
                        ),
                        child: Text(
                          "YOUR PERFORMANCE",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            // Big Score Text
                            Text(
                              "$score / $total",
                              style: GoogleFonts.montserrat(
                                fontSize: 56,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            
                            const SizedBox(height: 10),

                            // Percentage Bubble
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: isPassed ? const Color(0xFFC8E6C9) : const Color(0xFFFFCDD2),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: Text(
                                "$percent%",
                                style: GoogleFonts.montserrat(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: isPassed ? Colors.green[900] : Colors.red[900],
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            Text(
                              isPassed ? "Outstanding!" : "Don't give up!",
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            
                            const SizedBox(height: 10),

                            Text(
                              isPassed 
                                ? "You've mastered this module." 
                                : "Review the material and try again.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // Back Button (Neo-brutalist Yellow Button)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: 65,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBB017), // Yellow
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "BACK TO MODULES",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}