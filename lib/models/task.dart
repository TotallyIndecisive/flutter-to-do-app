import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

String _generateId() {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  return List.generate(16, (_) => chars[random.nextInt(chars.length)]).join();
}

enum TaskCategory {
  personal,
  work,
  study,
  other,
}

extension TaskCategoryExtension on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.personal:
        return 'Personal';
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.study:
        return 'Study';
      case TaskCategory.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case TaskCategory.personal:
        return const Color(0xFF4CAF50);
      case TaskCategory.work:
        return const Color(0xFF2196F3);
      case TaskCategory.study:
        return const Color(0xFFFF9800);
      case TaskCategory.other:
        return const Color(0xFF9E9E9E);
    }
  }
}

enum TaskColor {
  green,
  red,
  blue,
  purple,
}

extension TaskColorExtension on TaskColor {
  Color get color {
    switch (this) {
      case TaskColor.green:
        return const Color(0xFF4CAF50);
      case TaskColor.red:
        return const Color(0xFFF44336);
      case TaskColor.blue:
        return const Color(0xFF2196F3);
      case TaskColor.purple:
        return const Color(0xFF7E57C2);
    }
  }

  String get label {
    switch (this) {
      case TaskColor.green:
        return 'Green';
      case TaskColor.red:
        return 'Red';
      case TaskColor.blue:
        return 'Blue';
      case TaskColor.purple:
        return 'Purple';
    }
  }
}

class Task {
  final String id;
  final String title;
  final DateTime createdAt;
  bool isCompleted;
  TaskCategory category;
  String? customCategory;
  TaskColor taskColor;

  Task({
    required this.id,
    required this.title,
    required this.createdAt,
    this.isCompleted = false,
    this.category = TaskCategory.other,
    this.customCategory,
    this.taskColor = TaskColor.purple,
  });

  String get displayCategory =>
      (customCategory != null && customCategory!.trim().isNotEmpty)
          ? customCategory!.trim()
          : category.label;

  Color get displayColor => taskColor.color;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Task && id == other.id);

  @override
  int get hashCode => id.hashCode;
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final title = reader.readString();
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    bool isCompleted = false;
    try {
      isCompleted = reader.readBool();
    } catch (_) {}
    String id;
    try {
      id = reader.readString();
    } catch (_) {
      id = _generateId();
    }
    TaskCategory category = TaskCategory.other;
    try {
      final catStr = reader.readString();
      category = TaskCategory.values.firstWhere(
        (c) => c.name == catStr,
        orElse: () => TaskCategory.other,
      );
    } catch (_) {}
    String? customCategory;
    try {
      final hasCustom = reader.readBool();
      if (hasCustom) {
        customCategory = reader.readString();
      }
    } catch (_) {}
    TaskColor taskColor = TaskColor.purple;
    try {
      final colorStr = reader.readString();
      taskColor = TaskColor.values.firstWhere(
        (c) => c.name == colorStr,
        orElse: () => TaskColor.purple,
      );
    } catch (_) {}
    return Task(
      id: id,
      title: title,
      createdAt: createdAt,
      isCompleted: isCompleted,
      category: category,
      customCategory: customCategory,
      taskColor: taskColor,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeString(obj.title);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeBool(obj.isCompleted);
    writer.writeString(obj.id);
    writer.writeString(obj.category.name);
    writer.writeBool(obj.customCategory != null && obj.customCategory!.trim().isNotEmpty);
    if (obj.customCategory != null && obj.customCategory!.trim().isNotEmpty) {
      writer.writeString(obj.customCategory!.trim());
    }
    writer.writeString(obj.taskColor.name);
  }
}
