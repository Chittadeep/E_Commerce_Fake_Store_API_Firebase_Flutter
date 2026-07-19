import 'package:e_commerce/provider/auth_provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/auth_widgets.dart';

/// Top-level screen. Only responsibility: lay out the sections and
/// wire AuthProvider to the widgets that need it.
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthProvider>();

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Form(
              key: authService.signupFormKey,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const BrandLogoMark(),
                  const SizedBox(height: 12),
                  const _BrandWordmark(),
                  const SizedBox(height: 28),
                  _SignupCard(authService: authService),
                  const SizedBox(height: 24),
                  AuthSwitchPrompt(
                    promptText: 'Already have an account? ',
                    actionText: 'Sign In',
                    onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                  ),
                  const SizedBox(height: 20),
                  const _FooterLinks(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Lumina Commerce" wordmark under the logo. Static -> const.
class _BrandWordmark extends StatelessWidget {
  const _BrandWordmark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Lumina Commerce',
      style: TextStyle(color: kBrandBlue, fontWeight: FontWeight.bold, fontSize: 22),
    );
  }
}

/// The white form card: name/email/password fields, terms checkbox,
/// submit button, and social sign-up row. The only section that depends
/// on AuthProvider state.
class _SignupCard extends StatelessWidget {
  const _SignupCard({required this.authService});

  final AuthProvider authService;

  @override
  Widget build(BuildContext context) {
    return AuthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SignupHeader(),
          const SizedBox(height: 24),
          const FieldLabel('Full Name'),
          const SizedBox(height: 8),
          AuthTextField(
            controller: authService.signupNameController,
            hintText: 'John Doe',
            icon: Icons.person_outline,
            validator: _validateName,
          ),
          const SizedBox(height: 20),
          const FieldLabel('Email Address'),
          const SizedBox(height: 8),
          AuthTextField(
            controller: authService.signupEmailController,
            hintText: 'name@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
          ),
          const SizedBox(height: 20),
          const FieldLabel('Password'),
          const SizedBox(height: 8),
          AuthPasswordField(
            controller: authService.signupPasswordController,
            obscureText: authService.obscureSignupPassword,
            onToggleObscure: authService.toggleSignupPasswordVisibility,
            helperText: 'AT LEAST 8 CHARACTERS',
            validator: _validatePassword,
          ),
          const SizedBox(height: 16),
          _TermsCheckbox(
            value: authService.agreedToTerms,
            onChanged: authService.toggleAgreedToTerms,
          ),
          const SizedBox(height: 24),
          AuthPrimaryButton(
            label: 'Create Account',
            onPressed: () => authService.onTapCreateAccount(context),
          ),
          const SizedBox(height: 20),
          const OrDivider(),
          const SizedBox(height: 20),
          _SocialSignupRow(
            onGoogleTap: () => authService.onTapLoginWithGoogle(context),
            onAppleTap: () {
              // TODO: authService.onTapSignupWithApple(context)
            },
          ),
        ],
      ),
    );
  }

  static String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your name';
    return null;
  }

  static String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter email';
    if (!EmailValidator.validate(value)) return 'Please enter a valid email';
    return null;
  }

  static String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }
}

/// "Create Account" heading + subtitle. Static -> const.
class _SignupHeader extends StatelessWidget {
  const _SignupHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Create Account',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        SizedBox(height: 8),
        Text(
          'Join the community for exclusive commerce\nexperiences.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }
}

/// Checkbox + "I agree to the Terms & Conditions and Privacy Policy." row.
/// State (checked / not) is owned by AuthProvider, not this widget.
class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.black87, fontSize: 14, height: 1.3),
                children: [
                  TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(color: kBrandBlue, fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(color: kBrandBlue, fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialSignupRow extends StatelessWidget {
  const _SocialSignupRow({required this.onGoogleTap, required this.onAppleTap});

  final VoidCallback onGoogleTap;
  final VoidCallback onAppleTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SocialButton(
            label: 'Google',
            icon: Image.asset(
              'assets/icons/google.png',
              height: 20,
              width: 20,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.g_mobiledata, size: 22),
            ),
            onPressed: onGoogleTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SocialButton(
            label: 'Apple',
            icon: const Icon(Icons.apple, size: 20),
            onPressed: onAppleTap,
          ),
        ),
      ],
    );
  }
}

/// "Help · Privacy · Security" footer. Static -> const.
class _FooterLinks extends StatelessWidget {
  const _FooterLinks();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(color: Colors.black54, fontSize: 13);
    const dot = Text(' \u2022 ', style: TextStyle(color: Colors.black38));

    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Help', style: style),
        dot,
        Text('Privacy', style: style),
        dot,
        Text('Security', style: style),
      ],
    );
  }
}