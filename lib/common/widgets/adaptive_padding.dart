import 'package:flutter/material.dart';

import 'package:calcount/core/constants/app_dimensions.dart';

class AdaptivePadding extends StatelessWidget {
  final Widget child;

  const AdaptivePadding({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width >= AppBreakpoints.tablet
        ? AppDimensions.space(24)
        : AppDimensions.space(16);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      child: child,
    );
  }
}
