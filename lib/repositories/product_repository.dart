import '../models/product.dart';
import '../models/result.dart';

/// UI/state layers depend on this interface, never on a concrete backend.
/// Implementations: local cache first, then cloud (ARCHITECTURE.md §6a),
/// but callers must not know or care which one answered.
abstract interface class ProductRepository {
  /// Identify a product by barcode — retailer-independent (ARCHITECTURE.md §2b).
  Future<Result<Product>> findByUpc(String upc);
}
