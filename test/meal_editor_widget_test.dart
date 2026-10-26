import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:budget_bites/screens/meal_editor_screen.dart';
import 'package:budget_bites/db/models.dart';

void main() {
  Widget createTestApp() {
    return const MaterialApp(
      home: MealEditorScreen(),
    );
  }

  group('Meal Editor widget tests', () {
    testWidgets('Displays the new meal form', (tester) async {
      await tester.pumpWidget(createTestApp());

      expect(find.text('New meal'), findsOneWidget);
      expect(find.text('Name *'), findsOneWidget);
      expect(find.text('Category *'), findsOneWidget);
      expect(find.text('Target price (optional)'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('Requires a meal name', (tester) async {
      await tester.pumpWidget(createTestApp());

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('Requires a category', (tester) async {
      await tester.pumpWidget(createTestApp());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Name *'),
        'Chicken and Rice',
      );

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Category is required'), findsOneWidget);
    });

    testWidgets('Rejects invalid prices', (tester) async {
      await tester.pumpWidget(createTestApp());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Target price (optional)'),
        'abc',
      );

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Enter a valid price'), findsOneWidget);
    });

    testWidgets('Rejects negative prices', (tester) async {
      await tester.pumpWidget(createTestApp());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Target price (optional)'),
        '-5',
      );

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Price must be \$0 or more'), findsOneWidget);
    });

    testWidgets('Shows existing meal information when editing',
        (tester) async {
      final meal = Meal(
        id: 1,
        name: 'Chicken and Rice',
        category: 'Lunch',
        targetPriceCents: 850,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MealEditorScreen(meal: meal),
        ),
      );

      expect(find.text('Edit meal'), findsOneWidget);
      expect(find.text('Chicken and Rice'), findsOneWidget);
      expect(find.text('8.50'), findsOneWidget);
      expect(find.text('Delete meal'), findsOneWidget);
    });
  });
}