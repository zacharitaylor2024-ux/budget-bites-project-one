import 'package:flutter/material.dart';
import '../db/database.dart';
import '../db/models.dart';
import '../settings_store.dart';
import 'history_screen.dart';
import 'meal_details_screen.dart';
import 'meal_editor_screen.dart';
import 'settings_screen.dart';
import '../utils/budget_calculator.dart';

typedef DashboardLoader = Future<DashboardData> Function(String? category);

class DashboardData {
  final List<Meal> meals;
  final int weekTotal;

  const DashboardData({
    required this.meals,
    required this.weekTotal,
  });
}

Future<DashboardData> loadDashboardData(String? category) async {
  final (start, end) = currentWeek();

  final meals = await AppDb.instance.meals(category: category);
  final total = await AppDb.instance.totalBetween(start, end);

  return DashboardData(
    meals: meals,
    weekTotal: total,
  );
}

class DashboardScreen extends StatefulWidget {
  final DashboardLoader loader;

  const DashboardScreen({
    super.key,
    this.loader = loadDashboardData,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _filter;
  List<Meal> _meals = [];
  int _weekTotal = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await widget.loader(_filter);

    if (!mounted) return;

    setState(() {
      _meals = data.meals;
      _weekTotal = data.weekTotal;
    });
  }

  Future<void> _go(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );

    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final budget = SettingsStore.instance.weeklyBudgetCents;
    final ratio = BudgetCalculator.progress(budget, _weekTotal);
    final over = BudgetCalculator.isOverBudget(budget, _weekTotal);
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Bites'), actions: [
        IconButton(
            tooltip: 'History',
            icon: const Icon(Icons.history),
            onPressed: () => _go(const HistoryScreen())),
        IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () => _go(const SettingsScreen())),
      ]),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _go(const MealEditorScreen()),
          icon: const Icon(Icons.add),
          label: const Text('Meal')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('This week'),
                        Text('${money(_weekTotal)} / ${money(budget)}',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                            value: ratio,
                            minHeight: 8,
                            color: over
                                ? Theme.of(context).colorScheme.error
                                : null),
                        if (over)
                          Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                  'Over budget by ${money(BudgetCalculator.overBudgetAmount(budget, _weekTotal))}',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error))),
                      ]))),
          const SizedBox(height: 8),
          Wrap(
              spacing: 8,
              children: [null, ...categories]
                  .map((c) => ChoiceChip(
                      label: Text(c ?? 'All'),
                      selected: _filter == c,
                      onSelected: (_) {
                        _filter = c;
                        _load();
                      }))
                  .toList()),
          const SizedBox(height: 8),
          if (_meals.isEmpty)
            Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                    child: Text(
                        _filter == null
                            ? 'No meals yet. Tap + Meal to add your first meal.'
                            : 'No $_filter meals.',
                        textAlign: TextAlign.center)))
          else
            ..._meals.map((m) => Card(
                child: ListTile(
                    title: Text(m.name),
                    subtitle: Text(m.category),
                    trailing: Text(m.targetPriceCents == null
                        ? ''
                        : money(m.targetPriceCents!)),
                    onTap: () => _go(MealDetailsScreen(mealId: m.id!))))),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}
