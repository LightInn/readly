/// Streak & cumulative-deficit math for the Track page.
///
/// The model is deliberately simple: the user estimates a natural daily
/// expenditure (maintenance, default 2200 kcal). Every streak day that ends
/// under the daily goal banks `maintenance - eaten` kcal of deficit, and
/// 7700 kcal of cumulative deficit ≈ 1 kg of fat lost.
library;

class ProgressStats {
  const ProgressStats({required this.streakDays, required this.kcalDeficit});

  /// Consecutive days (ending today) at or under the daily goal.
  final int streakDays;

  /// Kcal banked below maintenance over the streak (finished days only —
  /// today's deficit isn't counted until the day is over).
  final double kcalDeficit;

  static const kcalPerKg = 7700;

  double get kgLost => kcalDeficit / kcalPerKg;
}

/// All-time weight trajectory, estimated from the net kcal balance of every
/// finished day that has logs (over-eating counts against the average — an
/// honest trend beats a flattering one).
class WeightOutlook {
  const WeightOutlook({
    required this.netKcalDeficit,
    required this.daysTracked,
  });

  /// Sum of (burn − eaten) over all finished, logged days. Can be negative.
  final double netKcalDeficit;
  final int daysTracked;

  /// Estimated total kg lost since tracking started (floored at 0).
  double get kgLostTotal =>
      netKcalDeficit > 0 ? netKcalDeficit / ProgressStats.kcalPerKg : 0;

  /// Average kg lost per tracked day; ≤ 0 when the trend is flat or upward.
  double get avgKgPerDay => daysTracked == 0
      ? 0
      : (netKcalDeficit / daysTracked) / ProgressStats.kcalPerKg;

  /// Days needed to lose [kgToGo] at the current pace; null when there is no
  /// downward trend to extrapolate.
  int? daysToLose(double kgToGo) {
    if (kgToGo <= 0) return 0;
    if (avgKgPerDay <= 0) return null;
    return (kgToGo / avgKgPerDay).ceil();
  }
}

/// See [computeProgress] for the [kcalByDay] contract. Today is excluded —
/// its balance is not final yet.
WeightOutlook computeWeightOutlook({
  required Map<DateTime, double> kcalByDay,
  required int burnKcal,
  required DateTime today,
}) {
  final day0 = DateTime(today.year, today.month, today.day);
  var net = 0.0;
  var days = 0;
  kcalByDay.forEach((day, kcal) {
    if (!day.isBefore(day0) || kcal <= 0) return;
    days++;
    net += burnKcal - kcal;
  });
  return WeightOutlook(netKcalDeficit: net, daysTracked: days);
}

/// [kcalByDay] maps a calendar day (midnight-keyed `DateTime(y, m, d)`) to
/// the total kcal eaten that day. Days with nothing logged must be absent.
/// [thresholdKcal] is the tolerance above the goal before a day counts as a
/// cheat — going slightly over should not annihilate a two-week streak.
ProgressStats computeProgress({
  required Map<DateTime, double> kcalByDay,
  required int goalKcal,
  required int burnKcal,
  required DateTime today,
  int thresholdKcal = 0,
}) {
  final day0 = DateTime(today.year, today.month, today.day);
  final todayKcal = kcalByDay[day0] ?? 0;
  final cheatLine = goalKcal + thresholdKcal;

  // Blowing past goal + tolerance today breaks the streak immediately —
  // that is the point.
  if (todayKcal > cheatLine) {
    return const ProgressStats(streakDays: 0, kcalDeficit: 0);
  }

  var streak = todayKcal > 0 ? 1 : 0;
  var deficit = 0.0;
  for (var i = 1; ; i++) {
    final kcal = kcalByDay[day0.subtract(Duration(days: i))];
    // A day with no logs ends the streak: not logging counts as cheating.
    if (kcal == null || kcal <= 0 || kcal > cheatLine) break;
    streak++;
    deficit += (burnKcal - kcal).clamp(0, double.infinity);
  }
  return ProgressStats(streakDays: streak, kcalDeficit: deficit);
}
