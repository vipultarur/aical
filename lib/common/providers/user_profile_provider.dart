import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:calcount/common/models/user_profile.dart';
import 'package:calcount/core/services/local_storage_service.dart';

class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() => UserProfile.initial();

  void updateProfile(UserProfile profile) {
    state = profile;
    LocalStorageService.saveUserProfile(profile);
  }

  void completeOnboarding() {
    final updated = state.copyWith(hasCompletedOnboarding: true);
    state = updated;
    LocalStorageService.saveUserProfile(updated);
  }

  void updateWeight(double newWeight) {
    final updated = state.copyWith(weight: newWeight);
    state = updated;
    LocalStorageService.saveUserProfile(updated);
  }
}

final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfile>(UserProfileNotifier.new);
