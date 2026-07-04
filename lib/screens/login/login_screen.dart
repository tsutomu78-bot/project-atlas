import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/result.dart';
import '../../providers.dart';
import '../../repositories/auth_repository.dart';
import '../../routing/app_router.dart';

/// Minimal MVP login — no profile customization or onboarding flow.
/// "Continue without an account" = Firebase anonymous auth, so every user
/// has a uid and firestore.rules' request.auth check passes either way.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _busy = false;

  Future<void> _signIn(Future<Result<AppUser>> Function(AuthRepository) method) async {
    setState(() => _busy = true);
    final result = await method(ref.read(authRepositoryProvider));
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Success():
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      case Offline():
        _showError('You appear to be offline. Check your connection and try again.');
      case Failure(message: final m):
        _showError(m);
      default:
        _showError('Sign-in failed. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

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
                onPressed: _busy ? null : () => _signIn((auth) => auth.signInWithGoogle()),
                icon: const Icon(Icons.g_mobiledata),
                label: const Text('Continue with Google'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                // Apple sign-in needs an Apple developer account + provider
                // setup — honest "not yet" beats a button that fakes it.
                onPressed: _busy
                    ? null
                    : () => _showError('Apple sign-in is not available yet.'),
                icon: const Icon(Icons.apple),
                label: const Text('Continue with Apple'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _busy ? null : () => _signIn((auth) => auth.signInAnonymously()),
                child: const Text('Continue without an account'),
              ),
              const SizedBox(height: 16),
              if (_busy) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
