/// Single historical weight measurement.
final class WeightEntry {
  const WeightEntry({required this.date, required this.weight});

  final DateTime date;
  final double weight;

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] as num).toDouble(),
    );
  }

  WeightEntry copyWith({DateTime? date, double? weight}) {
    return WeightEntry(date: date ?? this.date, weight: weight ?? this.weight);
  }

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'weight': weight};
  }

  @override
  String toString() => 'WeightEntry(date: $date, weight: $weight)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is WeightEntry && other.date == date && other.weight == weight;
  }

  @override
  int get hashCode => Object.hash(date, weight);
}
