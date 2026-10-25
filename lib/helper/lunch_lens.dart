/// Lunch Lens: rule-based statistical helper (not a trained model).
class LunchLensResult {
  final int? estimateCents; // null when no data
  final int sampleCount;
  final int? baselineCents; // most recent purchase
  const LunchLensResult(this.estimateCents, this.sampleCount, this.baselineCents);

  String get explanation => estimateCents == null
      ? 'Log a purchase to get an estimate.'
      : 'Based on $sampleCount recent purchase${sampleCount == 1 ? '' : 's'}. This is an estimate, not a guarantee.';
}

/// [recentNewestFirst] = purchase amounts in cents, newest first.
LunchLensResult lunchLens(List<int> recentNewestFirst) {
  final valid = recentNewestFirst.where((c) => c > 0).take(5).toList();
  if (valid.isEmpty) return const LunchLensResult(null, 0, null);
  final mean = (valid.reduce((a, b) => a + b) / valid.length).round();
  return LunchLensResult(mean, valid.length, valid.first);
}
