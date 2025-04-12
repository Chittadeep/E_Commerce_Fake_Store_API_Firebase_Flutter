import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_commerce/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final AuthService _authService = AuthService();

  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  final TextEditingController signupNameController = TextEditingController();
  final TextEditingController signupEmailController = TextEditingController();
  final TextEditingController signupPasswordController =
      TextEditingController();

  Future<User?> _signInWithGoogle() async {
    User? user = await _authService.signInWithGoogle();
    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('uid', user.uid);

      final DocumentReference userRef =
          _firestore.collection('users').doc(user.uid);

      final doc = await userRef.get();

      if (!doc.exists) {
        await userRef.set({
          'uid': user.uid,
          'name': user.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        });
        log("User document created");
      } else {
        log("User document already exists");
      }
      return user;
    }
    return null;
  }

  Future<void> signOut(BuildContext context) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    await _prefs.setString('uid', '');

    await GoogleSignIn().signOut();
    await _auth.signOut();

    Navigator.pushReplacementNamed(context, '/login');
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

  Future<User?> onTapLogin(BuildContext context) async {
    loginFormKey.currentState!.validate();

    User? user = await _authService.signInWithEmail(
        loginEmailController.text, loginPasswordController.text);
    if (user != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('uid', user.uid);
      Navigator.pushReplacementNamed(context, '/home');
      return user;
    }
    return null;
  }

  Future<void> onTapCreateAccount(BuildContext context) async {
    signupFormKey.currentState!.validate();

    User? user = await _authService.signUpWithEmail(signupEmailController.text,
        signupPasswordController.text, signupNameController.text);

    if (user != null) {
      Navigator.pop(context);
    }
  }
}
