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
}
