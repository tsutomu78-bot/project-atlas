/// A single entry in a user's shopping list.
/// No quantity, coupons, or cross-store totals in v1.0 (MVP-FREEZE-v1.0.md).
class ShoppingListItem {
  final String productId;
  final DateTime addedAt;

  const ShoppingListItem({required this.productId, required this.addedAt});
}
