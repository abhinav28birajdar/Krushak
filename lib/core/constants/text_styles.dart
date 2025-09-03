// This file is a compatibility layer that re-exports text styles from app_constants.dart
import 'app_constants.dart';

// Re-export for backward compatibility
typedef AppTextStyles = KrushakTextStyles;

// Additional legacy text styles for compatibility
class LegacyTextStyles {
  static const heading1 = KrushakTextStyles.h1;
  static const heading2 = KrushakTextStyles.h2;
  static const heading3 = KrushakTextStyles.h3;
  static const subheading = KrushakTextStyles.h4;
  static const body = KrushakTextStyles.bodyMedium;
  static const caption = KrushakTextStyles.caption;
  static const button = KrushakTextStyles.buttonMedium;
}
