import 'package:flutter_test/flutter_test.dart';
import 'package:budget_bites/db/models.dart';

void main() {
  group('Budget Bites model tests', () {
    test('Converts regular prices into integer cents', () {
      expect(parseCents('8.50'), 850);
      expect(parseCents('12.99'), 1299);
    });

    test('Handles dollar signs and surrounding spaces', () {
      expect(parseCents('  \$8.50 '), 850);
    });

    test('Rejects invalid price text', () {
      expect(parseCents('abc'), isNull);
      expect(parseCents(''), isNull);
    });

    test('Formats integer cents as currency', () {
      expect(money(850), '\$8.50');
      expect(money(0), '\$0.00');
      expect(money(1299), '\$12.99');
    });

    test('Converts a Meal to and from a database map', () {
      final original = Meal(
        id: 1,
        name: 'Chicken and Rice',
        category: 'Lunch',
        targetPriceCents: 850,
      );

      final restored = Meal.fromMap(original.toMap());

      expect(restored.id, 1);
      expect(restored.name, 'Chicken and Rice');
      expect(restored.category, 'Lunch');
      expect(restored.targetPriceCents, 850);
    });

    test('Converts a Purchase to and from a database map', () {
      final date = DateTime(2026, 10, 25, 12, 30);

      final original = Purchase(
        id: 3,
        mealId: 1,
        amountCents: 950,
        purchasedAt: date,
        notes: 'Lunch purchase',
      );

      final restored = Purchase.fromMap(original.toMap());

      expect(restored.id, 3);
      expect(restored.mealId, 1);
      expect(restored.amountCents, 950);
      expect(restored.purchasedAt, date);
      expect(restored.notes, 'Lunch purchase');
    });
  });
}