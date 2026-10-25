class Meal {
  final int? id;
  final String name;
  final String category;
  final int? targetPriceCents;
  Meal({this.id, required this.name, required this.category, this.targetPriceCents});
  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'category': category,
        'target_price_cents': targetPriceCents,
      };
  factory Meal.fromMap(Map<String, Object?> m) => Meal(
        id: m['id'] as int,
        name: m['name'] as String,
        category: m['category'] as String,
        targetPriceCents: m['target_price_cents'] as int?,
      );
}

class Purchase {
  final int? id;
  final int mealId;
  final int amountCents;
  final DateTime purchasedAt;
  final String? notes;
  Purchase({this.id, required this.mealId, required this.amountCents, required this.purchasedAt, this.notes});
  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'meal_id': mealId,
        'amount_cents': amountCents,
        'purchased_at': purchasedAt.toIso8601String(),
        'notes': notes,
      };
  factory Purchase.fromMap(Map<String, Object?> m) => Purchase(
        id: m['id'] as int,
        mealId: m['meal_id'] as int,
        amountCents: m['amount_cents'] as int,
        purchasedAt: DateTime.parse(m['purchased_at'] as String),
        notes: m['notes'] as String?,
      );
}

const categories = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

String money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

/// Parses "8.5" / "\$8.50" into cents; null if invalid.
int? parseCents(String s) {
  final v = double.tryParse(s.replaceAll('\$', '').trim());
  if (v == null) return null;
  return (v * 100).round();
}
