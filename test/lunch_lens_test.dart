import 'package:flutter_test/flutter_test.dart';
import 'package:budget_bites/helper/lunch_lens.dart';

void main() {
  absoluteErrorTests();
  test('normal: mean of 3', () => expect(lunchLens([800, 850, 810]).estimateCents, 820));
  test('empty history', () {
    final r = lunchLens([]);
    expect(r.estimateCents, isNull);
    expect(r.explanation, 'Log a purchase to get an estimate.');
  });
  test('ignores invalid amounts', () => expect(lunchLens([0, -200, 900]).estimateCents, 900));
  test('uses newest 5 only', () {
    final r = lunchLens([1200, 1100, 1000, 900, 800, 700]);
    expect(r.estimateCents, 1000);
    expect(r.sampleCount, 5);
  });
  test('outlier inflates estimate', () => expect(lunchLens([2500, 800, 800, 800, 800]).estimateCents, 1140));
  test('baseline is most recent', () => expect(lunchLens([950, 800]).baselineCents, 950));
}

void absoluteErrorTests() {
  group('absoluteErrorCents', () {
    test('over-estimate', () => expect(absoluteErrorCents(900, 850), 50));
    test('under-estimate', () => expect(absoluteErrorCents(800, 850), 50));
    test('exact', () => expect(absoluteErrorCents(850, 850), 0));
  });
}
