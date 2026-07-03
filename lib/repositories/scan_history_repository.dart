import '../models/scan_history_entry.dart';
import '../models/result.dart';

abstract interface class ScanHistoryRepository {
  Future<Result<List<ScanHistoryEntry>>> list(String userId);
  Future<Result<void>> record(String userId, String productId);
  Future<Result<void>> delete(String userId, String productId);
}
