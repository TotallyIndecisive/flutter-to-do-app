import 'package:hive/hive.dart';

class Task {
  final String title;
  final DateTime createdAt;

  Task({required this.title, required this.createdAt});
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final title = reader.readString();
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    return Task(title: title, createdAt: createdAt);
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeString(obj.title);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
