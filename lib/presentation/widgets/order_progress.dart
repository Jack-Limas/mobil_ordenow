import 'package:flutter/material.dart';

class OrderProgress extends StatelessWidget {
  const OrderProgress({
    super.key,
    required this.currentStep,
  });

  final int currentStep;

  static const _labels = [
    'Queued',
    'Accepted',
    'Cooking',
    'Ready',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(_labels.length, (index) {
            final isDone = index <= currentStep;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index == _labels.length - 1 ? 0 : 8),
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: isDone
                      ? const LinearGradient(
                          colors: [Color(0xFFFF6B00), Color(0xFF8A2F00)],
                        )
                      : null,
                  color: isDone ? null : Colors.white.withValues(alpha: 0.08),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 14),
        Row(
          children: List.generate(_labels.length, (index) {
            final isActive = index <= currentStep;
            return Expanded(
              child: Text(
                _labels[index],
                textAlign: index == 0
                    ? TextAlign.left
                    : index == _labels.length - 1
                        ? TextAlign.right
                        : TextAlign.center,
                style: TextStyle(
                  color: isActive
                      ? const Color(0xFFFFC7A7)
                      : Colors.white.withValues(alpha: 0.45),
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
