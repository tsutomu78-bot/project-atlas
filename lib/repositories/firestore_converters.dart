import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/price_info.dart';

/// Firestore <-> domain model mapping, isolated here so no other file
/// needs to know Firestore's document shape. Field names on disk use
/// `barcode` for clarity in the database; the Dart model keeps `upc`
/// since that's the name already used throughout the app and tests.
Product productFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data()!;
  return Product(
    upc: (data['barcode'] as String?) ?? doc.id,
    name: data['name'] as String? ?? '',
    brand: data['brand'] as String? ?? '',
    size: data['size'] as String?,
    category: data['category'] as String?,
    imageUrl: data['imageUrl'] as String?,
  );
}

Map<String, dynamic> productToMap(Product p) => {
      'barcode': p.upc,
      'name': p.name,
      'brand': p.brand,
      if (p.size != null) 'size': p.size,
      if (p.category != null) 'category': p.category,
      if (p.imageUrl != null) 'imageUrl': p.imageUrl,
    };

Availability _availabilityFromString(String? s) => switch (s) {
      'in_stock' => Availability.inStock,
      'out_of_stock' => Availability.outOfStock,
      _ => Availability.unknown,
    };

String _availabilityToString(Availability a) => switch (a) {
      Availability.inStock => 'in_stock',
      Availability.outOfStock => 'out_of_stock',
      Availability.unknown => 'unknown',
    };

PriceInfo priceFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data()!;
  final ts = data['verifiedAt'];
  return PriceInfo(
    connectorId: doc.id,
    source: data['source'] as String? ?? doc.id,
    price: (data['price'] as num?)?.toDouble(),
    availability: _availabilityFromString(data['availability'] as String?),
    verifiedAt: ts is Timestamp ? ts.toDate() : null,
    confidence: data['confidence'] as int?,
    submittedBy: data['submittedBy'] as String?, // always null in v1.0 — see MVP-FREEZE-v1.0.md
  );
}

Map<String, dynamic> priceToMap(PriceInfo p) => {
      'source': p.source,
      if (p.price != null) 'price': p.price,
      'availability': _availabilityToString(p.availability),
      if (p.verifiedAt != null) 'verifiedAt': Timestamp.fromDate(p.verifiedAt!),
      if (p.confidence != null) 'confidence': p.confidence,
      if (p.submittedBy != null) 'submittedBy': p.submittedBy,
    };
