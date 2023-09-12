import 'package:flutter/material.dart';
import 'database.dart';
import 'task.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-do App',
      theme: ThemeData(
        primarySwatch: const MaterialColor(0xff6F45FF, {
          50: Color(0xFFE8E1FF),
          100: Color(0xFFC0A8FF),
          200: Color(0xFF977FFF),
          300: Color(0xFF6F45FF),
          400: Color(0xFF561CFF),
          500: Color(0xFF3B14FF),
          600: Color(0xFF300EFF),
          700: Color(0xFF2605FF),
          800: Color(0xFF1B00FF),
          900: Color(0xFF0D00FF),
        }),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    List<Map<String, dynamic>> taskMaps =
        await DatabaseHelper.instance.getTasks();
    setState(() {
      tasks = taskMaps.map((taskMap) => Task.fromMap(taskMap)).toList();
    });
  }

  Future<void> _addTask(String taskName) async {
    Task task = Task(name: taskName);
    int taskId = await DatabaseHelper.instance.insertTask(task.toMap());
    task.id = taskId;
    setState(() {
      tasks.add(task);
    });
  }

  Future<void> _updateTask(Task task) async {
    task.isCompleted = !task.isCompleted;
    await DatabaseHelper.instance.updateTask(task.toMap());
    setState(() {});
  }

  Future<void> _deleteTask(Task task) async {
    await DatabaseHelper.instance.deleteTask(task.id!);
    setState(() {
      tasks.remove(task);
    });
  }

  Widget _buildTaskItem(Task task) {
    TextStyle textStyle = TextStyle(
      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
    );
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (value) => _updateTask(task),
      ),
      title: Text(task.name, style: textStyle),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () => _deleteTask(task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-do App'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return _buildTaskItem(tasks[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController textController = TextEditingController();
              return AlertDialog(
                title: const Text('Add Task'),
                content: TextField(
                  controller: textController,
                  decoration: const InputDecoration(hintText: 'Task name'),
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton(
                    child: const Text('Add'),
                    onPressed: () {
                      String taskName = textController.text.trim();
                      if (taskName.isNotEmpty) {
                        _addTask(taskName);
                      }
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
