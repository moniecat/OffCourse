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
  bool _isLoadingAttempts = true;
  int _totalQuestions = 0;


  @override
  void initState() {
    super.initState();
    _loadAttempts();
    _loadTotalQuestions();
  }

  Future<void> _loadTotalQuestions() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('modules')
          .doc(widget.moduleId)
          .collection('questions')
          .count()
          .get();
      if (mounted) setState(() => _totalQuestions = snap.count ?? 0);
    } catch (_) {}
  }

  Future<void> _loadAttempts() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        setState(() => _isLoadingAttempts = false);
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('results')
          .where('userId', isEqualTo: uid)
          .where('moduleId', isEqualTo: widget.moduleId)
          .get();

      setState(() {
        _attemptCount = querySnapshot.docs.length;
        _isLoadingAttempts = false;
      });
    } catch (e) {
      debugPrint('Error loading attempts: $e');
      setState(() => _isLoadingAttempts = false);
    }
  }

  /// Extract module number from the beginning of module name (e.g., "2.1" from "2.1 Hardware")
  String _extractModuleNumber(String moduleName) {
    final match = RegExp(r'^(\d+(?:\.\d+)?)').firstMatch(moduleName);
    if (match != null) {
      return 'MODULE ${match.group(1)}';
    }
    return 'MODULE';
  }

  /// Extract module name without the number prefix
  String _extractModuleName(String moduleName) {
    final noNumber = moduleName.replaceFirst(RegExp(r'^\d+(?:\.\d+)?\s*[-–]?\s*'), '').trim();
    return noNumber.isEmpty ? moduleName : noNumber;
  }

  void _showCustomStartSheet(BuildContext context) {
    const Color darkBorder = Color(0xFF1A1C1E);
    int selectedMax = _totalQuestions > 0 ? _totalQuestions : 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(top: BorderSide(color: darkBorder, width: 3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Custom Start',
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: darkBorder,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Practice Mode — Score will not be recorded',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Number of Questions',
                      style: GoogleFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: darkBorder,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC01D),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: darkBorder, width: 2),
                      ),
                      child: Text(
                        '$selectedMax',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: darkBorder,
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
                  activeColor: const Color(0xFF32C6AD),
                  inactiveColor: darkBorder.withValues(alpha: 0.2),
                  onChanged: (val) =>
                      setSheetState(() => selectedMax = val.round()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('1',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w700,
                            color: darkBorder.withValues(alpha: 0.5))),
                    Text('$_totalQuestions',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w700,
                            color: darkBorder.withValues(alpha: 0.5))),
                  ],
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      this.context,
                      MaterialPageRoute(
                        builder: (_) => BrainstormingScreen(
                          moduleName:   widget.moduleName,
                          courseId:     widget.courseId,
                          moduleId:     widget.moduleId,
                          courseIndex:  widget.courseIndex,
                          isCustom:     true,
                          maxQuestions: selectedMax,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 65,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC01D),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: darkBorder, width: 3),
                      boxShadow: const [
                        BoxShadow(color: darkBorder, offset: Offset(0, 6)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Start $selectedMax Question${selectedMax > 1 ? 's' : ''}',
                          style: GoogleFonts.montserrat(
                            color: darkBorder,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 24, color: darkBorder),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color themeYellow = Color(0xFFFFC01D);
    const Color themeTeal = Color(0xFF32C6AD);
    const Color darkBorder = Color(0xFF1A1C1E);

    return Scaffold(
      backgroundColor: themeYellow,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Module',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: darkBorder,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: darkBorder, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: darkBorder,
                            offset: Offset(4, 4),
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
            ),
            // Center Content (Flexible)
            Expanded(
              flex: 1,
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Course Name Chip
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: darkBorder, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: darkBorder,
                                offset: Offset(0, 4),
                              )
                            ],
                          ),
                          child: Text(
                            widget.courseName,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: darkBorder,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Module Number & Name (Separated)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: darkBorder, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: darkBorder,
                                offset: Offset(0, 6),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Module Number (Extracted or placeholder)
                              Text(
                                _extractModuleNumber(widget.moduleName),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: themeTeal,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Module Name
                              Text(
                                _extractModuleName(widget.moduleName),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: darkBorder,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Module Description (if present)
                        if (widget.description != null && widget.description!.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              widget.description!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: darkBorder.withValues(alpha: 0.7),
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        // Attempts Count
                        _isLoadingAttempts
                            ? SizedBox(
                                height: 16,
                                width: 120,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: darkBorder.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              )
                            : Text(
                                _attemptCount == 0
                                    ? 'No attempts yet'
                                    : 'Attempts: $_attemptCount',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: darkBorder.withValues(alpha: 0.6),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Buttons (Fixed at bottom)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      // Capture navigator before async gap
                      final navigator = Navigator.of(context);

                      final refreshed = await navigator.push<bool>(
                        MaterialPageRoute(
                          builder: (_) => BrainstormingScreen(
                            moduleName: widget.moduleName,
                            courseId: widget.courseId,
                            moduleId: widget.moduleId,
                            courseIndex: widget.courseIndex,
                          ),
                        ),
                      );

                      // FIX: Check if context is still mounted before popping
                      if (refreshed == true && context.mounted) {
                        // Reload attempts count before popping back
                        await _loadAttempts();
                        navigator.pop(true);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 65,
                      margin: const EdgeInsets.only(bottom: 12),
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
                  GestureDetector(
                    onTap: () => _showCustomStartSheet(context),
                    child: Container(
                      width: double.infinity,
                      height: 55,
                      margin: const EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: darkBorder, width: 3),
                        boxShadow: const [
                          BoxShadow(color: darkBorder, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Custom Start',
                            style: GoogleFonts.montserrat(
                              color: darkBorder,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.tune_rounded, size: 22, color: darkBorder),
                        ],
                      ),
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