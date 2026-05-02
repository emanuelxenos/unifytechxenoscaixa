import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ─── Brand Colors ───────────────────────────────────────────
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B83FF);
  static const Color primaryDark = Color(0xFF4B44DB);
  static const Color accentGreen = Color(0xFF00D9A6);
  static const Color accentGreenDark = Color(0xFF00B886);
  static const Color accentRed = Color(0xFFFF5C5C);
  static const Color accentRedDark = Color(0xFFFF3B3B);
  static const Color accentOrange = Color(0xFFFFB74D);
  static const Color accentBlue = Color(0xFF4FC3F7);
  static const Color accentPurple = Color(0xFF9C27B0);

  // ─── Surface Colors ─────────────────────────────────────────
  static const Color background = Color(0xFF0B0E1A);
  static const Color surface = Color(0xFF141829);
  static const Color surfaceVariant = Color(0xFF1C2039);
  static const Color card = Color(0xFF1C2039);
  static const Color primaryContainer = Color(0xFF2D2A5E);

  // ─── Text Colors ────────────────────────────────────────────
  static const Color onBackground = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFFE0E0E8);
  static const Color onSurfaceVariant = Color(0xFF8E92BC);

  // ─── Border/Divider ─────────────────────────────────────────
  static const Color outline = Color(0xFF2A2E4A);
  static const Color divider = Color(0xFF232744);

  // ─── Border Radius ──────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // ─── Spacing ────────────────────────────────────────────────
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // ─── Gradients ──────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4FC3F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00D9A6), Color(0xFF00B886)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFFF5C5C), Color(0xFFFF3B3B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF141829), Color(0xFF1C2039)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Glass Shadows ─────────────────────────────────────────
  static List<BoxShadow> get glassBoxShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> glowShadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.25),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  // ─── Glass Decorations ─────────────────────────────────────
  static BoxDecoration glassCard({Color? borderColor}) => BoxDecoration(
        color: card.withOpacity(0.85),
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(
          color: borderColor ?? outline.withOpacity(0.6),
          width: 1,
        ),
        boxShadow: glassBoxShadow,
      );

  static BoxDecoration glassCardHighlight({required Color accentColor}) =>
      BoxDecoration(
        color: card.withOpacity(0.85),
        borderRadius: BorderRadius.circular(radiusLg),
        border: Border.all(
          color: accentColor.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration glassInput() => BoxDecoration(
        color: surfaceVariant,
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: outline, width: 1),
      );

  // ─── ThemeData ──────────────────────────────────────────────
  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        primaryContainer: primaryContainer,
        secondary: accentGreen,
        surface: surface,
        surfaceContainerHighest: surfaceVariant,
        error: accentRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
      ),
      cardColor: card,
      dividerColor: divider,
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          color: onBackground,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: textTheme.headlineLarge?.copyWith(
          color: onBackground,
          fontWeight: FontWeight.w700,
          fontSize: 32,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          color: onBackground,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
        headlineSmall: textTheme.headlineSmall?.copyWith(
          color: onBackground,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          color: onBackground,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: onSurface,
          fontSize: 15,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: onSurfaceVariant,
          fontSize: 14,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: onSurfaceVariant,
          fontSize: 12,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          color: onBackground,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          color: onBackground,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: outline, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: outline, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: accentRed),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: onSurfaceVariant.withOpacity(0.5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      iconTheme: const IconThemeData(color: onSurfaceVariant, size: 22),
      dividerTheme: const DividerThemeData(color: divider, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceVariant,
        contentTextStyle: const TextStyle(color: onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: surfaceVariant,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: outline),
        ),
        textStyle: const TextStyle(color: onSurface, fontSize: 12),
      ),
    );
  }
}
