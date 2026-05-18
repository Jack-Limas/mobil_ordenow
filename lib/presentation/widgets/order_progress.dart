import 'package:flutter/material.dart';

class OrderProgress extends StatelessWidget {
  const OrderProgress({
    super.key,
    required this.currentStep,
  });

  // 0=Recibido  1=Cocinando  2=Reparto  3=Entregado
  final int currentStep;

  static const _labels = ['Recibido', 'Cocinando', 'Reparto', 'Entregado'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(_labels.length * 2 - 1, (i) {
            if (i.isOdd) {
              final lineIndex = i ~/ 2;
              final isDone = lineIndex < currentStep;
              return Expanded(
                child: Container(
                  height: 2,
                  color: isDone
                      ? const Color(0xFFFF6F22)
                      : const Color(0xFF3A3A3C),
                ),
              );
            } else {
              final stepIndex = i ~/ 2;
              return _StepCircle(
                isDone: stepIndex < currentStep,
                isActive: stepIndex == currentStep,
              );
            }
          }),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(_labels.length, (i) {
            final highlight = i <= currentStep;
            return Expanded(
              child: Text(
                _labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: highlight ? Colors.white : const Color(0xFF8E8E93),
                  fontSize: 11,
                  fontWeight:
                      highlight ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({required this.isDone, required this.isActive});

  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final orange = isDone || isActive;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: orange ? const Color(0xFFFF6F22) : const Color(0xFF3A3A3C),
        border: isActive
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.35), width: 2)
            : null,
      ),
      child: isDone
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
          : isActive
              ? Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
    );
  }
}
