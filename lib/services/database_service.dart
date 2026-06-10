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
      'userId': userId,
    });
  }
}
