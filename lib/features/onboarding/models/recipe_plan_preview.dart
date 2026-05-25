import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Typed recipe-preview row data for the onboarding meal-plan summary.
final class RecipePlanPreview extends Equatable {
  const RecipePlanPreview({
    required this.slot,
    required this.name,
    required this.caloriesLabel,
    required this.macrosLabel,
    required this.icon,
    required this.color,
  });

  final String slot;
  final String name;
  final String caloriesLabel;
  final String macrosLabel;
  final IconData icon;
  final Color color;

  RecipePlanPreview copyWith({
    String? slot,
    String? name,
    String? caloriesLabel,
    String? macrosLabel,
    IconData? icon,
    Color? color,
  }) {
    return RecipePlanPreview(
      slot: slot ?? this.slot,
      name: name ?? this.name,
      caloriesLabel: caloriesLabel ?? this.caloriesLabel,
      macrosLabel: macrosLabel ?? this.macrosLabel,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [
    slot,
    name,
    caloriesLabel,
    macrosLabel,
    icon,
    color,
  ];
}
