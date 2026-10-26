import 'package:flutter_test/flutter_test.dart';
import 'package:budget_bites/helper/lunch_lens.dart';

/// Reproducible evaluation set from the proposal. Run:
///   flutter test test/evaluation_report_test.dart
/// and copy the printed table into AI_FEATURE.md.
const cases = [
  LensCase('1 Normal', [800, 850, 810], 830),
  LensCase('2 Empty history', [], null),
  LensCase('3 Invalid amounts ignored', [0, -200, 900], 900),
  LensCase(
      '4 Boundary (>5 purchases)', [1200, 1100, 1000, 900, 800, 700], 1100),
  LensCase('5 Outlier', [2500, 800, 800, 800, 800], 800),
  LensCase('6 Counterexample (price rise)', [950, 800, 800], 950),
];

String _d(int? c) => c == null ? 'n/a' : '\$${(c / 100).toStringAsFixed(2)}';

void main() {
  test('evaluation report', () {
    final results = runEvaluation(cases);
    final lines = [
      '| Case | n | Helper | Baseline | Actual | Helper err | Baseline err |',
      '|---|---|---|---|---|---|---|'
    ];
    var hSum = 0, bSum = 0, scored = 0;
    for (final r in results) {
      lines.add(
          '| ${r.input.name} | ${r.result.sampleCount} | ${_d(r.result.estimateCents)} | '
          '${_d(r.result.baselineCents)} | ${_d(r.input.actualNextCents)} | '
          '${_d(r.helperErrorCents)} | ${_d(r.baselineErrorCents)} |');
      if (r.helperErrorCents != null && r.baselineErrorCents != null) {
        hSum += r.helperErrorCents!;
        bSum += r.baselineErrorCents!;
        scored++;
      }
    }
    lines.add('\nMean absolute error over $scored scored cases: '
        'helper ${_d((hSum / scored).round())}, baseline ${_d((bSum / scored).round())}');
    // ignore: avoid_print
    print(lines.join('\n'));
    expect(scored, 5);
  });
}
