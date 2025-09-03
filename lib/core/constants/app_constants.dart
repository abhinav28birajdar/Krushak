import 'package:flutter/material.dart';

/// Krushak App Color Palette
/// Following the farmer-friendly, nature-inspired design system
class KrushakColors {
  KrushakColors._();

  // Primary Colors (Strict Adherence to Design)
  static const Color primaryGreen = Color(0xFF1E523A); // Deep Forest Green
  static const Color secondaryGreen = Color(0xFF35906A); // Emerald Green
  static const Color accentTeal = Color(0xFF40B0B0); // Tech-oriented Teal

  // Text and UI Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFCCCCCC);
  static const Color mediumGray = Color(0xFF999999);
  static const Color darkGray = Color(0xFF333333);
  static const Color textDark = Color(0xFF333333);
  static const Color grey600 = Color(0xFF757575);

  // Background Colors
  static const Color backgroundLight = Color(
    0xFFF8FDF9,
  ); // Very subtle green tint
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FDF9);

  // Legacy color mappings for compatibility
  static const Color primary = primaryGreen;
  static const Color secondary = secondaryGreen;
  static const Color accent = accentTeal;
  static const Color accentBrown = Color(0xFF8D6E63);
  static const Color secondaryYellow = Color(0xFFFFC107);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Gradient Colors
  static const List<Color> primaryGradient = [primaryGreen, secondaryGreen];
  static const List<Color> accentGradient = [secondaryGreen, accentTeal];
  static const List<Color> backgroundGradient = [
    backgroundLight,
    backgroundWhite,
  ];

  // Card Colors
  static const Color cardBackground = primaryGreen;
  static const Color cardSecondary = secondaryGreen;
  static const Color cardSurface = white;

  // Opacity Variants
  static Color primaryGreenOpacity(double opacity) =>
      primaryGreen.withOpacity(opacity);
  static Color secondaryGreenOpacity(double opacity) =>
      secondaryGreen.withOpacity(opacity);
  static Color accentTealOpacity(double opacity) =>
      accentTeal.withOpacity(opacity);

  // Disabled States
  static const Color disabled = Color(0xFFE0E0E0);
  static const Color disabledText = Color(0xFF9E9E9E);
}

/// Typography System for Krushak App
class KrushakTextStyles {
  KrushakTextStyles._();

  // Font Families
  // static const String primaryFont = 'Montserrat';
  // static const String secondaryFont = 'Lato';

  // Headings - using system fonts
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle h5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle h6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  // Body Text - using system fonts
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // Labels and Captions
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
  );

  // Button Text
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // Legacy style mappings for compatibility
  static const TextStyle heading1 = h1;
  static const TextStyle heading2 = h2;
  static const TextStyle heading3 = h3;
  static const TextStyle heading4 = h4;
  static const TextStyle subheading = h5;
  static const TextStyle body = bodyMedium;
  static const TextStyle subtitle = labelLarge;

  // Color Variants
  static TextStyle onPrimary(TextStyle style) =>
      style.copyWith(color: KrushakColors.white);
  static TextStyle onSecondary(TextStyle style) =>
      style.copyWith(color: KrushakColors.white);
  static TextStyle onSurface(TextStyle style) =>
      style.copyWith(color: KrushakColors.darkGray);
  static TextStyle onBackground(TextStyle style) =>
      style.copyWith(color: KrushakColors.darkGray);
  static TextStyle primary(TextStyle style) =>
      style.copyWith(color: KrushakColors.primaryGreen);
  static TextStyle secondary(TextStyle style) =>
      style.copyWith(color: KrushakColors.secondaryGreen);
  static TextStyle accent(TextStyle style) =>
      style.copyWith(color: KrushakColors.accentTeal);
  static TextStyle disabled(TextStyle style) =>
      style.copyWith(color: KrushakColors.disabledText);
}

/// Spacing and Layout Constants
class KrushakSpacing {
  KrushakSpacing._();

  // Base spacing unit (8dp)
  static const double unit = 8.0;

  // Spacing Scale
  static const double xs = unit * 0.5; // 4
  static const double sm = unit; // 8
  static const double md = unit * 2; // 16
  static const double lg = unit * 3; // 24
  static const double xl = unit * 4; // 32
  static const double xxl = unit * 6; // 48
  static const double xxxl = unit * 8; // 64

  // Layout Margins
  static const double screenHorizontal = md;
  static const double screenVertical = md;
  static const double cardHorizontal = md;
  static const double cardVertical = md;

  // Component Spacing
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  static const double cardMinHeight = 120.0;
  static const double bottomNavHeight = 80.0;
  static const double appBarHeight = 56.0;
}

/// Border Radius Constants
class KrushakRadius {
  KrushakRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double circular = 50.0;

  // Component Specific
  static const double card = md;
  static const double button = lg;
  static const double input = sm;
  static const double modal = lg;
  static const double avatar = circular;
}

/// Shadow and Elevation Constants
class KrushakShadows {
  KrushakShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> cardElevated = [
    BoxShadow(
      color: Color(0x1F000000),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x33000000),
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];
}

/// Animation Duration Constants
class KrushakDurations {
  KrushakDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration splash = Duration(milliseconds: 1500);
}

/// Icon Size Constants
class KrushakIconSizes {
  KrushakIconSizes._();

  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
  static const double xxl = 64.0;
}

/// Z-Index Constants for Overlays
class KrushakZIndex {
  KrushakZIndex._();

  static const int tooltip = 1000;
  static const int modal = 1100;
  static const int toast = 1200;
  static const int loading = 1300;
}

/// Breakpoints for Responsive Design
class KrushakBreakpoints {
  KrushakBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}
