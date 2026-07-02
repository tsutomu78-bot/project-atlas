import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories/product_repository.dart';
import 'repositories/price_repository.dart';
import 'repositories/mock_repositories.dart';

/// Dependency wiring lives here, nowhere else. Screens read these providers
/// and stay ignorant of which implementation is behind them — swapping the
/// mocks for Firestore/connector-backed repositories (ATLAS-009+) is a
/// one-line change per provider.
final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => MockProductRepository(),
);

final priceRepositoryProvider = Provider<PriceRepository>(
  (ref) => MockPriceRepository(),
);
