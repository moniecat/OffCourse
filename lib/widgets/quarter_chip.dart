import 'package:flutter/material.dart';

class QuarterChip extends StatelessWidget {
  final String title;
  final Color color;
  final bool isActive;

  const QuarterChip({
    super.key,
    required this.title,
    required this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 62,
          height: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Center(
            child: Icon(
              isActive ? Icons.star : Icons.star_border,
              color: Colors.black,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}