# Budget Bites

Budget Bites is a Flutter application that helps users track their food expenses and manage a weekly food budget. Users can save meals, record purchases, and view their spending history. The application works offline and stores information locally.

## Team Members

- Zachari Taylor
- Jason Kim

## Technologies

- Flutter and Dart
- SQLite (`sqflite`)
- Shared Preferences for application settings

## Features

The application contains five screens:

1. Dashboard: Displays weekly spending, budget progress, saved meals, and category filters.
2. Meal Editor:Allows users to create, edit, and delete meals.
3. Meal Details: Allows users to record, edit, and delete purchases associated with a meal.
4. History: Displays purchases and spending totals for a selected date range.
5. Settings: Allows users to change their weekly budget and application theme.

## Smart Helper — Lunch Lens

Lunch Lens estimates the cost of a meal using its previous purchase prices. It provides an explanation of its estimate and allows users to use the suggested amount as an editable draft.

The helper operates locally without requiring an internet connection.

See [AI_FEATURE.md](AI_FEATURE.md) for the implementation method, evaluation results, and limitations.

## Running the Application

Make sure Flutter and an Android emulator or device are installed.

From the project directory, run:

flutter pub get
flutter run

## Running Tests

Run all unit and widget tests:

flutter test test

Run the Android integration test with an emulator or device connected:

flutter test integration_test/app_test.dart

Generate the code coverage report:

flutter test test --coverage

The coverage report is generated at `coverage/lcov.info`.

## Building the APK

To build the Android release APK, run:

flutter build apk --release

The generated APK is located at:

`build/app/outputs/flutter-apk/app-release.apk`

## Project Structure

- `lib/screens/` — Application screens
- `lib/db/` — SQLite database and data models
- `lib/helper/` — Lunch Lens estimation logic
- `lib/widgets/` — Reusable UI components
- `lib/utils/` — Budget calculation utilities
- `test/` — Unit, database, and widget tests
- `integration_test/` — Android integration tests

## Data Storage

Budget Bites stores meals and purchases in a local SQLite database. Application preferences are stored separately. Saved information remains available after closing and reopening the application.

No account or internet connection is required to use the app.