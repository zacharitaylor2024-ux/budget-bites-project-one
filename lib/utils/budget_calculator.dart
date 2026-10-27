class BudgetCalculator {
  static int remaining(int budgetCents, int spentCents) {
    return budgetCents - spentCents;
  }

  static bool isOverBudget(int budgetCents, int spentCents) {
    return spentCents > budgetCents;
  }

  static double progress(int budgetCents, int spentCents) {
    if (budgetCents <= 0) return 0.0;

    return (spentCents / budgetCents).clamp(0.0, 1.0);
  }

  static int overBudgetAmount(int budgetCents, int spentCents) {
    return spentCents > budgetCents
        ? spentCents - budgetCents
        : 0;
  }
}