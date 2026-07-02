import '../models/product.dart';
import '../models/price_info.dart';
import '../models/result.dart';
import 'product_repository.dart';
import 'price_repository.dart';

/// Temporary in-memory implementations so the UI is built against the real
/// repository interfaces from day one. Replaced by Firestore/connector-backed
/// implementations in ATLAS-009+ without touching any screen code.
class MockProductRepository implements ProductRepository {
  @override
  Future<Result<Product>> findByUpc(String upc) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const Success(Product(
      upc: '000000000000',
      name: 'Sample product',
      brand: 'Sample brand',
      size: '12 oz',
    ));
  }
}

class MockPriceRepository implements PriceRepository {
  @override
  Future<List<Result<PriceInfo>>> pricesForUpc(String upc) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      Success(PriceInfo(
        connectorId: 'connector_a',
        source: 'Connector A',
        price: 4.98,
        availability: Availability.inStock,
        verifiedAt: DateTime.now().subtract(const Duration(minutes: 3)),
        confidence: 99,
      )),
      Success(PriceInfo(
        connectorId: 'connector_b',
        source: 'Connector B',
        price: 5.29,
        availability: Availability.inStock,
        verifiedAt: DateTime.now().subtract(const Duration(days: 1)),
        confidence: 82,
      )),
      const ConnectorUnavailable('connector_c'),
    ];
  }
}
