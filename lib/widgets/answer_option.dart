import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AnswerState { idle, selected, correct, wrong }

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
    Color bgColor = Theme.of(context).cardColor;
    Color borderColor = Theme.of(context).colorScheme.onSurface;
    Color textColor = Theme.of(context).colorScheme.onSurface;

    // Logic for states
    if (state == AnswerState.selected) {
      // Use the requested color 0xFFFBB017 for selection
      bgColor = const Color(0xFFFFF9C4); // Very light yellow background
      borderColor = const Color(0xFFFBB017); // Your specific Orange/Yellow
      textColor = Colors.black;
    } else if (state == AnswerState.correct) {
      // Matches the green in your screenshot
      bgColor = const Color(0xFFE8F5E9); 
      borderColor = const Color(0xFF2E7D32); 
      textColor = const Color(0xFF2E7D32); 
    } else if (state == AnswerState.wrong) {
      bgColor = const Color(0xFFFFEBEE); 
      borderColor = const Color(0xFFC62828);
      textColor = const Color(0xFFC62828);
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
              ? [BoxShadow(color: Theme.of(context).colorScheme.onSurface, offset: const Offset(4, 4))] 
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
                  border: Border.all(color: borderColor, width: 2),
                  color: Theme.of(context).cardColor,
                ),
                child: Center(
                  child: Text(label, style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w900, 
                    fontSize: 14,
                    color: borderColor
                  )),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(text, style: GoogleFonts.montserrat(
                  fontSize: 16, 
                  fontWeight: FontWeight.w700,
                  color: textColor
                )),
              ),
              if (state == AnswerState.correct) 
                const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 24),
              if (state == AnswerState.wrong) 
                const Icon(Icons.cancel, color: Color(0xFFC62828), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}