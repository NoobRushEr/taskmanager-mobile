import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:taskmanager_mobile/firebase_options.dart';
import 'package:taskmanager_mobile/screens/home_screen.dart';
import 'package:taskmanager_mobile/screens/login_screen.dart';
import 'package:taskmanager_mobile/services/auth_service.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TaskManager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber[600]!,
          brightness: Brightness.dark, //Brightness.light,
        ),
      ),
      home: StreamBuilder(stream: AuthService().user, builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if(snapshot.hasData){
          return HomeScreen();
        }
        return LoginScreen();
      },),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return LoginScreen();
  }
}
