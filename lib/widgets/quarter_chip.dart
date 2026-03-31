import 'package:flutter/material.dart';

class QuarterChip extends StatelessWidget {
  final String title;
  final Color color;

  const QuarterChip({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 50,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black),
          ),
          child: const Center(
            child: Icon(Icons.star, color: Colors.black),
          ),
        ),
        const SizedBox(height: 6),
        Text(title),
      ],
    );
  }
}