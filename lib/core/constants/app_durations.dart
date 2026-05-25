abstract final class AppDurations {
  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration short = Duration(milliseconds: 250);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 600);
  static const Duration long = Duration(milliseconds: 700);
  static const Duration sweep = Duration(seconds: 1);
  static const Duration breathe = Duration(seconds: 3);
  static const Duration splash = Duration(milliseconds: 2500);
  static const Duration onboardingComplete = Duration(milliseconds: 2500);
  static const Duration recipePlanStep = Duration(milliseconds: 700);
  static const Duration recipePlanNavigationDelay = Duration(
    milliseconds: 1500,
  );
  static const Duration barcodeFeedback = Duration(seconds: 1);
}
