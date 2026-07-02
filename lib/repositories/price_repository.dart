import '../models/price_info.dart';
import '../models/result.dart';

/// Aggregates prices across all retail connectors for a product.
/// A connector with no data yields ConnectorUnavailable in its slot rather
/// than dropping silently — the UI shows "Price unavailable" per screen spec.
abstract interface class PriceRepository {
  /// One Result per active connector, in a stable display order.
  Future<List<Result<PriceInfo>>> pricesForUpc(String upc);
}
