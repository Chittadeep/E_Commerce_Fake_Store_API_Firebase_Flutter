import 'dart:developer';

import 'package:e_commerce/provider/auth_service_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SignInButton(
          Buttons.Google,
          text: "Sign in with Google",
          onPressed: () async {
            User? user = await _authService.signInWithGoogle();
            if (user != null) {
              log("Signed in as: ${user.displayName}");
              Navigator.pushNamed(context, '/home');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Welcome, ${user.displayName}!')),
              );
            } else {
              log("Sign-In canceled or failed");
            }
          },
        ),
      ),
    );
  }
}
