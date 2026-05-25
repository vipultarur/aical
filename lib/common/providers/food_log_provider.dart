import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:calcount/common/models/food_entry.dart';
import 'package:calcount/core/services/local_storage_service.dart';

class FoodLogNotifier extends Notifier<List<FoodEntry>> {
  @override
  List<FoodEntry> build() => [];

  void addFood(FoodEntry entry) {
    state = [...state, entry];
    LocalStorageService.saveFoodLog(state);
  }

  void removeFood(String id) {
    state = state.where((entry) => entry.id != id).toList();
    LocalStorageService.saveFoodLog(state);
  }
}

final foodLogProvider =
    NotifierProvider<FoodLogNotifier, List<FoodEntry>>(FoodLogNotifier.new);
