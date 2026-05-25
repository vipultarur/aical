import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:calcount/core/constants/app_dimensions.dart';

/// Central responsive typography styles used throughout the app.
abstract final class AppTypography {
  static TextStyle displayXl({Color? color}) => GoogleFonts.bricolageGrotesque(
    fontSize: AppDimensions.font(48),
    height: 1.08,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.5,
    color: color,
  );

  static TextStyle displayLg({Color? color}) => GoogleFonts.bricolageGrotesque(
    fontSize: AppDimensions.font(36),
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    color: color,
  );

  static TextStyle displayMd({Color? color}) => GoogleFonts.bricolageGrotesque(
    fontSize: AppDimensions.font(28),
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    color: color,
  );

  static TextStyle headingXl({Color? color}) => GoogleFonts.bricolageGrotesque(
    fontSize: AppDimensions.font(24),
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: color,
  );

  static TextStyle headingLg({Color? color}) => GoogleFonts.bricolageGrotesque(
    fontSize: AppDimensions.font(20),
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle headingMd({Color? color}) => GoogleFonts.bricolageGrotesque(
    fontSize: AppDimensions.font(17),
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle headingSm({Color? color}) => GoogleFonts.bricolageGrotesque(
    fontSize: AppDimensions.font(15),
    height: 1.33,
    fontWeight: FontWeight.w600,
    color: color,
  );

  static TextStyle bodyLg({Color? color, FontWeight? fontWeight}) =>
      GoogleFonts.dmSans(
        fontSize: AppDimensions.font(16),
        height: 1.5,
        fontWeight: fontWeight ?? FontWeight.w400,
        letterSpacing: 0.1,
        color: color,
      );

  static TextStyle bodyMd({Color? color, FontWeight? fontWeight}) =>
      GoogleFonts.dmSans(
        fontSize: AppDimensions.font(14),
        height: 1.4,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color,
      );

  static TextStyle bodySm({Color? color, FontWeight? fontWeight}) =>
      GoogleFonts.dmSans(
        fontSize: AppDimensions.font(12),
        height: 1.33,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color,
      );

  static TextStyle labelLg({Color? color, FontWeight? fontWeight}) =>
      GoogleFonts.dmSans(
        fontSize: AppDimensions.font(14),
        height: 1.28,
        fontWeight: fontWeight ?? FontWeight.w500,
        letterSpacing: 0.1,
        color: color,
      );

  static TextStyle labelMd({Color? color}) => GoogleFonts.dmSans(
    fontSize: AppDimensions.font(12),
    height: 1.33,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle labelSm({Color? color}) => GoogleFonts.dmSans(
    fontSize: AppDimensions.font(10),
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle numeralHero({Color? color}) =>
      GoogleFonts.bricolageGrotesque(
        fontSize: AppDimensions.font(64),
        height: 1.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -2.0,
        color: color,
      );

  static TextStyle numeralLg({Color? color}) => GoogleFonts.bricolageGrotesque(
    fontSize: AppDimensions.font(32),
    height: 1.12,
    fontWeight: FontWeight.w600,
    letterSpacing: -1.0,
    color: color,
  );

  static TextStyle numeralMd({Color? color}) => GoogleFonts.jetBrainsMono(
    fontSize: AppDimensions.font(24),
    height: 1.16,
    fontWeight: FontWeight.w500,
    color: color,
  );

  static TextStyle numeralSm({Color? color}) => GoogleFonts.jetBrainsMono(
    fontSize: AppDimensions.font(14),
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: color,
  );
}
