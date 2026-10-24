class Meal {
  final int? id;
  final String name;
  final double estimatedCost;
  final String notes;

  Meal({
    this.id,
    required this.name,
    required this.estimatedCost,
    this.notes = '',
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'estimated_cost': estimatedCost,
      'notes': notes,
    };
  }

  factory Meal.fromMap(Map<String, Object?> map) {
    return Meal(
      id: map['id'] as int?,
      name: map['name'] as String,
      estimatedCost: (map['estimated_cost'] as num).toDouble(),
      notes: map['notes'] as String? ?? '',
    );
  }
}