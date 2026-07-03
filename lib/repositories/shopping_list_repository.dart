import '../models/shopping_list_item.dart';
import '../models/result.dart';

/// v1.0: no quantity, no cross-store totals (MVP-FREEZE-v1.0.md).
abstract interface class ShoppingListRepository {
  Future<Result<List<ShoppingListItem>>> list(String userId);
  Future<Result<void>> add(String userId, String productId);
  Future<Result<void>> remove(String userId, String productId);
}
