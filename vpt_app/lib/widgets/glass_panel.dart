import 'dart:ui';

import 'package:flutter/material.dart';

/// Düz beyaz [Card]'ın yerini alan, hafif saydam/koyu dolgulu, ince
/// kenarlıklı, opsiyonel renkli glow gölgesine sahip bir konteyner.
class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? glowColor;
  final double borderRadius;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.glowColor,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final shadowColor = glowColor ?? Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF15151C).withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: glowColor != null ? 0.25 : 0.35),
            blurRadius: glowColor != null ? 24 : 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
