import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Magical, dreamy, playful theme for DreamWeaver
class DreamTheme {
  // ── Primary Colors ──
  static const Color primaryPurple = Color(0xFF6B4CE6);
  static const Color primaryPink = Color(0xFFFF6B9D);
  static const Color primaryBlue = Color(0xFF4ECDC4);

  // ── Background Colors ──
  static const Color deepNight = Color(0xFF0D0B2E);
  static const Color midnightBlue = Color(0xFF1A1550);
  static const Color twilightPurple = Color(0xFF2D2364);
  static const Color softLavender = Color(0xFFF0E6FF);

  // ── Accent Colors ──
  static const Color starYellow = Color(0xFFFFD93D);
  static const Color moonGlow = Color(0xFFFFF3CD);
  static const Color dreamsGreen = Color(0xFF6BCF7F);
  static const Color cloudWhite = Color(0xFFF8F6FF);
  static const Color sleepyPeach = Color(0xFFFFB6A3);
  static const Color magicTeal = Color(0xFF4ECDC4);

  // ── Surface Colors ──
  static const Color cardDark = Color(0xFF1E1854);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color surfaceOverlay = Color(0x33FFFFFF);

  // ── Text Colors ──
  static const Color textLight = Color(0xFFF8F6FF);
  static const Color textLightSecondary = Color(0xBBF8F6FF);
  static const Color textDark = Color(0xFF1A1550);
  static const Color textDarkSecondary = Color(0xFF6B6B8D);

  // ── Gradient Definitions ──
  static const LinearGradient nightSkyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [deepNight, midnightBlue, twilightPurple],
  );

  static const LinearGradient magicGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, primaryPink],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B9D), Color(0xFFFFB347), starYellow],
  );

  static const LinearGradient dreamGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A0533),
      Color(0xFF2D1B69),
      Color(0xFF4A2C8A),
      Color(0xFF7B4EBF),
    ],
  );

  // ── Box Shadows ──
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryPurple.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primaryPurple.withOpacity(0.4),
      blurRadius: 30,
      spreadRadius: 2,
    ),
  ];

  // ── Theme Data ──
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: deepNight,
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: primaryPink,
        tertiary: magicTeal,
        surface: cardDark,
        error: Color(0xFFFF6B6B),
        onPrimary: textLight,
        onSecondary: textLight,
        onSurface: textLight,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textLight,
        ),
        iconTheme: IconThemeData(color: textLight),
      ),
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: textLight,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryPurple,
          side: const BorderSide(color: primaryPurple, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceOverlay,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: const TextStyle(color: textLightSecondary),
        labelStyle: const TextStyle(color: textLightSecondary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: deepNight,
        selectedItemColor: primaryPurple,
        unselectedItemColor: textLightSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryPurple,
        inactiveTrackColor: primaryPurple.withOpacity(0.2),
        thumbColor: primaryPurple,
        overlayColor: primaryPurple.withOpacity(0.1),
        trackHeight: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceOverlay,
        selectedColor: primaryPurple,
        labelStyle: const TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 13,
          color: textLight,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.quicksand(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: textLight,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.quicksand(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textLight,
      ),
      displaySmall: GoogleFonts.quicksand(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      headlineMedium: GoogleFonts.quicksand(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      headlineSmall: GoogleFonts.quicksand(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      titleLarge: GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
      titleMedium: GoogleFonts.quicksand(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textLight,
      ),
      bodyLarge: GoogleFonts.quicksand(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textLight,
      ),
      bodyMedium: GoogleFonts.quicksand(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textLightSecondary,
      ),
      bodySmall: GoogleFonts.quicksand(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textLightSecondary,
      ),
      labelLarge: GoogleFonts.quicksand(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
    );
  }
}
