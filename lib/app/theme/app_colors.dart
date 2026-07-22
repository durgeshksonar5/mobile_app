import 'package:flutter/material.dart';

/// Official King Wins light-theme color system.
///
/// All screens and reusable components must use these semantic tokens instead
/// of declaring repeated raw hexadecimal colors.
abstract final class AppColors {
  // Brand colors extracted from the official logo.
  static const Color goldHighlight = Color(0xFFF8D044);
  static const Color mainGold = Color(0xFFE4AA25);
  static const Color midGold = Color(0xFFC58514);
  static const Color darkGold = Color(0xFFA06009);
  static const Color bronze = Color(0xFF773F06);
  static const Color deepBronze = Color(0xFF422106);
  static const Color lightGold = Color(0xFFF4E57C);
  static const Color softGold = Color(0xFFFBF7CB);

  // Light-theme surfaces.
  static const Color background = Color(0xFFFFF9E8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceGold = Color(0xFFFFF4D6);

  // Text.
  static const Color textPrimary = Color(0xFF1A1408);
  static const Color textSecondary = Color(0xFF5A4421);
  static const Color textMuted = Color(0xFF7A6A4B);

  // Borders and disabled states.
  static const Color border = Color(0xFFE7D5A2);
  static const Color divider = Color(0xFFEDE2C6);
  static const Color disabledBackground = Color(0xFFE7DFC9);
  static const Color disabledForeground = Color(0xFF978B70);

  // Legacy mappings to preserve compatibility with existing code.
  static const Color primaryGold = mainGold;
  static const Color primaryGoldLight = lightGold;
  static const Color primaryGoldDark = darkGold;
  static const Color primaryGoldBg = Color(0x1AE4AA25); // 10% opacity

  static const Color backgroundLight = background;
  static const Color surfaceWhite = surface;
  static const Color surfaceDark = surfaceGold;
  static const Color blockedBg = background;

  static const Color textDark = textPrimary;
  static const Color textWhite = Color(0xFFFFFFFF);

  static const Color borderLight = border;
  static const Color borderMedium = border;

  // Status & Outcome Badges (functional semantic colors are preserved).
  static const Color statusGreen = Color(0xFF16A34A);
  static const Color statusRed = Color(0xFFBA1F1F);
  static const Color statusAmber = Color(0xFFF59E0B);

  static const Color statusGreenBg = Color(0xFFF0FDF4);
  static const Color statusRedBg = Color(0xFFFEF2F2);
  static const Color statusAmberBg = Color(0xFFFFFBEB);
}
