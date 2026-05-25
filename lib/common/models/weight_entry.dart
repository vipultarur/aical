import 'package:equatable/equatable.dart';

/// Single historical weight measurement.
final class WeightEntry extends Equatable {
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
  List<Object?> get props => [date, weight];
}
