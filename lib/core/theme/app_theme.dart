import 'package:flutter/material.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_colors.dart';
import 'package:calcount/core/theme/app_typography.dart';

abstract final class AppTheme {
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.greenFresh,
    onPrimary: AppColors.neutral0,
    primaryContainer: AppColors.greenPale,
    onPrimaryContainer: AppColors.greenLeaf,
    secondary: AppColors.amberWarm,
    onSecondary: AppColors.neutral0,
    secondaryContainer: AppColors.amberPale,
    onSecondaryContainer: AppColors.neutral900,
    tertiary: AppColors.blueInfo,
    onTertiary: AppColors.neutral0,
    tertiaryContainer: AppColors.blueSoft,
    onTertiaryContainer: AppColors.neutral900,
    error: AppColors.coralAlert,
    onError: AppColors.neutral0,
    errorContainer: AppColors.coralSoft,
    onErrorContainer: AppColors.neutral900,
    surface: AppColors.neutral0,
    onSurface: AppColors.neutral900,
    surfaceContainerHighest: AppColors.neutral100,
    onSurfaceVariant: AppColors.neutral700,
    outline: AppColors.neutral300,
    outlineVariant: AppColors.neutral100,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.greenLight,
    onPrimary: AppColors
        .greenLeaf, // Using existing green since 003300 is just very dark green
    primaryContainer: AppColors.greenDark,
    onPrimaryContainer: AppColors.greenLightPale,
    secondary: AppColors.amberSoft,
    onSecondary: AppColors.amberDark,
    secondaryContainer: AppColors.amberDarkContainer,
    onSecondaryContainer: AppColors.amberLightPale,
    tertiary: AppColors.blueLight,
    onTertiary: AppColors.blueDark,
    tertiaryContainer: AppColors.blueDarkContainer,
    onTertiaryContainer: AppColors.blueLightPale,
    error: AppColors.coralSoft,
    onError: AppColors.coralDark,
    errorContainer: AppColors.coralDarkContainer,
    onErrorContainer: AppColors.coralLightPale,
    surface: AppColors.neutral950,
    onSurface: AppColors.neutral300, // E8E8E8 ~ neutral300
    surfaceContainerHighest: AppColors.neutral925,
    onSurfaceVariant: AppColors.neutral650,
    outline: AppColors.neutral700,
    outlineVariant: AppColors.neutral800,
  );

  static ThemeData get light => _buildTheme(lightColorScheme);
  static ThemeData get dark => _buildTheme(darkColorScheme);

  static ThemeData _buildTheme(ColorScheme colors) {
    final isDark = colors.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: colors.brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
      fontFamily: 'DMSans',
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        iconTheme: IconThemeData(color: colors.onSurface),
        titleTextStyle: AppTypography.headingXl(color: colors.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: isDark
            ? colors.primary.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.circular(12),
          side: isDark
              ? BorderSide(color: colors.outline, width: 1)
              : BorderSide.none,
        ),
        color: colors.surface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        elevation: 8,
        height: AppDimensions.navBarHeight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelMd(color: colors.primary);
          }

          return AppTypography.labelMd(color: colors.onSurfaceVariant);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: AppDimensions.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppDimensions.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppDimensions.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppDimensions.circular(12),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        labelStyle: AppTypography.bodyMd(color: colors.onSurfaceVariant),
        floatingLabelStyle: AppTypography.bodyMd(
          color: colors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(0, AppDimensions.buttonHeight),
          shape: const StadiumBorder(),
          elevation: 0,
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: colors.onSurface.withValues(alpha: 0.38),
          textStyle: AppTypography.labelLg(
            color: colors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(0, AppDimensions.buttonHeight),
          shape: const StadiumBorder(),
          side: BorderSide(color: colors.primary, width: 1.5),
          foregroundColor: colors.primary,
          textStyle: AppTypography.labelLg(
            color: colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: AppTypography.labelLg(
            color: colors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        backgroundColor: Colors.transparent,
        disabledColor: colors.onSurface.withValues(alpha: 0.08),
        selectedColor: colors.primaryContainer,
        secondarySelectedColor: colors.primaryContainer,
        padding: AppDimensions.symmetric(horizontal: 12, vertical: 8),
        side: BorderSide(color: colors.outline, width: 1),
        labelStyle: AppTypography.bodyMd(color: colors.onSurface),
        secondaryLabelStyle: AppTypography.bodyMd(
          color: colors.onPrimaryContainer,
        ),
        brightness: colors.brightness,
      ),
    );
  }
}

extension ThemeContext on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
