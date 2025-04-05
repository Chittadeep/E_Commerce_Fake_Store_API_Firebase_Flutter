import 'package:e_commerce/provider/auth_service_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = context.read<AuthService>();

    return Scaffold(
      body: Center(
        child: SignInButton(
          Buttons.Google,
          text: "Sign in with Google",
          onPressed: () => _authService.onTapLoginWithGoogle(context),
        ),
      ),
    );
  }
}
