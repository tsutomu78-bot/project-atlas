import 'package:project_atlas/models/price_info.dart';
import 'package:project_atlas/models/result.dart';
import 'package:project_atlas/repositories/price_repository.dart';

/// In-memory PriceRepository so widget tests never touch Firestore.
class FakePriceRepository implements PriceRepository {
  final List<Result<PriceInfo>> results;
  int callCount = 0;
  FakePriceRepository([List<Result<PriceInfo>>? results]) : results = results ?? const [];

  @override
  Future<List<Result<PriceInfo>>> pricesForUpc(String upc) async {
    callCount++;
    return results;
  }
}
