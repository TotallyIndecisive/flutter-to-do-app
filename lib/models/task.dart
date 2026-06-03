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

class Task {
  final String id;
  final String title;
  final DateTime createdAt;
  bool isCompleted;
  TaskCategory category;

  Task({
    required this.id,
    required this.title,
    required this.createdAt,
    this.isCompleted = false,
    this.category = TaskCategory.other,
  });

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
    return Task(
      id: id,
      title: title,
      createdAt: createdAt,
      isCompleted: isCompleted,
      category: category,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeString(obj.title);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeBool(obj.isCompleted);
    writer.writeString(obj.id);
    writer.writeString(obj.category.name);
  }
}
