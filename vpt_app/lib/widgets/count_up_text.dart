import 'package:flutter/material.dart';

/// Bir tam sayıyı 0'dan hedef değere sayarak gösteren küçük, yeniden
/// kullanılabilir metin widget'ı (örn. "Aktif takip: 3" kartı içeri
/// girdiğinde 0→3 sayarak belirsin diye).
class CountUpText extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final Duration duration;

  const CountUpText({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, count, child) => Text('$count', style: style),
    );
  }
}
