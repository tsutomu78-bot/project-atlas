import '../models/favorite.dart';
import '../models/result.dart';

abstract interface class FavoritesRepository {
  Future<Result<List<Favorite>>> list(String userId);
  Future<Result<void>> add(String userId, String productId);
  Future<Result<void>> remove(String userId, String productId);
}
