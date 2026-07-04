import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'providers.dart';
import 'theme/app_theme.dart';
import 'routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Web-only config for now (Chrome-first development). Mobile platforms
  // get their own FirebaseOptions when those builds are set up.
  if (kIsWeb) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  }
  runApp(const ProviderScope(child: ProjectAtlasApp()));
}

class ProjectAtlasApp extends ConsumerWidget {
  const ProjectAtlasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep the auth stream alive for the app's whole lifetime. Providers are
    // lazy — without this, a screen reached directly (deep link/refresh)
    // could read currentUserIdProvider before the stream ever started and
    // silently see null instead of the signed-in user.
    ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Project Atlas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      initialRoute: AppRoutes.launch,
      routes: AppRoutes.routes,
    );
  }
}
