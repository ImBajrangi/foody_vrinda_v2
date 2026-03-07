import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Industrial Maximalism Theme for Foody Vrinda v2
/// Design tokens extracted from Stitch HTML references
class AppTheme {
  // ============ COLORS ============

  // Core Palette
  static const Color background = Color(0xFF0D0D0D); // Vantablack
  static const Color surface = Color(0xFF1C1C1E); // Graphite
  static const Color borderDark = Color(0xFF333333); // Industrial Border
  static const Color primary = Color(0xFFFF3B30); // Hyper Red
  static const Color secondary = Color(0xFFFF9500); // Yolk Orange
  static const Color success = Color(0xFF30D158); // Matrix Green

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textMuted = Color(0xFF666666);

  // Status
  static const Color error = Color(0xFFFF453A);
  static const Color warning = Color(0xFFFF9F0A);

  // ============ SHADOWS ============

  static const BoxShadow hardShadow = BoxShadow(
    offset: Offset(4, 4),
    color: Colors.black,
    blurRadius: 0,
    spreadRadius: 0,
  );

  static const BoxShadow redGlowShadow = BoxShadow(
    offset: Offset(4, 4),
    color: Color(0xFFFF3B30),
    blurRadius: 0,
    spreadRadius: 0,
  );

  // ============ RADII ============

  static const double radiusSm = 2.0;
  static const double radiusMd = 4.0;
  static const double radiusLg = 8.0;

  // ============ TYPOGRAPHY HELPERS ============

  static TextStyle get displayLarge => GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => GoogleFonts.spaceGrotesk(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle get headlineLarge => GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle get headlineMedium => GoogleFonts.spaceGrotesk(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle get titleLarge => GoogleFonts.spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.spaceGrotesk(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.spaceGrotesk(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static TextStyle get bodySmall => GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  // Mono styles (JetBrains Mono)
  static TextStyle get monoLarge => GoogleFonts.jetBrainsMono(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: 1.5,
  );

  static TextStyle get monoMedium => GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    letterSpacing: 1.2,
  );

  static TextStyle get monoSmall => GoogleFonts.jetBrainsMono(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    letterSpacing: 1.5,
  );

  static TextStyle get monoPrice => GoogleFonts.jetBrainsMono(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: primary,
    letterSpacing: -0.5,
  );

  // ============ THEME DATA ============

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: textPrimary),
          displayMedium: TextStyle(color: textPrimary),
          displaySmall: TextStyle(color: textPrimary),
          headlineLarge: TextStyle(color: textPrimary),
          headlineMedium: TextStyle(color: textPrimary),
          headlineSmall: TextStyle(color: textPrimary),
          titleLarge: TextStyle(color: textPrimary),
          titleMedium: TextStyle(color: textPrimary),
          titleSmall: TextStyle(color: textSecondary),
          bodyLarge: TextStyle(color: textPrimary),
          bodyMedium: TextStyle(color: textPrimary),
          bodySmall: TextStyle(color: textSecondary),
          labelLarge: TextStyle(color: textPrimary),
          labelMedium: TextStyle(color: textSecondary),
          labelSmall: TextStyle(color: textMuted),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: borderDark),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          color: textSecondary,
          letterSpacing: 1.5,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF181111),
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
        ),
        unselectedLabelStyle: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.5,
        ),
      ),
      dividerTheme: const DividerThemeData(color: borderDark, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: const BorderSide(color: borderDark),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
