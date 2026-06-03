import 'dart:math';
import 'package:hive/hive.dart';

String _generateId() {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  return List.generate(16, (_) => chars[random.nextInt(chars.length)]).join();
}

class Task {
  final String id;
  final String title;
  final DateTime createdAt;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.createdAt,
    this.isCompleted = false,
  });
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
    return Task(id: id, title: title, createdAt: createdAt, isCompleted: isCompleted);
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeString(obj.title);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeBool(obj.isCompleted);
    writer.writeString(obj.id);
  }
}
