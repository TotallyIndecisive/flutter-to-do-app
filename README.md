# To-Do Flutter Application — v1.2

A minimalist, productivity-focused to-do app built with Flutter and Material 3. Data is persisted locally using Hive.

## Features

- **Create tasks** — FAB opens a dialog; tasks saved immediately to Hive
- **Complete tasks** — Checkbox toggles completion; strikethrough + reduced opacity
- **Delete tasks** — Confirmation dialog before permanent deletion
- **Sort** — Toggle button in the top-right header; newest first / oldest first
- **Persistent storage** — Hive database survives app close, restart, device reboot
- **Empty state** — Centred icon with "No Tasks Yet" and helper text
- **Task counter** — Live count displayed beneath the "My Tasks" header
- **Humanized timestamps** — 24-hour format: "Today • 14:22", "Yesterday • 09:30", "12 Jun 2026 • 08:15"

## Design System

| Token           | Value     |
|-----------------|-----------|
| Background      | `#F5F5F7` |
| Primary         | `#6750A4` |
| Cards           | `#FFFFFF` |
| Primary Text    | `#1C1B1F` |
| Secondary Text  | `#6B7280` |
| Delete Action   | `#D32F2F` |

- Card shape: 16px rounded corners, soft shadow (4px blur, 2px offset, 4% opacity)
- No gradients, no glassmorphism, no excessive shadows
- Optimised for Samsung Galaxy A55

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
  main.dart            — App entry point, UI, and state management
  models/
    task.dart          — Task model (id, title, createdAt, isCompleted) and Hive TypeAdapter
  widgets/
    task_card.dart     — Reusable TaskCard widget with timestamp formatting
```

## Technical Notes

- StatefulWidget for local state management
- `AnimatedList` with `SizeTransition` for Material motion on card insert/remove
- Hive with a manual TypeAdapter (no code generation required)
- Backward-compatible Hive reads for `isCompleted` and `id` fields
- Task `id` generated using timestamp + random alphanumeric string
- Empty task names prevented; whitespace trimmed automatically
- Single-page architecture — no bottom nav, no settings, no secondary screens
