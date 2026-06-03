# To-Do Flutter Application — v2.0

A minimalist, productivity-focused to-do app built with Flutter and Material 3. All data is persisted locally using Hive.

## Features

### Task Management
- **Create tasks** — FAB opens a dialog with task name and category picker
- **Complete tasks** — Checkbox toggles completion; strikethrough + reduced opacity
- **Delete tasks** — Confirmation dialog or swipe-to-delete with undo SnackBar
- **Categories** — Personal, Work, Study, Other — shown as colour-coded badges on cards

### Search & Filtering
- **Search** — Real-time filtering by task title via search bar in header
- **Filter** — Three filter chips (All / Active / Completed)

### Sorting
- **Newest / Oldest** — Toggle button in the top-right header area

### Bulk Actions
- **Mark All Complete** — via overflow menu (⋮)
- **Clear Completed** — removes all completed tasks permanently

### Statistics
- Live stats row below filters: Total, Active, Completed counts

### Storage
- **Hive** — Local offline-only persistence
- Survives: app close, app restart, device reboot, emulator restart

### Empty State
- Centred icon with "No Tasks Yet" heading and helper text

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
- Category colours: Personal `#4CAF50`, Work `#2196F3`, Study `#FF9800`, Other `#9E9E9E`
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
    task.dart          — Task model, TaskCategory enum, Hive TypeAdapter
  widgets/
    task_card.dart     — Reusable TaskCard widget with category badge
```

## Technical Notes

- StatefulWidget for local state management
- Hive with a manual TypeAdapter (no code generation required)
- Backward-compatible Hive reads for `isCompleted`, `id`, and `category` fields
- Unique task IDs generated from timestamp (`millisecondsSinceEpoch_microsecondsSinceEpoch`)
- Task Key Map (`Map<String, dynamic>`) maps task IDs to Hive box keys for reliable lookup
- `Dismissible` widget for swipe-to-delete with `onDismissed` callback
- SnackBar-based undo — tasks are deleted from Hive immediately, restored on Undo tap
- Search and filter operate on the in-memory list via `_filteredTasks` getter
- Bulk actions iterate the full task list and batch-update Hive
- Single-page architecture — no bottom nav, no settings, no secondary screens
