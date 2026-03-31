import 'package:flutter/material.dart';

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
    Color bgColor;
    Color borderColor;

    switch (state) {
      case AnswerState.correct:
        bgColor = Colors.green[100]!;
        borderColor = Colors.green;
        break;
      case AnswerState.wrong:
        bgColor = Colors.red[100]!;
        borderColor = Colors.red;
        break;
      case AnswerState.idle:
      default:
        bgColor = Colors.grey[100]!;
        borderColor = Colors.black;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
            if (state == AnswerState.correct)
              const Icon(Icons.check_circle, color: Colors.green, size: 18),
            if (state == AnswerState.wrong)
              const Icon(Icons.cancel, color: Colors.red, size: 18),
          ],
        ),
      ),
    );
  }
}