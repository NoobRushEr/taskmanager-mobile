import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskmanager_mobile/models/task_model.dart';
import 'package:taskmanager_mobile/services/database_service.dart';

class TaskWidget extends StatefulWidget {
  final VoidCallback onLogout;

  const TaskWidget({super.key, required this.onLogout});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String emsg = '';

  @override
  void dispose() {
    _taskController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showTaskSheet({TaskModel? task}) {
    // Pre-fill or clear based on mode
    if (task != null) {
      _taskController.text = task.title;
      _descriptionController.text = task.description;
    } else {
      _taskController.clear();
      _descriptionController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    task != null ? 'Edit Task' : 'Add Task',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(labelText: 'Task Title'),
                    maxLength: 50,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Task Description',
                    ),
                    maxLines: 2,
                    maxLength: 100,
                  ),
                  SizedBox(height: 15.0),
                  // ✅ Use StatefulBuilder to reflect emsg changes inside sheet
                  StatefulBuilder(
                    builder: (context, setSheetState) {
                      return Text(emsg, style: TextStyle(color: Colors.red));
                    },
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () async {
                      if (task != null) {
                        await _editTask(task, setSheetState);
                      } else {
                        await _addTask(setSheetState);
                      }
                    },
                    child: Text(task != null ? 'Save Changes' : 'Add Task'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      setState(() => emsg = '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: widget.onLogout),
        ],
      ),
      body: StreamBuilder(
        stream: _databaseService.getTasks(
          FirebaseAuth.instance.currentUser!.uid,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading tasks'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No tasks found. Add a new task using the + button below.',
              ),
            );
          }

          final pendingtasks =
              snapshot.data?.where((task) => !task.isCompleted).toList() ?? [];
          final completedtasks =
              snapshot.data?.where((task) => task.isCompleted).toList() ?? [];

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back! ${FirebaseAuth.instance.currentUser!.email}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Here are your tasks for today:',
                        style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Pending Tasks: ${pendingtasks.length}",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                if (pendingtasks.isEmpty)
                  Center(
                    child: Text(
                      "No pending tasks",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                else ...[
                  _buildTaskwidget(pendingtasks, false),
                ],

                Divider(height: 20, thickness: 1.5),

                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 0),
                  child: Text(
                    "Completed Tasks: ${completedtasks.length}",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),

                if (completedtasks.isEmpty)
                  Center(
                    child: Text(
                      "No completed tasks",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                else ...[
                  _buildTaskwidget(completedtasks, true),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskSheet(),
        child: Icon(Icons.add),
      ),
    );
  }

  //taskwidget for completed tasks
  Widget _buildTaskwidget(List<TaskModel> tasks, bool isCompleted) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final TaskModel task = tasks[index];
        return ListTile(
          title: isCompleted
              ? Text(
                  task.title,
                  style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey[500]),
                )
              : Text(task.title),
          subtitle: Text(
            task.description.isEmpty ? "No description" : task.description,
            style: TextStyle(color: Colors.grey[600]),
          ),
          leading: Checkbox(
            value: task.isCompleted,
            onChanged: (value) => _databaseService.updateTask(
              task.id,
              task.title,
              task.description,
              value ?? false,
            ),
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showTaskSheet(task: task);
              } else if (value == 'delete') {
                _databaseService.deleteTask(task.id);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addTask(StateSetter setSheetState) async {
    if (_taskController.text.isEmpty || _taskController.text.length < 3) {
      setSheetState(
        () => emsg = "Task name must be at least 3 characters long",
      );
      return;
    }

    await _databaseService.createTask(
      _taskController.text,
      _descriptionController.text,
      FirebaseAuth.instance.currentUser!.uid,
    );

    _taskController.clear();
    _descriptionController.clear();
    Navigator.pop(context);
  }

  Future<void> _editTask(TaskModel task, StateSetter setSheetState) async {
    if (_taskController.text.isEmpty || _taskController.text.length < 3) {
      setSheetState(
        () => emsg = "Task name must be at least 3 characters long",
      );
      return;
    }

    await _databaseService.updateTask(
      task.id,
      _taskController.text,
      _descriptionController.text,
      task.isCompleted,
    );

    _taskController.clear();
    _descriptionController.clear();
    Navigator.pop(context);
  }
}
