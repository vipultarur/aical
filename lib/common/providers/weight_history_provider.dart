import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:calcount/common/models/weight_entry.dart';
import 'package:calcount/core/services/local_storage_service.dart';

class WeightHistoryNotifier extends Notifier<List<WeightEntry>> {
  @override
  List<WeightEntry> build() => [];

  void logWeight(double weight, DateTime date) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    final nextEntries = state.where((entry) {
      final entryDate = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      return entryDate != cleanDate;
    }).toList();

    nextEntries.add(WeightEntry(date: date, weight: weight));
    nextEntries.sort((left, right) => left.date.compareTo(right.date));
    state = nextEntries;
    LocalStorageService.saveWeightHistory(state);
  }
}

final weightHistoryProvider =
    NotifierProvider<WeightHistoryNotifier, List<WeightEntry>>(
      WeightHistoryNotifier.new,
    );
