import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AnswerState { idle, correct, wrong }

class AnswerOption extends StatelessWidget {
  final String label;
  final String text;
  final AnswerState state;
  final VoidCallback? onTap;

  const AnswerOption({
    super.key,
    required this.label,
    required this.text,
    this.state = AnswerState.idle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    Color borderColor = Colors.black;

    if (state == AnswerState.correct) {
      bgColor = const Color(0xFFC8E6C9);
      borderColor = const Color(0xFF2E7D32);
    } else if (state == AnswerState.wrong) {
      bgColor = const Color(0xFFFFCDD2);
      borderColor = const Color(0xFFC62828);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2.5),
          boxShadow: state == AnswerState.idle 
              ? const [BoxShadow(color: Colors.black, offset: Offset(4, 4))] 
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                  color: Colors.white,
                ),
                child: Center(
                  child: Text(label, style: GoogleFonts.montserrat(fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(text, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              if (state == AnswerState.correct) const Icon(Icons.check_circle, color: Colors.green, size: 24),
              if (state == AnswerState.wrong) const Icon(Icons.cancel, color: Colors.red, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}