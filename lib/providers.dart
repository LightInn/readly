import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db/database.dart';
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
    ref.invalidate(aiServiceProvider);
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

final shoppingProvider = StreamProvider<List<ShoppingItem>>(
  (ref) => ref.watch(databaseProvider).watchShopping(),
);

final articlesProvider = StreamProvider<List<Article>>(
  (ref) => ref.watch(databaseProvider).watchArticles(),
);

// ---- AI results kept in memory ----

class MealSuggestionsNotifier
    extends Notifier<AsyncValue<List<MealSuggestion>>?> {
  @override
  AsyncValue<List<MealSuggestion>>? build() => null;

  Future<void> generate() async {
    final ai = await ref.read(aiServiceProvider.future);
    if (ai == null) {
      state = AsyncValue.error(
        AiException('Add your OpenAI API key in settings first.'),
        StackTrace.current,
      );
      return;
    }
    state = const AsyncValue.loading();

    final settings = await ref.read(settingsProvider.future);
    final pantry = await ref.read(databaseProvider).watchPantry().first;
    final entries = await ref.read(todayEntriesProvider.future);
    final eaten = entries.fold<double>(0, (sum, e) => sum + e.kcal);
    final remaining = settings.dailyKcalGoal - eaten;

    state = await AsyncValue.guard(
      () => ai.suggestMeals(
        pantry: [
          for (final item in pantry)
            {
              'name': item.name,
              if (item.brand != null) 'brand': item.brand,
              'amount_left_percent': (item.amountLeft * 100).round(),
              if (item.kcalPer100g != null) 'kcal_per_100g': item.kcalPer100g,
              if (item.packageQuantity != null)
                'package_size': item.packageQuantity,
            },
        ],
        remainingKcal: remaining.clamp(300, 4000).toDouble(),
        language: settings.language,
      ),
    );
  }

  void clear() => state = null;
}

final mealSuggestionsProvider =
    NotifierProvider<
      MealSuggestionsNotifier,
      AsyncValue<List<MealSuggestion>>?
    >(MealSuggestionsNotifier.new);
