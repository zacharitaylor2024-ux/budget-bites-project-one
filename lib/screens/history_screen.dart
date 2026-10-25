import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database.dart';
import '../db/models.dart';
import 'meal_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DateTimeRange _range;
  List<Map<String, Object?>> _rows = [];

  @override
  void initState() {
    super.initState();
    final (s, e) = currentWeek();
    _range = DateTimeRange(start: s, end: e.subtract(const Duration(days: 1)));
    _load();
  }

  Future<void> _load() async {
    final rows = await AppDb.instance.history(_range.start, _range.end.add(const Duration(days: 1)));
    if (mounted) setState(() => _rows = rows);
  }

  @override
  Widget build(BuildContext context) {
    final total = _rows.fold<int>(0, (a, r) => a + (r['amount_cents'] as int));
    final f = DateFormat.MMMd();
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        OutlinedButton.icon(icon: const Icon(Icons.date_range),
            label: Text('${f.format(_range.start)} – ${f.format(_range.end)}'),
            onPressed: () async {
              final r = await showDateRangePicker(context: context, initialDateRange: _range,
                  firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 7)));
              if (r != null) { _range = r; _load(); }
            }),
        Card(child: ListTile(title: const Text('Period total'),
            subtitle: Text('${_rows.length} purchase${_rows.length == 1 ? '' : 's'}'),
            trailing: Text(money(total), style: Theme.of(context).textTheme.titleLarge))),
        if (_rows.isEmpty)
          const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No purchases in this range.')))
        else
          ..._rows.map((r) => ListTile(
            leading: Text(f.format(DateTime.parse(r['purchased_at'] as String))),
            title: Text(r['meal_name'] as String),
            trailing: Text(money(r['amount_cents'] as int)),
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => MealDetailsScreen(mealId: r['meal_id'] as int)));
              _load();
            })),
      ]),
    );
  }
}
