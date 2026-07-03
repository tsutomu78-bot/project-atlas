import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories/product_repository.dart';
import 'repositories/price_repository.dart';
import 'repositories/favorites_repository.dart';
import 'repositories/shopping_list_repository.dart';
import 'repositories/scan_history_repository.dart';
import 'repositories/mock_repositories.dart';
import 'repositories/firestore_user_data_repositories.dart';

/// Dependency wiring lives here, nowhere else. Screens read these providers
/// and stay ignorant of which implementation is behind them.
///
/// Product/price providers still point at mocks. Firestore-backed
/// implementations already exist — `FirestoreProductRepository` in
/// firestore_product_repository.dart and `FirestorePriceRepository` in
/// firestore_price_repository.dart — but firestore.rules requires
/// request.auth != null, and this app has no authentication wired up yet
/// (Login screen is a placeholder). Import those two classes and swap the
/// bodies below once auth exists; no screen changes needed.
final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => MockProductRepository(),
);

final priceRepositoryProvider = Provider<PriceRepository>(
  (ref) => MockPriceRepository(),
);

/// These are already Firestore-backed since they only make sense per-user
/// and there's no meaningful mock behavior to fall back to — they'll simply
/// return PermissionDenied results until auth is wired up, which is itself
/// a correct, honest Result per ARCHITECTURE.md's transparency model.
final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FirestoreFavoritesRepository(),
);

final shoppingListRepositoryProvider = Provider<ShoppingListRepository>(
  (ref) => FirestoreShoppingListRepository(),
);

final scanHistoryRepositoryProvider = Provider<ScanHistoryRepository>(
  (ref) => FirestoreScanHistoryRepository(),
);
