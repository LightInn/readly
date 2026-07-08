import 'db/database.dart';

/// Helpers to reason about pantry quantities: the app never asks for exact
/// grams — everything is an estimated fraction of the package (or a number
/// of units for unit-counted foods like eggs).
extension PantryQuantity on PantryItem {
  /// Whether this item is tracked in units (eggs) rather than percent.
  bool get isUnitBased => unitCount != null && unitCount! > 0;

  /// Units remaining, rounded to whole units.
  int get unitsLeft =>
      isUnitBased ? (amountLeft * unitCount!).round().clamp(0, unitCount!) : 0;

  /// Whether the package is (practically) finished.
  bool get isConsumed => isUnitBased ? unitsLeft == 0 : amountLeft <= 0.005;

  /// "7/12" for unit-based items, "75%" otherwise.
  String get amountLabel => isUnitBased
      ? '$unitsLeft/${unitCount!}'
      : '${(amountLeft * 100).round()}%';

  /// Grams (or ml, treated as equivalent) in a full package, parsed from the
  /// human-readable [packageQuantity]. Null when it cannot be parsed.
  double? get packageGrams => parsePackageGrams(packageQuantity);

  /// Estimated kcal in a fraction of the package (e.g. what was just eaten).
  /// Null when kcal/100g or the package size is unknown.
  double? kcalForFraction(double fraction) {
    final grams = packageGrams;
    if (grams == null || kcalPer100g == null) return null;
    return kcalPer100g! * grams * fraction / 100;
  }
}

/// Parses "500 g", "1,5 kg", "33 cl", "1L"… into grams (ml counted as g,
/// close enough for kcal-per-100g estimates). Returns null when unparseable.
double? parsePackageGrams(String? packageQuantity) {
  if (packageQuantity == null) return null;
  final match = RegExp(
    r'([\d]+(?:[.,]\d+)?)\s*(kg|g|mg|l|dl|cl|ml)\b',
    caseSensitive: false,
  ).firstMatch(packageQuantity);
  if (match == null) return null;
  final value = double.parse(match.group(1)!.replaceAll(',', '.'));
  return switch (match.group(2)!.toLowerCase()) {
    'kg' || 'l' => value * 1000,
    'dl' => value * 100,
    'cl' => value * 10,
    'mg' => value / 1000,
    _ => value,
  };
}
