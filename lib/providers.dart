import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db/database.dart';
import 'data/progress.dart';
import 'data/quantity.dart';
import 'data/services/ai_service.dart';
import 'data/services/article_extractor.dart';
import 'data/services/off_service.dart';
import 'data/services/settings_service.dart';

// ---- Infrastructure ----

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final settingsServiceProvider = Provider<SettingsService>(
  (ref) => SettingsService(),
);

final offServiceProvider = Provider<OpenFoodFactsService>(
  (ref) => OpenFoodFactsService(),
);

final articleExtractorProvider = Provider<ArticleExtractor>(
  (ref) => ArticleExtractor(),
);

// ---- Settings state ----

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() => ref.read(settingsServiceProvider).load();

  Future<void> setApiKey(String? key) async {
    await ref.read(settingsServiceProvider).setApiKey(key);
    // No explicit invalidate: aiServiceProvider watches this provider, so
    // publishing the new state below rebuilds it (invalidating from inside
    // the watched notifier trips riverpod's circular-dependency check).
    state = await AsyncValue.guard(
      () => ref.read(settingsServiceProvider).load(),
    );
  }

  Future<void> setLanguage(String language) async {
    await ref.read(settingsServiceProvider).setLanguage(language);
    state = AsyncData(state.requireValue.copyWith(language: language));
  }

  Future<void> setDailyKcalGoal(int goal) async {
    await ref.read(settingsServiceProvider).setDailyKcalGoal(goal);
    state = AsyncData(state.requireValue.copyWith(dailyKcalGoal: goal));
  }

  Future<void> setDailyBurnKcal(int burn) async {
    await ref.read(settingsServiceProvider).setDailyBurnKcal(burn);
    state = AsyncData(state.requireValue.copyWith(dailyBurnKcal: burn));
  }

  Future<void> setCheatThresholdKcal(int threshold) async {
    await ref.read(settingsServiceProvider).setCheatThresholdKcal(threshold);
    state = AsyncData(
      state.requireValue.copyWith(cheatThresholdKcal: threshold),
    );
  }

  Future<void> setCurrentWeightKg(double kg) async {
    await ref.read(settingsServiceProvider).setCurrentWeightKg(kg);
    state = AsyncData(state.requireValue.copyWith(currentWeightKg: kg));
  }

  Future<void> setTargetWeightKg(double kg) async {
    await ref.read(settingsServiceProvider).setTargetWeightKg(kg);
    state = AsyncData(state.requireValue.copyWith(targetWeightKg: kg));
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

/// The OpenAI client, or null while no API key is configured.
final aiServiceProvider = FutureProvider<AiService?>((ref) async {
  // Re-created whenever settings change (invalidated on key updates).
  ref.watch(settingsProvider);
  final key = await ref.read(settingsServiceProvider).getApiKey();
  if (key == null || key.isEmpty) return null;
  return AiService(apiKey: key);
});

// ---- Database streams ----

final pantryProvider = StreamProvider<List<PantryItem>>(
  (ref) => ref.watch(databaseProvider).watchPantry(),
);

final todayEntriesProvider = StreamProvider<List<ConsumptionEntry>>((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1));
  return ref.watch(databaseProvider).watchEntriesBetween(start, end);
});

/// The day the Track page is looking at (midnight-keyed; today by default).
class SelectedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void select(DateTime day) => state = DateTime(day.year, day.month, day.day);

  void today() {
    final now = DateTime.now();
    state = DateTime(now.year, now.month, now.day);
  }
}

final selectedDayProvider = NotifierProvider<SelectedDayNotifier, DateTime>(
  SelectedDayNotifier.new,
);

/// Consumption entries of the selected Track day.
final selectedDayEntriesProvider = StreamProvider<List<ConsumptionEntry>>((
  ref,
) {
  final day = ref.watch(selectedDayProvider);
  return ref
      .watch(databaseProvider)
      .watchEntriesBetween(day, day.add(const Duration(days: 1)));
});

/// Streak ("days without cheat"), cumulative kcal deficit → kg lost, and the
/// all-time weight trajectory, recomputed whenever any entry changes.
final progressStatsProvider = StreamProvider<(ProgressStats, WeightOutlook)>((
  ref,
) {
  final settings = ref.watch(settingsProvider).value;
  final goal = settings?.dailyKcalGoal ?? SettingsService.defaultKcalGoal;
  final burn = settings?.dailyBurnKcal ?? SettingsService.defaultKcalBurn;
  final threshold =
      settings?.cheatThresholdKcal ?? SettingsService.defaultCheatThreshold;
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return ref
      .watch(databaseProvider)
      .watchEntriesBetween(
        today.subtract(const Duration(days: 366)),
        today.add(const Duration(days: 1)),
      )
      .map((entries) {
        final byDay = <DateTime, double>{};
        for (final entry in entries) {
          final day = DateTime(
            entry.loggedAt.year,
            entry.loggedAt.month,
            entry.loggedAt.day,
          );
          byDay[day] = (byDay[day] ?? 0) + entry.kcal;
        }
        return (
          computeProgress(
            kcalByDay: byDay,
            goalKcal: goal,
            burnKcal: burn,
            today: now,
            thresholdKcal: threshold,
          ),
          computeWeightOutlook(kcalByDay: byDay, burnKcal: burn, today: now),
        );
      });
});

/// Meals the user actually cooked, newest first.
final cookedMealsProvider = StreamProvider<List<CookedMeal>>(
  (ref) => ref.watch(databaseProvider).watchCookedMeals(),
);

final shoppingProvider = StreamProvider<List<ShoppingItem>>(
  (ref) => ref.watch(databaseProvider).watchShopping(),
);

final articlesProvider = StreamProvider<List<Article>>(
  (ref) => ref.watch(databaseProvider).watchArticles(),
);

/// The last generated meal suggestions, persisted in the database so they
/// survive app restarts.
final savedMealsProvider = StreamProvider<List<SavedMeal>>(
  (ref) => ref.watch(databaseProvider).watchSavedMeals(),
);

// ---- AI generation state ----

/// Tracks only the in-flight generation (loading/error); the resulting meals
/// live in the database (see [savedMealsProvider]).
class MealSuggestionsNotifier extends Notifier<AsyncValue<void>?> {
  @override
  AsyncValue<void>? build() => null;

  /// [focus] biases the ideas toward one ingredient (e.g. a perishable that
  /// must be eaten soon).
  Future<void> generate({String? focus}) async {
    state = const AsyncValue.loading();
    // Everything lives inside the guard: an exception anywhere would
    // otherwise leave the state stuck on loading forever.
    state = await AsyncValue.guard(() async {
      final ai = await ref.read(aiServiceProvider.future);
      if (ai == null) {
        throw AiException('Add your OpenAI API key in settings first.');
      }
      final settings = await ref.read(settingsProvider.future);
      final db = ref.read(databaseProvider);
      final pantry = await db.watchPantry().first;
      final now = DateTime.now();
      final dayStart = DateTime(now.year, now.month, now.day);
      final entries = await db
          .watchEntriesBetween(dayStart, dayStart.add(const Duration(days: 1)))
          .first;
      final eaten = entries.fold<double>(0, (sum, e) => sum + e.kcal);
      final remaining = settings.dailyKcalGoal - eaten;

      final meals = await ai.suggestMeals(
        pantry: [
          for (final item in pantry)
            if (!item.isConsumed)
              {
                'name': item.name,
                if (item.brand != null) 'brand': item.brand,
                if (item.isUnitBased) ...{
                  'units_left': item.unitsLeft,
                  'units_per_package': item.unitCount,
                } else
                  'amount_left_percent': (item.amountLeft * 100).round(),
                'perishable': item.perishable,
                if (item.kcalPer100g != null) 'kcal_per_100g': item.kcalPer100g,
                if (item.packageQuantity != null)
                  'package_size': item.packageQuantity,
              },
        ],
        eatenToday: [
          for (final entry in entries)
            {
              'name': entry.name,
              'kcal': entry.kcal.round(),
              'meal': entry.mealType,
            },
        ],
        consumedKcal: eaten,
        dailyGoalKcal: settings.dailyKcalGoal.toDouble(),
        remainingKcal: remaining.clamp(300, 4000).toDouble(),
        language: settings.language,
        focusIngredient: focus,
      );
      await db.replaceSavedMeals([
        for (final meal in meals)
          SavedMealsCompanion.insert(
            title: meal.title,
            description: meal.description,
            timeMinutes: meal.timeMinutes,
            kcal: meal.kcal,
            usedIngredients: jsonEncode(meal.usedIngredients),
            missingIngredients: jsonEncode(meal.missingIngredients),
            steps: jsonEncode(meal.steps),
          ),
      ]);
    });
  }

  void clear() => state = null;
}

final mealSuggestionsProvider =
    NotifierProvider<MealSuggestionsNotifier, AsyncValue<void>?>(
      MealSuggestionsNotifier.new,
    );
