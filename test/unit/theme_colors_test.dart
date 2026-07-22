import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:king_wins_mobile_app/app/theme/app_colors.dart';
import 'package:king_wins_mobile_app/app/theme/app_theme.dart';

void main() {
  group('King Wins Light Gold Theme Color Tests', () {
    test('AppColors tokens match visual spec', () {
      expect(AppColors.background, const Color(0xFFFFF9E8));
      expect(AppColors.surface, const Color(0xFFFFFFFF));
      expect(AppColors.mainGold, const Color(0xFFE4AA25));
      expect(AppColors.textPrimary, const Color(0xFF1A1408));
      expect(AppColors.darkGold, const Color(0xFFA06009));
      expect(AppColors.statusRed, const Color(0xFFBA1F1F));
      expect(AppColors.statusGreen, const Color(0xFF16A34A));
      expect(AppColors.divider, const Color(0xFFEDE2C6));
    });

    test('ThemeData mapping aligns with light theme design tokens', () {
      final theme = AppTheme.lightTheme;
      
      // Scaffold Background
      expect(theme.scaffoldBackgroundColor, AppColors.background);

      // ColorScheme mapping
      expect(theme.colorScheme.brightness, Brightness.light);
      expect(theme.colorScheme.primary, AppColors.mainGold);
      expect(theme.colorScheme.onPrimary, AppColors.textPrimary);
      expect(theme.colorScheme.secondary, AppColors.darkGold);
      expect(theme.colorScheme.surface, AppColors.surface);
      expect(theme.colorScheme.onSurface, AppColors.textPrimary);
      expect(theme.colorScheme.error, AppColors.statusRed);

      // Input Decoration Theme
      final focusedBorder = theme.inputDecorationTheme.focusedBorder as OutlineInputBorder;
      expect(focusedBorder.borderSide.color, AppColors.darkGold);

      // Bottom Navigation Bar Theme
      expect(theme.bottomNavigationBarTheme.selectedItemColor, AppColors.darkGold);
      expect(theme.bottomNavigationBarTheme.unselectedItemColor, AppColors.textMuted);
    });
  });
}
