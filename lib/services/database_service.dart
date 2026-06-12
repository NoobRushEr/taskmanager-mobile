import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskmanager_mobile/models/task_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get tasks for a specific user
  Stream<List<TaskModel>> getTasks(String userId) {
    return _db
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Create a new task
  Future<void> createTask(
    String title,
    String description,
    String userId,
  ) async {
    await _db.collection('tasks').add({
      'title': title,
      'description': description,
      'isCompleted': false,
      'created_at': FieldValue.serverTimestamp(),
      'userId': userId,
    });
  }

  // Update an existing task
  Future<void> updateTask(
    String taskId,
    String title,
    String description,
    bool isCompleted,
  ) async {
    await _db.collection('tasks').doc(taskId).update({
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    });
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await _db.collection('tasks').doc(taskId).delete();
  }
}
