import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:calcount/core/services/local_storage_service.dart';

/// Water intake in ml for the current calendar day.
/// Automatically resets each new day (stored with date-based key).
class WaterIntakeNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void addWater(int amount) {
    state = state + amount;
    LocalStorageService.saveWaterIntake(state);
  }

  void reset() {
    state = 0;
    LocalStorageService.saveWaterIntake(0);
  }
}

final waterIntakeProvider =
    NotifierProvider<WaterIntakeNotifier, int>(WaterIntakeNotifier.new);
