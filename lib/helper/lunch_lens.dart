/// Lunch Lens: rule-based statistical helper (not a trained model).
class LunchLensResult {
  final int? estimateCents; // null when no data
  final int sampleCount;
  final int? baselineCents; // most recent purchase
  const LunchLensResult(
      this.estimateCents, this.sampleCount, this.baselineCents);

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

/// Absolute error in cents between a prediction and the actual next price.
int absoluteErrorCents(int predictedCents, int actualCents) =>
    (predictedCents - actualCents).abs();

/// One reproducible evaluation case: history (newest first) and the real next price.
class LensCase {
  final String name;
  final List<int> historyNewestFirst;
  final int? actualNextCents; // null when there is no known next price
  const LensCase(this.name, this.historyNewestFirst, this.actualNextCents);
}

class LensCaseResult {
  final LensCase input;
  final LunchLensResult result;
  final int? helperErrorCents;
  final int? baselineErrorCents;
  const LensCaseResult(
      this.input, this.result, this.helperErrorCents, this.baselineErrorCents);

  /// True when the helper was at least as close as the baseline.
  bool? get helperWins => helperErrorCents == null || baselineErrorCents == null
      ? null
      : helperErrorCents! <= baselineErrorCents!;
}

/// Runs every case and compares helper vs. baseline (most recent price).
List<LensCaseResult> runEvaluation(List<LensCase> cases) => cases.map((c) {
      final r = lunchLens(c.historyNewestFirst);
      final actual = c.actualNextCents;
      return LensCaseResult(
        c,
        r,
        actual == null || r.estimateCents == null
            ? null
            : absoluteErrorCents(r.estimateCents!, actual),
        actual == null || r.baselineCents == null
            ? null
            : absoluteErrorCents(r.baselineCents!, actual),
      );
    }).toList();
