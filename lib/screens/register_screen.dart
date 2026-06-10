import 'package:flutter/material.dart';
import 'package:taskmanager_mobile/screens/login_screen.dart';
import 'package:taskmanager_mobile/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    double widthScreen = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, BoxConstraints constraints) {
                return FractionallySizedBox(
                  widthFactor: widthScreen > 500 ? 0.5 : 1,
                  child: Column(
                    children: [
                      Text(
                        'Register Screen',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20.0),

                      // TextField(
                      //   controller: usernameController,
                      //   decoration: InputDecoration(
                      //     hintText: 'Username',
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(8.0),
                      //     ),
                      //   ),
                      //   onEditingComplete: () => setState(() {}),
                      // ),

                      // SizedBox(height: 10.0),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onEditingComplete: () => setState(() {}),
                      ),

                      SizedBox(height: 10.0),

                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        obscureText: true,
                        onEditingComplete: () => setState(() {}),
                      ),

                      SizedBox(height: 10.0),

                      TextField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        obscureText: true,
                        onEditingComplete: () => setState(() {}),
                      ),

                      SizedBox(height: 20.0),

                      ElevatedButton(
                        onPressed: _isLoading ? null : userRegister,
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                            : Text('Register'),
                      ),

                      SizedBox(height: 10.0),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text('Already have an account? Sign In'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  bool validateEmail(String email) {
    String pattern =
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  bool checkPassword(String password, String confirmPassword) {
    if (password != confirmPassword) {
      return false;
    }
    return true;
  }

  bool validatePassword(String password) {
    if (password.length < 6 ||
        password.length > 20 ||
        !RegExp(r'[A-Z]').hasMatch(password) ||
        !RegExp(r'[a-z]').hasMatch(password) ||
        !RegExp(r'[0-9]').hasMatch(password) ||
        !RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return false;
    }
    return true;
  }

  void userRegister() async {
    setState(() => _isLoading = true);

    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(_buildSnackBar('Please fill all the fields', Colors.red));
      return;
    }
    if (!validateEmail(emailController.text.trim())) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar('Please enter a valid email address', Colors.red),
      );
      return;
    }
    if (!checkPassword(
      passwordController.text.trim(),
      confirmPasswordController.text.trim(),
    )) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(_buildSnackBar('Passwords do not match', Colors.red));
      return;
    }
    if (!validatePassword(passwordController.text.trim())) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar(
          'Password must be between 6 and 20 characters and include uppercase, lowercase, number, and special character',
          Colors.red,
        ),
      );
      return;
    }

    try {
      AuthService authService = AuthService();
      await authService.signUp(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        _buildSnackBar('Registration failed: ${e.toString()}', Colors.red),
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
}
