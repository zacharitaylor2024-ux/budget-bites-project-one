import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/database_service.dart';

class MealEditorScreen extends StatefulWidget {
  const MealEditorScreen({super.key});

  @override
  State<MealEditorScreen> createState() => _MealEditorScreenState();
}

class _MealEditorScreenState extends State<MealEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  bool _saving = false;
  List<Meal> _meals = [];
  bool _loading = true;

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final meal = Meal(
        name: _nameController.text.trim(),
        estimatedCost: double.parse(_costController.text.trim()),
        notes: _notesController.text.trim(),
      );

      await DatabaseService.insertMeal(meal);
      await _loadMeals();

      if (!mounted) return;

      _nameController.clear();
      _costController.clear();
      _notesController.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Meal saved successfully!')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save meal: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    try {
      final meals = await DatabaseService.getMeals();

      if (!mounted) return;

      setState(() {
        _meals = meals;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load meals: $error')));
    }
  }

  Widget _buildSavedMeals() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_meals.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No meals saved yet. Add your first meal!'),
      );
    }

    return Column(
      children: _meals.map((meal) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.restaurant),
            title: Text(meal.name),
            subtitle: Text(
              'Estimated cost: \$${meal.estimatedCost.toStringAsFixed(2)}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete meal',
              onPressed: () async {
                await DatabaseService.deleteMeal(meal.id!);
                await _loadMeals();
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Meal Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a meal name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _costController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Estimated Cost',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final cost = double.tryParse(value?.trim() ?? '');

                if (cost == null || !cost.isFinite || cost < 0) {
                  return 'Enter a valid nonnegative cost';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            FilledButton(
              onPressed: _saving ? null : _saveMeal,
              child: Text(_saving ? 'Saving...' : 'Save Meal'),
            ),

            const SizedBox(height: 32),

            const Divider(),

            const SizedBox(height: 16),

            Text('Saved Meals', style: Theme.of(context).textTheme.titleLarge),

            const SizedBox(height: 12),

            _buildSavedMeals(),
          ],
        ),
      ),
    );
  }
}
