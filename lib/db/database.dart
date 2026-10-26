import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'models.dart';

class AppDb {
  AppDb._();
  static final instance = AppDb._();

  Database? _db;

  Future<void> setTestDatabase(Database testDatabase) async {
    await _db?.close();
    _db = testDatabase;
  }

  Future<void> closeTestDatabase() async {
    await _db?.close();
    _db = null;
  }

  Future<Database> get db async => _db ??= await openDatabase(
        join(await getDatabasesPath(), 'budget_bites.db'),
        version: 1,
        onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
        onCreate: (d, _) async {
          await d.execute('''CREATE TABLE meals(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            target_price_cents INTEGER CHECK(target_price_cents IS NULL OR target_price_cents >= 0))''');
          await d.execute('''CREATE TABLE purchases(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            meal_id INTEGER NOT NULL REFERENCES meals(id) ON DELETE CASCADE,
            amount_cents INTEGER NOT NULL CHECK(amount_cents > 0),
            purchased_at TEXT NOT NULL,
            notes TEXT)''');
        },
      );

  // Meals
  Future<List<Meal>> meals({String? category}) async {
    final rows = await (await db).query('meals',
        where: category == null ? null : 'category = ?',
        whereArgs: category == null ? null : [category],
        orderBy: 'name COLLATE NOCASE');
    return rows.map(Meal.fromMap).toList();
  }

  Future<Meal?> meal(int id) async {
    final r = await (await db).query('meals', where: 'id = ?', whereArgs: [id]);
    return r.isEmpty ? null : Meal.fromMap(r.first);
  }

  Future<int> saveMeal(Meal m) async {
    final d = await db;
    if (m.id == null) return d.insert('meals', m.toMap());
    await d.update('meals', m.toMap(), where: 'id = ?', whereArgs: [m.id]);
    return m.id!;
  }

  Future<void> deleteMeal(int id) async =>
      (await db).delete('meals', where: 'id = ?', whereArgs: [id]); // cascades

  // Purchases
  Future<List<Purchase>> purchasesForMeal(int mealId, {int? limit}) async {
    final r = await (await db).query('purchases',
        where: 'meal_id = ?',
        whereArgs: [mealId],
        orderBy: 'purchased_at DESC, id DESC',
        limit: limit);
    return r.map(Purchase.fromMap).toList();
  }

  Future<List<Map<String, Object?>>> history(
          DateTime from, DateTime to) async =>
      (await db).rawQuery('''SELECT p.*, m.name AS meal_name FROM purchases p
        JOIN meals m ON m.id = p.meal_id
        WHERE p.purchased_at >= ? AND p.purchased_at < ?
        ORDER BY p.purchased_at DESC''',
          [from.toIso8601String(), to.toIso8601String()]);

  Future<int> totalBetween(DateTime from, DateTime to) async {
    final r = await (await db).rawQuery(
        'SELECT COALESCE(SUM(amount_cents),0) AS t FROM purchases WHERE purchased_at >= ? AND purchased_at < ?',
        [from.toIso8601String(), to.toIso8601String()]);
    return r.first['t'] as int;
  }

  Future<void> savePurchase(Purchase p) async {
    final d = await db;
    if (p.id == null) {
      await d.insert('purchases', p.toMap());
    } else {
      await d
          .update('purchases', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
    }
  }

  Future<void> deletePurchase(int id) async =>
      (await db).delete('purchases', where: 'id = ?', whereArgs: [id]);
}

/// Monday 00:00 of the current week through next Monday.
(DateTime, DateTime) currentWeek() {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
  return (start, start.add(const Duration(days: 7)));
}
