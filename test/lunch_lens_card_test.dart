import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_bites/helper/lunch_lens.dart';
import 'package:budget_bites/widgets/lunch_lens_card.dart';

Widget _wrap(Widget w) => MaterialApp(home: Scaffold(body: w));

void main() {
  testWidgets('empty history shows prompt and no draft button', (tester) async {
    await tester.pumpWidget(_wrap(LunchLensCard(
        lens: lunchLens([]), onUseDraft: (_) {}, onDismiss: () {})));
    expect(find.text('Log a purchase to get an estimate.'), findsOneWidget);
    expect(find.text('Use as draft'), findsNothing);
  });

  testWidgets('shows estimate, baseline and sample count', (tester) async {
    await tester.pumpWidget(_wrap(LunchLensCard(
        lens: lunchLens([800, 850, 810]),
        onUseDraft: (_) {},
        onDismiss: () {})));
    expect(find.text('Estimated next cost: \$8.20'), findsOneWidget);
    expect(find.text('Last paid: \$8.00'), findsOneWidget);
    expect(find.textContaining('3 recent purchases'), findsOneWidget);
  });

  testWidgets('Use as draft returns the estimate; Dismiss fires callback',
      (tester) async {
    int? draft;
    var dismissed = false;
    await tester.pumpWidget(_wrap(LunchLensCard(
        lens: lunchLens([800, 850, 810]),
        onUseDraft: (c) => draft = c,
        onDismiss: () => dismissed = true)));
    await tester.tap(find.text('Use as draft'));
    await tester.tap(find.text('Dismiss'));
    expect(draft, 820);
    expect(dismissed, isTrue);
  });

  testWidgets('outlier warning appears', (tester) async {
    await tester.pumpWidget(_wrap(LunchLensCard(
        lens: lunchLens([2500, 800, 800, 800, 800]),
        onUseDraft: (_) {},
        onDismiss: () {})));
    expect(find.textContaining('looks unusual'), findsOneWidget);
  });
}
