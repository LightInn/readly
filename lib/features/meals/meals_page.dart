import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/database.dart';
import '../../data/meal_type.dart';
import '../../data/quantity.dart';
import '../../data/services/ai_service.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import '../kitchen/kitchen_page.dart' show amountLeftColor;

List<String> _decodeList(String json) =>
    (jsonDecode(json) as List<dynamic>).cast<String>();

class MealsPage extends ConsumerWidget {
  const MealsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generation = ref.watch(mealSuggestionsProvider);
    final meals = ref.watch(savedMealsProvider).value ?? [];
    final hasApiKey = ref.watch(settingsProvider).value?.hasApiKey ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: switch (generation) {
        AsyncLoading() => const _Loading(),
        AsyncError(:final error) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not get suggestions',
          message: error is AiException ? error.message : '$error',
          action: FilledButton(
            onPressed: () =>
                ref.read(mealSuggestionsProvider.notifier).generate(),
            child: const Text('Try again'),
          ),
        ),
        // Idle or done: the saved batch (persisted across restarts) rules.
        _ => _MealsBody(meals: meals, hasApiKey: hasApiKey),
      },
    );
  }
}

class _Idle extends ConsumerWidget {
  const _Idle({required this.hasApiKey});

  final bool hasApiKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!hasApiKey) {
      return EmptyState(
        icon: Icons.key_off,
        title: 'AI is not set up yet',
        message:
            'Add your OpenAI API key in settings to unlock meal '
            'suggestions and article summaries.',
        action: FilledButton.icon(
          icon: const Icon(Icons.settings),
          label: const Text('Open settings'),
          onPressed: () => context.push('/settings'),
        ),
      );
    }
    final pantryCount = ref.watch(pantryProvider).value?.length ?? 0;
    return EmptyState(
      icon: Icons.restaurant_menu,
      title: 'What should I cook?',
      message: pantryCount == 0
          ? 'Your kitchen is empty. Scan a few items first so the '
                'suggestions can use what you actually own.'
          : 'Based on the $pantryCount items in your kitchen and your '
                'remaining kcal for today, get 3 healthy, low-effort ideas.',
      action: FilledButton.icon(
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Suggest 3 meals'),
        onPressed: pantryCount == 0
            ? null
            : () => ref.read(mealSuggestionsProvider.notifier).generate(),
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cooking up ideas…'),
        ],
      ),
    );
  }
}

/// Suggestions (or the idle pitch) followed by the cook history.
class _MealsBody extends ConsumerWidget {
  const _MealsBody({required this.meals, required this.hasApiKey});

  final List<SavedMeal> meals;
  final bool hasApiKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cooked = ref.watch(cookedMealsProvider).value ?? [];
    if (meals.isEmpty && cooked.isEmpty) return _Idle(hasApiKey: hasApiKey);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        if (meals.isEmpty)
          _Idle(hasApiKey: hasApiKey)
        else ...[
          for (final meal in meals) ...[
            _MealCard(meal: meal),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Suggest something else'),
            onPressed: () =>
                ref.read(mealSuggestionsProvider.notifier).generate(),
          ),
        ],
        if (cooked.isNotEmpty) ...[
          const SectionHeader('Cooked before'),
          Card(
            child: Column(
              children: [
                for (final meal in cooked)
                  ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.tertiaryContainer,
                      child: Icon(
                        Icons.restaurant_menu,
                        size: 20,
                        color: Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                    ),
                    title: Text(meal.title),
                    subtitle: Text(
                      '${_agoLabel(meal.cookedAt)} · ${meal.kcal.round()} kcal',
                    ),
                    trailing: IconButton(
                      tooltip: 'I made it again',
                      icon: const Icon(Icons.replay),
                      onPressed: () => _relogCooked(context, ref, meal),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static String _agoLabel(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days <= 0) return 'today';
    if (days == 1) return 'yesterday';
    if (days < 30) return '$days days ago';
    return '${(days / 30).floor()} month${days >= 60 ? 's' : ''} ago';
  }

  Future<void> _relogCooked(
    BuildContext context,
    WidgetRef ref,
    CookedMeal meal,
  ) async {
    final type = await showModalBottomSheet<MealType>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Log "${meal.title}" (${meal.kcal.round()} kcal) as:',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            for (final type in MealType.values)
              ListTile(
                leading: Icon(type.icon, color: type.color),
                title: Text(type.label),
                onTap: () => Navigator.pop(sheetContext, type),
              ),
          ],
        ),
      ),
    );
    if (type == null) return;
    final db = ref.read(databaseProvider);
    await db.logConsumption(
      ConsumptionEntriesCompanion.insert(
        name: meal.title,
        kcal: meal.kcal,
        mealType: type.value,
      ),
    );
    await db.addCookedMeal(
      CookedMealsCompanion.insert(title: meal.title, kcal: meal.kcal),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged ${meal.kcal.round()} kcal. Enjoy!')),
      );
    }
  }
}

class _MealCard extends ConsumerWidget {
  const _MealCard({required this.meal});

  final SavedMeal meal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final usedIngredients = _decodeList(meal.usedIngredients);
    final missingIngredients = _decodeList(meal.missingIngredients);
    final steps = _decodeList(meal.steps);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meal.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(meal.description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: Icon(
                    Icons.schedule,
                    size: 18,
                    color: scheme.onSecondaryContainer,
                  ),
                  backgroundColor: scheme.secondaryContainer,
                  labelStyle: TextStyle(color: scheme.onSecondaryContainer),
                  label: Text('${meal.timeMinutes} min'),
                ),
                Chip(
                  avatar: Icon(
                    Icons.local_fire_department,
                    size: 18,
                    color: scheme.onTertiaryContainer,
                  ),
                  backgroundColor: scheme.tertiaryContainer,
                  labelStyle: TextStyle(
                    color: scheme.onTertiaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                  label: Text('${meal.kcal.round()} kcal'),
                ),
              ],
            ),
            if (usedIngredients.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'From your kitchen',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                usedIngredients.join(' · '),
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
            if (missingIngredients.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Missing — tap to add to groceries',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final ingredient in missingIngredients)
                    ActionChip(
                      avatar: const Icon(Icons.add_shopping_cart, size: 18),
                      label: Text(ingredient),
                      onPressed: () =>
                          _addToGroceries(context, ref, ingredient),
                    ),
                ],
              ),
            ],
            if (steps.isNotEmpty) ...[
              const SizedBox(height: 8),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                shape: const Border(),
                title: Text(
                  'Ingredients & steps',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                children: [
                  // Everything the recipe needs, missing items flagged.
                  for (final ingredient in usedIngredients)
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: scheme.primary,
                      ),
                      title: Text(ingredient),
                    ),
                  for (final ingredient in missingIngredients)
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.remove_shopping_cart_outlined,
                        size: 20,
                        color: scheme.error,
                      ),
                      title: Text('$ingredient (to buy)'),
                    ),
                  const Divider(),
                  for (final (index, step) in steps.indexed)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 13,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(step),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: meal.done
                  ? FilledButton.tonalIcon(
                      icon: Icon(Icons.check_circle, color: scheme.primary),
                      label: const Text('Already done'),
                      onPressed: null,
                    )
                  : FilledButton.tonalIcon(
                      icon: const Icon(Icons.check),
                      label: const Text('I made it'),
                      onPressed: () => _logMeal(context, ref, usedIngredients),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToGroceries(
    BuildContext context,
    WidgetRef ref,
    String ingredient,
  ) async {
    await ref
        .read(databaseProvider)
        .addShoppingItem(
          ShoppingItemsCompanion.insert(
            name: ingredient,
            note: Value('For "${meal.title}"'),
            source: const Value('ai'),
          ),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"$ingredient" added to groceries.')),
      );
    }
  }

  Future<void> _logMeal(
    BuildContext context,
    WidgetRef ref,
    List<String> usedIngredients,
  ) async {
    final type = await showModalBottomSheet<MealType>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Log "${meal.title}" (${meal.kcal.round()} kcal) as:',
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            for (final type in MealType.values)
              ListTile(
                leading: Icon(type.icon, color: type.color),
                title: Text(type.label),
                onTap: () => Navigator.pop(sheetContext, type),
              ),
          ],
        ),
      ),
    );
    if (type == null) return;
    final db = ref.read(databaseProvider);
    await db.logConsumption(
      ConsumptionEntriesCompanion.insert(
        name: meal.title,
        kcal: meal.kcal,
        mealType: type.value,
      ),
    );
    await db.setSavedMealDone(meal.id);
    await db.addCookedMeal(
      CookedMealsCompanion.insert(title: meal.title, kcal: meal.kcal),
    );

    // Cooking used up ingredients: offer to adjust the kitchen quantities.
    if (!context.mounted) return;
    final pantry = await ref.read(pantryProvider.future);
    final used = matchUsedPantryItems(pantry, usedIngredients);
    if (!context.mounted) return;
    if (used.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged ${meal.kcal.round()} kcal. Enjoy!')),
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _UpdateKitchenSheet(mealTitle: meal.title, items: used),
    );
  }
}

/// Fuzzy-matches the AI's free-text ingredient names against pantry items.
/// Exposed for testing.
List<PantryItem> matchUsedPantryItems(
  List<PantryItem> pantry,
  List<String> ingredients,
) {
  Set<String> words(String s) => s
      .toLowerCase()
      .split(RegExp(r'[^a-zà-ÿ0-9]+'))
      .where((w) => w.length >= 3)
      .toSet();

  bool matches(PantryItem item, String ingredient) {
    final name = item.name.toLowerCase();
    final ing = ingredient.toLowerCase();
    if (name.contains(ing) || ing.contains(name)) return true;
    return words(item.name).intersection(words(ingredient)).isNotEmpty;
  }

  return [
    for (final item in pantry)
      if (!item.isConsumed && ingredients.any((i) => matches(item, i))) item,
  ];
}

/// After "I made it": sliders to estimate what is left of each ingredient
/// the meal used.
class _UpdateKitchenSheet extends ConsumerStatefulWidget {
  const _UpdateKitchenSheet({required this.mealTitle, required this.items});

  final String mealTitle;
  final List<PantryItem> items;

  @override
  ConsumerState<_UpdateKitchenSheet> createState() =>
      _UpdateKitchenSheetState();
}

class _UpdateKitchenSheetState extends ConsumerState<_UpdateKitchenSheet> {
  late final Map<int, double> _amounts = {
    for (final item in widget.items) item.id: item.amountLeft,
  };

  Future<void> _save() async {
    final db = ref.read(databaseProvider);
    for (final item in widget.items) {
      final amount = _amounts[item.id]!;
      if (amount != item.amountLeft) {
        await db.updatePantryItem(
          item.id,
          PantryItemsCompanion(amountLeft: Value(amount)),
        );
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Update your kitchen',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Estimate what is left of the ingredients "${widget.mealTitle}" '
              'used.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final item in widget.items)
                    _AmountRow(
                      item: item,
                      amount: _amounts[item.id]!,
                      onChanged: (v) => setState(() => _amounts[item.id] = v),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Save quantities'),
              onPressed: _save,
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Skip'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({
    required this.item,
    required this.amount,
    required this.onChanged,
  });

  final PantryItem item;
  final double amount;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = amountLeftColor(amount, scheme);
    final label = item.isUnitBased
        ? '${(amount * item.unitCount!).round()}/${item.unitCount}'
        : '${(amount * 100).round()}%';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.name, style: Theme.of(context).textTheme.titleSmall),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: amount,
                divisions: item.isUnitBased ? item.unitCount : 20,
                activeColor: color,
                onChanged: onChanged,
              ),
            ),
            SizedBox(
              width: 56,
              child: Text(
                label,
                textAlign: TextAlign.end,
                style: TextStyle(fontWeight: FontWeight.w700, color: color),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
