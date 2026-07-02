import 'package:flutter/material.dart';
import '../../widgets/bottom_nav.dart';

/// v1.0: no quantity, coupons, budget tracking, route optimization,
/// auto-retailer-switching, or multi-store checkout (see MVP-FREEZE-v1.0.md).
class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping list')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.list_alt_outlined, size: 28),
              SizedBox(height: 8),
              Text('Scan products to build your shopping list.'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}
