import 'package:flutter/material.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/constants/app_durations.dart';
import 'package:calcount/core/theme/app_colors.dart';

enum AppSnackBarType { success, error, info, warning }

/// App-wide snackbar facade with consistent colors and defaults.
abstract final class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    SnackBarAction? action,
    Duration duration = AppDurations.breathe,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: AppDimensions.font(14),
          ),
        ),
        backgroundColor: _backgroundColor(type),
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: AppDimensions.circular(16)),
        margin: EdgeInsets.fromLTRB(
          AppDimensions.width(16),
          0,
          AppDimensions.width(16),
          AppDimensions.height(24),
        ),
      ),
    );
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
    SnackBarAction? action,
    Duration duration = AppDurations.breathe,
  }) {
    show(
      context,
      message: message,
      type: AppSnackBarType.success,
      action: action,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    SnackBarAction? action,
    Duration duration = AppDurations.breathe,
  }) {
    show(
      context,
      message: message,
      type: AppSnackBarType.error,
      action: action,
      duration: duration,
    );
  }

  static Color _backgroundColor(AppSnackBarType type) {
    return switch (type) {
      AppSnackBarType.success => AppColors.statusSuccess,
      AppSnackBarType.error => AppColors.statusDanger,
      AppSnackBarType.info => AppColors.statusInfo,
      AppSnackBarType.warning => AppColors.statusWarning,
    };
  }
}
