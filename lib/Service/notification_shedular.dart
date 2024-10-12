// services/notification_scheduler.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../Model/task_model.dart';

class NotificationScheduler {
  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final location = tz.local;
    return tz.TZDateTime.from(dateTime, location);
  }
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> scheduleTaskNotification(Task task) async {
    var androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Notifications',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    var notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id.hashCode,
      'Task Reminder',
      '${task.title} is due soon!',
      tz.TZDateTime.from(
        task.dueDate,
        tz.local,
      ),

      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
