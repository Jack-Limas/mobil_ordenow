import 'package:flutter/material.dart';

class WelcomeMetric extends StatelessWidget {
  const WelcomeMetric({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFFFB599),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.33,
          ),
        ),
      ],
    );
  }
}
