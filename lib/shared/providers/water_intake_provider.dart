import 'package:flutter_riverpod/flutter_riverpod.dart';

class WaterIntakeNotifier extends StateNotifier<int> {
  WaterIntakeNotifier() : super(1500);

  void addWater(int amount) {
    state += amount;
  }

  void reset() {
    state = 0;
  }
}

final waterIntakeProvider = StateNotifierProvider<WaterIntakeNotifier, int>((
  ref,
) {
  return WaterIntakeNotifier();
});
