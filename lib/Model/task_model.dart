import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';


@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  bool isCompleted;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = false,
  });

  // Factory constructor to create a Task object from Firestore DocumentSnapshot
  factory Task.fromDocument(DocumentSnapshot doc) {
    return Task(
      id: doc.id,
      title: doc['title'],
      description: doc['description'],
      dueDate: (doc['dueDate'] as Timestamp).toDate(),
      isCompleted: doc['isCompleted'],
    );
  }

  // Method to convert a Task object to a Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'isCompleted': isCompleted,
    };
  }
}
