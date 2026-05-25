import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:calcount/shared/models/user_profile.dart';

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(UserProfile.initial());

  void updateProfile(UserProfile profile) {
    state = profile;
  }

  void completeOnboarding() {
    state = state.copyWith(hasCompletedOnboarding: true);
  }

  void updateWeight(double newWeight) {
    state = state.copyWith(weight: newWeight);
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
      return UserProfileNotifier();
    });
