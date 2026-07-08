import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readly/app/app.dart';
import 'package:readly/data/db/database.dart';
import 'package:readly/data/services/settings_service.dart';
import 'package:readly/providers.dart';

class _FakeSettingsService extends SettingsService {
  String? apiKey;
  String language = 'english';
  int goal = 2000;

  @override
  Future<String?> getApiKey() async => apiKey;

  @override
  Future<void> setApiKey(String? key) async => apiKey = key;

  @override
  Future<AppSettings> load() async => AppSettings(
    hasApiKey: apiKey != null,
    language: language,
    dailyKcalGoal: goal,
  );

  @override
  Future<void> setLanguage(String value) async => language = value;

  @override
  Future<void> setDailyKcalGoal(int value) async => goal = value;
}

void main() {
  testWidgets('app boots and all five tabs navigate', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    // Bounded pumps instead of pumpAndSettle: the app keeps light background
    // activity (font loading, platform channels) that never fully settles in
    // the test environment.
    Future<void> pump() async {
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          settingsServiceProvider.overrideWithValue(_FakeSettingsService()),
        ],
        child: const ReadlyApp(),
      ),
    );
    await pump();

    // Track tab is home.
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Log food'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.kitchen_outlined));
    await pump();
    expect(find.text('Your kitchen is empty'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.restaurant_menu_outlined));
    await pump();
    expect(find.text('AI is not set up yet'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.shopping_basket_outlined));
    await pump();
    expect(find.text('Nothing to buy'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.auto_stories_outlined));
    await pump();
    expect(find.text('No summaries yet'), findsOneWidget);

    // Flush any lingering timers (stream cleanup, snackbars, etc.) so the
    // framework's end-of-test invariants pass.
    await tester.pump(const Duration(minutes: 2));
  });

  test('extractUrl pulls the first link out of shared text', () {
    expect(
      ReadlyApp.extractUrl('Check this https://example.com/a?x=1 out'),
      'https://example.com/a?x=1',
    );
    expect(ReadlyApp.extractUrl('no link here'), isNull);
  });
}
