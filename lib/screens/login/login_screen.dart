import 'package:flutter/material.dart';
import '../../routing/app_router.dart';

/// Minimal MVP login — no profile customization or onboarding flow.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_scanner, size: 44),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.home),
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Continue with Google'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.home),
                icon: const Icon(Icons.apple),
                label: const Text('Continue with Apple'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.home),
                child: const Text('Continue without an account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
