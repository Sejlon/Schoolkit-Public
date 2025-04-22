import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  @override
  void initState() {
    super.initState();
    initializeApp(); // Start Firebase initialization
  }

  Future<void> initializeApp() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    checkCurrentUser(); // After initialization, check user auth
  }

  void checkCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacementNamed(context, "/home"); // Replace Loading with Home
    } else {
      Navigator.pushReplacementNamed(context, "/login"); // Replace Loading with Login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent[100],
      body: Center(
        child: SpinKitThreeBounce(
          color: Colors.white,
          size: 100.0,
        ),
      ),
    );
  }
}