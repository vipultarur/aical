abstract final class AppRoutes {
  static const splash = '/';

  static const login = '/auth/login';
  static const signup = '/auth/signup';

  static const onboardingWelcome = '/onboarding/welcome';
  static const onboardingBasicInfo = '/onboarding/basic-info';
  static const onboardingHeightWeight = '/onboarding/height-weight';
  static const onboardingGoals = '/onboarding/goals';
  static const onboardingTarget = '/onboarding/target';
  static const onboardingTargetReach = '/onboarding/reach-goal';
  static const onboardingPrediction = '/onboarding/prediction';
  static const onboardingActivityLevel = '/onboarding/activity-level';
  static const onboardingCalorieCut = '/onboarding/calorie-cut';
  static const onboardingEatingStyle = '/onboarding/eating-style';
  static const onboardingRecipePlan = '/onboarding/recipe-plan';
  static const onboardingDietPrefs = '/onboarding/diet-prefs';
  static const onboardingComplete = '/onboarding/complete';

  static const dashboard = '/dashboard';
  static const foodLog = '/log';
  static const insights = '/insights';
  static const planner = '/planner';
  static const profile = '/profile';

  static const foodDetailPath = '/log/food/:id';
  static const barcodeScanner = '/log/barcode';
  static const recipeBuilder = '/log/recipe/new';
  static const weightLog = '/insights/weight';
  static const settings = '/profile/settings';

  static String log({String? slot}) {
    if (slot == null || slot.isEmpty) {
      return foodLog;
    }

    return '$foodLog?slot=$slot';
  }

  static String foodDetail(String id, {String? slot}) {
    if (slot == null || slot.isEmpty) {
      return '/log/food/$id';
    }
    return '/log/food/$id?slot=$slot';
  }
}
