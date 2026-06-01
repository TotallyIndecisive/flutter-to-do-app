# To-Do Flutter Application — v1.0

A minimal, modern to-do app built with Flutter and Material 3, inspired by premium productivity apps. Data is persisted locally using Hive.

## Features

- **Create tasks** — FloatingActionButton opens a dialog to enter a new task
- **Task list** — Scrollable list of task cards with pastel leading icons, title, and date
- **Complete tasks** — Checkbox toggles task completion, crossing out the text with grey styling
- **Delete tasks** — Delete icon removes a task from the list and storage
- **Persistent storage** — All tasks are saved to a local Hive database and survive restarts
- **Empty state** — Friendly "No tasks yet" message when the list is empty
- **Task count** — Live count displayed below the header

## Prerequisites

- Flutter SDK (3.x or later)
- Android emulator or physical device
- Dart SDK (bundled with Flutter)

## Setup & Running

```bash
# Get dependencies
flutter pub get

# Run on a specific emulator
flutter run -d emulator-5554

# Or let Flutter auto-detect available devices
flutter run
```

## Hive Database

Tasks are stored in a Hive box at:

```
/data/data/com.example.test_app/app_flutter/tasks.hive
```

Inspect the database with:

```bash
adb shell run-as com.example.test_app ls /data/data/com.example.test_app/app_flutter/
```

## Project Structure

```
lib/
  main.dart           — App entry point, UI, and state management
  models/
    task.dart         — Task model and Hive TypeAdapter
```

## Technical Notes

- StatefulWidget for local state management
- Hive with a manual TypeAdapter (no code generation required)
- Material 3 design with custom color scheme (#F6F3FA background, #7C4DFF primary)
- Backward-compatible Hive reads for the `isCompleted` field
