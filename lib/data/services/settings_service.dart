import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  const AppSettings({
    required this.hasApiKey,
    required this.language,
    required this.dailyKcalGoal,
  });

  final bool hasApiKey;
  final String language;
  final int dailyKcalGoal;

  AppSettings copyWith({
    bool? hasApiKey,
    String? language,
    int? dailyKcalGoal,
  }) {
    return AppSettings(
      hasApiKey: hasApiKey ?? this.hasApiKey,
      language: language ?? this.language,
      dailyKcalGoal: dailyKcalGoal ?? this.dailyKcalGoal,
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
  static const defaultKcalGoal = 2200;
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
    return AppSettings(
      hasApiKey: apiKey != null && apiKey.isNotEmpty,
      language: language ?? defaultLanguage,
      dailyKcalGoal: goal ?? defaultKcalGoal,
    );
  }

  Future<void> setLanguage(String language) =>
      _prefs.setString(_languageKey, language);

  Future<void> setDailyKcalGoal(int goal) => _prefs.setInt(_kcalGoalKey, goal);
}
