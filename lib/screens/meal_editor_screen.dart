import 'package:flutter/material.dart';
import '../db/database.dart';
import '../db/models.dart';

class MealEditorScreen extends StatefulWidget {
  final Meal? meal; // null = create
  const MealEditorScreen({super.key, this.meal});
  @override
  State<MealEditorScreen> createState() => _MealEditorScreenState();
}

class _MealEditorScreenState extends State<MealEditorScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.meal?.name);
  late final _price = TextEditingController(
      text: widget.meal?.targetPriceCents == null
          ? ''
          : (widget.meal!.targetPriceCents! / 100).toStringAsFixed(2));
  late String? _category = widget.meal?.category;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    final p = _price.text.trim();

    try {
      await AppDb.instance.saveMeal(
        Meal(
          id: widget.meal?.id,
          name: _name.text.trim(),
          category: _category!,
          targetPriceCents: p.isEmpty ? null : parseCents(p),
        ),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving meal: $error'),
          duration: const Duration(seconds: 8),
        ),
      );

      debugPrint('Meal save error: $error');
    }
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: const Text('Delete meal?'),
                content: Text(
                    '"${widget.meal!.name}" and all of its purchases will be permanently deleted.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Delete')),
                ]));
    if (ok != true) return;
    await AppDb.instance.deleteMeal(widget.meal!.id!);
    if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar:
            AppBar(title: Text(widget.meal == null ? 'New meal' : 'Edit meal')),
        body: Form(
            key: _form,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name *'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category *'),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v),
                  validator: (v) => v == null ? 'Category is required' : null),
              const SizedBox(height: 12),
              TextFormField(
                  controller: _price,
                  decoration: const InputDecoration(
                      labelText: 'Target price (optional)', prefixText: '\$'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final c = parseCents(v);
                    if (c == null) return 'Enter a valid price';
                    if (c < 0) return 'Price must be \$0 or more';
                    return null;
                  }),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'))),
                const SizedBox(width: 12),
                Expanded(
                    child: FilledButton(
                        onPressed: _save, child: const Text('Save'))),
              ]),
              if (widget.meal != null) ...[
                const SizedBox(height: 24),
                TextButton.icon(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete meal'),
                    style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error)),
              ],
            ])),
      );
}
