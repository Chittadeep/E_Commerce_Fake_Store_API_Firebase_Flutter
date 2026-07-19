import 'package:e_commerce/provider/auth_provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/auth_widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthProvider>();

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: authService.loginFormKey,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const BrandLogoMark(),
                  const SizedBox(height: 24),
                  const _LoginHeader(),
                  const SizedBox(height: 28),
                  _LoginCard(authService: authService),
                  const SizedBox(height: 24),
                  AuthSwitchPrompt(
                    promptText: "Don't have an account? ",
                    actionText: 'Sign Up',
                    onTap: () => Navigator.pushNamed(context, '/signup'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Welcome Back" heading + subtitle. Static -> const.
class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Welcome Back',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        SizedBox(height: 8),
        Text(
          'Access your personalized Lumina experience\n'
              'and manage your premium commerce hub.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }
}

/// The white form card: email/password fields, sign-in button, and
/// social row. The only section that depends on AuthProvider state.
class _LoginCard extends StatelessWidget {
  const _LoginCard({required this.authService});

  final AuthProvider authService;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldLabel('EMAIL ADDRESS'),
          const SizedBox(height: 8),
          AuthTextField(
            controller: authService.loginEmailController,
            hintText: 'name@lumina.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FieldLabel('PASSWORD'),
              _ForgotPasswordLink(),
            ],
          ),
          const SizedBox(height: 8),
          AuthPasswordField(
            controller: authService.loginPasswordController,
            obscureText: authService.obscureLoginPassword,
            onToggleObscure: authService.toggleLoginPasswordVisibility,
            validator: _validatePassword,
          ),
          const SizedBox(height: 24),
          AuthPrimaryButton(
            label: 'Sign In',
            onPressed: () => authService.onTapLogin(context),
          ),
          const SizedBox(height: 20),
          const OrDivider(),
          const SizedBox(height: 20),
          SocialAuthRow(
            onGoogleTap: () => authService.onTapLoginWithGoogle(context),
            onAppleTap: () {
              // TODO: authService.onTapLoginWithApple(context)
            },
          ),
        ],
      ),
    );
  }

  static String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter email';
    if (!EmailValidator.validate(value)) return 'Please enter a valid email';
    return null;
  }

  static String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}

class _ForgotPasswordLink extends StatelessWidget {
  const _ForgotPasswordLink();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () {
        // TODO: hook up forgot-password flow
      },
      child: const Text(
        'Forgot Password?',
        style: TextStyle(color: kBrandBlue, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}