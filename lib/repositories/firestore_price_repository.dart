import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/price_info.dart';
import '../models/result.dart';
import 'price_repository.dart';
import 'firestore_converters.dart';

/// Firestore-backed PriceRepository. Prices live as a subcollection under
/// their product (`products/{id}/prices/{connectorId}`) per ARCHITECTURE.md
/// §3 — one document per retail connector, in the normalized PriceInfo shape.
/// A connector with no document yields ConnectorUnavailable, not an error.
class FirestorePriceRepository implements PriceRepository {
  final FirebaseFirestore _db;
  static const _knownConnectors = ['kroger', 'target', 'walmart'];

  FirestorePriceRepository([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<List<Result<PriceInfo>>> pricesForUpc(String upc) async {
    try {
      final productQuery =
          await _db.collection('products').where('barcode', isEqualTo: upc).limit(1).get();
      if (productQuery.docs.isEmpty) return const [NotFound()];

      final pricesSnapshot = await productQuery.docs.first.reference.collection('prices').get();
      final byConnector = {for (final d in pricesSnapshot.docs) d.id: d};

      return _knownConnectors.map((connectorId) {
        final doc = byConnector[connectorId];
        if (doc == null) return ConnectorUnavailable<PriceInfo>(connectorId);
        return Success(priceFromDoc(doc));
      }).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') return const [PermissionDenied()];
      return [Failure(e.message ?? e.code)];
    } catch (_) {
      return const [Offline()];
    }
  }
}
