import 'package:flutter/material.dart';
import '../models/product.dart';

/// Shared card used by Shopping List, History, and Favorites.
/// See WIREFRAME-SPEC.md in the vault: one component, reused per screen,
/// only the secondary line and trailing action vary.
class ProductCard extends StatelessWidget {
  final Product product;
  final String bestPriceLabel; // e.g. "$4.98 · Connector A"
  final int? confidence;
  final String secondaryLine; // varies: availability/date/verified-time
  final Widget trailing; // varies: remove / favorite+delete / heart
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.bestPriceLabel,
    required this.secondaryLine,
    required this.trailing,
    required this.onTap,
    this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: SizedBox(
          width: 40,
          height: 40,
          child: product.imageUrl == null
              ? const Icon(Icons.image_outlined)
              : Image.network(product.imageUrl!, fit: BoxFit.cover),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(bestPriceLabel, style: const TextStyle(fontSize: 12))),
                if (confidence != null)
                  Text('$confidence%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
            Text(secondaryLine, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline)),
          ],
        ),
        trailing: trailing,
      ),
    );
  }
}
