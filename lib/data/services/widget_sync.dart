import 'package:home_widget/home_widget.dart';

/// Pushes the Track headline numbers to the Android home-screen widget.
///
/// Everything is sent as strings: platform-channel integers can land as Long
/// on the Android side, which would break `SharedPreferences.getInt` in the
/// widget provider.
class WidgetSync {
  static const _provider = 'ReadlyWidgetProvider';

  static Future<void> push({
    required int kcalLeft,
    required int streakDays,
    required double kgLost,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('kcal_left', '$kcalLeft');
      await HomeWidget.saveWidgetData<String>('streak_days', '$streakDays');
      await HomeWidget.saveWidgetData<String>(
        'kg_lost',
        kgLost.toStringAsFixed(2),
      );
      await HomeWidget.updateWidget(
        qualifiedAndroidName: 'al.brev.readly.$_provider',
        name: _provider,
      );
    } catch (_) {
      // No widget host (tests, desktop) — never break the app for this.
    }
  }
}
