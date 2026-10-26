import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:budget_bites/db/models.dart';
import 'package:budget_bites/screens/dashboard_screen.dart';

void main() {
  Future<void> showDashboard(
    WidgetTester tester, {
    List<Meal> meals = const [],
    int weekTotal = 0,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(
          loader: (category) async {
            final filtered = category == null
                ? meals
                : meals.where((m) => m.category == category).toList();

            return DashboardData(
              meals: filtered,
              weekTotal: weekTotal,
            );
          },
        ),
      ),
    );

    await tester.pump();
  }

  group('Dashboard widget tests', () {
    testWidgets('Displays weekly spending summary', (tester) async {
      await showDashboard(tester);

      expect(find.text('This week'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('Shows empty meal message', (tester) async {
      await showDashboard(tester);

      expect(
        find.text('No meals yet. Tap + Meal to add your first meal.'),
        findsOneWidget,
      );
    });

    testWidgets('Displays saved meals', (tester) async {
      await showDashboard(
        tester,
        meals: [
          Meal(
            id: 1,
            name: 'Chicken and Rice',
            category: 'Lunch',
            targetPriceCents: 850,
          ),
        ],
      );

      expect(find.text('Chicken and Rice'), findsOneWidget);
      expect(find.text('\$8.50'), findsOneWidget);
    });

    testWidgets('Filters meals by category', (tester) async {
      await showDashboard(
        tester,
        meals: [
          Meal(id: 1, name: 'Oatmeal', category: 'Breakfast'),
          Meal(id: 2, name: 'Chicken', category: 'Lunch'),
        ],
      );

      expect(find.text('Oatmeal'), findsOneWidget);
      expect(find.text('Chicken'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Lunch'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Chicken'), findsOneWidget);
      expect(find.text('Oatmeal'), findsNothing);
    });

    testWidgets('Displays an over-budget warning', (tester) async {
      await showDashboard(
        tester,
        weekTotal: 100000000,
      );

      expect(
        find.textContaining('Over budget by'),
        findsOneWidget,
      );
    });
  });
}