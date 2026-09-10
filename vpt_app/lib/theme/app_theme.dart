import 'package:flutter/material.dart';

/// "Showroom karanlığı" — uygulama genelinde kullanılan tek tema.
///
/// `VehicleViewer`'ın zaten kurduğu koyu stüdyo zeminini (bkz.
/// [surfaceColor]) tüm uygulamaya yayıp, sıcak bir "spot ışığı" vurgu
/// rengiyle (bkz. [accentColor]) bütünlük kazandırıyor.
class AppTheme {
  AppTheme._();

  static const Color backgroundColor = Color(0xFF0A0A0F);
  static const Color surfaceColor = Color(0xFF15151C);
  static const Color accentColor = Color(0xFFE8B34C);
  static const Color onAccentColor = Color(0xFF1A1204);
  static const Color errorColor = Color(0xFFFF6B6B);

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.dark,
    ).copyWith(
      primary: accentColor,
      onPrimary: onAccentColor,
      secondary: accentColor,
      surface: surfaceColor,
      onSurface: Colors.white,
      error: errorColor,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
    );

    final textTheme = base.textTheme
        .apply(bodyColor: Colors.white.withValues(alpha: 0.92), displayColor: Colors.white)
        .copyWith(
          headlineSmall: base.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
          titleLarge: base.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          titleMedium: base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          labelLarge: base.textTheme.labelLarge?.copyWith(
            letterSpacing: 0.8,
            fontWeight: FontWeight.w600,
          ),
        );

    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        titleTextStyle: textTheme.titleLarge,
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
      dividerColor: Colors.white12,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        border: outlineBorder,
        enabledBorder: outlineBorder,
        focusedBorder: outlineBorder.copyWith(
          borderSide: const BorderSide(color: accentColor, width: 1.5),
        ),
        errorBorder: outlineBorder.copyWith(
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIconColor: accentColor,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: onAccentColor,
          disabledBackgroundColor: accentColor.withValues(alpha: 0.35),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accentColor),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? accentColor : Colors.white70,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? accentColor.withValues(alpha: 0.4)
              : Colors.white24,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: accentColor),
    );
  }
}
