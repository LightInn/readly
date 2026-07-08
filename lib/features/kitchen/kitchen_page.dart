import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/database.dart';
import '../../data/services/off_service.dart';
import '../../providers.dart';
import '../../widgets/common.dart';

class KitchenPage extends ConsumerWidget {
  const KitchenPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantry = ref.watch(pantryProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
        onPressed: () => _showAddMenu(context, ref),
      ),
      body: pantry.isEmpty
          ? const EmptyState(
              icon: Icons.kitchen,
              title: 'Your kitchen is empty',
              message:
                  'Scan the barcodes of what you have at home to build your '
                  'inventory — the meal maker uses it to suggest what to cook.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: pantry.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _PantryCard(item: pantry[index]),
            ),
    );
  }

  void _showAddMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scan a barcode'),
              subtitle: const Text('Fill in details from Open Food Facts'),
              onTap: () {
                Navigator.pop(sheetContext);
                _scanAndAdd(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Add manually'),
              onTap: () {
                Navigator.pop(sheetContext);
                showPantryEditSheet(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanAndAdd(BuildContext context, WidgetRef ref) async {
    final code = await context.push<String>('/scan');
    if (code == null || !context.mounted) return;

    final db = ref.read(databaseProvider);
    final existing = await db.pantryItemByBarcode(code);
    if (!context.mounted) return;
    if (existing != null) {
      // Re-scanning something you own: treat it as a fresh, full package.
      await db.updatePantryItem(
        existing.id,
        const PantryItemsCompanion(amountLeft: Value(1.0)),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${existing.name}" refilled to 100%.')),
        );
      }
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Looking up product…')),
    );
    OffProduct? product;
    try {
      product = await ref.read(offServiceProvider).fetchProduct(code);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Lookup failed: $e')));
    }
    messenger.hideCurrentSnackBar();
    if (!context.mounted) return;
    await showPantryEditSheet(context, ref, product: product, barcode: code);
  }
}

class _PantryCard extends ConsumerStatefulWidget {
  const _PantryCard({required this.item});

  final PantryItem item;

  @override
  ConsumerState<_PantryCard> createState() => _PantryCardState();
}

class _PantryCardState extends ConsumerState<_PantryCard> {
  double? _pendingAmount;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final scheme = Theme.of(context).colorScheme;
    final amount = _pendingAmount ?? item.amountLeft;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Thumbnail(imageUrl: item.imageUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        [
                          if (item.brand != null) item.brand!,
                          if (item.packageQuantity != null)
                            item.packageQuantity!,
                          if (item.kcalPer100g != null)
                            '${item.kcalPer100g!.round()} kcal/100g',
                        ].join(' · '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _onMenu(value),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(
                      value: 'shop',
                      child: Text('Add to groceries'),
                    ),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: amount,
                    onChanged: (v) => setState(() => _pendingAmount = v),
                    onChangeEnd: (v) {
                      ref
                          .read(databaseProvider)
                          .updatePantryItem(
                            item.id,
                            PantryItemsCompanion(amountLeft: Value(v)),
                          );
                    },
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    '${(amount * 100).round()}%',
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onMenu(String value) async {
    final db = ref.read(databaseProvider);
    switch (value) {
      case 'edit':
        await showPantryEditSheet(context, ref, existing: widget.item);
      case 'shop':
        await db.addShoppingItem(
          ShoppingItemsCompanion.insert(name: widget.item.name),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${widget.item.name}" added to groceries.'),
            ),
          );
        }
      case 'delete':
        await db.deletePantryItem(widget.item.id);
    }
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 52,
        height: 52,
        child: imageUrl == null
            ? ColoredBox(
                color: scheme.surfaceContainerHigh,
                child: Icon(Icons.fastfood, color: scheme.onSurfaceVariant),
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: scheme.surfaceContainerHigh,
                  child: Icon(Icons.fastfood, color: scheme.onSurfaceVariant),
                ),
              ),
      ),
    );
  }
}

/// Add/edit sheet, optionally pre-filled from an Open Food Facts [product]
/// or an [existing] pantry item.
Future<void> showPantryEditSheet(
  BuildContext context,
  WidgetRef ref, {
  OffProduct? product,
  PantryItem? existing,
  String? barcode,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _PantryEditSheet(
      product: product,
      existing: existing,
      barcode: barcode,
    ),
  );
}

class _PantryEditSheet extends ConsumerStatefulWidget {
  const _PantryEditSheet({this.product, this.existing, this.barcode});

  final OffProduct? product;
  final PantryItem? existing;
  final String? barcode;

  @override
  ConsumerState<_PantryEditSheet> createState() => _PantryEditSheetState();
}

class _PantryEditSheetState extends ConsumerState<_PantryEditSheet> {
  late final TextEditingController _name;
  late final TextEditingController _brand;
  late final TextEditingController _kcal;
  late final TextEditingController _package;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? p?.name ?? '');
    _brand = TextEditingController(text: e?.brand ?? p?.brand ?? '');
    _kcal = TextEditingController(
      text: (e?.kcalPer100g ?? p?.kcalPer100g)?.round().toString() ?? '',
    );
    _package = TextEditingController(
      text: e?.packageQuantity ?? p?.quantity ?? '',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _kcal.dispose();
    _package.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final db = ref.read(databaseProvider);
    final kcal = double.tryParse(_kcal.text.replaceAll(',', '.'));
    final brand = _brand.text.trim();
    final package = _package.text.trim();
    final p = widget.product;

    if (widget.existing != null) {
      await db.updatePantryItem(
        widget.existing!.id,
        PantryItemsCompanion(
          name: Value(name),
          brand: Value(brand.isEmpty ? null : brand),
          kcalPer100g: Value(kcal),
          packageQuantity: Value(package.isEmpty ? null : package),
        ),
      );
    } else {
      await db.addPantryItem(
        PantryItemsCompanion.insert(
          name: name,
          barcode: Value(widget.barcode ?? p?.barcode),
          brand: Value(brand.isEmpty ? null : brand),
          imageUrl: Value(p?.imageUrl),
          kcalPer100g: Value(kcal),
          proteinsPer100g: Value(p?.proteinsPer100g),
          carbsPer100g: Value(p?.carbsPer100g),
          sugarsPer100g: Value(p?.sugarsPer100g),
          fatsPer100g: Value(p?.fatsPer100g),
          packageQuantity: Value(package.isEmpty ? null : package),
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing == null ? 'Add to kitchen' : 'Edit item',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _brand,
            decoration: const InputDecoration(labelText: 'Brand (optional)'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _kcal,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'kcal / 100 g'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _package,
                  decoration: const InputDecoration(
                    labelText: 'Package (e.g. 500 g)',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            icon: const Icon(Icons.check),
            label: Text(widget.existing == null ? 'Add item' : 'Save'),
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
