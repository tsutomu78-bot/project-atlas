/// Product identification data — retailer-independent.
/// See ARCHITECTURE.md §2b in the Obsidian vault: Product Identification
/// must not depend on any retailer connector.
class Product {
  final String upc;
  final String name;
  final String brand;
  final String? size;
  final String? category;
  final String? imageUrl;

  const Product({
    required this.upc,
    required this.name,
    required this.brand,
    this.size,
    this.category,
    this.imageUrl,
  });
}
