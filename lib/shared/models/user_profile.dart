/// In-memory user profile collected across auth, onboarding, and tracking.
final class UserProfile {
  const UserProfile({
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.height,
    required this.weight,
    required this.targetWeight,
    required this.weightUnit,
    required this.mainGoal,
    required this.activityLevel,
    required this.dietPrefs,
    required this.calorieTarget,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    required this.waterTarget,
    required this.targetDate,
    this.hasCompletedOnboarding = false,
    this.currentStreak = 14,
  });

  final String name;
  final DateTime dateOfBirth;
  final String gender;
  final double height;
  final double weight;
  final double targetWeight;
  final String weightUnit;
  final String mainGoal;
  final String activityLevel;
  final List<String> dietPrefs;
  final int calorieTarget;
  final int proteinTarget;
  final int carbsTarget;
  final int fatTarget;
  final int waterTarget;
  final DateTime targetDate;
  final bool hasCompletedOnboarding;
  final int currentStreak;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      targetWeight: (json['targetWeight'] as num).toDouble(),
      weightUnit: json['weightUnit'] as String,
      mainGoal: json['mainGoal'] as String,
      activityLevel: json['activityLevel'] as String,
      dietPrefs: List<String>.from(json['dietPrefs'] as List<dynamic>),
      calorieTarget: json['calorieTarget'] as int,
      proteinTarget: json['proteinTarget'] as int,
      carbsTarget: json['carbsTarget'] as int,
      fatTarget: json['fatTarget'] as int,
      waterTarget: json['waterTarget'] as int,
      targetDate: DateTime.parse(json['targetDate'] as String),
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      currentStreak: json['currentStreak'] as int? ?? 14,
    );
  }

  factory UserProfile.initial() {
    return UserProfile(
      name: 'Alex Johnson',
      dateOfBirth: DateTime(1995, 5, 17),
      gender: 'Male',
      height: 178,
      weight: 75,
      targetWeight: 68,
      weightUnit: 'kg',
      mainGoal: 'Lose Weight',
      activityLevel: 'Moderately Active',
      dietPrefs: const ['High Protein', 'Whole Foods'],
      calorieTarget: 1847,
      proteinTarget: 138,
      carbsTarget: 231,
      fatTarget: 62,
      waterTarget: 2500,
      targetDate: DateTime.now().add(const Duration(days: 84)),
    );
  }

  UserProfile copyWith({
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    double? height,
    double? weight,
    double? targetWeight,
    String? weightUnit,
    String? mainGoal,
    String? activityLevel,
    List<String>? dietPrefs,
    int? calorieTarget,
    int? proteinTarget,
    int? carbsTarget,
    int? fatTarget,
    int? waterTarget,
    DateTime? targetDate,
    bool? hasCompletedOnboarding,
    int? currentStreak,
  }) {
    return UserProfile(
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      targetWeight: targetWeight ?? this.targetWeight,
      weightUnit: weightUnit ?? this.weightUnit,
      mainGoal: mainGoal ?? this.mainGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      dietPrefs: dietPrefs ?? this.dietPrefs,
      calorieTarget: calorieTarget ?? this.calorieTarget,
      proteinTarget: proteinTarget ?? this.proteinTarget,
      carbsTarget: carbsTarget ?? this.carbsTarget,
      fatTarget: fatTarget ?? this.fatTarget,
      waterTarget: waterTarget ?? this.waterTarget,
      targetDate: targetDate ?? this.targetDate,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'height': height,
      'weight': weight,
      'targetWeight': targetWeight,
      'weightUnit': weightUnit,
      'mainGoal': mainGoal,
      'activityLevel': activityLevel,
      'dietPrefs': dietPrefs,
      'calorieTarget': calorieTarget,
      'proteinTarget': proteinTarget,
      'carbsTarget': carbsTarget,
      'fatTarget': fatTarget,
      'waterTarget': waterTarget,
      'targetDate': targetDate.toIso8601String(),
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'currentStreak': currentStreak,
    };
  }

  @override
  String toString() {
    return 'UserProfile(name: $name, weight: $weight, targetWeight: $targetWeight, '
        'goal: $mainGoal, completed: $hasCompletedOnboarding)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is UserProfile &&
        other.name == name &&
        other.dateOfBirth == dateOfBirth &&
        other.gender == gender &&
        other.height == height &&
        other.weight == weight &&
        other.targetWeight == targetWeight &&
        other.weightUnit == weightUnit &&
        other.mainGoal == mainGoal &&
        other.activityLevel == activityLevel &&
        _listEquals(other.dietPrefs, dietPrefs) &&
        other.calorieTarget == calorieTarget &&
        other.proteinTarget == proteinTarget &&
        other.carbsTarget == carbsTarget &&
        other.fatTarget == fatTarget &&
        other.waterTarget == waterTarget &&
        other.targetDate == targetDate &&
        other.hasCompletedOnboarding == hasCompletedOnboarding &&
        other.currentStreak == currentStreak;
  }

  @override
  int get hashCode => Object.hash(
    name,
    dateOfBirth,
    gender,
    height,
    weight,
    targetWeight,
    weightUnit,
    mainGoal,
    activityLevel,
    Object.hashAll(dietPrefs),
    calorieTarget,
    proteinTarget,
    carbsTarget,
    fatTarget,
    waterTarget,
    targetDate,
    hasCompletedOnboarding,
    currentStreak,
  );

  static bool _listEquals(List<String> left, List<String> right) {
    if (left.length != right.length) {
      return false;
    }

    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) {
        return false;
      }
    }

    return true;
  }
}
