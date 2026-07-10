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

/// Rough kcal estimates for typical work-lunch restaurant meals — logging
/// something imprecise beats logging nothing.
const restaurantPresets = <(String, double)>[
  ('Poké saumon', 650),
  ('Poké poulet', 600),
  ('Poké africain', 750),
  ('Curry indien + riz', 850),
  ('Bento', 700),
  ('Kebab', 950),
  ('Burger + frites', 1100),
  ('Salade repas', 500),
];

String _dayLabel(DateTime day) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${weekdays[day.weekday - 1]} ${day.day} ${months[day.month - 1]}';
}

class TrackPage extends ConsumerWidget {
  const TrackPage({super.key});

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day) == day;
  }

  /// Logs land at "now" for today, midday for a past day being reviewed.
  DateTime? _logTimestamp(DateTime day) =>
      _isToday(day) ? null : day.add(const Duration(hours: 12));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(selectedDayProvider);
    final entries = ref.watch(selectedDayEntriesProvider).value ?? [];
    final settings = ref.watch(settingsProvider).value;
    final goal = settings?.dailyKcalGoal ?? 2200;
    final threshold = settings?.cheatThresholdKcal ?? 200;
    final consumed = entries.fold<double>(0, (sum, e) => sum + e.kcal);
    final isToday = _isToday(day);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track'),
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
        onPressed: () => _showLogMenu(context, ref, day),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
        children: [
          _DayNavigator(day: day, isToday: isToday),
          _KcalHeader(consumed: consumed, goal: goal, threshold: threshold),
          const SizedBox(height: 12),
          const _ProgressCard(),
          const _WeightGoalCard(),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: EmptyState(
                icon: Icons.restaurant,
                title: isToday ? 'Nothing logged yet' : 'Nothing logged',
                message: isToday
                    ? 'Scan a barcode, pick something from your kitchen or '
                          'quick-add whatever you just ate.'
                    : 'No food was logged on this day.',
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
                  onTap: () => _editEntry(context, ref, entry),
                ),
              ),
          ],
        ),
      ),
    ];
  }

  Future<void> _editEntry(
    BuildContext context,
    WidgetRef ref,
    ConsumptionEntry entry,
  ) async {
    final result = await showModalBottomSheet<(String, double, MealType)>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditEntrySheet(entry: entry),
    );
    if (result == null) return;
    await ref
        .read(databaseProvider)
        .updateConsumption(
          entry.id,
          ConsumptionEntriesCompanion(
            name: Value(result.$1),
            kcal: Value(result.$2),
            mealType: Value(result.$3.value),
          ),
        );
  }

  void _showLogMenu(BuildContext context, WidgetRef ref, DateTime day) {
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
                _scanAndLog(context, ref, day);
              },
            ),
            ListTile(
              leading: const Icon(Icons.kitchen),
              title: const Text('From my kitchen'),
              subtitle: const Text('Log something from your pantry'),
              onTap: () {
                Navigator.pop(sheetContext);
                _logFromPantry(context, ref, day);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bolt),
              title: const Text('Quick add'),
              subtitle: const Text('A name and kcal — restaurant presets too'),
              onTap: () {
                Navigator.pop(sheetContext);
                _quickAdd(context, ref, day);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanAndLog(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
  ) async {
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
        await _quickAdd(context, ref, day);
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
      final loggedAt = _logTimestamp(day);
      await ref
          .read(databaseProvider)
          .logConsumption(
            ConsumptionEntriesCompanion.insert(
              name: product.name,
              kcal: result.kcal,
              mealType: result.mealType.value,
              grams: Value(result.grams),
              loggedAt: loggedAt == null
                  ? const Value.absent()
                  : Value(loggedAt),
            ),
          );
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text('Lookup failed: $e')));
    }
  }

  Future<void> _logFromPantry(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
  ) async {
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
              if (!item.isConsumed)
                ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(item.name),
                  subtitle: item.kcalPer100g == null
                      ? null
                      : Text('${item.kcalPer100g!.round()} kcal / 100 g'),
                  trailing: Text(item.amountLabel),
                  onTap: () => Navigator.pop(sheetContext, item),
                ),
          ],
        ),
      ),
    );
    if (item == null || !context.mounted) return;
    await eatPantryItemFlow(context, ref, item, loggedAt: _logTimestamp(day));
  }

  Future<void> _quickAdd(
    BuildContext context,
    WidgetRef ref,
    DateTime day,
  ) async {
    final result = await showModalBottomSheet<(String, double, MealType)>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _QuickAddSheet(),
    );
    if (result == null) return;
    final loggedAt = _logTimestamp(day);
    await ref
        .read(databaseProvider)
        .logConsumption(
          ConsumptionEntriesCompanion.insert(
            name: result.$1,
            kcal: result.$2,
            mealType: result.$3.value,
            loggedAt: loggedAt == null ? const Value.absent() : Value(loggedAt),
          ),
        );
  }
}

/// "‹ Today ›" — browse previous days; the forward chevron stops at today.
class _DayNavigator extends ConsumerWidget {
  const _DayNavigator({required this.day, required this.isToday});

  final DateTime day;
  final bool isToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => ref
                  .read(selectedDayProvider.notifier)
                  .select(day.subtract(const Duration(days: 1))),
            ),
            Expanded(
              child: GestureDetector(
                onTap: isToday
                    ? null
                    : () => ref.read(selectedDayProvider.notifier).today(),
                child: Text(
                  _dayLabel(day),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isToday ? null : scheme.primary,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: isToday
                  ? null
                  : () => ref
                        .read(selectedDayProvider.notifier)
                        .select(day.add(const Duration(days: 1))),
            ),
          ],
        ),
        if (!isToday)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Viewing a past day — new logs are saved to this date. '
              'Tap the date to jump back to today.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
}

/// Streak ("days without cheat") + estimated mass lost from the cumulative
/// kcal deficit banked over the streak.
class _ProgressCard extends ConsumerWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(progressStatsProvider).value;
    if (data == null) return const SizedBox.shrink();
    final stats = data.stats;
    final scheme = Theme.of(context).colorScheme;
    final kg = stats.kgLost;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.local_fire_department,
                color: stats.streakDays > 0
                    ? const Color(0xFFE8930C)
                    : scheme.onSurfaceVariant,
                value:
                    '${stats.streakDays} day${stats.streakDays == 1 ? '' : 's'}',
                label: stats.streakDays > 0
                    ? 'without cheat!'
                    : 'fresh start — stay under goal',
              ),
            ),
            SizedBox(
              height: 36,
              child: VerticalDivider(color: scheme.outlineVariant),
            ),
            Expanded(
              child: _StatTile(
                icon: Icons.monitor_weight_outlined,
                color: kg > 0 ? scheme.primary : scheme.onSurfaceVariant,
                value: '−${kg.toStringAsFixed(kg >= 10 ? 0 : 2)} kg',
                label: 'est. lost this streak',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Progress toward the target weight: bar + estimated days remaining at the
/// average daily pace. Hidden until both weights are set in settings.
class _WeightGoalCard extends ConsumerWidget {
  const _WeightGoalCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    final data = ref.watch(progressStatsProvider).value;
    if (settings == null || data == null) return const SizedBox.shrink();
    final current = settings.currentWeightKg;
    final target = settings.targetWeightKg;
    if (current <= 0 || target <= 0 || target >= current) {
      return const SizedBox.shrink();
    }
    final outlook = data.outlook;

    final scheme = Theme.of(context).colorScheme;
    final lost = outlook.kgLostTotal;
    final toGo = current - target;
    // The journey started at (current + what was already lost since
    // tracking began); the bar fills as the estimate grows.
    final progress = lost / (lost + toGo);
    final daysLeft = outlook.daysToLose(toGo);
    final gramsPerDay = (outlook.avgKgPerDay * 1000).round();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.flag_outlined, size: 20, color: scheme.tertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      daysLeft == null
                          ? '${target.toStringAsFixed(1)} kg — no date yet'
                          : daysLeft == 0
                          ? '${target.toStringAsFixed(1)} kg — reached! 🎉'
                          : '${target.toStringAsFixed(1)} kg on '
                                '${_futureDateLabel(daysLeft)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: daysLeft == null ? null : scheme.tertiary,
                      ),
                    ),
                  ),
                  Text(
                    gramsPerDay > 0
                        ? '−$gramsPerDay g/day avg'
                        : 'no trend yet',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: gramsPerDay > 0
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  color: scheme.tertiary,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                daysLeft == null
                    ? 'Log a few under-goal days to project a finish date.'
                    : 'Now ≈ ${(current - lost).toStringAsFixed(1)} kg '
                          '(started ${current.toStringAsFixed(1)}) · '
                          '$daysLeft days left · burn target today: '
                          '${data.dailyBurnKcal} kcal',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// "15 Mar 2027" — the estimated calendar day [daysFromNow] ahead.
  static String _futureDateLabel(int daysFromNow) {
    final date = DateTime.now().add(Duration(days: daysFromNow));
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _KcalHeader extends StatelessWidget {
  const _KcalHeader({
    required this.consumed,
    required this.goal,
    required this.threshold,
  });

  final double consumed;
  final int goal;

  /// Kcal of tolerance above the goal before the streak breaks.
  final int threshold;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final remaining = goal - consumed;
    final over = remaining < 0;
    // Slightly over is forgiven; the punishment UI fires past the tolerance.
    final cheated = consumed > goal + threshold;
    final progress = goal == 0 ? 0.0 : consumed / goal;

    return Card(
      color: cheated ? scheme.errorContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, animated, child) => CustomPaint(
                  painter: _RingPainter(
                    progress: animated,
                    background: cheated
                        ? scheme.onErrorContainer.withValues(alpha: 0.15)
                        : scheme.surfaceContainerHighest,
                    foreground: cheated ? scheme.error : scheme.primary,
                    foregroundEnd: cheated ? scheme.error : scheme.tertiary,
                    overflowColor: scheme.error,
                  ),
                  child: child,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        consumed.round().toString(),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cheated ? scheme.onErrorContainer : null,
                            ),
                      ),
                      Text(
                        'kcal',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cheated ? scheme.onErrorContainer : null,
                        ),
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
                              '${cheated ? ' 😬' : ''}'
                        : '${remaining.round()} kcal left',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cheated
                          ? scheme.error
                          : over
                          ? const Color(0xFFE8930C)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cheated
                        ? 'Goal blown — the streak resets. Log everything '
                              'anyway: honest data beats a pretty ring.'
                        : over
                        ? 'Still inside your $threshold kcal tolerance — '
                              'the streak survives. Stop here!'
                        : 'Goal: $goal kcal',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cheated
                          ? scheme.onErrorContainer
                          : scheme.onSurfaceVariant,
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
    required this.overflowColor,
  });

  /// May exceed 1.0 — the overflow is drawn as a second, darker lap.
  final double progress;
  final Color background;
  final Color foreground;
  final Color foregroundEnd;
  final Color overflowColor;

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

    // Past 100%: a thinner, darker second lap makes the excess unmissable.
    if (progress > 1.0) {
      final overflowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 0.55
        ..color = Color.lerp(overflowColor, const Color(0xFF000000), 0.25)!
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        arcRect,
        -math.pi / 2,
        2 * math.pi * (progress - 1.0).clamp(0.0, 1.0),
        false,
        overflowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.foreground != foreground ||
      oldDelegate.foregroundEnd != foregroundEnd ||
      oldDelegate.overflowColor != overflowColor ||
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
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Quick add', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(
            'Restaurant lunch? Tap to prefill a rough estimate:',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: restaurantPresets.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final (name, kcal) = restaurantPresets[index];
                return ActionChip(
                  avatar: const Icon(Icons.storefront, size: 16),
                  label: Text('$name · ${kcal.round()}'),
                  onPressed: () => setState(() {
                    _nameController.text = name;
                    _kcalController.text = kcal.round().toString();
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
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

/// Edit a logged entry: name, kcal and the meal period it belongs to.
class _EditEntrySheet extends StatefulWidget {
  const _EditEntrySheet({required this.entry});

  final ConsumptionEntry entry;

  @override
  State<_EditEntrySheet> createState() => _EditEntrySheetState();
}

class _EditEntrySheetState extends State<_EditEntrySheet> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.entry.name,
  );
  late final TextEditingController _kcalController = TextEditingController(
    text: widget.entry.kcal.round().toString(),
  );
  late MealType _mealType = MealType.fromValue(widget.entry.mealType);

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
          Text('Edit entry', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Name'),
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
          const SizedBox(height: 8),
          Center(
            child: Text(
              _mealType.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _mealType.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Save'),
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
