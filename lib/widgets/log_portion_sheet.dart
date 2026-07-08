import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart';
import '../data/meal_type.dart';
import '../data/quantity.dart';
import '../providers.dart';

class LogPortionResult {
  const LogPortionResult({
    required this.kcal,
    required this.mealType,
    required this.fraction,
    this.grams,
  });

  final double kcal;
  final MealType mealType;

  /// Fraction of the full package that was eaten (0..1). Callers tracking
  /// stock subtract this from the item's amountLeft.
  final double fraction;
  final double? grams;
}

/// Bottom sheet asking "how much of it did you eat?" with a slider over the
/// whole package — nobody knows their portions to the gram. The part of the
/// package that was already consumed earlier is greyed out. Unit-counted
/// foods (eggs…) slide in units, everything else in percent.
Future<LogPortionResult?> showLogPortionSheet(
  BuildContext context, {
  required String foodName,
  required double? kcalPer100g,
  double? packageGrams,
  int? unitCount,
  double amountLeft = 1.0,
  String? packageLabel,
}) {
  return showModalBottomSheet<LogPortionResult>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _LogPortionSheet(
      foodName: foodName,
      kcalPer100g: kcalPer100g,
      packageGrams: packageGrams,
      unitCount: (unitCount ?? 0) > 0 ? unitCount : null,
      amountLeft: amountLeft.clamp(0.0, 1.0),
      packageLabel: packageLabel,
    ),
  );
}

class _LogPortionSheet extends StatefulWidget {
  const _LogPortionSheet({
    required this.foodName,
    required this.kcalPer100g,
    required this.packageGrams,
    required this.unitCount,
    required this.amountLeft,
    required this.packageLabel,
  });

  final String foodName;
  final double? kcalPer100g;
  final double? packageGrams;
  final int? unitCount;
  final double amountLeft;
  final String? packageLabel;

  @override
  State<_LogPortionSheet> createState() => _LogPortionSheetState();
}

class _LogPortionSheetState extends State<_LogPortionSheet> {
  late final TextEditingController _kcalController;
  late double _fraction;
  bool _kcalEdited = false;
  MealType _mealType = MealType.suggestedNow();

  bool get _unitBased => widget.unitCount != null;

  int get _unitsLeft => _unitBased
      ? (widget.amountLeft * widget.unitCount!).round().clamp(
          0,
          widget.unitCount!,
        )
      : 0;

  @override
  void initState() {
    super.initState();
    // Sensible starting bite: one unit, or a quarter of the package.
    _fraction = _unitBased
        ? (_unitsLeft == 0 ? 0.0 : 1.0 / widget.unitCount!)
        : (widget.amountLeft < 0.25 ? widget.amountLeft : 0.25);
    _kcalController = TextEditingController(text: _estimatedKcalText());
  }

  @override
  void dispose() {
    _kcalController.dispose();
    super.dispose();
  }

  double? _estimatedKcal() {
    if (widget.packageGrams == null || widget.kcalPer100g == null) return null;
    return widget.kcalPer100g! * widget.packageGrams! * _fraction / 100;
  }

  String _estimatedKcalText() {
    final kcal = _estimatedKcal();
    return kcal == null ? '' : kcal.round().toString();
  }

  double? _grams() {
    if (widget.packageGrams == null) return null;
    return widget.packageGrams! * _fraction;
  }

  String _portionLabel() {
    if (_unitBased) {
      final units = (_fraction * widget.unitCount!).round();
      return '$units / ${widget.unitCount}';
    }
    final percent = (_fraction * 100).round();
    final grams = _grams();
    return grams == null ? '$percent%' : '$percent% · ≈${grams.round()} g';
  }

  void _onSlider(double value) {
    final max = _unitBased ? _unitsLeft / widget.unitCount! : widget.amountLeft;
    setState(() {
      _fraction = value.clamp(0.0, max);
      if (!_kcalEdited) _kcalController.text = _estimatedKcalText();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final consumedBefore = widget.amountLeft < 1.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.foodName, style: Theme.of(context).textTheme.titleLarge),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              [
                if (widget.packageLabel != null) widget.packageLabel!,
                if (widget.kcalPer100g != null)
                  '${widget.kcalPer100g!.round()} kcal / 100 g',
              ].join(' · '),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'How much did you eat?',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Spacer(),
              Text(
                _portionLabel(),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          // The track beyond amountLeft stays grey: that part of the package
          // is already gone.
          Slider(
            value: _fraction,
            max: 1.0,
            divisions: _unitBased ? widget.unitCount : 20,
            secondaryTrackValue: widget.amountLeft,
            secondaryActiveColor: scheme.primaryContainer,
            inactiveColor: scheme.onSurface.withValues(alpha: 0.28),
            onChanged: _onSlider,
          ),
          if (consumedBefore)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                _unitBased
                    ? 'Grey end of the track: units already used.'
                    : 'Grey end of the track: part already used.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _kcalController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'kcal',
              helperText: _estimatedKcal() == null
                  ? 'No package data — enter your estimate'
                  : 'Estimated from the portion, adjust if needed',
            ),
            onChanged: (_) => _kcalEdited = true,
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
            label: const Text('Log it'),
            onPressed: () {
              final kcal = double.tryParse(
                _kcalController.text.replaceAll(',', '.'),
              );
              if (kcal == null || _fraction <= 0) return;
              Navigator.of(context).pop(
                LogPortionResult(
                  kcal: kcal,
                  mealType: _mealType,
                  fraction: _fraction,
                  grams: _grams(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Convenience for pantry items: opens the sheet pre-configured with the
/// item's package info and current stock.
Future<LogPortionResult?> showEatPantryItemSheet(
  BuildContext context,
  PantryItem item,
) {
  return showLogPortionSheet(
    context,
    foodName: item.name,
    kcalPer100g: item.kcalPer100g,
    packageGrams: item.packageGrams,
    unitCount: item.unitCount,
    amountLeft: item.amountLeft,
    packageLabel: item.packageQuantity,
  );
}

/// The full "I ate some of this" flow shared by Kitchen and Track: portion
/// sheet → log the kcal → keep the pantry stock in sync. Returns true when
/// something was logged.
Future<bool> eatPantryItemFlow(
  BuildContext context,
  WidgetRef ref,
  PantryItem item,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final result = await showEatPantryItemSheet(context, item);
  if (result == null) return false;
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
  await db.updatePantryItem(
    item.id,
    PantryItemsCompanion(
      amountLeft: Value((item.amountLeft - result.fraction).clamp(0.0, 1.0)),
    ),
  );
  messenger.showSnackBar(
    SnackBar(
      content: Text('Logged ${result.kcal.round()} kcal — stock updated.'),
    ),
  );
  return true;
}
