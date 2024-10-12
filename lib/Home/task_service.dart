// services/task_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../Auth/auth_service.dart';
import '../Model/task_model.dart';
import '../Service/notification_shedular.dart';

class TaskService with ChangeNotifier {
  final notificationScheduler = NotificationScheduler();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService;
  final Box<Task> _taskBox = Hive.box<Task>('tasks');
  final Connectivity _connectivity = Connectivity();

  TaskService(this._authService);

  // Check if the user is online or offline
  Future<bool> isOnline() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Get tasks, including syncing Hive data if offline
  Stream<List<Task>> getTasks() async* {
    bool online = await isOnline();
    if (online) {
      // Fetch from Firestore if online
      yield* _firestore
          .collection('users')
          .doc(_authService.currentUser!.uid)
          .collection('tasks')
          .orderBy('dueDate')
          .snapshots()
          .map((snapshot) {
        final tasks = snapshot.docs
            .map((doc) => Task.fromDocument(doc))
            .toList();

        // Sync Firestore data to Hive
        _taskBox.clear();
        tasks.forEach((task) => _taskBox.put(task.id, task));

        return tasks;
      });
    } else {
      // Fetch from Hive if offline
      yield _taskBox.values.toList();
    }
  }

  // Add a task, save offline if needed
  Future<void> addTask(Task task) async {
    bool online = await isOnline();
    if (online) {
      // Add to Firestore
      await _firestore
          .collection('users')
          .doc(_authService.currentUser!.uid)
          .collection('tasks')
          .add(task.toMap());

      await notificationScheduler.scheduleTaskNotification(task);
    } else {
      // Add to Hive (offline)
      await notificationScheduler.scheduleTaskNotification(task);

      _taskBox.put(task.id, task);
    }

    notifyListeners();
  }

  // Update a task, save offline if needed
  Future<void> updateTask(Task task) async {
    bool online = await isOnline();
    if (online) {
      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(_authService.currentUser!.uid)
          .collection('tasks')
          .doc(task.id)
          .update(task.toMap());

      await notificationScheduler.scheduleTaskNotification(task);
    } else {
      // Update in Hive (offline)
      await notificationScheduler.scheduleTaskNotification(task);

      _taskBox.put(task.id, task);
    }

    notifyListeners();
  }
  Future<void> completeTask(Task task) async {
    bool online = await isOnline();
    if (online) {
      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(_authService.currentUser!.uid)
          .collection('tasks')
          .doc(task.id)
          .update(task.toMap());


    } else {
      // Update in Hive (offline)


      _taskBox.put(task.id, task);
    }

    notifyListeners();
  }

  // Delete a task, remove offline if needed
  Future<void> deleteTask(String taskId) async {
    bool online = await isOnline();
    if (online) {
      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(_authService.currentUser!.uid)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } else {
      // Delete from Hive (offline)
      _taskBox.delete(taskId);
    }

    notifyListeners();
  }

  // Sync offline tasks with Firestore once back online
  Future<void> syncTasks() async {
    bool online = await isOnline();
    if (online) {
      for (var task in _taskBox.values) {
        await _firestore
            .collection('users')
            .doc(_authService.currentUser!.uid)
            .collection('tasks')
            .doc(task.id)
            .set(task.toMap());
      }

      // Clear Hive after syncing
      _taskBox.clear();
    }
  }
}
