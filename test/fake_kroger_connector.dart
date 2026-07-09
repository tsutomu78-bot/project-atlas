import 'package:project_atlas/connectors/kroger_connector.dart';
import 'package:project_atlas/models/result.dart';

/// Records refreshPrice calls without ever touching FirebaseFunctions —
/// widget tests have no Firebase app registered.
class FakeKrogerConnector extends KrogerConnector {
  final List<({String productId, String upc, String? locationId})> calls = [];

  FakeKrogerConnector() : super(defaultLocationId: '70100023');

  @override
  Future<Result<void>> refreshPrice({
    required String productId,
    required String upc,
    String? locationId,
  }) async {
    calls.add((productId: productId, upc: upc, locationId: locationId));
    return const Success(null);
  }
}
