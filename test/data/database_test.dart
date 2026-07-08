import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readly/data/db/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('pantry: add, update amount left, refill by barcode, delete', () async {
    final id = await db.addPantryItem(
      PantryItemsCompanion.insert(
        name: 'Pasta',
        barcode: const Value('123'),
        kcalPer100g: const Value(360),
      ),
    );

    var pantry = await db.watchPantry().first;
    expect(pantry.single.amountLeft, 1.0);

    await db.updatePantryItem(
      id,
      const PantryItemsCompanion(amountLeft: Value(0.25)),
    );
    pantry = await db.watchPantry().first;
    expect(pantry.single.amountLeft, 0.25);

    final byBarcode = await db.pantryItemByBarcode('123');
    expect(byBarcode?.name, 'Pasta');
    expect(await db.pantryItemByBarcode('999'), isNull);

    await db.deletePantryItem(id);
    expect(await db.watchPantry().first, isEmpty);
  });

  test('pantry: newest items first, unit/perishable columns default', () async {
    await db.addPantryItem(
      PantryItemsCompanion.insert(
        name: 'Old rice',
        addedAt: Value(DateTime(2026, 1, 1)),
      ),
    );
    await db.addPantryItem(
      PantryItemsCompanion.insert(
        name: 'Fresh eggs',
        unitCount: const Value(12),
        perishable: const Value(true),
        addedAt: Value(DateTime(2026, 7, 1)),
      ),
    );

    final pantry = await db.watchPantry().first;
    expect(pantry.map((i) => i.name), ['Fresh eggs', 'Old rice']);
    expect(pantry.first.unitCount, 12);
    expect(pantry.first.perishable, isTrue);
    expect(pantry.last.unitCount, isNull);
    expect(pantry.last.perishable, isFalse);
  });

  test('consumption: only entries inside the window are returned', () async {
    final today = DateTime(2026, 7, 8, 12);
    final start = DateTime(2026, 7, 8);
    final end = start.add(const Duration(days: 1));

    await db.logConsumption(
      ConsumptionEntriesCompanion.insert(
        name: 'Breakfast bowl',
        kcal: 420,
        mealType: 'breakfast',
        loggedAt: Value(today),
      ),
    );
    await db.logConsumption(
      ConsumptionEntriesCompanion.insert(
        name: 'Yesterday pizza',
        kcal: 900,
        mealType: 'dinner',
        loggedAt: Value(today.subtract(const Duration(days: 1))),
      ),
    );

    final entries = await db.watchEntriesBetween(start, end).first;
    expect(entries.map((e) => e.name), ['Breakfast bowl']);
  });

  test('shopping: done items sort last and can be cleared', () async {
    final milkId = await db.addShoppingItem(
      ShoppingItemsCompanion.insert(name: 'Milk'),
    );
    await db.addShoppingItem(ShoppingItemsCompanion.insert(name: 'Eggs'));

    await db.setShoppingDone(milkId, true);
    var items = await db.watchShopping().first;
    expect(items.first.name, 'Eggs');
    expect(items.last.done, isTrue);

    await db.clearDoneShopping();
    items = await db.watchShopping().first;
    expect(items.map((i) => i.name), ['Eggs']);
  });

  test('articles: saved summaries can be fetched back by id', () async {
    final id = await db.saveArticle(
      ArticlesCompanion.insert(
        url: 'https://example.com/a',
        title: 'A title',
        summary: 'A summary',
      ),
    );
    final article = await db.articleById(id);
    expect(article?.summary, 'A summary');
    expect(await db.articleById(9999), isNull);
  });
}
