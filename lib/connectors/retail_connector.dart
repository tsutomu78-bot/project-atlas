import '../models/price_info.dart';
import '../models/result.dart';

/// A store is a swappable part (ARCHITECTURE.md §2b). Every retailer —
/// Kroger, Target, Walmart, and any future addition — implements this and
/// returns the same normalized PriceInfo shape. Adding a store must never
/// require touching UI or repository code.
abstract interface class RetailConnector {
  String get connectorId;
  String get displayName;

  Future<Result<PriceInfo>> priceForUpc(String upc);
}
