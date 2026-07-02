import 'package:flutter/material.dart';
import '../../routing/app_router.dart';
import '../../widgets/bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Atlas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: InkWell(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.scan),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: const [
                    Icon(Icons.document_scanner_outlined, size: 40),
                    SizedBox(height: 8),
                    Text('Scan a product', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text('Compare price and availability', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Recent scans', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          // Empty state placeholder for a first-time user (see WIREFRAME-SPEC.md)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.barcode_reader, size: 28),
                  SizedBox(height: 8),
                  Text('Scan your first product', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text('Your recent scans will show up here.', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}
