import 'package:flutter/material.dart';

/// The "drawers" the kitchen list is organized into.
enum KitchenCategory {
  fridge('fridge', 'Fridge', Icons.kitchen),
  freezer('freezer', 'Freezer', Icons.ac_unit),
  cupboard('cupboard', 'Cupboard', Icons.inventory_2_outlined),
  snacks('snacks', 'Snacks', Icons.cookie_outlined),
  drinks('drinks', 'Drinks', Icons.local_cafe_outlined),
  other('other', 'Other', Icons.category_outlined);

  const KitchenCategory(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;

  static KitchenCategory fromValue(String? value) =>
      KitchenCategory.values.firstWhere(
        (c) => c.value == value,
        orElse: () => KitchenCategory.other,
      );
}
