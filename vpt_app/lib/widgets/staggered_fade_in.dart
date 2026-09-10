import 'package:flutter/material.dart';

/// Liste elemanlarını index'e göre kademeli bir gecikme hissiyle
/// fade + yukarı kayarak içeri sokan sarmalayıcı. Gerçek bir gecikme
/// yerine index arttıkça animasyon süresini uzatarak kademeli görünüm
/// veriyor — ekstra bir [AnimationController]/dispose gerektirmiyor.
class StaggeredFadeIn extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration stepDelay;

  const StaggeredFadeIn({
    super.key,
    required this.index,
    required this.child,
    this.stepDelay = const Duration(milliseconds: 60),
  });

  @override
  Widget build(BuildContext context) {
    final extraMs = (index * stepDelay.inMilliseconds).clamp(0, 480);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + extraMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
