import 'dart:developer';

import 'package:e_commerce/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<User?> _signInWithGoogle() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    User? user = await _authService.signInWithGoogle();
    if (user != null) {
      _prefs.setString('uid', user.uid);
    }
  }

  Future<void> signOut() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString('uid', '');

    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  bool isUserSignedIn() {
    if (_auth.currentUser != null) {
      return true;
    }
    return false;
  }

  Future<void> onTapLoginWithGoogle(BuildContext context) async {
    User? user = await _signInWithGoogle();
    if (user != null) {
      log("Signed in as: ${user.displayName}");
      Navigator.pushNamed(context, '/home');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome, ${user.displayName}!')),
      );
    } else {
      log("Sign-In canceled or failed");
    }
  }

  Future<void> onTapLogin(BuildContext context) async {
    formKey.currentState!.validate();
  }
}
