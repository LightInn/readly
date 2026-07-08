import 'package:flutter/material.dart';

enum MealType {
  breakfast('breakfast', 'Breakfast', Icons.free_breakfast),
  lunch('lunch', 'Lunch', Icons.lunch_dining),
  dinner('dinner', 'Dinner', Icons.dinner_dining),
  snack('snack', 'Snack', Icons.cookie);

  const MealType(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;

  static MealType fromValue(String value) => MealType.values.firstWhere(
    (t) => t.value == value,
    orElse: () => MealType.snack,
  );

  /// Best guess for the current time of day.
  static MealType suggestedNow([DateTime? now]) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour < 11) return MealType.breakfast;
    if (hour < 15) return MealType.lunch;
    if (hour < 18) return MealType.snack;
    if (hour < 22) return MealType.dinner;
    return MealType.snack;
  }
}
