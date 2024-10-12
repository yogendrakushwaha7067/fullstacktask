// screens/add_edit_task_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:fullstack/Home/task_service.dart';
import 'package:provider/provider.dart';

import '../Model/task_model.dart';
import '../Service/convertTime.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  AddEditTaskScreen({this.task});

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  DateTime _dueDate = DateTime.now().add(Duration(days: 1));

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description;
      _dueDate = widget.task!.dueDate;
    } else {
      _title = '';
      _description = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskService = Provider.of<TaskService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Title'),
                onSaved: (value) => _title = value!,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value!,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('Due Date: ${formatDateWithMonthNameAndTime(_dueDate)}',),
                  Spacer(),
                  TextButton(
                    onPressed: () async {

                      DatePicker.showDateTimePicker(
                        context,
                        showTitleActions: true,
                        onChanged: (date) => setState(() {


                          _dueDate = date;
                          print(_dueDate);
                        }),
                        onConfirm: (date) {
                          setState(() {


                            _dueDate = date;
                            print(_dueDate);
                          });
                        },
                      );
                    },
                    child: Text('Select Date'),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final task = Task(
                      id: widget.task?.id,
                      title: _title,
                      description: _description,
                      dueDate: _dueDate,
                      isCompleted: widget.task?.isCompleted ?? false,
                    );
                    if (widget.task == null) {
                      await taskService.addTask(task);
                    } else {
                      await taskService.updateTask(task);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.task == null ? 'Add Task' : 'Update Task'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
