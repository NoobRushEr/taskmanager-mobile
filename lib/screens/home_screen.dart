import 'package:flutter/material.dart';
import 'package:taskmanager_mobile/services/auth_service.dart';
import 'package:taskmanager_mobile/widgets/task_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String emsg = '';

  @override
  Widget build(BuildContext context) {
    return TaskWidget(onLogout: logout);
  }

  SnackBar _buildSnackBar(String message, Color backgroundColor) {
    return SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
    );
  }

  void logout() async {
    try {
      await AuthService().signOut();

      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar('Logout failed: ${e.toString()}', Colors.red),
      );
    }
  }


}
