import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe/game.dart';
import 'package:tic_tac_toe/helpers.dart';
import 'package:tic_tac_toe/login.dart';

Future main() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCaxKmGrR2YnmAZJCl0YlSGS2lhXwmrZjo",
            appId: "1:779401833333:web:0073b9eded06559bb5413c",
            messagingSenderId: "779401833333",
            projectId: "tic-tac-toe-1efda"));
  } else {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isSignedIn = false;
  @override
  void initState() {
    super.initState();
    getUserLoggedInStatus;
  }

  getUserLoggedInStatus() async {
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          isSignedIn = value;
        });
      }
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: isSignedIn ? const GamePage() : const LoginPage());
  }
}
