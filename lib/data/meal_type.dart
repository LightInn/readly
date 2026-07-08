import 'package:flutter/material.dart';

enum MealType {
  breakfast('breakfast', 'Breakfast', Icons.free_breakfast, Color(0xFFE8930C)),
  lunch('lunch', 'Lunch', Icons.lunch_dining, Color(0xFF3E9B4F)),
  dinner('dinner', 'Dinner', Icons.dinner_dining, Color(0xFF5C6BC0)),
  snack('snack', 'Snack', Icons.cookie, Color(0xFFD81B75));

  const MealType(this.value, this.label, this.icon, this.color);

  final String value;
  final String label;
  final IconData icon;

  /// Accent color used for icons and highlights of this meal.
  final Color color;

  /// Soft background tint matching [color].
  Color get tint => color.withValues(alpha: 0.14);

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
