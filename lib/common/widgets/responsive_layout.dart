import 'package:flutter/material.dart';

import 'package:calcount/core/constants/app_dimensions.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget phone;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    required this.phone,
    this.tablet,
    this.desktop,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= AppBreakpoints.desktop && desktop != null) return desktop!;
    if (width >= AppBreakpoints.tablet && tablet != null) return tablet!;
    return phone;
  }
}
