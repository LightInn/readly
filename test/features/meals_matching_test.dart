import 'package:flutter_test/flutter_test.dart';
import 'package:readly/data/db/database.dart';
import 'package:readly/features/meals/meals_page.dart';

PantryItem _item(String name, {double amountLeft = 1.0}) {
  return PantryItem(
    id: name.hashCode,
    name: name,
    perishable: false,
    amountLeft: amountLeft,
    addedAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  test('matches ingredients to pantry items by containment and words', () {
    final pantry = [
      _item('Œufs de plein air'),
      _item('Pâtes complètes Barilla'),
      _item('Chocolat noir'),
    ];
    final used = matchUsedPantryItems(pantry, ['œufs', 'pâtes']);
    expect(used.map((i) => i.name), [
      'Œufs de plein air',
      'Pâtes complètes Barilla',
    ]);
  });

  test('ignores finished items and unrelated ingredients', () {
    final pantry = [_item('Riz basmati', amountLeft: 0.0), _item('Tomates')];
    expect(matchUsedPantryItems(pantry, ['riz']), isEmpty);
    expect(matchUsedPantryItems(pantry, ['courgette']), isEmpty);
  });
}
