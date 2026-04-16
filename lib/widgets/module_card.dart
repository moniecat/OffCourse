import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import '../screens/module_welcome.dart';
import '../services/result_service.dart';
import '../services/question_service.dart';
import '../models/best_score.dart';

class ModuleCard extends StatefulWidget {
  final String title;
  final Color color;
  final String courseId;
  final String moduleId; // 👈 new
  final String courseName; // 👈 new

  const ModuleCard({
    super.key,
    required this.title,
    required this.color,
    required this.courseId,
    required this.moduleId, // 👈 new
    required this.courseName, // 👈 new
  });

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  int? _totalQuestions;
  int? _bestScore;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Fetch total questions and best score in parallel
    final results = await Future.wait([
      QuestionService.getTotalQuestions(widget.courseId, widget.moduleId),
      ResultService.getBestScore(userId: uid, moduleId: widget.moduleId),
    ]);

    if (mounted) {
      setState(() {
        _totalQuestions = results[0] as int;
        final best = results[1] as BestScoreModel?;
        _bestScore = best?.score;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBorder = Color(0xFF1A1A1A);
    const double thickness = 3.5;
    const double shadowOffset = 7.0;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ModuleOneScreen(
              moduleName: widget.title,
              courseId: widget.courseId,
              courseName: widget.courseName,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: shadowOffset + 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: darkBorder, width: thickness),
          boxShadow: const [
            BoxShadow(
              color: darkBorder,
              offset: Offset(0, shadowOffset),
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Illustration Area
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: widget.color,
                  border: const Border(
                    bottom: BorderSide(color: darkBorder, width: thickness),
                  ),
                ),
                child: CustomPaint(
                  painter: _BoldStickerPainter(darkBorder, thickness),
                ),
              ),

              // Info Area
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: darkBorder,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _totalQuestions == null
                            ? Container(
                                height: 13,
                                width: 160,
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              )
                            : Text(
                                _bestScore == null
                                    ? 'Total: $_totalQuestions  •  No attempts yet'
                                    : 'Total: $_totalQuestions  •  Best: $_bestScore/$_totalQuestions',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: darkBorder.withValues(alpha: 0.6),
                                ),
                              ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: darkBorder, width: thickness),
                      ),
                      child: const Icon(Icons.arrow_forward_rounded, color: darkBorder, size: 26),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ... Keep your _BoldStickerPainter class here ...
class _BoldStickerPainter extends CustomPainter {
  final Color borderColor;
  final double thickness;
  _BoldStickerPainter(this.borderColor, this.thickness);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h * 0.8;

    _drawStickerBook(canvas, w * 0.22, h * 0.4, 35, 45, -20, const Color(0xFF3DBFA8), fillPaint, paint);
    _drawStickerBook(canvas, w * 0.38, h * 0.22, 30, 40, -5, Colors.white, fillPaint, paint);
    _drawStickerBook(canvas, w * 0.68, h * 0.20, 40, 30, 15, Colors.white, fillPaint, paint);
    _drawStickerBook(canvas, w * 0.82, h * 0.45, 35, 45, 25, const Color(0xFF3DBFA8), fillPaint, paint);

    final bookPath = Path();
    bookPath.moveTo(cx, cy);
    bookPath.quadraticBezierTo(cx - 50, cy - 10, cx - (w * 0.35), cy + 10);
    bookPath.lineTo(cx - (w * 0.35), cy - 20);
    bookPath.quadraticBezierTo(cx - 50, cy - 40, cx, cy - 30);
    bookPath.quadraticBezierTo(cx + 50, cy - 40, cx + (w * 0.35), cy - 20);
    bookPath.lineTo(cx + (w * 0.35), cy + 10);
    bookPath.quadraticBezierTo(cx + 50, cy - 10, cx, cy);

    canvas.drawPath(bookPath, fillPaint..color = Colors.white);
    canvas.drawPath(bookPath, paint);
    canvas.drawLine(Offset(cx, cy - 30), Offset(cx, cy), paint);
  }

  void _drawStickerBook(Canvas canvas, double x, double y, double bw, double bh,
      double angle, Color color, Paint fill, Paint stroke) {
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle * math.pi / 180);
    final rect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, bw, bh), const Radius.circular(6));
    canvas.drawRRect(rect.shift(const Offset(3, 3)), fill..color = borderColor);
    canvas.drawRRect(rect, fill..color = color);
    canvas.drawRRect(rect, stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}