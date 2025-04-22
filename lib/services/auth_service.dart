import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/services/database.dart';

class AuthService {

  static Future<bool> register({required String email, required String password, required String firstName, required String lastName, required String role, String? className, required BuildContext context}) async {
    try {
      UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      User? user =  result.user;

      // Null safety check before accessing type User? (it can be null)
      if (user != null) {
        bool status = await DatabaseService(uid: user.uid).updateUserData(firstName, lastName, email, role, className);
        if (status) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Register successful!")));
          return true;
        }
      } else {
        // Handle case where user is unexpectedly null
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User couldn't be created")));
        return false;
      }

    } on FirebaseAuthException catch (e) {
      //String message = "";
      if (e.code == "weak-password") {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("The password provided is too weak")));
      }
      else if (e.code == "email-already-in-use") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An account already exists with that email")));
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("FirebaseAuthException was called")));
      }
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("General exception, check your internet connection")));
      print(e);
      return false;
    }
    return false;
  }

  static Future<bool> login({required String email, required String password,
    required BuildContext context}) async {
    try {
      UserCredential result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      //print(user);
      if (FirebaseAuth.instance.currentUser != null && user != null) {
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email") {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No user found for that email")));
      }
      else if (e.code == "invalid-credential") {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Wrong password provided for that user")));
      }
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("General exception, check your internet connection")));
      print(e);
      return false;
    }
  }

  static Future<void> logout({required BuildContext context}) async {
    try {
      print(FirebaseAuth.instance.currentUser);
      await FirebaseAuth.instance.signOut();
      print(FirebaseAuth.instance.currentUser);
      Navigator.pushReplacementNamed(context, "/login");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("General exception, check your internet connection")));
      print(e);
    }

  }

}
