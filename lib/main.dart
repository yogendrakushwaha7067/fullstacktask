// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'Auth/auth_service.dart';
import 'Auth/login_screen.dart';
import 'Home/home_task.dart';
import 'Home/task_service.dart';
import 'Model/task_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'Service/push_notification.dart';
import 'Service/task_adaptar.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;
Future<void> requestNotificationPermissions() async {
  // Check the current status of the permission
  var status = await Permission.notification.status;

  if (!status.isGranted) {
    // Request permission
    var result = await Permission.notification.request();

    if (result.isGranted) {
      // Permission granted
      print("Notification permission granted.");

    } else {
      // Handle permission denied
      print("Notification permission denied.");
    }
  } else {
    // Permission already granted

  }
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tz.initializeTimeZones(); // This is required to initialize the time zones.

    await Hive.initFlutter();
     Hive.registerAdapter(TaskAdapter());

    await Hive.openBox<Task>('tasks');
await requestNotificationPermissions();
  await PushNotificationService().initialize();


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => TaskService(_.read<AuthService>())),


        // Add other providers here
      ],
      child: MaterialApp(
        title: 'Task Manager App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          return user == null ? LoginScreen() : HomeScreen();
        } else {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
