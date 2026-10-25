import 'package:flutter/material.dart';
import '../db/models.dart';
import '../settings_store.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _form = GlobalKey<FormState>();
  final _store = SettingsStore.instance;
  late final _budget = TextEditingController(text: (_store.weeklyBudgetCents / 100).toStringAsFixed(2));
  late ThemeMode _mode = _store.themeMode.value;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    await _store.save(budgetCents: parseCents(_budget.text)!, mode: _mode);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Form(key: _form, child: ListView(padding: const EdgeInsets.all(16), children: [
          TextFormField(controller: _budget,
              decoration: const InputDecoration(labelText: 'Weekly food budget', prefixText: '\$'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final c = parseCents(v ?? '');
                if (c == null) return 'Enter a budget';
                if (c <= 0) return 'Budget must be greater than \$0';
                return null;
              }),
          const SizedBox(height: 24),
          const Text('Theme'),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() => _mode = s.first)),
          const SizedBox(height: 16),
          const Text('Saved locally on this device. No account, works offline.'),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))),
            const SizedBox(width: 12),
            Expanded(child: FilledButton(onPressed: _save, child: const Text('Save'))),
          ]),
        ])),
      );
}
