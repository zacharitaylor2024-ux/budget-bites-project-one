import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database.dart';
import '../db/models.dart';
import '../helper/lunch_lens.dart';
import '../widgets/lunch_lens_card.dart';
import 'meal_editor_screen.dart';

class MealDetailsScreen extends StatefulWidget {
  final int mealId;
  const MealDetailsScreen({super.key, required this.mealId});
  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  Meal? _meal;
  List<Purchase> _purchases = [];
  LunchLensResult _lens = const LunchLensResult(null, 0, null);
  bool _lensDismissed = false;

  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  DateTime _date = DateTime.now();
  Purchase? _editing; // purchase being edited, null = new

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await AppDb.instance.meal(widget.mealId);
    final ps = await AppDb.instance.purchasesForMeal(widget.mealId);
    if (!mounted) return;
    setState(() {
      _meal = m;
      _purchases = ps;
      _lens = lunchLens(ps.map((p) => p.amountCents).toList()); // recalculated on every change
               _lensDismissed = false; // new data -> show the updated estimate again
    });
  }

  void _resetForm() {
    _amount.clear();
    _notes.clear();
    _date = DateTime.now();
    _editing = null;
    _form.currentState?.reset();
    setState(() {});
  }

  Future<void> _savePurchase() async {
    if (!_form.currentState!.validate()) return;
    await AppDb.instance.savePurchase(Purchase(
        id: _editing?.id, mealId: widget.mealId, amountCents: parseCents(_amount.text)!,
        purchasedAt: _date, notes: _notes.text.trim().isEmpty ? null : _notes.text.trim()));
    _resetForm();
    _load();
  }

  void _startEdit(Purchase p) => setState(() {

     void _useDraft(int cents) {
       setState(() => _amount.text = (cents / 100).toStringAsFixed(2));
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
           content: Text('Draft amount filled in. Edit it if needed, then tap Save.')));
     }        _editing = p;
        _amount.text = (p.amountCents / 100).toStringAsFixed(2);
        _notes.text = p.notes ?? '';
        _date = p.purchasedAt;
      });

  Future<void> _deletePurchase(Purchase p) async {
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Delete purchase?'),
      content: Text('${money(p.amountCents)} on ${DateFormat.yMd().format(p.purchasedAt)}'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
      ]));
    if (ok != true) return;
    await AppDb.instance.deletePurchase(p.id!);
    if (_editing?.id == p.id) _resetForm();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final m = _meal;
    if (m == null) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(m.name), actions: [
        IconButton(tooltip: 'Edit meal', icon: const Icon(Icons.edit), onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => MealEditorScreen(meal: m)));
          _load();
        }),
      ]),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('${m.category}${m.targetPriceCents == null ? '' : ' · Target ${money(m.targetPriceCents!)}'}'),
        const SizedBox(height: 12),
                  if (!_lensDismissed)
             LunchLensCard(
               lens: _lens,
               onUseDraft: _useDraft,
               onDismiss: () => setState(() => _lensDismissed = true),
             ),
              const SizedBox(height: 8),
              if (_lens.estimateCents != null)
                Text('Estimated next cost: ${money(_lens.estimateCents!)}',
                    style: Theme.of(context).textTheme.titleLarge),
              Text(_lens.explanation),
              const SizedBox(height: 8),
              Row(children: [
                if (_lens.estimateCents != null)
                  FilledButton.tonal(onPressed: () => setState(() =>
                      _amount.text = (_lens.estimateCents! / 100).toStringAsFixed(2)),
                      child: const Text('Use as draft')),
                const SizedBox(width: 8),
                TextButton(onPressed: () => setState(() => _lensDismissed = true), child: const Text('Dismiss')),
              ]),
            ]))),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Form(key: _form, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_editing == null ? 'Log purchase' : 'Edit purchase', style: Theme.of(context).textTheme.titleMedium),
            TextFormField(controller: _amount,
                decoration: const InputDecoration(labelText: 'Amount *', prefixText: '\$'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final c = parseCents(v ?? '');
                  if (c == null) return 'Enter an amount';
                  if (c <= 0) return 'Amount must be greater than \$0';
                  return null;
                }),
            TextFormField(controller: _notes, decoration: const InputDecoration(labelText: 'Notes (optional)')),
            TextButton.icon(icon: const Icon(Icons.calendar_today, size: 18),
                label: Text(DateFormat.yMMMd().format(_date)),
                onPressed: () async {
                  final d = await showDatePicker(context: context, initialDate: _date,
                      firstDate: DateTime(2020), lastDate: DateTime.now());
                  if (d != null) setState(() => _date = d);
                }),
            Row(children: [
              Expanded(child: OutlinedButton(onPressed: _resetForm, child: const Text('Cancel'))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton(onPressed: _savePurchase, child: const Text('Save'))),
            ]),
          ])))),
        const SizedBox(height: 12),
        Text('Purchases', style: Theme.of(context).textTheme.titleMedium),
        if (_purchases.isEmpty)
          const Padding(padding: EdgeInsets.all(16), child: Text('No purchases yet.'))
        else
          ..._purchases.map((p) => ListTile(
            title: Text(money(p.amountCents)),
            subtitle: Text([DateFormat.yMMMd().format(p.purchasedAt), if (p.notes != null) p.notes!].join(' · ')),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(tooltip: 'Edit', icon: const Icon(Icons.edit_outlined), onPressed: () => _startEdit(p)),
              IconButton(tooltip: 'Delete', icon: const Icon(Icons.delete_outline), onPressed: () => _deletePurchase(p)),
            ]))),
      ]),
    );
  }
}
