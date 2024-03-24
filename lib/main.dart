import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ToDoListScreen(),
    );
  }
}

class ToDoListScreen extends StatefulWidget {
  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  List<Task> tasks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          color: Colors.blue, // Set background color
          child: AppBar(
            title:
                Text('To Do List App', style: TextStyle(color: Colors.white)),
            centerTitle: true, // Center the title
            backgroundColor: Colors.transparent, // Make app bar transparent
            elevation: 0, // Remove app bar shadow
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Checkbox(
              value: tasks[index].isCompleted,
              onChanged: (bool? value) {
                setState(() {
                  tasks[index].isCompleted = value ?? false;
                });
              },
            ),
            title: Text(
              tasks[index].task,
              style: TextStyle(
                decoration: tasks[index].isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmationDialog(index);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          _navigateToAddTaskScreen(context);
        },
        child: Icon(Icons.add, color: Colors.white),
        shape: CircleBorder(),
      ),
    );
  }

  void _navigateToAddTaskScreen(BuildContext context) async {
    final newTask = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskScreen()),
    );

    if (newTask != null) {
      setState(() {
        tasks.add(Task(task: newTask));
      });
    }
  }

  void _showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this task?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                setState(() {
                  tasks.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Task deleted"),
                    duration: Duration(seconds: 2),
                  ),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(labelText: 'Task'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _addTask();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue, // Set button color to blue
              ),
              child: Text(
                'Add',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addTask() {
    String task = _taskController.text.trim();
    if (task.isNotEmpty) {
      Navigator.pop(context, task);
    } else {
      // Show some error message if task is empty
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}

class Task {
  String task;
  bool isCompleted;

  Task({required this.task, this.isCompleted = false});
}
