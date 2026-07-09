import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories/product_repository.dart';
import 'repositories/price_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/favorites_repository.dart';
import 'repositories/shopping_list_repository.dart';
import 'repositories/scan_history_repository.dart';
import 'repositories/firestore_product_repository.dart';
import 'repositories/firestore_price_repository.dart';
import 'repositories/firestore_user_data_repositories.dart';
import 'connectors/kroger_connector.dart';

/// Dependency wiring lives here, nowhere else. Screens read these providers
/// and stay ignorant of which implementation is behind them.

/// Fred Meyer Bellevue (cert env) — dev default until a Settings
/// store-location picker exists (later ticket).
const defaultKrogerLocationId = '70100023';

final krogerConnectorProvider = Provider(
  (ref) => KrogerConnector(defaultLocationId: defaultKrogerLocationId),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(),
);

/// Reactive auth state — Launch routes on it, Settings displays it.
final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// Convenience for repositories that key on userId; null while signed out.
final currentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(authStateProvider).value?.uid,
);

/// Firestore-backed as of ATLAS-010 — firestore.rules requires a signed-in
/// request, which the auth flow now guarantees before these are reached.
final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => FirestoreProductRepository(),
);

final priceRepositoryProvider = Provider<PriceRepository>(
  (ref) => FirestorePriceRepository(),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FirestoreFavoritesRepository(),
);

final shoppingListRepositoryProvider = Provider<ShoppingListRepository>(
  (ref) => FirestoreShoppingListRepository(),
);

final scanHistoryRepositoryProvider = Provider<ScanHistoryRepository>(
  (ref) => FirestoreScanHistoryRepository(),
);
