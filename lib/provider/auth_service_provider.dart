import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> _signInWithGoogle() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User canceled the login
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential using GoogleAuthProvider
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the new credential
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      _prefs.setString('uid', userCredential.user!.uid);

      return userCredential.user;
    } catch (e) {
      log('Error during Google Sign-In: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString('uid', '');

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
}
