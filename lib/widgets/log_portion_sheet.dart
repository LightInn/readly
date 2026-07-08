import 'package:flutter/material.dart';

import '../data/meal_type.dart';

class LogPortionResult {
  const LogPortionResult({
    required this.kcal,
    required this.mealType,
    this.grams,
  });

  final double kcal;
  final MealType mealType;
  final double? grams;
}

/// Bottom sheet asking for a portion size (grams) and meal type for a food
/// with known kcal/100 g. Pops with a [LogPortionResult].
Future<LogPortionResult?> showLogPortionSheet(
  BuildContext context, {
  required String foodName,
  required double? kcalPer100g,
  double? defaultGrams,
}) {
  return showModalBottomSheet<LogPortionResult>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _LogPortionSheet(
      foodName: foodName,
      kcalPer100g: kcalPer100g,
      defaultGrams: defaultGrams,
    ),
  );
}

class _LogPortionSheet extends StatefulWidget {
  const _LogPortionSheet({
    required this.foodName,
    required this.kcalPer100g,
    this.defaultGrams,
  });

  final String foodName;
  final double? kcalPer100g;
  final double? defaultGrams;

  @override
  State<_LogPortionSheet> createState() => _LogPortionSheetState();
}

class _LogPortionSheetState extends State<_LogPortionSheet> {
  late final TextEditingController _gramsController;
  late final TextEditingController _kcalController;
  MealType _mealType = MealType.suggestedNow();

  @override
  void initState() {
    super.initState();
    final grams = widget.defaultGrams ?? 100;
    _gramsController = TextEditingController(text: _trim(grams));
    _kcalController = TextEditingController(
      text: widget.kcalPer100g == null
          ? ''
          : _trim(widget.kcalPer100g! * grams / 100),
    );
  }

  static String _trim(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  void _recomputeKcal() {
    final grams = double.tryParse(_gramsController.text.replaceAll(',', '.'));
    if (grams != null && widget.kcalPer100g != null) {
      _kcalController.text = _trim(widget.kcalPer100g! * grams / 100);
    }
  }

  @override
  void dispose() {
    _gramsController.dispose();
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
          Text(widget.foodName, style: Theme.of(context).textTheme.titleLarge),
          if (widget.kcalPer100g != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${widget.kcalPer100g!.round()} kcal / 100 g',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _gramsController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Portion (g)'),
                  onChanged: (_) => _recomputeKcal(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _kcalController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'kcal'),
                ),
              ),
            ],
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
              style: Theme.of(context).textTheme.bodyMedium,
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
              if (kcal == null) return;
              Navigator.of(context).pop(
                LogPortionResult(
                  kcal: kcal,
                  mealType: _mealType,
                  grams: double.tryParse(
                    _gramsController.text.replaceAll(',', '.'),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
