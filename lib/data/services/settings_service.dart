import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    required this.hasApiKey,
    required this.language,
    required this.dailyKcalGoal,
    required this.dailyBurnKcal,
    this.cheatThresholdKcal = SettingsService.defaultCheatThreshold,
    this.currentWeightKg = 0,
    this.targetWeightKg = 0,
  });

  final bool hasApiKey;
  final String language;
  final int dailyKcalGoal;

  /// Estimated natural daily energy expenditure (maintenance kcal). The
  /// difference with what is eaten builds the cumulative-deficit stat
  /// (7700 kcal ≈ 1 kg of fat).
  final int dailyBurnKcal;

  /// Tolerance above the goal before the streak resets.
  final int cheatThresholdKcal;

  /// Weight tracking for the goal progress bar. 0 = unset.
  final double currentWeightKg;
  final double targetWeightKg;

  AppSettings copyWith({
    bool? hasApiKey,
    String? language,
    int? dailyKcalGoal,
    int? dailyBurnKcal,
    int? cheatThresholdKcal,
    double? currentWeightKg,
    double? targetWeightKg,
  }) {
    return AppSettings(
      hasApiKey: hasApiKey ?? this.hasApiKey,
      language: language ?? this.language,
      dailyKcalGoal: dailyKcalGoal ?? this.dailyKcalGoal,
      dailyBurnKcal: dailyBurnKcal ?? this.dailyBurnKcal,
      cheatThresholdKcal: cheatThresholdKcal ?? this.cheatThresholdKcal,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
    );
  }
}

class SettingsService {
  SettingsService({
    FlutterSecureStorage? secureStorage,
    SharedPreferencesAsync? prefs,
  }) : _secure = secureStorage ?? const FlutterSecureStorage(),
       _prefsOverride = prefs;

  static const _apiKeyKey = 'openaiApiKey';
  static const _languageKey = 'language';
  static const _kcalGoalKey = 'dailyKcalGoal';
  static const _kcalBurnKey = 'dailyBurnKcal';
  static const _cheatThresholdKey = 'cheatThresholdKcal';
  static const _currentWeightKey = 'currentWeightKg';
  static const _targetWeightKey = 'targetWeightKg';
  static const defaultKcalGoal = 2200;
  static const defaultKcalBurn = 2200;
  static const defaultCheatThreshold = 200;
  static const defaultLanguage = 'english';

  final FlutterSecureStorage _secure;
  final SharedPreferencesAsync? _prefsOverride;

  // Lazy so that test fakes overriding every method never touch the platform.
  late final SharedPreferencesAsync _prefs =
      _prefsOverride ?? SharedPreferencesAsync();

  Future<String?> getApiKey() => _secure.read(key: _apiKeyKey);

  Future<void> setApiKey(String? key) async {
    if (key == null || key.trim().isEmpty) {
      await _secure.delete(key: _apiKeyKey);
    } else {
      await _secure.write(key: _apiKeyKey, value: key.trim());
    }
  }

  Future<AppSettings> load() async {
    final apiKey = await getApiKey();
    final language = await _prefs.getString(_languageKey);
    final goal = await _prefs.getInt(_kcalGoalKey);
    final burn = await _prefs.getInt(_kcalBurnKey);
    final threshold = await _prefs.getInt(_cheatThresholdKey);
    final currentWeight = await _prefs.getDouble(_currentWeightKey);
    final targetWeight = await _prefs.getDouble(_targetWeightKey);
    return AppSettings(
      hasApiKey: apiKey != null && apiKey.isNotEmpty,
      language: language ?? defaultLanguage,
      dailyKcalGoal: goal ?? defaultKcalGoal,
      dailyBurnKcal: burn ?? defaultKcalBurn,
      cheatThresholdKcal: threshold ?? defaultCheatThreshold,
      currentWeightKg: currentWeight ?? 0,
      targetWeightKg: targetWeight ?? 0,
    );
  }

  Future<void> setLanguage(String language) =>
      _prefs.setString(_languageKey, language);

  Future<void> setDailyKcalGoal(int goal) => _prefs.setInt(_kcalGoalKey, goal);

  Future<void> setDailyBurnKcal(int burn) => _prefs.setInt(_kcalBurnKey, burn);

  Future<void> setCheatThresholdKcal(int threshold) =>
      _prefs.setInt(_cheatThresholdKey, threshold);

  Future<void> setCurrentWeightKg(double kg) =>
      _prefs.setDouble(_currentWeightKey, kg);

  Future<void> setTargetWeightKg(double kg) =>
      _prefs.setDouble(_targetWeightKey, kg);
}
