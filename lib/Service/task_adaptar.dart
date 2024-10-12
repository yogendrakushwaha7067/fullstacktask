// GENERATED CODE - DO NOT MODIFY BY HAND


// part of 'task.dart';
// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

import 'package:hive/hive.dart';

import '../Model/task_model.dart';


class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    return Task(
      id: reader.readString(),
      title: reader.readString(),
      description: reader.readString(),
      dueDate: reader.read(),
      isCompleted: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeString(obj.id ?? "");
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.write(obj.dueDate);
    writer.writeBool(obj.isCompleted);
  }
}
