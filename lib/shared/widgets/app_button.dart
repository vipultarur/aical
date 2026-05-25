import 'package:flutter/material.dart';

import 'package:calcount/core/constants/app_dimensions.dart';
import 'package:calcount/core/theme/app_theme.dart';
import 'package:calcount/core/theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, outlined, text, danger, icon }

/// Reusable button wrapper for the common action styles used in the app.
class AppButton extends StatelessWidget {
  const AppButton._({
    required this.label,
    required this.onPressed,
    required this.variant,
    super.key,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.isExpanded = true,
    this.width,
  });

  const AppButton.primary({
    required String label,
    required VoidCallback? onPressed,
    Key? key,
    Widget? icon,
    bool isLoading = false,
    bool isDisabled = false,
    bool isExpanded = true,
    double? width,
  }) : this._(
         label: label,
         onPressed: onPressed,
         variant: AppButtonVariant.primary,
         key: key,
         icon: icon,
         isLoading: isLoading,
         isDisabled: isDisabled,
         isExpanded: isExpanded,
         width: width,
       );

  const AppButton.secondary({
    required String label,
    required VoidCallback? onPressed,
    Key? key,
    Widget? icon,
    bool isLoading = false,
    bool isDisabled = false,
    bool isExpanded = true,
    double? width,
  }) : this._(
         label: label,
         onPressed: onPressed,
         variant: AppButtonVariant.secondary,
         key: key,
         icon: icon,
         isLoading: isLoading,
         isDisabled: isDisabled,
         isExpanded: isExpanded,
         width: width,
       );

  const AppButton.outlined({
    required String label,
    required VoidCallback? onPressed,
    Key? key,
    Widget? icon,
    bool isLoading = false,
    bool isDisabled = false,
    bool isExpanded = true,
    double? width,
  }) : this._(
         label: label,
         onPressed: onPressed,
         variant: AppButtonVariant.outlined,
         key: key,
         icon: icon,
         isLoading: isLoading,
         isDisabled: isDisabled,
         isExpanded: isExpanded,
         width: width,
       );

  const AppButton.text({
    required String label,
    required VoidCallback? onPressed,
    Key? key,
    Widget? icon,
    bool isLoading = false,
    bool isDisabled = false,
    bool isExpanded = true,
    double? width,
  }) : this._(
         label: label,
         onPressed: onPressed,
         variant: AppButtonVariant.text,
         key: key,
         icon: icon,
         isLoading: isLoading,
         isDisabled: isDisabled,
         isExpanded: isExpanded,
         width: width,
       );

  const AppButton.danger({
    required String label,
    required VoidCallback? onPressed,
    Key? key,
    Widget? icon,
    bool isLoading = false,
    bool isDisabled = false,
    bool isExpanded = true,
    double? width,
  }) : this._(
         label: label,
         onPressed: onPressed,
         variant: AppButtonVariant.danger,
         key: key,
         icon: icon,
         isLoading: isLoading,
         isDisabled: isDisabled,
         isExpanded: isExpanded,
         width: width,
       );

  const AppButton.icon({
    required String label,
    required VoidCallback? onPressed,
    required Widget icon,
    Key? key,
    bool isLoading = false,
    bool isDisabled = false,
    bool isExpanded = true,
    double? width,
  }) : this._(
         label: label,
         onPressed: onPressed,
         variant: AppButtonVariant.icon,
         key: key,
         icon: icon,
         isLoading: isLoading,
         isDisabled: isDisabled,
         isExpanded: isExpanded,
         width: width,
       );

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool isDisabled;
  final bool isExpanded;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveOnPressed = isDisabled || isLoading ? null : onPressed;
    final effectiveWidth = width ?? (isExpanded ? double.infinity : null);
    final inlineStyle = switch (variant) {
      AppButtonVariant.outlined => OutlinedButton.styleFrom(
        minimumSize: Size(0, AppDimensions.buttonHeight),
      ),
      AppButtonVariant.text => TextButton.styleFrom(
        minimumSize: Size(0, AppDimensions.buttonHeight),
      ),
      AppButtonVariant.secondary => ElevatedButton.styleFrom(
        minimumSize: Size(0, AppDimensions.buttonHeight),
        backgroundColor: colors.secondaryContainer,
        foregroundColor: colors.onSecondaryContainer,
      ),
      AppButtonVariant.danger => ElevatedButton.styleFrom(
        minimumSize: Size(0, AppDimensions.buttonHeight),
        backgroundColor: colors.error,
        foregroundColor: colors.onError,
      ),
      _ => ElevatedButton.styleFrom(
        minimumSize: Size(0, AppDimensions.buttonHeight),
      ),
    };
    final child = _ButtonChild(
      label: label,
      icon: icon,
      isLoading: isLoading,
      variant: variant,
    );

    final button = switch (variant) {
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: effectiveOnPressed,
        style: inlineStyle,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        style: inlineStyle,
        child: child,
      ),
      AppButtonVariant.secondary => ElevatedButton(
        onPressed: effectiveOnPressed,
        style: inlineStyle,
        child: child,
      ),
      AppButtonVariant.danger => ElevatedButton(
        onPressed: effectiveOnPressed,
        style: inlineStyle,
        child: child,
      ),
      _ => ElevatedButton(
        onPressed: effectiveOnPressed,
        style: inlineStyle,
        child: child,
      ),
    };

    return SizedBox(width: effectiveWidth, child: button);
  }
}

class _ButtonChild extends StatelessWidget {
  const _ButtonChild({
    required this.label,
    required this.variant,
    this.icon,
    this.isLoading = false,
  });

  final String label;
  final AppButtonVariant variant;
  final Widget? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final indicatorColor = switch (variant) {
      AppButtonVariant.outlined || AppButtonVariant.text => colors.primary,
      AppButtonVariant.secondary => colors.onSecondaryContainer,
      AppButtonVariant.danger => colors.onError,
      _ => colors.onPrimary,
    };

    if (isLoading) {
      return SizedBox(
        height: AppDimensions.iconLg,
        width: AppDimensions.iconLg,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
          strokeCap: StrokeCap.round,
        ),
      );
    }

    if (icon == null) {
      return Text(label);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon!,
        SizedBox(width: AppDimensions.sm),
        Text(label, style: AppTypography.labelLg(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
