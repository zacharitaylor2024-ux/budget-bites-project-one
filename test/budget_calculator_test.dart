import 'package:flutter_test/flutter_test.dart';
import 'package:budget_bites/utils/budget_calculator.dart';

void main() {
  group('Budget Calculator Tests', () {
    test('Calculates remaining budget correctly', () {
      expect(BudgetCalculator.remaining(10000, 3500), 6500);
    });

    test('Detects when spending is over budget', () {
      expect(BudgetCalculator.isOverBudget(5000, 6000), true);
      expect(BudgetCalculator.isOverBudget(5000, 4000), false);
    });

    test('Calculates budget progress correctly', () {
      expect(BudgetCalculator.progress(10000, 2500), 0.25);
      expect(BudgetCalculator.progress(10000, 5000), 0.5);
    });

    test('Caps progress at 100 percent', () {
      expect(BudgetCalculator.progress(5000, 7000), 1.0);
    });

    test('Handles a zero budget safely', () {
      expect(BudgetCalculator.progress(0, 1000), 0.0);
    });

    test('Calculates over-budget amount correctly', () {
      expect(BudgetCalculator.overBudgetAmount(5000, 6500), 1500);
      expect(BudgetCalculator.overBudgetAmount(5000, 3000), 0);
    });
  });
}