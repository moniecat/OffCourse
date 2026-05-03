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
  List<LeaderboardEntry> _topThree = [];
  int _userRank = -1;
  bool _userAffected = false;

  // Theme-aware color getters
  Color get _borderColor => Theme.of(context).colorScheme.onSurface;
  Color get _backgroundColor => Theme.of(context).scaffoldBackgroundColor;
  Color get _cardBackground => Theme.of(context).cardColor;
  Color get _textColor => Theme.of(context).colorScheme.onSurface;
  Color get _hintColor =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

  // Accent colors (branding - keep as-is)
  final Color themeTeal = const Color(0xFF249780);
  final Color themeYellow = const Color(0xFFFBB017);
  final Color passGreen = const Color(0xFFC8E6C9);
  final Color failRed = const Color(0xFFFFCDD2);

  @override
  void initState() {
    super.initState();
    if (!widget.isCustom) {
      _loadLeaderboardData();
    }
  }

  Future<void> _loadLeaderboardData() async {
    try {
      final leaderboard =
          await LeaderboardService.getLeaderboard(widget.moduleId);
      final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Find current user in top 10
      LeaderboardEntry? userEntry;
      int userRank = -1;
      for (int i = 0; i < leaderboard.length && i < 10; i++) {
        if (leaderboard[i].userId == currentUserId) {
          userEntry = leaderboard[i];
          userRank = i + 1;
          break;
        }
      }

      if (mounted) {
        setState(() {
          if (userEntry != null) {
            _topThree = [userEntry];
            _userRank = userRank;
            _userAffected = true;
          } else {
            _topThree = [];
            _userRank = -1;
            _userAffected = false;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading leaderboard: $e');
    }
  }

  String get _formattedTime {
    final m = (widget.elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (widget.elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>().isDarkMode;

    final percent =
        widget.total > 0 ? (widget.score / widget.total * 100).round() : 0;
    final bool isPassed = percent >= 75;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;
        Navigator.pop(context, true);
      },
      child: Scaffold(
        backgroundColor: _backgroundColor,
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
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Teal Header Block
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: themeTeal,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            border: Border(
                              bottom:
                                  BorderSide(color: _borderColor, width: 3),
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

                        if (widget.isCustom)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            color: const Color(0xFFFFF3CD),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.info_outline,
                                    size: 16, color: Color(0xFF856404)),
                                const SizedBox(width: 6),
                                Text(
                                  'Practice Mode — Score not recorded',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF856404),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              // Big Score Text
                              Text(
                                "${widget.score} / ${widget.total}",
                                style: GoogleFonts.montserrat(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w900,
                                  color: _textColor,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Percentage Bubble
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isPassed ? passGreen : failRed,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                      color: _borderColor, width: 2),
                                ),
                                child: Text(
                                  "$percent%",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: isPassed
                                        ? Colors.green[900]
                                        : Colors.red[900],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Time taken badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 7),
                                decoration: BoxDecoration(
                                  color: _backgroundColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: _borderColor, width: 2),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.timer_outlined,
                                        size: 16, color: _hintColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formattedTime,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: _textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              Text(
                                isPassed
                                    ? "Outstanding!"
                                    : "Don't give up!",
                                style: GoogleFonts.montserrat(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: _textColor,
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
                                  color: _hintColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Leaderboard Section (only if user is in top 10)
                  if (_userAffected && _topThree.isNotEmpty && !widget.isCustom)
                    Column(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _cardBackground,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _borderColor,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _borderColor,
                                offset: const Offset(0, 6),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Header
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: themeTeal,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  border: Border(
                                    bottom: BorderSide(
                                        color: _borderColor, width: 3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.trending_up_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "IN THE TOP 10!",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Content
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: _topThree
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final leaderboardEntry = entry.value;

                                    return Row(
                                      children: [
                                        // Premium Rank Badge
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: _userRank == 1
                                                  ? [
                                                      const Color(0xFFFFD700),
                                                      const Color(0xFFFFC700),
                                                    ]
                                                  : _userRank == 2
                                                      ? [
                                                          const Color(0xFFC0C0C0),
                                                          const Color(0xFFB0B0B0),
                                                        ]
                                                      : _userRank <= 10
                                                          ? [
                                                              const Color(
                                                                  0xFFCD7F32),
                                                              const Color(
                                                                  0xFFBD6F22),
                                                            ]
                                                          : [
                                                              themeTeal,
                                                              const Color(
                                                                  0xFF1E9B7C),
                                                            ],
                                            ),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: _borderColor,
                                              width: 3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _borderColor
                                                    .withValues(alpha: 0.3),
                                                offset: const Offset(0, 4),
                                                blurRadius: 8,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              '#${_userRank}',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // User Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                leaderboardEntry.name,
                                                style:
                                                    GoogleFonts.montserrat(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w900,
                                                  color: _textColor,
                                                ),
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              const SizedBox(height: 4),
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                  horizontal: 10,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _userRank == 1
                                                      ? const Color(0xFFFFD700)
                                                          .withValues(
                                                              alpha: 0.2)
                                                      : _userRank == 2
                                                          ? const Color(
                                                                  0xFFC0C0C0)
                                                              .withValues(
                                                              alpha: 0.2)
                                                          : themeTeal
                                                              .withValues(
                                                              alpha: 0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          6),
                                                  border: Border.all(
                                                    color: _userRank == 1
                                                        ? const Color(
                                                            0xFFFFD700)
                                                        : _userRank == 2
                                                            ? const Color(
                                                                0xFFC0C0C0)
                                                            : themeTeal,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: Text(
                                                  _userRank == 1
                                                      ? '🥇 Champion'
                                                      : _userRank == 2
                                                          ? '🥈 Runner-up'
                                                          : _userRank == 3
                                                              ? '🥉 Third Place'
                                                              : '⭐ Top 10',
                                                  style: GoogleFonts
                                                      .montserrat(
                                                    fontSize: 11,
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    color: _userRank == 1
                                                        ? const Color(
                                                            0xFFFFD700)
                                                        : _userRank == 2
                                                            ? const Color(
                                                                0xFFC0C0C0)
                                                            : themeTeal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Score Badge
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _backgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: _borderColor,
                                              width: 2.5,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                '${leaderboardEntry.score}/${leaderboardEntry.total}',
                                                style:
                                                    GoogleFonts.montserrat(
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight.w900,
                                                  color: _textColor,
                                                ),
                                              ),
                                              Text(
                                                'Score',
                                                style:
                                                    GoogleFonts.montserrat(
                                                  fontSize: 9,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: _hintColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // Back Button (Neo-brutalist Yellow Button)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => HomeScreen(
                              initialCourseIndex: widget.courseIndex),
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
                          BoxShadow(
                            color: _borderColor,
                            offset: const Offset(4, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "BACK TO MODULES",
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _textColor,
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
}