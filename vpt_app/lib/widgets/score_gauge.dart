import 'package:flutter/material.dart';

/// Eşleşme skorunu (0-100) düz bir "%xx" yerine dairesel bir gösterge
/// olarak çizen widget. Halka ve sayı, kart göründüğünde 0'dan hedef
/// skora birlikte animasyonla dolup sayarak beliriyor.
class ScoreGauge extends StatelessWidget {
  final double score;
  final Color color;
  final double size;

  const ScoreGauge({
    super.key,
    required this.score,
    required this.color,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: score.clamp(0, 100)),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, animatedScore, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: animatedScore / 100,
                strokeWidth: 4,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
              Text(
                '${animatedScore.round()}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.32,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
