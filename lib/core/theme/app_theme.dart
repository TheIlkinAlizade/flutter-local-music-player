import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        surface: AppColors.surface,
        primary: AppColors.accentBlue,
        secondary: AppColors.accentYellow,
        error: AppColors.accentRed,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ).copyWith(
        bodySmall: base.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accentBlue,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.accentBlue,
        overlayColor: AppColors.accentBlue.withValues(alpha: 0.2),
        trackHeight: 4,
      ),
      dividerColor: AppColors.border,
      splashFactory: NoSplash.splashFactory,
      hoverColor: AppColors.border,
    );
  }
}