import 'package:project_atlas/models/favorite.dart';
import 'package:project_atlas/models/result.dart';
import 'package:project_atlas/models/scan_history_entry.dart';
import 'package:project_atlas/models/shopping_list_item.dart';
import 'package:project_atlas/repositories/favorites_repository.dart';
import 'package:project_atlas/repositories/scan_history_repository.dart';
import 'package:project_atlas/repositories/shopping_list_repository.dart';

/// In-memory user-data repositories so widget tests never touch Firestore.
/// Set [failWith] (e.g. `const Offline<Never>()`) to make every call return
/// that Result instead — `Result<Never>` is assignable to any `Result<T>`.

class FakeFavoritesRepository implements FavoritesRepository {
  final List<Favorite> items;
  Result<Never>? failWith;
  FakeFavoritesRepository([List<Favorite>? items]) : items = items ?? [];

  @override
  Future<Result<List<Favorite>>> list(String userId) async =>
      failWith ?? Success(List.of(items));

  @override
  Future<Result<void>> add(String userId, String productId) async {
    if (failWith != null) return failWith!;
    items.add(Favorite(productId: productId, addedAt: DateTime.now()));
    return const Success(null);
  }

  @override
  Future<Result<void>> remove(String userId, String productId) async {
    if (failWith != null) return failWith!;
    items.removeWhere((f) => f.productId == productId);
    return const Success(null);
  }
}

class FakeShoppingListRepository implements ShoppingListRepository {
  final List<ShoppingListItem> items;
  Result<Never>? failWith;
  FakeShoppingListRepository([List<ShoppingListItem>? items]) : items = items ?? [];

  @override
  Future<Result<List<ShoppingListItem>>> list(String userId) async =>
      failWith ?? Success(List.of(items));

  @override
  Future<Result<void>> add(String userId, String productId) async {
    if (failWith != null) return failWith!;
    items.add(ShoppingListItem(productId: productId, addedAt: DateTime.now()));
    return const Success(null);
  }

  @override
  Future<Result<void>> remove(String userId, String productId) async {
    if (failWith != null) return failWith!;
    items.removeWhere((i) => i.productId == productId);
    return const Success(null);
  }
}

class FakeScanHistoryRepository implements ScanHistoryRepository {
  final List<ScanHistoryEntry> entries;
  Result<Never>? failWith;
  FakeScanHistoryRepository([List<ScanHistoryEntry>? entries]) : entries = entries ?? [];

  @override
  Future<Result<List<ScanHistoryEntry>>> list(String userId) async =>
      failWith ?? Success(List.of(entries));

  @override
  Future<Result<void>> record(String userId, String productId) async {
    if (failWith != null) return failWith!;
    entries.add(ScanHistoryEntry(productId: productId, scannedAt: DateTime.now()));
    return const Success(null);
  }

  @override
  Future<Result<void>> delete(String userId, String productId) async {
    if (failWith != null) return failWith!;
    entries.removeWhere((e) => e.productId == productId);
    return const Success(null);
  }
}
