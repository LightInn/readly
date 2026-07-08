import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/database.dart';
import '../../data/meal_type.dart';
import '../../data/services/anthropic_service.dart';
import '../../providers.dart';
import '../../widgets/common.dart';

class MealsPage extends ConsumerWidget {
  const MealsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(mealSuggestionsProvider);
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
      body: switch (suggestions) {
        null => _Idle(hasApiKey: hasApiKey),
        AsyncLoading() => const _Loading(),
        AsyncError(:final error) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not get suggestions',
          message: error is AnthropicException ? error.message : '$error',
          action: FilledButton(
            onPressed: () =>
                ref.read(mealSuggestionsProvider.notifier).generate(),
            child: const Text('Try again'),
          ),
        ),
        AsyncValue(:final value?) => _SuggestionList(meals: value),
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
            'Add your Anthropic API key in settings to unlock meal '
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

class _SuggestionList extends ConsumerWidget {
  const _SuggestionList({required this.meals});

  final List<MealSuggestion> meals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
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
    );
  }
}

class _MealCard extends ConsumerWidget {
  const _MealCard({required this.meal});

  final MealSuggestion meal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
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
                  avatar: const Icon(Icons.schedule, size: 18),
                  label: Text('${meal.timeMinutes} min'),
                ),
                Chip(
                  avatar: const Icon(Icons.local_fire_department, size: 18),
                  label: Text('${meal.kcal.round()} kcal'),
                ),
              ],
            ),
            if (meal.usedIngredients.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'From your kitchen',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                meal.usedIngredients.join(' · '),
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ],
            if (meal.missingIngredients.isNotEmpty) ...[
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
                  for (final ingredient in meal.missingIngredients)
                    ActionChip(
                      avatar: const Icon(Icons.add_shopping_cart, size: 18),
                      label: Text(ingredient),
                      onPressed: () =>
                          _addToGroceries(context, ref, ingredient),
                    ),
                ],
              ),
            ],
            if (meal.steps.isNotEmpty) ...[
              const SizedBox(height: 8),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                shape: const Border(),
                title: Text(
                  'Steps',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                children: [
                  for (final (index, step) in meal.steps.indexed)
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
              child: FilledButton.tonalIcon(
                icon: const Icon(Icons.check),
                label: const Text('I made it'),
                onPressed: () => _logMeal(context, ref),
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

  Future<void> _logMeal(BuildContext context, WidgetRef ref) async {
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
                leading: Icon(type.icon),
                title: Text(type.label),
                onTap: () => Navigator.pop(sheetContext, type),
              ),
          ],
        ),
      ),
    );
    if (type == null) return;
    await ref
        .read(databaseProvider)
        .logConsumption(
          ConsumptionEntriesCompanion.insert(
            name: meal.title,
            kcal: meal.kcal,
            mealType: type.value,
          ),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged ${meal.kcal.round()} kcal. Enjoy!')),
      );
    }
  }
}
