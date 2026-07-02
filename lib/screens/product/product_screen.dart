import 'package:flutter/material.dart';
import '../../models/price_info.dart';

/// The core value screen. Placeholder data illustrates the Confidence
/// Engine display contract from ARCHITECTURE.md §5 — every connector
/// shows source + verified time + confidence, and fails gracefully
/// when a connector has no data.
class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  static const _samplePrices = [
    PriceInfo(connectorId: 'a', source: 'Connector A', price: 4.98, availability: Availability.inStock, confidence: 99),
    PriceInfo(connectorId: 'b', source: 'Connector B', price: 5.29, availability: Availability.inStock, confidence: 82),
    PriceInfo(connectorId: 'c', source: 'Connector C'), // no price = fails gracefully
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product'),
        actions: [IconButton(icon: const Icon(Icons.favorite_outline), onPressed: () {})],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Icon(Icons.image_outlined, size: 56),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product name', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text('Brand · size', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Compare across stores', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          for (final p in _samplePrices) _PriceCard(price: p),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Add to list'),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final PriceInfo price;
  const _PriceCard({required this.price});

  @override
  Widget build(BuildContext context) {
    if (!price.isAvailable) {
      // Fail gracefully — never a blank field or crash (ARCHITECTURE.md §6b).
      return Card(
        child: ListTile(
          title: Text(price.source),
          subtitle: const Text('Price unavailable · No current data · Last checked today'),
        ),
      );
    }
    return Card(
      child: ListTile(
        title: Text(price.source),
        subtitle: Text(
          '${price.availability == Availability.inStock ? "In stock" : "Out of stock"} · Verified recently',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('\$${price.price!.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('${price.confidence}%', style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
