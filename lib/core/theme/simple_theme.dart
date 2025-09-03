import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Simple application theme configuration
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: KrushakColors.primaryGreen,
        brightness: Brightness.light,
        primary: KrushakColors.primaryGreen,
        secondary: KrushakColors.accentTeal,
        surface: Colors.white,
        onSurface: Colors.black87,
        error: Colors.red.shade600,
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: KrushakColors.primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KrushakColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KrushakColors.primaryGreen,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: KrushakColors.primaryGreen,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: KrushakColors.primaryGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
