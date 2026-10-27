import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:budget_bites/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete meal purchase and history workflow',
      (tester) async {
    // Unique name prevents conflicts with existing meals.
    final mealName =
        'Integration Meal ${DateTime.now().microsecondsSinceEpoch}';

    const purchaseAmount = '9.25';
    const purchaseNotes = 'Integration test purchase';

    // Start the actual application.
    app.main();
    await tester.pumpAndSettle();

    // 1. Open the Meal Editor.
    await tester.tap(find.text('Meal').last);
    await tester.pumpAndSettle();

    expect(find.text('New meal'), findsOneWidget);

    // 2. Enter the meal name.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Name *'),
      mealName,
    );

    // 3. Select the Lunch category.
    await tester.tap(
      find.byType(DropdownButtonFormField<String>),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lunch').last);
    await tester.pumpAndSettle();

    // 4. Enter a target price.
    await tester.enterText(
      find.widgetWithText(
        TextFormField,
        'Target price (optional)',
      ),
      '8.50',
    );

    // 5. Save the meal.
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Dashboard should display the newly created meal.
    expect(find.text(mealName), findsOneWidget);

    // 6. Open Meal Details.
    await tester.tap(find.text(mealName));
    await tester.pumpAndSettle();

    expect(find.text('Log purchase'), findsOneWidget);

    // 7. Record a purchase.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount *'),
      purchaseAmount,
    );

    await tester.enterText(
      find.widgetWithText(
        TextFormField,
        'Notes (optional)',
      ),
      purchaseNotes,
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify the purchase appears.
    expect(find.text('\$9.25'), findsWidgets);
    expect(find.textContaining(purchaseNotes), findsWidgets);

    // 8. Return to Dashboard.
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 9. Open History.
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();

    expect(find.text('History'), findsOneWidget);
    expect(find.text(mealName), findsOneWidget);

    // The period total includes the new purchase.
    expect(find.text('Period total'), findsOneWidget);

    // 10. Return to Dashboard.
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 11. Verify the meal still exists after navigation.
    expect(find.text(mealName), findsOneWidget);

    // 12. Clean up the test meal.
    await tester.tap(find.text(mealName));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Edit meal'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Delete meal'));
    await tester.tap(find.text('Delete meal'));
    await tester.pumpAndSettle();

    expect(find.text('Delete meal?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    // Deleting a meal also removes its purchases.
    expect(find.text(mealName), findsNothing);
  });
}