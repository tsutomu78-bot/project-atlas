import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

/// Fred Meyer Bellevue (cert env) — the default until the user picks a store
/// in Settings.
const defaultKrogerLocationId = '70100023';

/// The user's chosen Kroger store, persisted locally (localStorage on web).
/// Falls back to the in-memory default when preferences are unavailable
/// (tests, private browsing) — a lost preference is honest degradation,
/// never an error surfaced to the UI.
class KrogerLocationController extends StateNotifier<String> {
  static const _prefsKey = 'krogerLocationId';

  KrogerLocationController() : super(defaultKrogerLocationId) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved != null && mounted) state = saved;
    } catch (e) {
      // Prefs can be unavailable (missing plugin registrant after a stale
      // build, private browsing). Degrade to the in-memory default, but log —
      // a silent persistence failure cost real debugging time on 2026-07-18.
      debugPrint('PREFS-DEBUG load failed: $e');
    }
  }

  Future<void> select(String locationId) async {
    state = locationId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, locationId);
    } catch (e) {
      // See _load — same degradation, same reason to stay loud in console.
      debugPrint('PREFS-DEBUG save failed: $e');
    }
  }
}

final krogerLocationIdProvider =
    StateNotifierProvider<KrogerLocationController, String>(
  (_) => KrogerLocationController(),
);

final krogerConnectorProvider = Provider(
  (ref) => KrogerConnector(
    defaultLocationId: ref.watch(krogerLocationIdProvider),
  ),
);

/// Whether the Scan screen builds the real camera scanner. Overridden to
/// false in widget tests — MobileScanner needs platform channels that don't
/// exist under flutter_test.
final scannerCameraEnabledProvider = Provider<bool>((_) => true);

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
