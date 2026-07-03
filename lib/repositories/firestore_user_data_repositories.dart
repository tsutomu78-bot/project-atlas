import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/favorite.dart';
import '../models/shopping_list_item.dart';
import '../models/scan_history_entry.dart';
import '../models/result.dart';
import 'favorites_repository.dart';
import 'shopping_list_repository.dart';
import 'scan_history_repository.dart';

/// User-owned data nests under `users/{userId}/...` so Firestore security
/// rules can scope reads/writes with a single `request.auth.uid == userId`
/// check (see firestore.rules in the repo root).
Result<T> _mapError<T>(Object e) {
  if (e is FirebaseException && e.code == 'permission-denied') return const PermissionDenied();
  if (e is FirebaseException) return Failure(e.message ?? e.code);
  return const Offline();
}

class FirestoreFavoritesRepository implements FavoritesRepository {
  final FirebaseFirestore _db;
  FirestoreFavoritesRepository([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _db.collection('users').doc(userId).collection('favorites');

  @override
  Future<Result<List<Favorite>>> list(String userId) async {
    try {
      final snap = await _col(userId).get();
      return Success(snap.docs
          .map((d) => Favorite(
                productId: d.id,
                addedAt: (d.data()['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              ))
          .toList());
    } catch (e) {
      return _mapError(e);
    }
  }

  @override
  Future<Result<void>> add(String userId, String productId) async {
    try {
      await _col(userId).doc(productId).set({'addedAt': Timestamp.now()});
      return const Success(null);
    } catch (e) {
      return _mapError(e);
    }
  }

  @override
  Future<Result<void>> remove(String userId, String productId) async {
    try {
      await _col(userId).doc(productId).delete();
      return const Success(null);
    } catch (e) {
      return _mapError(e);
    }
  }
}

class FirestoreShoppingListRepository implements ShoppingListRepository {
  final FirebaseFirestore _db;
  FirestoreShoppingListRepository([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _db.collection('users').doc(userId).collection('shoppingList');

  @override
  Future<Result<List<ShoppingListItem>>> list(String userId) async {
    try {
      final snap = await _col(userId).get();
      return Success(snap.docs
          .map((d) => ShoppingListItem(
                productId: d.id,
                addedAt: (d.data()['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              ))
          .toList());
    } catch (e) {
      return _mapError(e);
    }
  }

  @override
  Future<Result<void>> add(String userId, String productId) async {
    try {
      await _col(userId).doc(productId).set({'addedAt': Timestamp.now()});
      return const Success(null);
    } catch (e) {
      return _mapError(e);
    }
  }

  @override
  Future<Result<void>> remove(String userId, String productId) async {
    try {
      await _col(userId).doc(productId).delete();
      return const Success(null);
    } catch (e) {
      return _mapError(e);
    }
  }
}

class FirestoreScanHistoryRepository implements ScanHistoryRepository {
  final FirebaseFirestore _db;
  FirestoreScanHistoryRepository([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _db.collection('users').doc(userId).collection('scanHistory');

  @override
  Future<Result<List<ScanHistoryEntry>>> list(String userId) async {
    try {
      final snap = await _col(userId).orderBy('scannedAt', descending: true).get();
      return Success(snap.docs
          .map((d) => ScanHistoryEntry(
                productId: d.data()['productId'] as String? ?? d.id,
                scannedAt: (d.data()['scannedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              ))
          .toList());
    } catch (e) {
      return _mapError(e);
    }
  }

  @override
  Future<Result<void>> record(String userId, String productId) async {
    try {
      await _col(userId).add({'productId': productId, 'scannedAt': Timestamp.now()});
      return const Success(null);
    } catch (e) {
      return _mapError(e);
    }
  }

  @override
  Future<Result<void>> delete(String userId, String productId) async {
    try {
      final snap = await _col(userId).where('productId', isEqualTo: productId).get();
      for (final d in snap.docs) {
        await d.reference.delete();
      }
      return const Success(null);
    } catch (e) {
      return _mapError(e);
    }
  }
}
