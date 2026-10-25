import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  SettingsStore._();
  static final instance = SettingsStore._();
  final themeMode = ValueNotifier(ThemeMode.system);
  int weeklyBudgetCents = 6000;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    weeklyBudgetCents = p.getInt('weekly_budget_cents') ?? 6000;
    themeMode.value = ThemeMode.values[p.getInt('theme_mode') ?? 0];
  }

  Future<void> save({required int budgetCents, required ThemeMode mode}) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt('weekly_budget_cents', budgetCents);
    await p.setInt('theme_mode', mode.index);
    weeklyBudgetCents = budgetCents;
    themeMode.value = mode;
  }
}
