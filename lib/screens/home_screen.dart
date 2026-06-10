import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskmanager_mobile/services/auth_service.dart';
import 'package:taskmanager_mobile/services/database_service.dart';
import 'package:taskmanager_mobile/widgets/container_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  String emsg = '';

  @override
  Widget build(BuildContext context) {
    List<String> list = ['Task 1', 'Task 2', 'Task 3', 'Task 4', 'Task 5'];

    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: logout)],
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

          final tasks = snapshot.data ?? [];

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text('Description: ${task.description}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    // TODO: Wire up the Delete execution call using task.id
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Forces keyboard layout handling
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(
              context,
            ).viewInsets.bottom, // Adjusts for keyboard
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _taskController,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Task Description',
                ),
              ),
              SizedBox(height: 10.0),
              Text("$emsg", style: TextStyle(color: Colors.red)),
              const SizedBox(height: 35),
              ElevatedButton(
                onPressed: () async {
                  await addTask();
                },
                child: const Text('Add Task'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> addTask() async {
    String title = _taskController.text.trim();
    if (title.isEmpty || title.length < 3) {
      setState(() {
        emsg = 'Task title must be at least 3 characters long';
      });
      return;
    }
    setState(() => emsg = '');

    try {
      // Replace with actual user ID from auth service
      AuthService authService = AuthService();
      String? userId = authService.currentUser?.uid;
      await _databaseService.createTask(
        title,
        _descriptionController.text.trim(),
        userId!,
      );
      _taskController.clear();
      _descriptionController.clear();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar('Failed to add task: ${e.toString()}', Colors.red),
      );
    }
  }

  SnackBar _buildSnackBar(String message, Color backgroundColor) {
    return SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
    );
  }

  void logout() async {
    setState(() => _isLoading = true);

    try {
      await AuthService().signOut();

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar('Logout failed: ${e.toString()}', Colors.red),
      );
    }
  }
}
