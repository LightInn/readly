import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/db/database.dart';
import '../../data/meal_type.dart';
import '../../data/quantity.dart';
import '../../providers.dart';
import '../../widgets/common.dart';
import '../../widgets/log_portion_sheet.dart';

class TrackPage extends ConsumerWidget {
  const TrackPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(todayEntriesProvider).value ?? [];
    final goal = ref.watch(settingsProvider).value?.dailyKcalGoal ?? 2200;
    final consumed = entries.fold<double>(0, (sum, e) => sum + e.kcal);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Log food'),
        onPressed: () => _showLogMenu(context, ref),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          _KcalHeader(consumed: consumed, goal: goal),
          const _EatSoonCard(),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: EmptyState(
                icon: Icons.restaurant,
                title: 'Nothing logged yet',
                message:
                    'Scan a barcode, pick something from your kitchen or '
                    'quick-add whatever you just ate.',
              ),
            )
          else
            for (final type in MealType.values)
              ..._mealSection(context, ref, type, entries),
        ],
      ),
    );
  }

  List<Widget> _mealSection(
    BuildContext context,
    WidgetRef ref,
    MealType type,
    List<ConsumptionEntry> all,
  ) {
    final entries = all.where((e) => e.mealType == type.value).toList();
    if (entries.isEmpty) return const [];
    final subtotal = entries.fold<double>(0, (sum, e) => sum + e.kcal);
    return [
      SectionHeader(
        type.label,
        trailing: Text(
          '${subtotal.round()} kcal',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: type.color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      Card(
        child: Column(
          children: [
            for (final entry in entries)
              Dismissible(
                key: ValueKey('entry-${entry.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: const Icon(Icons.delete_outline),
                ),
                onDismissed: (_) async {
                  final db = ref.read(databaseProvider);
                  final messenger = ScaffoldMessenger.of(context);
                  await db.deleteConsumption(entry.id);
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Removed "${entry.name}".'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () => db.logConsumption(
                          ConsumptionEntriesCompanion.insert(
                            name: entry.name,
                            kcal: entry.kcal,
                            mealType: entry.mealType,
                            pantryItemId: Value(entry.pantryItemId),
                            grams: Value(entry.grams),
                            loggedAt: Value(entry.loggedAt),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 18,
                    backgroundColor: type.tint,
                    child: Icon(type.icon, size: 20, color: type.color),
                  ),
                  title: Text(entry.name),
                  subtitle: entry.grams == null
                      ? null
                      : Text('${entry.grams!.round()} g'),
                  trailing: Text(
                    '${entry.kcal.round()} kcal',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
      ),
    ];
  }

  void _showLogMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code_scanner),
              title: const Text('Scan a barcode'),
              subtitle: const Text('Look up nutrition on Open Food Facts'),
              onTap: () {
                Navigator.pop(sheetContext);
                _scanAndLog(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.kitchen),
              title: const Text('From my kitchen'),
              subtitle: const Text('Log something from your pantry'),
              onTap: () {
                Navigator.pop(sheetContext);
                _logFromPantry(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bolt),
              title: const Text('Quick add'),
              subtitle: const Text('Just a name and kcal'),
              onTap: () {
                Navigator.pop(sheetContext);
                _quickAdd(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanAndLog(BuildContext context, WidgetRef ref) async {
    final code = await context.push<String>('/scan');
    if (code == null || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Looking up product…')),
    );
    try {
      final product = await ref.read(offServiceProvider).fetchProduct(code);
      messenger.hideCurrentSnackBar();
      if (!context.mounted) return;
      if (product == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Product not found — use quick add instead.'),
          ),
        );
        await _quickAdd(context, ref);
        return;
      }
      final result = await showLogPortionSheet(
        context,
        foodName: product.name,
        kcalPer100g: product.kcalPer100g,
        packageGrams:
            parsePackageGrams(product.quantity) ?? product.servingGrams,
        packageLabel: product.quantity,
      );
      if (result == null) return;
      await ref
          .read(databaseProvider)
          .logConsumption(
            ConsumptionEntriesCompanion.insert(
              name: product.name,
              kcal: result.kcal,
              mealType: result.mealType.value,
              grams: Value(result.grams),
            ),
          );
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text('Lookup failed: $e')));
    }
  }

  Future<void> _logFromPantry(BuildContext context, WidgetRef ref) async {
    final pantry = await ref.read(pantryProvider.future);
    if (!context.mounted) return;
    if (pantry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your kitchen is empty — scan items in the Kitchen tab first.',
          ),
        ),
      );
      return;
    }
    final item = await showModalBottomSheet<PantryItem>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final item in pantry)
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text(item.name),
                subtitle: item.kcalPer100g == null
                    ? null
                    : Text('${item.kcalPer100g!.round()} kcal / 100 g'),
                onTap: () => Navigator.pop(sheetContext, item),
              ),
          ],
        ),
      ),
    );
    if (item == null || !context.mounted) return;
    final result = await showEatPantryItemSheet(context, item);
    if (result == null) return;
    final db = ref.read(databaseProvider);
    await db.logConsumption(
      ConsumptionEntriesCompanion.insert(
        name: item.name,
        kcal: result.kcal,
        mealType: result.mealType.value,
        pantryItemId: Value(item.id),
        grams: Value(result.grams),
      ),
    );
    // The slider estimates what was eaten, so keep the pantry stock in sync.
    await db.updatePantryItem(
      item.id,
      PantryItemsCompanion(
        amountLeft: Value((item.amountLeft - result.fraction).clamp(0.0, 1.0)),
      ),
    );
  }

  Future<void> _quickAdd(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<(String, double, MealType)>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _QuickAddSheet(),
    );
    if (result == null) return;
    await ref
        .read(databaseProvider)
        .logConsumption(
          ConsumptionEntriesCompanion.insert(
            name: result.$1,
            kcal: result.$2,
            mealType: result.$3.value,
          ),
        );
  }
}

/// Perishable items that are not finished yet — eat these first.
/// Hidden when there is nothing perishable in the kitchen.
class _EatSoonCard extends ConsumerWidget {
  const _EatSoonCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantry = ref.watch(pantryProvider).value ?? [];
    final perishables = [
      for (final item in pantry)
        if (item.perishable && !item.isConsumed) item,
    ];
    if (perishables.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        color: scheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.eco, size: 18, color: Color(0xFFE8930C)),
                  const SizedBox(width: 8),
                  Text(
                    'Eat these first',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in perishables.take(6))
                    ActionChip(
                      avatar: const Icon(Icons.restaurant, size: 16),
                      label: Text('${item.name} · ${item.amountLabel}'),
                      onPressed: () => eatPantryItemFlow(context, ref, item),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KcalHeader extends StatelessWidget {
  const _KcalHeader({required this.consumed, required this.goal});

  final double consumed;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final remaining = goal - consumed;
    final over = remaining < 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: goal == 0 ? 0 : consumed / goal,
                  background: scheme.surfaceContainerHighest,
                  foreground: over ? scheme.error : scheme.primary,
                  foregroundEnd: over ? scheme.error : scheme.tertiary,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        consumed.round().toString(),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'kcal',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    over
                        ? '${remaining.abs().round()} kcal over'
                        : '${remaining.round()} kcal left',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Goal: $goal kcal',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.background,
    required this.foreground,
    required this.foregroundEnd,
  });

  final double progress;
  final Color background;
  final Color foreground;
  final Color foregroundEnd;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 12.0;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = background
      ..strokeCap = StrokeCap.round;
    final foregroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        transform: const GradientRotation(-math.pi / 2),
        colors: [foreground, foregroundEnd],
      ).createShader(arcRect)
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, 0, 2 * math.pi, false, backgroundPaint);
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.foreground != foreground ||
      oldDelegate.foregroundEnd != foregroundEnd ||
      oldDelegate.background != background;
}

class _QuickAddSheet extends StatefulWidget {
  const _QuickAddSheet();

  @override
  State<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<_QuickAddSheet> {
  final _nameController = TextEditingController();
  final _kcalController = TextEditingController();
  MealType _mealType = MealType.suggestedNow();

  @override
  void dispose() {
    _nameController.dispose();
    _kcalController.dispose();
    super.dispose();
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
          Text('Quick add', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'What did you eat?'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _kcalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'kcal'),
          ),
          const SizedBox(height: 20),
          SegmentedButton<MealType>(
            segments: [
              for (final type in MealType.values)
                ButtonSegment(value: type, icon: Icon(type.icon, size: 18)),
            ],
            selected: {_mealType},
            onSelectionChanged: (selection) =>
                setState(() => _mealType = selection.first),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Log it'),
            onPressed: () {
              final name = _nameController.text.trim();
              final kcal = double.tryParse(
                _kcalController.text.replaceAll(',', '.'),
              );
              if (name.isEmpty || kcal == null) return;
              Navigator.of(context).pop((name, kcal, _mealType));
            },
          ),
        ],
      ),
    );
  }
}
