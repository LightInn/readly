import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:readly/app/app.dart';
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
    // The database layer has its own tests (test/data/database_test.dart);
    // here the streams are overridden so no real database is involved.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsServiceProvider.overrideWithValue(_FakeSettingsService()),
          pantryProvider.overrideWith((ref) => Stream.value(const [])),
          todayEntriesProvider.overrideWith((ref) => Stream.value(const [])),
          shoppingProvider.overrideWith((ref) => Stream.value(const [])),
          articlesProvider.overrideWith((ref) => Stream.value(const [])),
        ],
        child: const ReadlyApp(),
      ),
    );

    // Bounded pumps instead of pumpAndSettle: the app keeps light background
    // activity (font loading, platform channels) that never fully settles in
    // the test environment.
    Future<void> pump() async {
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }

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
  });

  test('extractUrl pulls the first link out of shared text', () {
    expect(
      ReadlyApp.extractUrl('Check this https://example.com/a?x=1 out'),
      'https://example.com/a?x=1',
    );
    expect(ReadlyApp.extractUrl('no link here'), isNull);
  });
}
