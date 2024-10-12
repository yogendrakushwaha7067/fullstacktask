// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:fullstack/Home/task_service.dart';
import 'package:provider/provider.dart';

import '../Auth/auth_service.dart';
import '../Model/task_model.dart';
import '../Service/convertTime.dart';
import 'add_edit_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final taskService = Provider.of<TaskService>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authService.signOut();
            },
          )
        ],
      ),
      body: StreamBuilder<List<Task>>(
        stream: taskService.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading tasks'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final tasks = snapshot.data!;
          if (tasks.isEmpty) {
            return Center(child: Text('No tasks found'));
          }
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle:
                Text('${task.description}\nDue: ${formatDateWithMonthNameAndTime(task.dueDate)}'),
                isThreeLine: true,
                trailing: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    task.isCompleted = value!;
                    taskService.completeTask(task);
                  },
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditTaskScreen(task: task),
                    ),
                  );
                },
                onLongPress: () {
                  // Delete Task
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Delete Task'),
                      content:
                      Text('Are you sure you want to delete this task?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            taskService.deleteTask(task.id!);
                            Navigator.pop(context);
                          },
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditTaskScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
