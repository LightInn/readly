import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/database.dart';
import '../../data/services/ai_service.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import '../kitchen/kitchen_page.dart' show showPantryEditSheet;

class GroceriesPage extends ConsumerStatefulWidget {
  const GroceriesPage({super.key});

  @override
  ConsumerState<GroceriesPage> createState() => _GroceriesPageState();
}

class _GroceriesPageState extends ConsumerState<GroceriesPage> {
  final _addController = TextEditingController();
  bool _aiLoading = false;

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  Future<void> _addManual() async {
    final name = _addController.text.trim();
    if (name.isEmpty) return;
    _addController.clear();
    await ref
        .read(databaseProvider)
        .addShoppingItem(ShoppingItemsCompanion.insert(name: name));
  }

  Future<void> _askAi() async {
    final ai = await ref.read(aiServiceProvider.future);
    if (!mounted) return;
    if (ai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your OpenAI API key in settings first.'),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ),
      );
      return;
    }

    setState(() => _aiLoading = true);
    try {
      final db = ref.read(databaseProvider);
      final settings = await ref.read(settingsProvider.future);
      final pantry = await ref.read(pantryProvider.future);
      final current = await ref.read(shoppingProvider.future);
      final recent = await db.entriesSince(
        DateTime.now().subtract(const Duration(days: 14)),
      );

      final suggestions = await ai.suggestGroceries(
        pantry: [
          for (final item in pantry)
            {
              'name': item.name,
              'amount_left_percent': (item.amountLeft * 100).round(),
            },
        ],
        recentlyEaten: recent.map((e) => e.name).toSet().take(30).toList(),
        alreadyOnList: current.map((i) => i.name).toList(),
        language: settings.language,
      );

      final existingNames = current.map((i) => i.name.toLowerCase()).toSet();
      var added = 0;
      for (final suggestion in suggestions) {
        if (existingNames.contains(suggestion.name.toLowerCase())) continue;
        await db.addShoppingItem(
          ShoppingItemsCompanion.insert(
            name: suggestion.name,
            note: Value(suggestion.reason),
            source: const Value('ai'),
            quantity: Value(suggestion.quantity),
            estimatedPrice: Value(suggestion.priceEur),
          ),
        );
        added++;
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Added $added AI suggestions.')));
      }
    } on AiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Suggestion failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _aiLoading = false);
    }
  }

  /// "note · 500 g · ~2.50 €" — whatever is known about the item.
  static Widget? _subtitleFor(ShoppingItem item) {
    final parts = [
      if (item.note != null) item.note!,
      if (item.quantity != null) item.quantity!,
      if (item.estimatedPrice != null)
        '~${item.estimatedPrice!.toStringAsFixed(2)} €',
    ];
    if (parts.isEmpty) return null;
    return Text(
      parts.join(' · '),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Future<void> _deleteWithUndo(ShoppingItem item) async {
    final db = ref.read(databaseProvider);
    final messenger = ScaffoldMessenger.of(context);
    await db.deleteShoppingItem(item.id);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Removed "${item.name}".'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => db.addShoppingItem(
            ShoppingItemsCompanion.insert(
              name: item.name,
              note: Value(item.note),
              done: Value(item.done),
              source: Value(item.source),
              quantity: Value(item.quantity),
              estimatedPrice: Value(item.estimatedPrice),
              addedAt: Value(item.addedAt),
            ),
          ),
        ),
      ),
    );
  }

  /// Checking something off means it was bought — offer to put it in the
  /// kitchen (refill if it already exists there, otherwise quick-add).
  Future<void> _setDone(ShoppingItem item, bool done) async {
    final db = ref.read(databaseProvider);
    final messenger = ScaffoldMessenger.of(context);
    await db.setShoppingDone(item.id, done);
    if (!done) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Bought "${item.name}"!'),
        action: SnackBarAction(
          label: 'To kitchen',
          onPressed: () => _addBoughtToKitchen(item.name),
        ),
      ),
    );
  }

  Future<void> _addBoughtToKitchen(String name) async {
    final db = ref.read(databaseProvider);
    final messenger = ScaffoldMessenger.of(context);
    final pantry = await ref.read(pantryProvider.future);
    final query = name.trim().toLowerCase();
    PantryItem? match;
    for (final item in pantry) {
      final itemName = item.name.toLowerCase();
      if (itemName == query ||
          itemName.contains(query) ||
          query.contains(itemName)) {
        match = item;
        break;
      }
    }
    if (match != null) {
      await db.updatePantryItem(
        match.id,
        const PantryItemsCompanion(amountLeft: Value(1.0)),
      );
      messenger.showSnackBar(
        SnackBar(content: Text('"${match.name}" refilled to 100%.')),
      );
      return;
    }
    if (!mounted) return;
    await showPantryEditSheet(context, ref, initialName: name.trim());
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(shoppingProvider).value ?? [];
    final hasDone = items.any((i) => i.done);
    // Rough cart total for what still has to be bought.
    final remainingPrice = items
        .where((i) => !i.done && i.estimatedPrice != null)
        .fold<double>(0, (sum, i) => sum + i.estimatedPrice!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groceries'),
        actions: [
          if (hasDone)
            IconButton(
              tooltip: 'Clear checked items',
              icon: const Icon(Icons.playlist_remove),
              onPressed: () => ref.read(databaseProvider).clearDoneShopping(),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: _aiLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.auto_awesome),
        label: const Text('What should I buy?'),
        onPressed: _aiLoading ? null : _askAi,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _addController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Add an item…',
                prefixIcon: const Icon(Icons.add),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_upward),
                  onPressed: _addManual,
                ),
              ),
              onSubmitted: (_) => _addManual(),
            ),
          ),
          if (remainingPrice > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.shopping_cart_checkout,
                    size: 18,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estimated cart: ≈ ${remainingPrice.toStringAsFixed(2)} €',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    icon: Icons.shopping_basket,
                    title: 'Nothing to buy',
                    message:
                        'Add items yourself, or let the AI propose what to '
                        'buy based on your kitchen and eating habits.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Dismissible(
                        key: ValueKey('shop-${item.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: const Icon(Icons.delete_outline),
                        ),
                        onDismissed: (_) => _deleteWithUndo(item),
                        child: CheckboxListTile(
                          value: item.done,
                          onChanged: (value) => _setDone(item, value ?? false),
                          title: Text(
                            item.name,
                            style: item.done
                                ? const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                  )
                                : null,
                          ),
                          subtitle: _subtitleFor(item),
                          secondary: item.source == 'ai'
                              ? const Icon(Icons.auto_awesome, size: 18)
                              : null,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
