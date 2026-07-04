import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers.dart';
import '../../routing/app_router.dart';

/// MVP scope only: Account / Retailer connections / Privacy-About / version.
/// No themes, AI preferences, pantry settings, or experimental features
/// (see MVP-FREEZE-v1.0.md).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final accountLabel = user == null
        ? 'Not signed in'
        : user.isAnonymous
            ? 'Signed in as guest'
            : 'Signed in${user.displayName != null ? ' as ${user.displayName}' : ''}';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('Account'),
          ListTile(title: Text(accountLabel)),
          if (user != null)
            ListTile(
              title: const Text('Sign out'),
              leading: const Icon(Icons.logout),
              onTap: () async {
                await ref.read(authRepositoryProvider).signOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
                }
              },
            ),
          const _SectionHeader('Retailer connections'),
          const ListTile(title: Text('3 connectors active'), trailing: Icon(Icons.chevron_right)),
          const _SectionHeader('Privacy / About'),
          const ListTile(title: Text('Privacy policy'), trailing: Icon(Icons.chevron_right)),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('App version 0.1.0', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title, style: const TextStyle(fontSize: 11)),
    );
  }
}
