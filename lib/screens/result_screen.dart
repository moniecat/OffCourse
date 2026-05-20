import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/theme_provider.dart';
import '../services/leaderboard_service.dart';
import 'home.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int total;
  final String courseId;
  final String moduleId;
  final int courseIndex;
  final bool isCustom;
  final int elapsedSeconds;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.courseId,
    required this.moduleId,
    required this.courseIndex,
    this.isCustom = false,
    this.elapsedSeconds = 0,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int? _userRank;
  bool _isLoadingRank = true;

  @override
  void initState() {
    super.initState();
    _fetchRank();
  }

  /// Records the score and calculates the user's rank on the leaderboard
  Future<void> _fetchRank() async {
    if (widget.isCustom) {
      if (mounted) setState(() => _isLoadingRank = false);
      return;
    }

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        if (mounted) setState(() => _isLoadingRank = false);
        return;
      }

      // 1. Record the current score (Service only saves if it is the new best)
      await LeaderboardService.recordScore(
        userId: uid,
        moduleId: widget.moduleId,
        courseId: widget.courseId,
        score: widget.score,
        elapsedSeconds: widget.elapsedSeconds,
      );

      // 2. Fetch historical Best Score from the database
      final bestScoreInDb = await LeaderboardService.getBestScore(uid, widget.moduleId);

      // 3. Fetch current rank position
      final entries = await LeaderboardService.getLeaderboard(widget.moduleId);
      final index = entries.indexWhere((e) => e.userId == uid);
      
      if (mounted) {
        setState(() {
          // Only show rank if this attempt is the best score recorded
          if (widget.score >= bestScoreInDb && index != -1) {
            _userRank = index + 1;
          } else {
            _userRank = null; 
          }
          _isLoadingRank = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching rank: $e");
      if (mounted) setState(() => _isLoadingRank = false);
    }
  }

  // Theme-aware color getters
  Color get _borderColor => Theme.of(context).colorScheme.onSurface;
  Color get _backgroundColor => Theme.of(context).scaffoldBackgroundColor;
  Color get _cardBackground => Theme.of(context).cardColor;
  Color get _textColor => Theme.of(context).colorScheme.onSurface;
  Color get _hintColor => Theme.of(context).colorScheme.onSurface.withValues(alpha: .6);

  final Color themeTeal = const Color(0xFF249780);
  final Color themeYellow = const Color(0xFFFBB017);
  final Color passGreen = const Color(0xFFC8E6C9);
  final Color failRed = const Color(0xFFFFCDD2);

  String get _formattedTime {
    final m = (widget.elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (widget.elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    // Re-build on theme change
    context.watch<ThemeProvider>().isDarkMode;

    final percent = widget.total > 0 ? (widget.score / widget.total * 100).round() : 0;
    final bool isPassed = percent >= 75;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        // Forced navigation back to home
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => HomeScreen(initialCourseIndex: widget.courseIndex)),
          (route) => false,
        );
      },
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "QUIZ COMPLETE!",
                    style: GoogleFonts.montserrat(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Main Result Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _cardBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _borderColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: _borderColor,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header Strip
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: themeTeal,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            border: Border(bottom: BorderSide(color: _borderColor, width: 3)),
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
                        // Practice Mode Banner
                        if (widget.isCustom)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            color: themeYellow.withValues(alpha: 0.2),
                            child: Center(
                              child: Text(
                                'Practice Mode — Score not recorded',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _textColor,
                                ),
                              ),
                            ),
                          ),
                        // Score Content
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Text(
                                "${widget.score} / ${widget.total}",
                                style: GoogleFonts.montserrat(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w900,
                                  color: _textColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Percentage Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isPassed ? passGreen : failRed,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: _borderColor, width: 2),
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
                              // Badges Row
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _buildSmallBadge(Icons.timer_outlined, _formattedTime),
                                  if (!widget.isCustom && !_isLoadingRank && _userRank != null)
                                    _buildSmallBadge(
                                      Icons.emoji_events_outlined,
                                      "RANK #$_userRank",
                                      color: themeYellow,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              Text(
                                isPassed ? "Outstanding!" : "Don't give up!",
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: _textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isPassed
                                    ? "You've mastered this module."
                                    : "Review the material and try again.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: _hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Action Button
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => HomeScreen(initialCourseIndex: widget.courseIndex),
                        ),
                        (route) => false,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 65,
                      decoration: BoxDecoration(
                        color: themeYellow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _borderColor, width: 3),
                        boxShadow: [
                          BoxShadow(color: _borderColor, offset: const Offset(4, 4)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "BACK TO MODULES",
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black, // High contrast for Neobrutalism
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
      ),
    );
  }

  Widget _buildSmallBadge(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color ?? _backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color != null ? Colors.black : _textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color != null ? Colors.black : _textColor,
            ),
          ),
        ],
      ),
    );
  }
}