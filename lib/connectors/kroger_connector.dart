import 'package:cloud_functions/cloud_functions.dart';
import 'retail_connector.dart';
import '../models/price_info.dart';
import '../models/result.dart' as result;

/// Kroger is called only through the `lookupKrogerPrice` Cloud Function
/// (functions/src/index.ts) — the Kroger Client ID/Secret live server-side
/// in Google Secret Manager and never reach this Flutter client. This class
/// triggers the lookup, then reads the normalized result back out of
/// Firestore (products/{id}/prices/kroger) via FirestorePriceRepository,
/// keeping one single source of truth for "what does the UI read."
class KrogerConnector implements RetailConnector {
  final FirebaseFunctions? _functionsOverride;
  final String _defaultLocationId;

  KrogerConnector({required String defaultLocationId, FirebaseFunctions? functions})
      : _defaultLocationId = defaultLocationId,
        _functionsOverride = functions;

  // Resolved lazily (not in the constructor) so a test subclass that
  // overrides refreshPrice entirely never triggers FirebaseFunctions.instance
  // — which throws if no Firebase app is registered, as in widget tests.
  FirebaseFunctions get _functions => _functionsOverride ?? FirebaseFunctions.instance;

  @override
  String get connectorId => 'kroger';

  @override
  String get displayName => 'Kroger';

  /// [productId] is the Firestore products/{id} this price attaches to.
  /// Triggering the lookup is a side effect (writes Firestore); the actual
  /// read-back for display goes through FirestorePriceRepository like any
  /// other connector — this method exists mainly to kick off a fresh lookup.
  Future<result.Result<void>> refreshPrice({
    required String productId,
    required String upc,
    String? locationId,
  }) async {
    try {
      await _functions.httpsCallable('lookupKrogerPrice').call({
        'productId': productId,
        'upc': upc,
        'locationId': locationId ?? _defaultLocationId,
      });
      return const result.Success(null);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'unavailable') return const result.Offline();
      return result.Failure(e.message ?? e.code);
    } catch (_) {
      return const result.Offline();
    }
  }

  @override
  Future<result.Result<PriceInfo>> priceForUpc(String upc) async {
    // Not used directly by the UI today — FirestorePriceRepository already
    // reads all connectors' prices in one call. Present to satisfy the
    // RetailConnector interface for future direct-connector use cases.
    throw UnimplementedError(
      'Read Kroger prices via FirestorePriceRepository; call refreshPrice() to trigger a fresh lookup.',
    );
  }
}
