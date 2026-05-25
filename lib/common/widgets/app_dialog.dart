import 'package:flutter/material.dart';

import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';

/// Shared dialog entrypoints for confirm, info, error, and custom flows.
abstract final class AppDialog {
  static Future<T?> showCustom<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    final colors = context.colors;

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            title,
            style: AppTypography.headingMd(color: colors.onSurface),
          ),
          content: content,
          actions: actions,
        );
      },
    );
  }

  static Future<bool?> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDanger = false,
  }) {
    return showCustom<bool>(
      context,
      title: title,
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: isDanger
              ? FilledButton.styleFrom(
                  backgroundColor: context.colors.error,
                  foregroundColor: context.colors.onError,
                )
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    );
  }

  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String message,
    String buttonLabel = 'OK',
  }) {
    return showCustom<void>(
      context,
      title: title,
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(buttonLabel),
        ),
      ],
    );
  }

  static Future<void> showError(
    BuildContext context, {
    required String title,
    required String message,
    String buttonLabel = 'Dismiss',
  }) {
    return showInfo(
      context,
      title: title,
      message: message,
      buttonLabel: buttonLabel,
    );
  }
}
