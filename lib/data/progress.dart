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

/// [kcalByDay] maps a calendar day (midnight-keyed `DateTime(y, m, d)`) to
/// the total kcal eaten that day. Days with nothing logged must be absent.
ProgressStats computeProgress({
  required Map<DateTime, double> kcalByDay,
  required int goalKcal,
  required int burnKcal,
  required DateTime today,
}) {
  final day0 = DateTime(today.year, today.month, today.day);
  final todayKcal = kcalByDay[day0] ?? 0;

  // Blowing today's goal breaks the streak immediately — that is the point.
  if (todayKcal > goalKcal) {
    return const ProgressStats(streakDays: 0, kcalDeficit: 0);
  }

  var streak = todayKcal > 0 ? 1 : 0;
  var deficit = 0.0;
  for (var i = 1; ; i++) {
    final kcal = kcalByDay[day0.subtract(Duration(days: i))];
    // A day with no logs ends the streak: not logging counts as cheating.
    if (kcal == null || kcal <= 0 || kcal > goalKcal) break;
    streak++;
    deficit += (burnKcal - kcal).clamp(0, double.infinity);
  }
  return ProgressStats(streakDays: streak, kcalDeficit: deficit);
}
