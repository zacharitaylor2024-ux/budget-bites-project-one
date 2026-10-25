import 'package:flutter_test/flutter_test.dart';
import 'package:budget_bites/db/database.dart';

void main() {
  group('Dashboard weekly date tests', () {
    test('Current week starts on Monday', () {
      final (start, end) = currentWeek();

      expect(start.weekday, DateTime.monday);
      expect(start.hour, 0);
      expect(start.minute, 0);
    });

    test('Current week ends seven days later', () {
      final (start, end) = currentWeek();

      expect(
        end.difference(start),
        const Duration(days: 7),
      );
    });

    test('Current date falls inside the selected week', () {
      final (start, end) = currentWeek();
      final now = DateTime.now();

      expect(now.isBefore(start), false);
      expect(now.isBefore(end), true);
    });
  });
}