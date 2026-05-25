import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:calcount/shared/models/weight_entry.dart';

class WeightHistoryNotifier extends StateNotifier<List<WeightEntry>> {
  WeightHistoryNotifier() : super(_initialMockHistory());

  static List<WeightEntry> _initialMockHistory() {
    final now = DateTime.now();

    return [
      WeightEntry(date: now.subtract(const Duration(days: 7)), weight: 165.8),
      WeightEntry(date: now.subtract(const Duration(days: 5)), weight: 166.0),
      WeightEntry(date: now.subtract(const Duration(days: 3)), weight: 165.4),
      WeightEntry(date: now.subtract(const Duration(days: 1)), weight: 165.0),
    ];
  }

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
  }
}

final weightHistoryProvider =
    StateNotifierProvider<WeightHistoryNotifier, List<WeightEntry>>((ref) {
      return WeightHistoryNotifier();
    });
