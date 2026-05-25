import 'package:flutter/material.dart';

/// Typed recipe-preview row data for the onboarding meal-plan summary.
final class RecipePlanPreview {
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
  String toString() {
    return 'RecipePlanPreview(slot: $slot, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is RecipePlanPreview &&
        other.slot == slot &&
        other.name == name &&
        other.caloriesLabel == caloriesLabel &&
        other.macrosLabel == macrosLabel &&
        other.icon == icon &&
        other.color == color;
  }

  @override
  int get hashCode =>
      Object.hash(slot, name, caloriesLabel, macrosLabel, icon, color);
}
