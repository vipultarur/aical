import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class AppBreakpoints {
  static const double tablet = 600;
  static const double desktop = 1200;
}

/// Central responsive sizing tokens backed by flutter_screenutil.
abstract final class AppDimensions {
  static double get xxs => space(2);
  static double get xs => space(4);
  static double get sm => space(8);
  static double get md => space(12);
  static double get lg => space(16);
  static double get xl => space(20);
  static double get xxl => space(24);
  static double get xxxl => space(32);
  static double get jumbo => space(40);
  static double get hero => space(48);
  static double get giant => space(64);

  static double get radiusXs => radius(4);
  static double get radiusSm => radius(8);
  static double get radiusMd => radius(12);
  static double get radiusLg => radius(16);
  static double get radiusXl => radius(24);
  static const double radiusFull = 999;

  static double get iconSm => icon(16);
  static double get iconMd => icon(20);
  static double get iconLg => icon(24);
  static double get iconXl => icon(32);

  static double get buttonHeight => height(52);
  static double get navBarHeight => height(80);
  static double get bottomBarHeight => height(60);
  static double get fabSize => size(64);
  static double get desktopNavWidth =>
      _capWidth(260, tabletMax: 1.12, desktopMax: 1.22);
  static double get pagePadding => space(24);

  static double space(num value) =>
      _capWidth(value.toDouble(), tabletMax: 1.16, desktopMax: 1.22);

  static double width(num value) =>
      _capWidth(value.toDouble(), tabletMax: 1.18, desktopMax: 1.24);

  static double height(num value) =>
      _capHeight(value.toDouble(), tabletMax: 1.16, desktopMax: 1.2);

  static double size(num value) => math.min(width(value), height(value));

  static double radius(num value) =>
      _capRadius(value.toDouble(), tabletMax: 1.14, desktopMax: 1.18);

  static double icon(num value) =>
      _capRadius(value.toDouble(), tabletMax: 1.15, desktopMax: 1.2);

  static double font(num value) =>
      _capFont(value.toDouble(), tabletMax: 1.12, desktopMax: 1.16);

  static EdgeInsets all(num value) => EdgeInsets.all(space(value));

  static EdgeInsets symmetric({num horizontal = 0, num vertical = 0}) {
    return EdgeInsets.symmetric(
      horizontal: width(horizontal),
      vertical: height(vertical),
    );
  }

  static EdgeInsets only({
    num left = 0,
    num top = 0,
    num right = 0,
    num bottom = 0,
  }) {
    return EdgeInsets.only(
      left: width(left),
      top: height(top),
      right: width(right),
      bottom: height(bottom),
    );
  }

  static BorderRadius circular(num value) =>
      BorderRadius.circular(radius(value));

  static BorderRadius vertical({num top = 0, num bottom = 0}) {
    return BorderRadius.vertical(
      top: Radius.circular(radius(top)),
      bottom: Radius.circular(radius(bottom)),
    );
  }

  static Radius radiusOnly(num value) => Radius.circular(radius(value));

  static double _capWidth(
    double base, {
    required double tabletMax,
    required double desktopMax,
  }) {
    final scaled = base.w;
    final screenWidth = ScreenUtil().screenWidth;

    if (screenWidth >= AppBreakpoints.desktop) {
      return math.min(scaled, base * desktopMax);
    }
    if (screenWidth >= AppBreakpoints.tablet) {
      return math.min(scaled, base * tabletMax);
    }
    return scaled;
  }

  static double _capHeight(
    double base, {
    required double tabletMax,
    required double desktopMax,
  }) {
    final scaled = base.h;
    final screenWidth = ScreenUtil().screenWidth;

    if (screenWidth >= AppBreakpoints.desktop) {
      return math.min(scaled, base * desktopMax);
    }
    if (screenWidth >= AppBreakpoints.tablet) {
      return math.min(scaled, base * tabletMax);
    }
    return scaled;
  }

  static double _capRadius(
    double base, {
    required double tabletMax,
    required double desktopMax,
  }) {
    final scaled = base.r;
    final screenWidth = ScreenUtil().screenWidth;

    if (screenWidth >= AppBreakpoints.desktop) {
      return math.min(scaled, base * desktopMax);
    }
    if (screenWidth >= AppBreakpoints.tablet) {
      return math.min(scaled, base * tabletMax);
    }
    return scaled;
  }

  static double _capFont(
    double base, {
    required double tabletMax,
    required double desktopMax,
  }) {
    final scaled = base.sp;
    final screenWidth = ScreenUtil().screenWidth;

    if (screenWidth >= AppBreakpoints.desktop) {
      return math.min(scaled, base * desktopMax);
    }
    if (screenWidth >= AppBreakpoints.tablet) {
      return math.min(scaled, base * tabletMax);
    }
    return scaled;
  }
}
