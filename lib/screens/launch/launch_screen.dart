import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../routing/app_router.dart';

/// No user decisions here — auto-routes to Home (already signed in,
/// including a restored anonymous session) or Login.
class LaunchScreen extends ConsumerStatefulWidget {
  const LaunchScreen({super.key});

  @override
  ConsumerState<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends ConsumerState<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), _route);
  }

  Future<void> _route() async {
    if (!mounted) return;
    // First stream event = Firebase has finished restoring any persisted
    // session, so this never misroutes a returning user to Login.
    final user = await ref.read(authRepositoryProvider).authStateChanges().first;
    if (!mounted) return;
    Navigator.of(context)
        .pushReplacementNamed(user != null ? AppRoutes.home : AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 56),
            SizedBox(height: 12),
            Text('Project Atlas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            SizedBox(height: 4),
            Text('Never guess. Always explain.', style: TextStyle(fontSize: 12)),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
