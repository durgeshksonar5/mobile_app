import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized King Win typography styles.
class AppTypography {
  static const TextStyle headerTitle = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w800,
    color: AppColors.textWhite,
    letterSpacing: 0.5,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    letterSpacing: 0.3,
  );

  static const TextStyle resultValue = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryGold,
    letterSpacing: 1.2,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle badgeLabel = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
}
