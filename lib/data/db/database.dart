import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class PantryItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get barcode => text().nullable()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  RealColumn get kcalPer100g => real().nullable()();
  RealColumn get proteinsPer100g => real().nullable()();
  RealColumn get carbsPer100g => real().nullable()();
  RealColumn get sugarsPer100g => real().nullable()();
  RealColumn get fatsPer100g => real().nullable()();

  /// Human readable package size, e.g. "500 g".
  TextColumn get packageQuantity => text().nullable()();

  /// Estimated fraction left in the package, 0.0 to 1.0.
  RealColumn get amountLeft => real().withDefault(const Constant(1.0))();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ConsumptionEntry')
class ConsumptionEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get kcal => real()();

  /// breakfast | lunch | dinner | snack
  TextColumn get mealType => text()();
  IntColumn get pantryItemId => integer().nullable()();
  RealColumn get grams => real().nullable()();
  DateTimeColumn get loggedAt => dateTime().withDefault(currentDateAndTime)();
}

class ShoppingItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// Optional reason/note (filled by AI suggestions).
  TextColumn get note => text().nullable()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();

  /// manual | ai
  TextColumn get source => text().withDefault(const Constant('manual'))();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
}

class Articles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get url => text()();
  TextColumn get title => text()();
  TextColumn get summary => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [PantryItems, ConsumptionEntries, ShoppingItems, Articles],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'readly'));

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  // ---- Pantry ----

  Stream<List<PantryItem>> watchPantry() =>
      (select(pantryItems)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Future<int> addPantryItem(PantryItemsCompanion item) =>
      into(pantryItems).insert(item);

  Future<void> updatePantryItem(int id, PantryItemsCompanion changes) =>
      (update(pantryItems)..where((t) => t.id.equals(id))).write(
        changes.copyWith(updatedAt: Value(DateTime.now())),
      );

  Future<void> deletePantryItem(int id) =>
      (delete(pantryItems)..where((t) => t.id.equals(id))).go();

  Future<PantryItem?> pantryItemByBarcode(String barcode) => (select(
    pantryItems,
  )..where((t) => t.barcode.equals(barcode))).getSingleOrNull();

  // ---- Consumption ----

  Stream<List<ConsumptionEntry>> watchEntriesBetween(
    DateTime start,
    DateTime end,
  ) =>
      (select(consumptionEntries)
            ..where((t) => t.loggedAt.isBetweenValues(start, end))
            ..orderBy([(t) => OrderingTerm.desc(t.loggedAt)]))
          .watch();

  Future<List<ConsumptionEntry>> entriesSince(DateTime since) => (select(
    consumptionEntries,
  )..where((t) => t.loggedAt.isBiggerThanValue(since))).get();

  Future<int> logConsumption(ConsumptionEntriesCompanion entry) =>
      into(consumptionEntries).insert(entry);

  Future<void> deleteConsumption(int id) =>
      (delete(consumptionEntries)..where((t) => t.id.equals(id))).go();

  // ---- Shopping ----

  Stream<List<ShoppingItem>> watchShopping() =>
      (select(shoppingItems)..orderBy([
            (t) => OrderingTerm.asc(t.done),
            (t) => OrderingTerm.desc(t.addedAt),
          ]))
          .watch();

  Future<int> addShoppingItem(ShoppingItemsCompanion item) =>
      into(shoppingItems).insert(item);

  Future<void> setShoppingDone(int id, bool done) =>
      (update(shoppingItems)..where((t) => t.id.equals(id))).write(
        ShoppingItemsCompanion(done: Value(done)),
      );

  Future<void> deleteShoppingItem(int id) =>
      (delete(shoppingItems)..where((t) => t.id.equals(id))).go();

  Future<void> clearDoneShopping() =>
      (delete(shoppingItems)..where((t) => t.done.equals(true))).go();

  // ---- Articles ----

  Stream<List<Article>> watchArticles() => (select(
    articles,
  )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();

  Future<int> saveArticle(ArticlesCompanion article) =>
      into(articles).insert(article);

  Future<Article?> articleById(int id) =>
      (select(articles)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> deleteArticle(int id) =>
      (delete(articles)..where((t) => t.id.equals(id))).go();
}
