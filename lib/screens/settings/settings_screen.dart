import 'package:flutter/material.dart';

/// MVP scope only: Account / Retailer connections / Privacy-About / version.
/// No themes, AI preferences, pantry settings, or experimental features
/// (see MVP-FREEZE-v1.0.md).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: const [
          _SectionHeader('Account'),
          ListTile(title: Text('Signed in'), trailing: Icon(Icons.chevron_right)),
          _SectionHeader('Retailer connections'),
          ListTile(title: Text('3 connectors active'), trailing: Icon(Icons.chevron_right)),
          _SectionHeader('Privacy / About'),
          ListTile(title: Text('Privacy policy'), trailing: Icon(Icons.chevron_right)),
          Padding(
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
