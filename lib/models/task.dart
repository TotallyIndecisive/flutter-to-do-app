import 'package:hive/hive.dart';

class Task {
  final String title;
  final DateTime createdAt;
  bool isCompleted;

  Task({
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
    return Task(title: title, createdAt: createdAt, isCompleted: isCompleted);
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeString(obj.title);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeBool(obj.isCompleted);
  }
}
