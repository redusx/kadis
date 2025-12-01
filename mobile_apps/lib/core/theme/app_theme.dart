import 'package:flutter/material.dart';

class AppTheme {
  // Colors from JSON spec
  static const Color background = Color(0xFF000000);
  static const Color foreground = Color(0xFFFFFFFF);
  static const Color stroke = Color(0xFFFFFFFF);
  static const Color buttonBg = Color(0xFFFFFFFF);
  static const Color buttonText = Color(0xFF000000);

  // Spacing constants
  static const double defaultPadding = 16.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 20.0;
  static const double borderRadius = 12.0;
  static const double strokeThin = 1.0;
  static const double startEndPadding = 4.0;


  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        surface: background,
        primary: foreground,
        onPrimary: buttonText,
        secondary: foreground,
        onSecondary: background,
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: foreground),
        bodyMedium: TextStyle(color: foreground),
        bodySmall: TextStyle(color: foreground),
        titleLarge: TextStyle(color: foreground, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: foreground, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: foreground),
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: foreground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: stroke, width: strokeThin),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: foreground, width: 2),
        ),
        labelStyle: const TextStyle(color: foreground),
        hintStyle: TextStyle(color: foreground.withOpacity(0.5)),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBg,
          foregroundColor: buttonText,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: const BorderSide(color: stroke, width: strokeThin),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: foreground,
          textStyle: const TextStyle(fontSize: 14),
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: const BorderSide(color: stroke, width: strokeThin),
        ),
        margin: const EdgeInsets.symmetric(vertical: spacingSmall, horizontal: 0),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: foreground,
        unselectedItemColor: foreground,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
