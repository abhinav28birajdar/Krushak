import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

/// Krushak App Theme Configuration
class AppTheme {
  AppTheme._();

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: KrushakColors.primaryGreen,
        onPrimary: KrushakColors.white,
        secondary: KrushakColors.secondaryGreen,
        onSecondary: KrushakColors.white,
        tertiary: KrushakColors.accentTeal,
        onTertiary: KrushakColors.white,
        error: KrushakColors.error,
        onError: KrushakColors.white,
        surface: KrushakColors.white,
        onSurface: KrushakColors.darkGray,
        background: KrushakColors.backgroundLight,
        onBackground: KrushakColors.darkGray,
        outline: KrushakColors.lightGray,
        surfaceVariant: KrushakColors.backgroundLight,
        onSurfaceVariant: KrushakColors.mediumGray,
      ),

      // Typography
      textTheme: _buildTextTheme(),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: KrushakColors.primaryGreen,
        foregroundColor: KrushakColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: KrushakTextStyles.onPrimary(KrushakTextStyles.h5),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(
          color: KrushakColors.white,
          size: KrushakIconSizes.md,
        ),
        actionsIconTheme: const IconThemeData(
          color: KrushakColors.white,
          size: KrushakIconSizes.md,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: KrushakColors.cardBackground,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KrushakRadius.card),
        ),
        margin: const EdgeInsets.all(KrushakSpacing.sm),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KrushakColors.primaryGreen,
          foregroundColor: KrushakColors.white,
          textStyle: KrushakTextStyles.buttonLarge,
          minimumSize: const Size(double.infinity, KrushakSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KrushakRadius.button),
          ),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KrushakColors.primaryGreen,
          textStyle: KrushakTextStyles.buttonLarge,
          minimumSize: const Size(double.infinity, KrushakSpacing.buttonHeight),
          side: const BorderSide(color: KrushakColors.primaryGreen, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KrushakRadius.button),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KrushakColors.primaryGreen,
          textStyle: KrushakTextStyles.buttonMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KrushakRadius.button),
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: KrushakColors.accentTeal,
        foregroundColor: KrushakColors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KrushakColors.backgroundWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KrushakRadius.input),
          borderSide: const BorderSide(color: KrushakColors.lightGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KrushakRadius.input),
          borderSide: const BorderSide(color: KrushakColors.lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KrushakRadius.input),
          borderSide: const BorderSide(
            color: KrushakColors.primaryGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KrushakRadius.input),
          borderSide: const BorderSide(color: KrushakColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KrushakRadius.input),
          borderSide: const BorderSide(color: KrushakColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KrushakRadius.input),
          borderSide: const BorderSide(color: KrushakColors.disabled),
        ),
        labelStyle: KrushakTextStyles.labelMedium,
        hintStyle: KrushakTextStyles.bodyMedium.copyWith(
          color: KrushakColors.mediumGray,
        ),
        errorStyle: KrushakTextStyles.caption.copyWith(
          color: KrushakColors.error,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KrushakSpacing.md,
          vertical: KrushakSpacing.md,
        ),
      ),

      // Bottom Navigation Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: KrushakColors.white,
        selectedItemColor: KrushakColors.primaryGreen,
        unselectedItemColor: KrushakColors.mediumGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: KrushakColors.backgroundLight,
        deleteIconColor: KrushakColors.mediumGray,
        disabledColor: KrushakColors.disabled,
        selectedColor: KrushakColors.primaryGreen,
        secondarySelectedColor: KrushakColors.secondaryGreen,
        labelPadding: const EdgeInsets.symmetric(
          horizontal: KrushakSpacing.sm,
          vertical: KrushakSpacing.xs,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: KrushakSpacing.md,
          vertical: KrushakSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KrushakRadius.md),
        ),
        labelStyle: KrushakTextStyles.labelMedium,
        secondaryLabelStyle: KrushakTextStyles.labelMedium.copyWith(
          color: KrushakColors.white,
        ),
        brightness: Brightness.light,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return KrushakColors.primaryGreen;
          }
          return KrushakColors.lightGray;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return KrushakColors.primaryGreenOpacity(0.3);
          }
          return KrushakColors.disabled;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return KrushakColors.primaryGreen;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(KrushakColors.white),
        side: const BorderSide(color: KrushakColors.primaryGreen, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KrushakRadius.sm),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return KrushakColors.primaryGreen;
          }
          return KrushakColors.lightGray;
        }),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: KrushakColors.accentTeal,
        linearTrackColor: KrushakColors.lightGray,
        circularTrackColor: KrushakColors.lightGray,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: KrushakColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KrushakRadius.modal),
        ),
        titleTextStyle: KrushakTextStyles.h5,
        contentTextStyle: KrushakTextStyles.bodyMedium,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: KrushakColors.darkGray,
        contentTextStyle: KrushakTextStyles.bodyMedium.copyWith(
          color: KrushakColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KrushakRadius.sm),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: KrushakColors.darkGray,
        size: KrushakIconSizes.md,
      ),

      primaryIconTheme: const IconThemeData(
        color: KrushakColors.white,
        size: KrushakIconSizes.md,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: KrushakColors.lightGray,
        thickness: 1,
        space: 1,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KrushakSpacing.md,
          vertical: KrushakSpacing.sm,
        ),
        titleTextStyle: KrushakTextStyles.bodyLarge,
        subtitleTextStyle: KrushakTextStyles.bodyMedium.copyWith(
          color: KrushakColors.mediumGray,
        ),
        leadingAndTrailingTextStyle: KrushakTextStyles.labelMedium,
        iconColor: KrushakColors.primaryGreen,
        textColor: KrushakColors.darkGray,
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: KrushakColors.primaryGreen,
        unselectedLabelColor: KrushakColors.mediumGray,
        labelStyle: KrushakTextStyles.labelLarge,
        unselectedLabelStyle: KrushakTextStyles.labelMedium,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: KrushakColors.primaryGreen, width: 2),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // Expansion Tile Theme
      expansionTileTheme: const ExpansionTileThemeData(
        backgroundColor: KrushakColors.backgroundLight,
        collapsedBackgroundColor: KrushakColors.white,
        iconColor: KrushakColors.primaryGreen,
        collapsedIconColor: KrushakColors.mediumGray,
        textColor: KrushakColors.darkGray,
        collapsedTextColor: KrushakColors.darkGray,
      ),

      // Material State
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Platform brightness
      platform: TargetPlatform.android,
    );
  }

  /// Dark Theme Configuration (Optional - for future implementation)
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: KrushakColors.secondaryGreen,
        onPrimary: KrushakColors.darkGray,
        secondary: KrushakColors.accentTeal,
        onSecondary: KrushakColors.darkGray,
        surface: Color(0xFF1E1E1E),
        onSurface: KrushakColors.white,
        background: Color(0xFF121212),
        onBackground: KrushakColors.white,
        error: KrushakColors.error,
        onError: KrushakColors.white,
      ),
    );
  }

  /// Build custom text theme
  static TextTheme _buildTextTheme() {
    return TextTheme(
      // Display styles
      displayLarge: KrushakTextStyles.h1,
      displayMedium: KrushakTextStyles.h2,
      displaySmall: KrushakTextStyles.h3,

      // Headline styles
      headlineLarge: KrushakTextStyles.h1,
      headlineMedium: KrushakTextStyles.h2,
      headlineSmall: KrushakTextStyles.h3,

      // Title styles
      titleLarge: KrushakTextStyles.h4,
      titleMedium: KrushakTextStyles.h5,
      titleSmall: KrushakTextStyles.h6,

      // Body styles
      bodyLarge: KrushakTextStyles.bodyLarge,
      bodyMedium: KrushakTextStyles.bodyMedium,
      bodySmall: KrushakTextStyles.bodySmall,

      // Label styles
      labelLarge: KrushakTextStyles.labelLarge,
      labelMedium: KrushakTextStyles.labelMedium,
      labelSmall: KrushakTextStyles.labelSmall,
    );
  }
}

/// Custom Gradient Decorations
class KrushakGradients {
  KrushakGradients._();

  static const LinearGradient primary = LinearGradient(
    colors: KrushakColors.primaryGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accent = LinearGradient(
    colors: KrushakColors.accentGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient background = LinearGradient(
    colors: KrushakColors.backgroundGradient,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient cardShadow = RadialGradient(
    colors: [Color(0x1A000000), Colors.transparent],
    radius: 1.0,
  );
}
