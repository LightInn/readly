import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/database.dart';
import '../../data/services/anthropic_service.dart';
import '../../providers.dart';
import '../../widgets/common.dart';

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
    final anthropic = await ref.read(anthropicServiceProvider.future);
    if (!mounted) return;
    if (anthropic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your Anthropic API key in settings first.'),
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

      final suggestions = await anthropic.suggestGroceries(
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
          ),
        );
        added++;
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Added $added AI suggestions.')));
      }
    } on AnthropicException catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(shoppingProvider).value ?? [];
    final hasDone = items.any((i) => i.done);

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
                        onDismissed: (_) => ref
                            .read(databaseProvider)
                            .deleteShoppingItem(item.id),
                        child: CheckboxListTile(
                          value: item.done,
                          onChanged: (value) => ref
                              .read(databaseProvider)
                              .setShoppingDone(item.id, value ?? false),
                          title: Text(
                            item.name,
                            style: item.done
                                ? const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                  )
                                : null,
                          ),
                          subtitle: item.note == null
                              ? null
                              : Text(
                                  item.note!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
