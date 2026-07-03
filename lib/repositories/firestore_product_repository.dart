import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/result.dart';
import 'product_repository.dart';
import 'firestore_converters.dart';

/// Firestore-backed ProductRepository. Product identification lives in a
/// top-level `products` collection, independent of any retailer — see
/// ARCHITECTURE.md §2b.
class FirestoreProductRepository implements ProductRepository {
  final FirebaseFirestore _db;
  FirestoreProductRepository([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<Result<Product>> findByUpc(String upc) async {
    try {
      final query = await _db.collection('products').where('barcode', isEqualTo: upc).limit(1).get();
      if (query.docs.isEmpty) return const NotFound();
      return Success(productFromDoc(query.docs.first));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') return const PermissionDenied();
      return Failure(e.message ?? e.code);
    } catch (_) {
      return const Offline();
    }
  }
}
