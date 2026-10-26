import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:budget_bites/db/database.dart';
import 'package:budget_bites/db/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database db;
  final appDb = AppDb.instance;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        singleInstance: false,
        onConfigure: (database) async {
          await database.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (database, version) async {
          await database.execute('''
            CREATE TABLE meals(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              category TEXT NOT NULL,
              target_price_cents INTEGER
                CHECK(target_price_cents IS NULL
                  OR target_price_cents >= 0)
            )
          ''');

          await database.execute('''
            CREATE TABLE purchases(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              meal_id INTEGER NOT NULL
                REFERENCES meals(id) ON DELETE CASCADE,
              amount_cents INTEGER NOT NULL
                CHECK(amount_cents > 0),
              purchased_at TEXT NOT NULL,
              notes TEXT
            )
          ''');
        },
        version: 1,
      ),
    );

    await appDb.setTestDatabase(db);
  });

  tearDown(() async {
    await appDb.closeTestDatabase();
  });

  test('Creates and retrieves a meal', () async {
    final id = await appDb.saveMeal(
      Meal(
        name: 'Chicken and Rice',
        category: 'Lunch',
        targetPriceCents: 850,
      ),
    );

    final saved = await appDb.meal(id);

    expect(saved, isNotNull);
    expect(saved!.name, 'Chicken and Rice');
    expect(saved.category, 'Lunch');
    expect(saved.targetPriceCents, 850);
  });

  test('Updates an existing meal', () async {
    final id = await appDb.saveMeal(
      Meal(name: 'Rice', category: 'Lunch'),
    );

    await appDb.saveMeal(
      Meal(
        id: id,
        name: 'Chicken and Rice',
        category: 'Dinner',
        targetPriceCents: 950,
      ),
    );

    final updated = await appDb.meal(id);

    expect(updated!.name, 'Chicken and Rice');
    expect(updated.category, 'Dinner');
    expect(updated.targetPriceCents, 950);
  });

  test('Filters meals by category', () async {
    await appDb.saveMeal(
      Meal(name: 'Oatmeal', category: 'Breakfast'),
    );

    await appDb.saveMeal(
      Meal(name: 'Chicken', category: 'Lunch'),
    );

    final lunches = await appDb.meals(category: 'Lunch');

    expect(lunches.length, 1);
    expect(lunches.first.name, 'Chicken');
  });

  test('Records a purchase and calculates spending', () async {
    final mealId = await appDb.saveMeal(
      Meal(name: 'Chicken', category: 'Lunch'),
    );

    final date = DateTime(2026, 10, 25, 12);

    await appDb.savePurchase(
      Purchase(
        mealId: mealId,
        amountCents: 850,
        purchasedAt: date,
      ),
    );

    await appDb.savePurchase(
      Purchase(
        mealId: mealId,
        amountCents: 650,
        purchasedAt: date,
      ),
    );

    final total = await appDb.totalBetween(
      DateTime(2026, 10, 25),
      DateTime(2026, 10, 26),
    );

    expect(total, 1500);
  });

  test('History excludes purchases outside the date range',
      () async {
    final mealId = await appDb.saveMeal(
      Meal(name: 'Chicken', category: 'Lunch'),
    );

    await appDb.savePurchase(
      Purchase(
        mealId: mealId,
        amountCents: 850,
        purchasedAt: DateTime(2026, 10, 24),
      ),
    );

    await appDb.savePurchase(
      Purchase(
        mealId: mealId,
        amountCents: 950,
        purchasedAt: DateTime(2026, 10, 25),
      ),
    );

    final history = await appDb.history(
      DateTime(2026, 10, 25),
      DateTime(2026, 10, 26),
    );

    expect(history.length, 1);
    expect(history.first['amount_cents'], 950);
  });

  test('Deleting a meal also deletes its purchases', () async {
    final mealId = await appDb.saveMeal(
      Meal(name: 'Chicken', category: 'Lunch'),
    );

    await appDb.savePurchase(
      Purchase(
        mealId: mealId,
        amountCents: 850,
        purchasedAt: DateTime(2026, 10, 25),
      ),
    );

    await appDb.deleteMeal(mealId);

    final savedMeal = await appDb.meal(mealId);
    final purchases = await appDb.purchasesForMeal(mealId);

    expect(savedMeal, isNull);
    expect(purchases, isEmpty);
  });

  test('Rejects purchases with zero or negative amounts',
      () async {
    final mealId = await appDb.saveMeal(
      Meal(name: 'Chicken', category: 'Lunch'),
    );

    expect(
      () => appDb.savePurchase(
        Purchase(
          mealId: mealId,
          amountCents: 0,
          purchasedAt: DateTime(2026, 10, 25),
        ),
      ),
      throwsA(isA<DatabaseException>()),
    );
  });
}