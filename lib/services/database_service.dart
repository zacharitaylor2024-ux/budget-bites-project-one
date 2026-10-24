import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/meal.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'budget_bites.db');

    _database = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE meals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            estimated_cost REAL NOT NULL,
            notes TEXT NOT NULL DEFAULT ''
          )
        ''');

        await db.execute('''
          CREATE TABLE purchases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            meal_id INTEGER NOT NULL,
            amount REAL NOT NULL,
            purchased_at TEXT NOT NULL,
            FOREIGN KEY (meal_id)
              REFERENCES meals(id)
              ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            weekly_budget REAL NOT NULL DEFAULT 50.0
          )
        ''');

        await db.insert('settings', {'id': 1, 'weekly_budget': 50.0});
      },
    );

    return _database!;
  }

  // Add a meal to the database.
  static Future<int> insertMeal(Meal meal) async {
    final db = await database;

    return await db.insert('meals', meal.toMap());
  }

  // Retrieve all saved meals.
  static Future<List<Meal>> getMeals() async {
    final db = await database;

    final results = await db.query('meals', orderBy: 'id DESC');

    return results.map((map) => Meal.fromMap(map)).toList();
  }

  // Update an existing meal.
  static Future<int> updateMeal(Meal meal) async {
    final db = await database;

    if (meal.id == null) {
      throw ArgumentError('Cannot update a meal without an ID');
    }

    return await db.update(
      'meals',
      meal.toMap(),
      where: 'id = ?',
      whereArgs: [meal.id],
    );
  }

  // Delete a meal.
  static Future<int> deleteMeal(int id) async {
    final db = await database;

    return await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }
}
