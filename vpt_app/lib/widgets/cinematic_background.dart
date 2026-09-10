import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'grain_overlay.dart';

/// Ekranların arkasına yumuşak bir "spot ışığı" gradyanı çizen sarmalayıcı.
/// [Stack] + [Positioned.fill] kullanılıyor ki [child]'ın kendi boyutlanma
/// davranışından bağımsız olarak gradyan her zaman tüm ekranı kaplasın.
class CinematicBackground extends StatelessWidget {
  final Widget child;
  final Alignment glowAlignment;

  const CinematicBackground({
    super.key,
    required this.child,
    this.glowAlignment = const Alignment(0.6, -0.9),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: glowAlignment,
                radius: 1.3,
                colors: [
                  AppTheme.accentColor.withValues(alpha: 0.16),
                  AppTheme.backgroundColor,
                ],
                stops: const [0.0, 0.75],
              ),
            ),
          ),
        ),
        const Positioned.fill(child: GrainOverlay()),
        child,
      ],
    );
  }
}
