import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/brainstorming_screen.dart';

class ModuleOneScreen extends StatefulWidget {
  final String moduleName;
  final String courseId;
  final String courseName;
  final String moduleId;
  final String? description;
  final int courseIndex;

  const ModuleOneScreen({
    super.key,
    required this.moduleName,
    required this.courseId,
    required this.courseName,
    required this.moduleId,
    this.description,
    required this.courseIndex,
  });

  @override
  State<ModuleOneScreen> createState() => _ModuleOneScreenState();
}

class _ModuleOneScreenState extends State<ModuleOneScreen> {
  int _attemptCount = 0;
  bool _isLoading = true;
  int _totalQuestions = 0;

  // Constants for Neobrutalist Theme
  final Color themeYellow = const Color(0xFFFFC01D);
  final Color themeTeal = const Color(0xFF32C6AD);
  final Color darkBorder = const Color(0xFF1A1C1E);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      // Fetch Total Questions in this module
      final questionSnap = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .collection('questions')
          .count()
          .get();

      // Fetch User Attempt Count
      int attempts = 0;
      if (uid != null) {
        final attemptSnap = await FirebaseFirestore.instance
            .collection('results')
            .where('userId', isEqualTo: uid)
            .where('moduleId', isEqualTo: widget.moduleId)
            .get();
        attempts = attemptSnap.docs.length;
      }

      if (mounted) {
        setState(() {
          _totalQuestions = questionSnap.count ?? 0;
          _attemptCount = attempts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading module data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Extracts "MODULE 1.4" from "1.4 Name"
  String _extractModuleNumber(String moduleName) {
    final match = RegExp(r'^(\d+(?:\.\d+)?)').firstMatch(moduleName);
    return match != null ? 'MODULE ${match.group(1)}' : 'MODULE';
  }

  /// Extracts "Name" from "1.4 Name"
  String _extractModuleName(String moduleName) {
    final noNumber = moduleName
        .replaceFirst(RegExp(r'^\d+(?:\.\d+)?\s*[-–]?\s*'), '')
        .trim();
    return noNumber.isEmpty ? moduleName : noNumber;
  }

  /// Logic for "0 Questions" / "1 Question" / "Many Questions"
  String _pluralize(int count, String noun) {
    return '$count $noun${count == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themeYellow,
      body: SafeArea(
        child: Column(
          children: [
            // --- TOP BAR ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Module',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w900,
                      fontSize: 30,
                      color: darkBorder,
                    ),
                  ),
                  _buildCloseButton(),
                ],
              ),
            ),

            // --- CENTERED CONTENT ---
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- COURSE PILL ---
                      _buildCoursePill(),
                      const SizedBox(height: 30),

                      // --- MODULE CARD ---
                      _buildMainCard(),
                      const SizedBox(height: 32),

                      // --- STATS ROW ---
                      _buildStatsRow(),
                    ],
                  ),
                ),
              ),
            ),

            // --- ACTION BUTTONS ---
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context, false),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: darkBorder, width: 3),
          boxShadow: [BoxShadow(color: darkBorder, offset: const Offset(4, 4))],
        ),
        child: Icon(Icons.close, size: 24, color: darkBorder, weight: 800),
      ),
    );
  }

  Widget _buildCoursePill() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: darkBorder, width: 3),
        boxShadow: [BoxShadow(color: darkBorder, offset: const Offset(5, 5))],
      ),
      child: Text(
        widget.courseName.toUpperCase(),
        textAlign: TextAlign.center,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: darkBorder, width: 3),
        boxShadow: [BoxShadow(color: darkBorder, offset: const Offset(6, 6))],
      ),
      child: Column(
        children: [
          Text(
            _extractModuleNumber(widget.moduleName),
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: themeTeal,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _extractModuleName(widget.moduleName),
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: darkBorder,
              height: 1.1,
            ),
          ),
          if (widget.description != null && widget.description!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              widget.description!,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: darkBorder.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatItem(
          Icons.help_outline_rounded,
          _isLoading ? '...' : _pluralize(_totalQuestions, 'Question'),
        ),
        Container(
          height: 20,
          width: 3,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: darkBorder.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        _buildStatItem(
          Icons.history_rounded,
          _isLoading ? '...' : _pluralize(_attemptCount, 'Attempt'),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: darkBorder.withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: darkBorder.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
      child: Column(
        children: [
          _buildNeobrutalistButton(
            label: 'Start Quiz',
            color: themeTeal,
            textColor: Colors.white,
            icon: Icons.play_arrow_rounded,
            onTap: () async {
              final nav = Navigator.of(context);
              final refreshed = await nav.push<bool>(
                MaterialPageRoute(
                  builder: (_) => BrainstormingScreen(
                    moduleName: widget.moduleName,
                    courseId: widget.courseId,
                    moduleId: widget.moduleId,
                    courseIndex: widget.courseIndex,
                  ),
                ),
              );
              if (refreshed == true && mounted) _loadData();
            },
          ),
          const SizedBox(height: 16),
          _buildNeobrutalistButton(
            label: 'Custom Practice',
            color: Colors.white,
            textColor: darkBorder,
            icon: Icons.tune_rounded,
            onTap: () => _showCustomStartSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildNeobrutalistButton({
    required String label,
    required Color color,
    required Color textColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 65,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: darkBorder, width: 3),
          boxShadow: [BoxShadow(color: darkBorder, offset: const Offset(0, 6))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.montserrat(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, size: 24, color: textColor),
          ],
        ),
      ),
    );
  }

  void _showCustomStartSheet(BuildContext context) {
    int selectedMax = _totalQuestions > 0 ? _totalQuestions : 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(top: BorderSide(color: darkBorder, width: 3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Custom Practice',
                  style: GoogleFonts.montserrat(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: darkBorder,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Practice mode: Score will not be recorded',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Questions amount:',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: darkBorder,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: themeYellow,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: darkBorder, width: 2),
                      ),
                      child: Text(
                        '$selectedMax',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: selectedMax.toDouble(),
                  min: 1,
                  max: _totalQuestions > 0 ? _totalQuestions.toDouble() : 1,
                  divisions: _totalQuestions > 1 ? _totalQuestions - 1 : 1,
                  activeColor: themeTeal,
                  inactiveColor: darkBorder.withValues(alpha: 0.1),
                  onChanged: (val) => setSheetState(() => selectedMax = val.round()),
                ),
                const SizedBox(height: 32),
                _buildNeobrutalistButton(
                  label: 'Start ${_pluralize(selectedMax, "Question")}',
                  color: themeYellow,
                  textColor: darkBorder,
                  icon: Icons.rocket_launch_rounded,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BrainstormingScreen(
                          moduleName: widget.moduleName,
                          courseId: widget.courseId,
                          moduleId: widget.moduleId,
                          courseIndex: widget.courseIndex,
                          isCustom: true,
                          maxQuestions: selectedMax,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}