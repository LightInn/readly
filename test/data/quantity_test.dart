import 'package:flutter_test/flutter_test.dart';
import 'package:readly/data/db/database.dart';
import 'package:readly/data/quantity.dart';

PantryItem _item({
  double? kcalPer100g,
  String? packageQuantity,
  int? unitCount,
  double amountLeft = 1.0,
}) {
  return PantryItem(
    id: 1,
    name: 'Test',
    kcalPer100g: kcalPer100g,
    packageQuantity: packageQuantity,
    unitCount: unitCount,
    perishable: false,
    amountLeft: amountLeft,
    addedAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  group('parsePackageGrams', () {
    test('parses common weight formats', () {
      expect(parsePackageGrams('500 g'), 500);
      expect(parsePackageGrams('500g'), 500);
      expect(parsePackageGrams('1,5 kg'), 1500);
      expect(parsePackageGrams('1.5 kg'), 1500);
      // Multipacks: the first weight found wins (the per-pot size here).
      expect(parsePackageGrams('6 x 125 g'), 125);
    });

    test('treats volumes as gram-equivalents', () {
      expect(parsePackageGrams('1 L'), 1000);
      expect(parsePackageGrams('33 cl'), 330);
      expect(parsePackageGrams('250 ml'), 250);
    });

    test('returns null when unparseable', () {
      expect(parsePackageGrams(null), isNull);
      expect(parsePackageGrams('a dozen'), isNull);
      expect(parsePackageGrams(''), isNull);
    });
  });

  group('PantryQuantity', () {
    test('percent-based items format and detect consumption', () {
      final item = _item(packageQuantity: '500 g', amountLeft: 0.75);
      expect(item.isUnitBased, isFalse);
      expect(item.amountLabel, '75%');
      expect(item.isConsumed, isFalse);
      expect(_item(amountLeft: 0.0).isConsumed, isTrue);
    });

    test('unit-based items count in units', () {
      final eggs = _item(unitCount: 12, amountLeft: 0.5);
      expect(eggs.isUnitBased, isTrue);
      expect(eggs.unitsLeft, 6);
      expect(eggs.amountLabel, '6/12');
      expect(_item(unitCount: 12, amountLeft: 0.01).isConsumed, isTrue);
    });

    test('kcalForFraction estimates from package size', () {
      final item = _item(kcalPer100g: 360, packageQuantity: '500 g');
      expect(item.kcalForFraction(0.5), 900); // 250 g of 360 kcal/100g
      expect(_item(kcalPer100g: 360).kcalForFraction(0.5), isNull);
      expect(_item(packageQuantity: '500 g').kcalForFraction(0.5), isNull);
    });
  });
}
