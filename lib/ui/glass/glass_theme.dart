import 'package:flutter/material.dart';

/// Shared shape, spacing, and color tokens for the glass UI.
abstract final class AppGlassTheme {
  static const pagePadding = EdgeInsets.fromLTRB(20, 4, 20, 20);

  /// 8 — progress tracks, tiny controls
  static const radiusXs = 8.0;

  /// 12 — buttons, chips, inputs, icon buttons
  static const radiusSm = 12.0;

  /// 16 — cards, list rows, default panels
  static const radiusMd = 16.0;

  /// 24 — hero stats, sheets, dialogs
  static const radiusLg = 24.0;

  /// 32 — large empty states (optional overrides)
  static const radiusXl = 32.0;

  /// Pill / dock / FAB capsules
  static const radiusFull = 999.0;

  static BorderRadius border(double radius) => BorderRadius.circular(radius);

  static const navDockHeight = 58.0;
  static const navDockHorizontalMargin = 24.0;
  static const navDockBottomMargin = 14.0;

  /// Space reserved above the floating dock (safe area + dock + breathing room).
  static double navContentInset(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return navDockHeight + navDockBottomMargin + bottom + 20;
  }

  static const _lightAccent = Color(0xFF3D6FD9);
  static const _darkAccent = Color(0xFF7EB4FF);
  static const _lightSecondary = Color(0xFF2BA88C);
  static const _darkSecondary = Color(0xFF5ED4C0);

  static ThemeData material({required bool isDark}) {
    final accent = isDark ? _darkAccent : _lightAccent;
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      dividerColor: Colors.white.withValues(alpha: isDark ? 0.08 : 0.35),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }

  static TextStyle pageTitle(BuildContext context, {required bool isDark}) {
    return TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.8,
      height: 1.05,
      color: isDark ? Colors.white : const Color(0xFF152440),
    );
  }

  static TextStyle pageSubtitle(BuildContext context, {required bool isDark}) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.4,
      color: (isDark ? Colors.white : const Color(0xFF1A2A44)).withValues(alpha: 0.58),
    );
  }

  static TextStyle sectionEyebrow(BuildContext context, {required bool isDark}) {
    return TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.1,
      color: accent(isDark).withValues(alpha: 0.85),
    );
  }

  static List<Color> backdropGradient(bool isDark) {
    if (isDark) {
      return const [
        Color(0xFF0A0E14),
        Color(0xFF142036),
        Color(0xFF0E1A28),
        Color(0xFF101628),
      ];
    }
    return const [
      Color(0xFFCFE0FF),
      Color(0xFFE6DEFF),
      Color(0xFFD0F0E8),
      Color(0xFFE8F0FF),
    ];
  }

  static Color accent(bool isDark) => isDark ? _darkAccent : _lightAccent;

  static Color secondary(bool isDark) => isDark ? _darkSecondary : _lightSecondary;
}

extension GlassPalette on BuildContext {
  bool get glassIsDark => Theme.of(this).brightness == Brightness.dark;

  Color get glassAccent => AppGlassTheme.accent(glassIsDark);

  Color get glassSecondary => AppGlassTheme.secondary(glassIsDark);

  Color get glassFill =>
      glassIsDark ? const Color(0xFF1C2230) : const Color(0xFFF8FAFD);

  Color get glassFillStrong =>
      glassIsDark ? const Color(0xFF262E40) : Colors.white;

  Color get glassBorder =>
      glassIsDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.06);

  Color get glassBorderStrong =>
      glassIsDark ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.9);

  List<BoxShadow> glassShadow({bool prominent = false}) {
    if (glassIsDark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: prominent ? 0.42 : 0.28),
          blurRadius: prominent ? 20 : 12,
          offset: Offset(0, prominent ? 10 : 5),
        ),
      ];
    }
    return [
      BoxShadow(
        color: glassAccent.withValues(alpha: prominent ? 0.16 : 0.09),
        blurRadius: prominent ? 24 : 14,
        offset: Offset(0, prominent ? 12 : 6),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }
}
