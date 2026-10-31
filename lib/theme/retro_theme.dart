import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RetroColors {
  static const Color paperBg = Color(0xFFF5F0E6);
  static const Color cardSurface = Color(0xFFFBF9F5); // Warm off-white paper box
  static const Color ink = Color(0xFF111111);
  static const Color secondaryText = Color(0xFF3D3A30);
  static const Color brandGreen = Color(0xFF1FA34A);
  static const Color deepGreen = Color(0xFF0B7A4B);
  static const Color mint = Color(0xFFBDEFD0);
  static const Color expenseRed = Color(0xFFE5432F);
  static const Color expensePastel = Color(0xFFF6C9BF);
  static const Color infoBluePastel = Color(0xFFA9D3F5);
  static const Color deepNavy = Color(0xFF003366);
  static const Color dividerDashed = Color(0x59111111);
}

class RetroTheme {
  static const BorderSide border2_5 = BorderSide(color: RetroColors.ink, width: 2.5);
  static const BorderSide border2 = BorderSide(color: RetroColors.ink, width: 2.0);

  static const BoxShadow hardShadow = BoxShadow(
    color: RetroColors.ink,
    offset: Offset(3, 4),
    blurRadius: 0,
    spreadRadius: 0,
  );

  static const BoxShadow hardShadowSmall = BoxShadow(
    color: RetroColors.ink,
    offset: Offset(2, 2),
    blurRadius: 0,
    spreadRadius: 0,
  );

  static TextStyle headingStyle({
    double fontSize = 18,
    Color color = RetroColors.ink,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    ).copyWith(
      fontFamilyFallback: const ['Noto Sans Bengali', 'Roboto', 'sans-serif'],
    );
  }

  static TextStyle monoStyle({
    double fontSize = 11,
    Color color = RetroColors.secondaryText,
    FontWeight fontWeight = FontWeight.w700,
    double letterSpacing = 1.5,
  }) {
    return GoogleFonts.spaceMono(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    ).copyWith(
      fontFamilyFallback: const ['Noto Sans Bengali', 'Roboto', 'sans-serif'],
    );
  }

  static ThemeData themeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: RetroColors.paperBg,
    colorScheme: const ColorScheme.light(
      primary: RetroColors.brandGreen,
      surface: RetroColors.paperBg,
      onSurface: RetroColors.ink,
    ),
    textTheme: GoogleFonts.spaceGroteskTextTheme().copyWith(
      bodyMedium: GoogleFonts.spaceGrotesk(
        color: RetroColors.ink,
        fontWeight: FontWeight.w500,
      ).copyWith(
        fontFamilyFallback: const ['Noto Sans Bengali', 'Roboto', 'sans-serif'],
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: RetroColors.paperBg,
      foregroundColor: RetroColors.ink,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 20,
      titleTextStyle: headingStyle(fontSize: 20, fontWeight: FontWeight.w800),
      iconTheme: const IconThemeData(color: RetroColors.ink),
    ),
    cardTheme: CardThemeData(
      color: RetroColors.cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: border2_5,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: RetroColors.brandGreen,
      foregroundColor: RetroColors.ink,
      elevation: 0,
    ),
  );
}
