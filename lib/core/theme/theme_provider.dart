import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

enum AppThemeMode { light, dark, system }

class ThemeState {
  final AppThemeMode themeMode;
  final bool isDarkMode;

  const ThemeState({required this.themeMode, required this.isDarkMode});

  ThemeState copyWith({AppThemeMode? themeMode, bool? isDarkMode}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier()
    : super(
        const ThemeState(themeMode: AppThemeMode.system, isDarkMode: false),
      ) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode') ?? AppThemeMode.system.index;
    final themeMode = AppThemeMode.values[themeIndex];

    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDarkMode =
        themeMode == AppThemeMode.dark ||
        (themeMode == AppThemeMode.system && brightness == Brightness.dark);

    state = ThemeState(themeMode: themeMode, isDarkMode: isDarkMode);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);

    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final isDarkMode =
        mode == AppThemeMode.dark ||
        (mode == AppThemeMode.system && brightness == Brightness.dark);

    state = state.copyWith(themeMode: mode, isDarkMode: isDarkMode);
  }

  void toggleTheme() {
    final newMode = state.isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    setThemeMode(newMode);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

// Theme data providers
final lightThemeProvider = Provider<ThemeData>((ref) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: KrushakColors.primaryGreen,
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: KrushakColors.primaryGreen,
      foregroundColor: KrushakColors.white,
      elevation: 0,
      titleTextStyle: KrushakTextStyles.h4.copyWith(color: KrushakColors.white),
    ),
    cardTheme: CardThemeData(
      color: KrushakColors.backgroundWhite,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KrushakRadius.md),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: KrushakColors.primaryGreen,
        foregroundColor: KrushakColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KrushakRadius.md),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KrushakRadius.md),
        borderSide: const BorderSide(color: KrushakColors.lightGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KrushakRadius.md),
        borderSide: const BorderSide(
          color: KrushakColors.primaryGreen,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: KrushakColors.backgroundWhite,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: KrushakColors.backgroundWhite,
      selectedItemColor: KrushakColors.primaryGreen,
      unselectedItemColor: KrushakColors.mediumGray,
      type: BottomNavigationBarType.fixed,
    ),
  );
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: KrushakColors.primaryGreen,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF2D2D2D),
      foregroundColor: KrushakColors.white,
      elevation: 0,
      titleTextStyle: KrushakTextStyles.h4.copyWith(color: KrushakColors.white),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF2D2D2D),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KrushakRadius.md),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: KrushakColors.secondaryGreen,
        foregroundColor: KrushakColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KrushakRadius.md),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KrushakRadius.md),
        borderSide: const BorderSide(color: Color(0xFF404040)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(KrushakRadius.md),
        borderSide: const BorderSide(
          color: KrushakColors.secondaryGreen,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: const Color(0xFF2D2D2D),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF2D2D2D),
      selectedItemColor: KrushakColors.secondaryGreen,
      unselectedItemColor: Color(0xFF808080),
      type: BottomNavigationBarType.fixed,
    ),
  );
});

final currentThemeProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(themeProvider);
  return themeState.isDarkMode
      ? ref.read(darkThemeProvider)
      : ref.read(lightThemeProvider);
});
