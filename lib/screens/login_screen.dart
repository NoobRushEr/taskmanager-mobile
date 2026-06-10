import 'package:flutter/material.dart';
import 'package:taskmanager_mobile/screens/register_screen.dart';
import 'package:taskmanager_mobile/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
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
                        'Login Screen',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20.0),

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

                      SizedBox(height: 20.0),

                      ElevatedButton(
                        onPressed: loginUser,
                        child: _isLoading
                            ? SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: CircularProgressIndicator(),
                              )
                            : Text('Login'),
                      ),

                      SizedBox(height: 10.0),

                      Row(
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text('Forgot Password?'),
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: Text('Don\'t have an account? Sign Up'),
                          ),
                        ],
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

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });

    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      AuthService authService = AuthService();
      await authService.signIn(email, password);

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      String errorMessage = '';
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if(e.toString().contains('user-not-found')){
        errorMessage = 'No user found for that email.';
      } else if(e.toString().contains('invalid-credential')){
        errorMessage = 'Invalid email and/or password provided for the user.';
      } else if(e.toString().contains('invalid-email')){
        errorMessage = 'The email address is not valid.';
      }
      else {
        errorMessage = 'Login failed: ${e.toString()}';
      }


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login Failed: $errorMessage"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
