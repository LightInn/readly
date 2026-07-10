import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/services/settings_service.dart';
import '../../providers.dart';
import '../../widgets/common.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _apiKeyController = TextEditingController();
  final _goalController = TextEditingController();
  final _burnController = TextEditingController();
  final _thresholdController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  bool _obscureKey = true;
  bool _fieldsPopulated = false;
  Timer? _saveDebounce;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider).value;
    if (settings != null) _populateFields(settings);
  }

  /// The settings load asynchronously; the page may open before they exist.
  void _populateFields(AppSettings settings) {
    _fieldsPopulated = true;
    _goalController.text = settings.dailyKcalGoal.toString();
    _burnController.text = settings.dailyBurnKcal.toString();
    _thresholdController.text = settings.cheatThresholdKcal.toString();
    if (settings.currentWeightKg > 0) {
      _currentWeightController.text = settings.currentWeightKg.toStringAsFixed(
        1,
      );
    }
    if (settings.targetWeightKg > 0) {
      _targetWeightController.text = settings.targetWeightKg.toStringAsFixed(1);
    }
  }

  /// Persist shortly after the user stops typing — waiting for a submit or a
  /// tap-outside loses the value when the page is simply popped.
  void _scheduleSave(Future<void> Function() save) {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 600), () {
      unawaited(save());
    });
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _apiKeyController.dispose();
    _goalController.dispose();
    _burnController.dispose();
    _thresholdController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) return;
    await ref.read(settingsProvider.notifier).setApiKey(key);
    _apiKeyController.clear();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('API key saved.')));
    }
  }

  Future<void> _saveGoal() async {
    final goal = int.tryParse(_goalController.text.trim());
    if (goal == null || goal <= 0) return;
    await ref.read(settingsProvider.notifier).setDailyKcalGoal(goal);
  }

  Future<void> _saveBurn() async {
    final burn = int.tryParse(_burnController.text.trim());
    if (burn == null || burn <= 0) return;
    await ref.read(settingsProvider.notifier).setDailyBurnKcal(burn);
  }

  Future<void> _saveThreshold() async {
    final threshold = int.tryParse(_thresholdController.text.trim());
    if (threshold == null || threshold < 0) return;
    await ref.read(settingsProvider.notifier).setCheatThresholdKcal(threshold);
  }

  Future<void> _saveWeights() async {
    final notifier = ref.read(settingsProvider.notifier);
    final current = double.tryParse(
      _currentWeightController.text.replaceAll(',', '.'),
    );
    final target = double.tryParse(
      _targetWeightController.text.replaceAll(',', '.'),
    );
    if (current != null && current > 0) {
      await notifier.setCurrentWeightKg(current);
    }
    if (target != null && target > 0) {
      await notifier.setTargetWeightKg(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fill the fields once the settings arrive, if the page opened first.
    ref.listen(settingsProvider, (_, next) {
      final value = next.value;
      if (value != null && !_fieldsPopulated) _populateFields(value);
    });
    final settings = ref.watch(settingsProvider).value;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const SectionHeader('AI (OpenAI)'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        settings?.hasApiKey ?? false
                            ? Icons.check_circle
                            : Icons.key_off,
                        color: settings?.hasApiKey ?? false
                            ? scheme.primary
                            : scheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          settings?.hasApiKey ?? false
                              ? 'API key configured'
                              : 'No API key yet — AI features are disabled',
                        ),
                      ),
                      if (settings?.hasApiKey ?? false)
                        TextButton(
                          onPressed: () => ref
                              .read(settingsProvider.notifier)
                              .setApiKey(null),
                          child: const Text('Remove'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: _obscureKey,
                    decoration: InputDecoration(
                      labelText: 'OpenAI API key',
                      hintText: 'sk-…',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureKey ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () =>
                            setState(() => _obscureKey = !_obscureKey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _saveApiKey,
                    child: const Text('Save key'),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Get a key at platform.openai.com'),
                    onPressed: () => launchUrl(
                      Uri.parse('https://platform.openai.com/api-keys'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader('Preferences'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownMenu<String>(
                    initialSelection: settings?.language ?? 'english',
                    label: const Text('AI answers language'),
                    expandedInsets: EdgeInsets.zero,
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 'english', label: 'English'),
                      DropdownMenuEntry(value: 'french', label: 'Français'),
                    ],
                    onSelected: (value) {
                      if (value != null) {
                        ref.read(settingsProvider.notifier).setLanguage(value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _goalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Daily kcal goal',
                    ),
                    onChanged: (_) => _scheduleSave(_saveGoal),
                    onSubmitted: (_) => _saveGoal(),
                    onTapOutside: (_) => _saveGoal(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _burnController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Maintenance kcal (daily burn estimate)',
                      helperText:
                          'Used for the streak deficit → kg lost estimate '
                          '(7700 kcal ≈ 1 kg)',
                    ),
                    onChanged: (_) => _scheduleSave(_saveBurn),
                    onSubmitted: (_) => _saveBurn(),
                    onTapOutside: (_) => _saveBurn(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _thresholdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cheat tolerance (kcal over goal)',
                      helperText:
                          'The streak only resets beyond goal + this margin',
                    ),
                    onChanged: (_) => _scheduleSave(_saveThreshold),
                    onSubmitted: (_) => _saveThreshold(),
                    onTapOutside: (_) => _saveThreshold(),
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader('Weight goal'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _currentWeightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Current weight (kg)',
                      ),
                      onChanged: (_) => _scheduleSave(_saveWeights),
                      onSubmitted: (_) => _saveWeights(),
                      onTapOutside: (_) => _saveWeights(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _targetWeightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Target weight (kg)',
                      ),
                      onChanged: (_) => _scheduleSave(_saveWeights),
                      onSubmitted: (_) => _saveWeights(),
                      onTapOutside: (_) => _saveWeights(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Readly 3.0 — everything stays on your device.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
