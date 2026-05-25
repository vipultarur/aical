import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:calcount/common/providers/mock_data_provider.dart';

typedef WeightTrendSummary = ({
  double latestWeight,
  double deltaFromPrevious,
  bool isTrendingDown,
});

final weightTrendSummaryProvider = Provider<WeightTrendSummary>((ref) {
  final history = ref.watch(weightHistoryProvider);

  if (history.isEmpty) {
    return (latestWeight: 0, deltaFromPrevious: 0, isTrendingDown: false);
  }

  final latest = history.last.weight;
  final previous = history.length > 1
      ? history[history.length - 2].weight
      : latest;
  final delta = latest - previous;

  return (
    latestWeight: latest,
    deltaFromPrevious: delta,
    isTrendingDown: delta <= 0,
  );
});
