/// Known Kroger certification-environment stores (the Seattle-area data set
/// that cert env actually serves — see ATLAS-007 notes in the vault).
class KrogerStore {
  final String locationId;
  final String label;
  const KrogerStore({required this.locationId, required this.label});
}

const krogerStores = [
  KrogerStore(locationId: '70100023', label: 'Fred Meyer — Bellevue'),
  KrogerStore(locationId: '70500820', label: 'QFC — Redmond'),
  KrogerStore(locationId: '70500860', label: 'QFC — Redmond Ridge'),
];
