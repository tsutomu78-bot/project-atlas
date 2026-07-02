import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/models/price_info.dart';
import 'package:project_atlas/models/product.dart';
import 'package:project_atlas/models/result.dart';
import 'package:project_atlas/repositories/mock_repositories.dart';

void main() {
  group('Product', () {
    test('holds retailer-independent identification', () {
      const p = Product(upc: '012345678905', name: 'Milk', brand: 'BrandX', size: '1 gal');
      expect(p.upc, '012345678905');
      expect(p.name, 'Milk');
      expect(p.imageUrl, isNull);
    });
  });

  group('PriceInfo', () {
    test('isAvailable is false when price is missing', () {
      const p = PriceInfo(connectorId: 'x', source: 'X');
      expect(p.isAvailable, isFalse);
      expect(p.availability, Availability.unknown);
      expect(p.submittedBy, isNull); // community submissions disabled in v1.0
    });

    test('isAvailable is true when price exists', () {
      const p = PriceInfo(connectorId: 'x', source: 'X', price: 1.99, confidence: 90);
      expect(p.isAvailable, isTrue);
    });
  });

  group('Result', () {
    test('cases are distinguishable via pattern matching', () {
      const Result<int> ok = Success(42);
      const Result<int> missing = NotFound();
      const Result<int> down = ConnectorUnavailable('kroger');

      expect(switch (ok) { Success(value: final v) => v, _ => -1 }, 42);
      expect(missing, isA<NotFound<int>>());
      expect(switch (down) { ConnectorUnavailable(connectorId: final id) => id, _ => '' }, 'kroger');
    });
  });

  group('MockPriceRepository', () {
    test('returns one result per connector including a graceful failure', () async {
      final results = await MockPriceRepository().pricesForUpc('any');
      expect(results, hasLength(3));
      expect(results.whereType<Success<PriceInfo>>(), hasLength(2));
      expect(results.whereType<ConnectorUnavailable<PriceInfo>>(), hasLength(1));
    });
  });
}
