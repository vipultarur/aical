import 'package:flutter/material.dart';

import 'package:calcount/core/constants/app_dimensions.dart';

class AppPageBody extends StatelessWidget {
  const AppPageBody({
    required this.child,
    super.key,
    this.padding,
    this.scrollable = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? AppDimensions.all(24),
      child: child,
    );

    return SafeArea(
      child: scrollable ? SingleChildScrollView(child: content) : content,
    );
  }
}
