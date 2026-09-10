import 'dart:math';

import 'package:flutter/material.dart';

/// Düz gradyan arka planın üstüne çok hafif, statik bir film grenli doku
/// bindiren overlay — harici bir asset gerektirmiyor, sabit bir seed ile
/// (her build'de aynı) noktaları prosedürel olarak çiziyor.
class GrainOverlay extends StatelessWidget {
  final double opacity;

  const GrainOverlay({super.key, this.opacity = 0.035});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(painter: _GrainPainter(), size: Size.infinite),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  static const int _dotCount = 800;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint();

    for (var i = 0; i < _dotCount; i++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final shade = random.nextBool() ? Colors.white : Colors.black;
      paint.color = shade.withValues(alpha: random.nextDouble() * 0.5 + 0.2);
      canvas.drawCircle(Offset(dx, dy), 0.6, paint);
    }
  }

  // Sabit seed'li statik bir doku — bir daha çizmeye gerek yok.
  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) => false;
}
