import 'package:flutter/material.dart';
import '../../routing/app_router.dart';

/// No user decisions here — auto-routes to Home or Login.
/// MVP placeholder: routes straight to Home (auth not implemented yet).
class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    });
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
