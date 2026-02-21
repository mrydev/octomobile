import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF6C5CE7); // Modern purple
  static const Color secondaryColor = Color(0xFF00CEC9); // Teal accent

  static const Color backgroundColor = Color(
    0xFF14141A,
  ); // Deep dark background
  static const Color surfaceColor = Color(
    0xFF1E1E28,
  ); // Slightly lighter for cards
  static const Color surfaceHighlight = Color(
    0xFF2D2D3A,
  ); // For hovered/active states

  static const Color textPrimary = Color(0xFFF1F1F1);
  static const Color textSecondary = Color(0xFFA0A0B0);

  static const Color errorColor = Color(0xFFFF7675);
  static const Color successColor = Color(0xFF55EFC4);
  static const Color warningColor = Color(0xFFFDCB6E);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.outfit(
              color: textPrimary,
              fontWeight: FontWeight.bold,
            ),
            displayMedium: GoogleFonts.outfit(
              color: textPrimary,
              fontWeight: FontWeight.bold,
            ),
            displaySmall: GoogleFonts.outfit(
              color: textPrimary,
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: GoogleFonts.outfit(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
            titleLarge: GoogleFonts.outfit(
              color: textPrimary,
              fontWeight: FontWeight.w600,
            ),
            titleMedium: GoogleFonts.outfit(
              color: textPrimary,
              fontWeight: FontWeight.w500,
            ),
            bodyLarge: GoogleFonts.outfit(color: textPrimary),
            bodyMedium: GoogleFonts.outfit(color: textSecondary),
          ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
