import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/database.dart';
import '../../data/kitchen_category.dart';
import '../../data/quantity.dart';
import '../../data/services/off_service.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import '../../widgets/log_portion_sheet.dart';

/// Color of the "amount left" indicator: green when plenty, amber when
/// running low, red when almost gone.
Color amountLeftColor(double amountLeft, ColorScheme scheme) {
  if (amountLeft > 0.5) return const Color(0xFF3E9B4F);
  if (amountLeft > 0.2) return const Color(0xFFE8930C);
  return scheme.error;
}

class KitchenPage extends ConsumerStatefulWidget {
  const KitchenPage({super.key});

  @override
  ConsumerState<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends ConsumerState<KitchenPage> {
  final _searchController = TextEditingController();
  bool _perishableOnly = false;
  bool _showFinished = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PantryItem> _visibleItems(List<PantryItem> pantry) {
    final query = _searchController.text.trim().toLowerCase();
    return [
      for (final item in pantry)
        if (item.isConsumed == _showFinished &&
            (!_perishableOnly || item.perishable) &&
            (query.isEmpty ||
                item.name.toLowerCase().contains(query) ||
                (item.brand?.toLowerCase().contains(query) ?? false)))
          item,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final pantry = ref.watch(pantryProvider).value ?? [];
    final visible = _visibleItems(pantry);
    final finishedCount = pantry.where((i) => i.isConsumed).length;

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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search your kitchen…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  setState(_searchController.clear),
                            ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      FilterChip(
                        avatar: Icon(
                          Icons.eco,
                          size: 18,
                          color: _perishableOnly
                              ? Theme.of(context).colorScheme.onPrimary
                              : const Color(0xFFE8930C),
                        ),
                        label: const Text('Perishable'),
                        selected: _perishableOnly,
                        selectedColor: const Color(0xFFE8930C),
                        showCheckmark: false,
                        onSelected: (v) => setState(() => _perishableOnly = v),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        avatar: Icon(
                          Icons.hourglass_empty,
                          size: 18,
                          color: _showFinished
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        label: Text('Finished ($finishedCount)'),
                        selected: _showFinished,
                        selectedColor: Theme.of(context).colorScheme.error,
                        showCheckmark: false,
                        onSelected: (v) => setState(() => _showFinished = v),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? const EmptyState(
                          icon: Icons.search_off,
                          title: 'Nothing matches',
                          message:
                              'No item matches the current search or filters.',
                        )
                      : _DrawerList(items: visible),
                ),
              ],
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

/// The pantry organized into collapsible "drawers" (fridge, cupboard…).
class _DrawerList extends StatelessWidget {
  const _DrawerList({required this.items});

  final List<PantryItem> items;

  @override
  Widget build(BuildContext context) {
    final grouped = <KitchenCategory, List<PantryItem>>{};
    for (final item in items) {
      grouped
          .putIfAbsent(KitchenCategory.fromValue(item.category), () => [])
          .add(item);
    }
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
      children: [
        for (final category in KitchenCategory.values)
          if (grouped[category] case final drawer?)
            ExpansionTile(
              initiallyExpanded: true,
              maintainState: true,
              shape: const Border(),
              collapsedShape: const Border(),
              tilePadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: Icon(category.icon, color: scheme.primary),
              title: Text(
                '${category.label} · ${drawer.length}',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              children: [
                for (final item in drawer)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PantryCard(item: item),
                  ),
              ],
            ),
      ],
    );
  }
}

class _PantryCard extends ConsumerStatefulWidget {
  const _PantryCard({required this.item});

  final PantryItem item;

  @override
  ConsumerState<_PantryCard> createState() => _PantryCardState();
}

class _PantryCardState extends ConsumerState<_PantryCard> {
  bool _expanded = false;
  double? _pendingAmount;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final scheme = Theme.of(context).colorScheme;
    final amount = _pendingAmount ?? item.amountLeft;
    final color = amountLeftColor(amount, scheme);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // The adjust slider only appears once you tap the item.
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
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
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.name,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (item.perishable)
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(
                                  Icons.eco,
                                  size: 16,
                                  color: Color(0xFFE8930C),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          [
                            if (item.brand != null) item.brand!,
                            if (item.packageQuantity != null)
                              item.packageQuantity!,
                            if (item.unitCount != null)
                              '${item.unitCount} units',
                            if (item.kcalPer100g != null)
                              '${item.kcalPer100g!.round()} kcal/100g',
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'I ate some',
                    icon: const Icon(Icons.restaurant),
                    color: scheme.primary,
                    onPressed: item.isConsumed ? null : () => _eatSome(),
                  ),
                  IconButton(
                    tooltip: 'Add to groceries',
                    icon: const Icon(Icons.add_shopping_cart),
                    color: scheme.tertiary,
                    onPressed: () => _addToGroceries(),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _onMenu(value),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(
                        value: 'refill',
                        child: Text('Refill to 100%'),
                      ),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_expanded) ...[
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: amount,
                        divisions: item.isUnitBased ? item.unitCount : 20,
                        activeColor: color,
                        onChanged: (v) => setState(() => _pendingAmount = v),
                        onChangeEnd: (v) {
                          setState(() => _pendingAmount = null);
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
                      width: 56,
                      child: Text(
                        _amountLabel(item, amount),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: amount,
                            minHeight: 6,
                            color: color,
                            backgroundColor: scheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        item.isConsumed
                            ? 'Finished'
                            : _amountLabel(item, amount),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _amountLabel(PantryItem item, double amount) {
    if (item.isUnitBased) {
      final units = (amount * item.unitCount!).round().clamp(
        0,
        item.unitCount!,
      );
      return '$units/${item.unitCount}';
    }
    return '${(amount * 100).round()}%';
  }

  Future<void> _eatSome() => eatPantryItemFlow(context, ref, widget.item);

  Future<void> _addToGroceries() async {
    await ref
        .read(databaseProvider)
        .addShoppingItem(ShoppingItemsCompanion.insert(name: widget.item.name));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${widget.item.name}" added to groceries.')),
      );
    }
  }

  Future<void> _onMenu(String value) async {
    final db = ref.read(databaseProvider);
    switch (value) {
      case 'edit':
        await showPantryEditSheet(context, ref, existing: widget.item);
      case 'refill':
        await db.updatePantryItem(
          widget.item.id,
          const PantryItemsCompanion(amountLeft: Value(1.0)),
        );
      case 'delete':
        final item = widget.item;
        final messenger = ScaffoldMessenger.of(context);
        await db.deletePantryItem(item.id);
        messenger.showSnackBar(
          SnackBar(
            content: Text('Deleted "${item.name}".'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => db.addPantryItem(
                PantryItemsCompanion.insert(
                  name: item.name,
                  barcode: Value(item.barcode),
                  brand: Value(item.brand),
                  imageUrl: Value(item.imageUrl),
                  kcalPer100g: Value(item.kcalPer100g),
                  proteinsPer100g: Value(item.proteinsPer100g),
                  carbsPer100g: Value(item.carbsPer100g),
                  sugarsPer100g: Value(item.sugarsPer100g),
                  fatsPer100g: Value(item.fatsPer100g),
                  packageQuantity: Value(item.packageQuantity),
                  unitCount: Value(item.unitCount),
                  perishable: Value(item.perishable),
                  category: Value(item.category),
                  amountLeft: Value(item.amountLeft),
                  addedAt: Value(item.addedAt),
                ),
              ),
            ),
          ),
        );
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
                color: scheme.secondaryContainer,
                child: Icon(Icons.fastfood, color: scheme.onSecondaryContainer),
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: scheme.secondaryContainer,
                  child: Icon(
                    Icons.fastfood,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
      ),
    );
  }
}

/// Add/edit sheet, optionally pre-filled from an Open Food Facts [product],
/// an [existing] pantry item, or just an [initialName] (e.g. coming from a
/// checked-off grocery).
Future<void> showPantryEditSheet(
  BuildContext context,
  WidgetRef ref, {
  OffProduct? product,
  PantryItem? existing,
  String? barcode,
  String? initialName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _PantryEditSheet(
      product: product,
      existing: existing,
      barcode: barcode,
      initialName: initialName,
    ),
  );
}

class _PantryEditSheet extends ConsumerStatefulWidget {
  const _PantryEditSheet({
    this.product,
    this.existing,
    this.barcode,
    this.initialName,
  });

  final OffProduct? product;
  final PantryItem? existing;
  final String? barcode;
  final String? initialName;

  @override
  ConsumerState<_PantryEditSheet> createState() => _PantryEditSheetState();
}

class _PantryEditSheetState extends ConsumerState<_PantryEditSheet> {
  late final TextEditingController _name;
  late final TextEditingController _brand;
  late final TextEditingController _kcal;
  late final TextEditingController _package;
  late final TextEditingController _units;
  late bool _perishable;
  late KitchenCategory _category;
  bool _categoryTouched = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    final e = widget.existing;
    _category = KitchenCategory.fromValue(e?.category ?? 'cupboard');
    _categoryTouched = e != null;
    _name = TextEditingController(
      text: e?.name ?? p?.name ?? widget.initialName ?? '',
    );
    _brand = TextEditingController(text: e?.brand ?? p?.brand ?? '');
    _kcal = TextEditingController(
      text: (e?.kcalPer100g ?? p?.kcalPer100g)?.round().toString() ?? '',
    );
    _package = TextEditingController(
      text: e?.packageQuantity ?? p?.quantity ?? '',
    );
    _units = TextEditingController(text: e?.unitCount?.toString() ?? '');
    _perishable = e?.perishable ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _kcal.dispose();
    _package.dispose();
    _units.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final db = ref.read(databaseProvider);
    final kcal = double.tryParse(_kcal.text.replaceAll(',', '.'));
    final brand = _brand.text.trim();
    final package = _package.text.trim();
    final units = int.tryParse(_units.text.trim());
    final p = widget.product;

    if (widget.existing != null) {
      await db.updatePantryItem(
        widget.existing!.id,
        PantryItemsCompanion(
          name: Value(name),
          brand: Value(brand.isEmpty ? null : brand),
          kcalPer100g: Value(kcal),
          packageQuantity: Value(package.isEmpty ? null : package),
          unitCount: Value((units ?? 0) > 0 ? units : null),
          perishable: Value(_perishable),
          category: Value(_category.value),
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
          unitCount: Value((units ?? 0) > 0 ? units : null),
          perishable: Value(_perishable),
          category: Value(_category.value),
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
          const SizedBox(height: 12),
          TextField(
            controller: _units,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Units per package (e.g. 12 eggs — optional)',
              helperText: 'When set, quantities are tracked in units, not %',
            ),
          ),
          DropdownMenu<KitchenCategory>(
            key: ValueKey(_category),
            initialSelection: _category,
            label: const Text('Drawer'),
            expandedInsets: EdgeInsets.zero,
            dropdownMenuEntries: [
              for (final category in KitchenCategory.values)
                DropdownMenuEntry(
                  value: category,
                  label: category.label,
                  leadingIcon: Icon(category.icon, size: 20),
                ),
            ],
            onSelected: (value) {
              if (value == null) return;
              setState(() {
                _category = value;
                _categoryTouched = true;
              });
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Perishable'),
            subtitle: const Text('Fresh food that should be eaten first'),
            secondary: const Icon(Icons.eco, color: Color(0xFFE8930C)),
            value: _perishable,
            onChanged: (v) => setState(() {
              _perishable = v;
              // Perishable food obviously lives in the fridge — until the
              // user says otherwise.
              if (!_categoryTouched) {
                _category = v
                    ? KitchenCategory.fridge
                    : KitchenCategory.cupboard;
              }
            }),
          ),
          const SizedBox(height: 8),
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
