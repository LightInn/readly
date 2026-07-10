import 'package:flutter_test/flutter_test.dart';
import 'package:readly/data/progress.dart';

void main() {
  final today = DateTime(2026, 7, 10, 14, 30);
  DateTime day(int daysAgo) =>
      DateTime(2026, 7, 10).subtract(Duration(days: daysAgo));

  test('counts consecutive under-goal days and banks past deficits', () {
    final stats = computeProgress(
      kcalByDay: {
        day(0): 800, // today, in progress — streak yes, deficit not banked
        day(1): 1700, // banks 500
        day(2): 1900, // banks 300
        day(3): 1500, // banks 700
      },
      goalKcal: 1900,
      burnKcal: 2200,
      today: today,
    );
    expect(stats.streakDays, 4);
    expect(stats.kcalDeficit, 1500);
    expect(stats.kgLost, closeTo(1500 / 7700, 1e-9));
  });

  test('an over-goal day in the past ends the streak there', () {
    final stats = computeProgress(
      kcalByDay: {day(0): 500, day(1): 1800, day(2): 2500, day(3): 1600},
      goalKcal: 1900,
      burnKcal: 2200,
      today: today,
    );
    expect(stats.streakDays, 2);
    expect(stats.kcalDeficit, 400); // only day(1)
  });

  test('blowing today resets everything — that is the punishment', () {
    final stats = computeProgress(
      kcalByDay: {day(0): 2400, day(1): 1500, day(2): 1500},
      goalKcal: 1900,
      burnKcal: 2200,
      today: today,
    );
    expect(stats.streakDays, 0);
    expect(stats.kcalDeficit, 0);
  });

  test('a day with no logs breaks the streak (not logging = cheating)', () {
    final stats = computeProgress(
      kcalByDay: {day(0): 900, day(2): 1500},
      goalKcal: 1900,
      burnKcal: 2200,
      today: today,
    );
    expect(stats.streakDays, 1); // only today
    expect(stats.kcalDeficit, 0);
  });

  test('empty today does not break the streak of previous days', () {
    final stats = computeProgress(
      kcalByDay: {day(1): 1600, day(2): 1800},
      goalKcal: 1900,
      burnKcal: 2200,
      today: today,
    );
    expect(stats.streakDays, 2);
    expect(stats.kcalDeficit, 600 + 400);
  });

  test('eating over maintenance but under goal banks nothing negative', () {
    final stats = computeProgress(
      kcalByDay: {day(1): 2100}, // goal 2200, burn 2000 → no negative deficit
      goalKcal: 2200,
      burnKcal: 2000,
      today: today,
    );
    expect(stats.streakDays, 1);
    expect(stats.kcalDeficit, 0);
  });

  test('cheat threshold forgives small overshoots', () {
    final stats = computeProgress(
      kcalByDay: {
        day(0): 2050, // 150 over goal — inside the 200 kcal tolerance
        day(1): 2000, // 100 over — also forgiven, banks nothing (over burn)
        day(2): 1500,
      },
      goalKcal: 1900,
      burnKcal: 2200,
      today: today,
      thresholdKcal: 200,
    );
    expect(stats.streakDays, 3);
    expect(stats.kcalDeficit, 200 + 700);

    // But past the tolerance the streak still resets.
    final blown = computeProgress(
      kcalByDay: {day(0): 2150},
      goalKcal: 1900,
      burnKcal: 2200,
      today: today,
      thresholdKcal: 200,
    );
    expect(blown.streakDays, 0);
  });

  group('estimateDailyBurn', () {
    test('matches the calibration point: 25 y / 120 kg / 179 cm = 2830', () {
      expect(estimateDailyBurn(weightKg: 120, heightCm: 179, age: 25), 2830);
    });

    test('drops as the estimated weight drops (adaptive target)', () {
      final at120 = estimateDailyBurn(weightKg: 120, heightCm: 179, age: 25);
      final at118 = estimateDailyBurn(weightKg: 118, heightCm: 179, age: 25);
      expect(at118, lessThan(at120));
      // 10 kcal of BMR per kg × 1.287 activity ≈ 13 kcal/kg.
      expect(at120 - at118, closeTo(2 * 10 * 1.287, 1));
    });
  });

  group('computeWeightOutlook', () {
    test('averages the net balance over finished logged days', () {
      final outlook = computeWeightOutlook(
        kcalByDay: {
          day(0): 500, // today — excluded
          day(1): 1700, // +500
          day(2): 2700, // −500 (overate: counts against)
          day(3): 1200, // +1000
        },
        burnKcal: 2200,
        today: today,
      );
      expect(outlook.daysTracked, 3);
      expect(outlook.netKcalDeficit, 1000);
      expect(outlook.kgLostTotal, closeTo(1000 / 7700, 1e-9));
      expect(outlook.avgKgPerDay, closeTo(1000 / 3 / 7700, 1e-9));
      expect(outlook.daysToLose(1.0), (1.0 / (1000 / 3 / 7700)).ceil());
    });

    test('no downward trend → no projection', () {
      final outlook = computeWeightOutlook(
        kcalByDay: {day(1): 2500},
        burnKcal: 2200,
        today: today,
      );
      expect(outlook.kgLostTotal, 0);
      expect(outlook.avgKgPerDay, lessThan(0));
      expect(outlook.daysToLose(5), isNull);
      expect(outlook.daysToLose(0), 0);
    });
  });
}
