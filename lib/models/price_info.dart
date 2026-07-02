enum Availability { inStock, outOfStock, unknown }

/// One retailer connector's price data for a product.
/// Matches the schema in ARCHITECTURE.md §3 — this is the normalized
/// shape every connector (Kroger, Target, Walmart, ...) must return.
/// `submittedBy` is future-proofing for community submissions (disabled
/// in MVP v1.0 — see MVP-FREEZE-v1.0.md) and is always null for now.
class PriceInfo {
  final String connectorId;
  final double? price;
  final Availability availability;
  final String source;
  final DateTime? verifiedAt;
  final int? confidence; // 0-100, null if unavailable
  final String? submittedBy;

  const PriceInfo({
    required this.connectorId,
    required this.source,
    this.price,
    this.availability = Availability.unknown,
    this.verifiedAt,
    this.confidence,
    this.submittedBy,
  });

  bool get isAvailable => price != null;
}
