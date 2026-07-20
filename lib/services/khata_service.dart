import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shop_pandaa/data/models.dart';

/// Device-local store for the shopkeeper's khata (running supplier credit).
/// Persisted in shared_preferences — a khata is private bookkeeping, so it
/// lives on the device rather than in Firestore. Singleton + ChangeNotifier
/// so any screen can `ListenableBuilder` on it.
class KhataService extends ChangeNotifier {
  KhataService._();
  static final KhataService instance = KhataService._();

  static const _prefsKey = 'thokbazaar_khata_v1';
  static const _seededKey = 'thokbazaar_khata_seeded_v1';

  List<KhataSupplier> _suppliers = const [];
  bool _loaded = false;

  List<KhataSupplier> get suppliers => _suppliers;
  bool get isLoaded => _loaded;

  /// Total outstanding udhaar across every supplier (Rs).
  int get totalOutstanding =>
      _suppliers.fold<int>(0, (sum, s) => sum + s.balance);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      _suppliers = _decode(raw);
    } else if (!(prefs.getBool(_seededKey) ?? false)) {
      _suppliers = _sampleSuppliers();
      await prefs.setBool(_seededKey, true);
      await _persist();
    }
    _loaded = true;
    notifyListeners();
  }

  KhataSupplier? supplierById(String id) {
    for (final s in _suppliers) {
      if (s.id == id) return s;
    }
    return null;
  }

  Future<void> addSupplier({
    required String name,
    required String market,
    String? phone,
  }) async {
    final supplier = KhataSupplier(
      id: _newId('sup'),
      name: name,
      market: market,
      phone: phone,
    );
    _suppliers = [..._suppliers, supplier];
    await _persist();
    notifyListeners();
  }

  Future<void> addEntry({
    required String supplierId,
    required int amount,
    required KhataEntryType type,
    required String note,
  }) async {
    final entry = KhataEntry(
      id: _newId('ent'),
      note: note,
      amount: amount.abs(),
      type: type,
      date: DateTime.now(),
    );
    _suppliers = _suppliers
        .map((s) => s.id == supplierId
            ? s.copyWith(entries: [...s.entries, entry])
            : s)
        .toList();
    await _persist();
    notifyListeners();
  }

  Future<void> removeSupplier(String supplierId) async {
    _suppliers = _suppliers.where((s) => s.id != supplierId).toList();
    await _persist();
    notifyListeners();
  }

  // --- internals ---

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _encode(_suppliers));
  }

  static String _encode(List<KhataSupplier> list) =>
      jsonEncode(list.map((s) => s.toJson()).toList());

  static List<KhataSupplier> _decode(String raw) {
    try {
      final data = jsonDecode(raw);
      if (data is List) {
        return data
            .whereType<Map>()
            .map((m) => KhataSupplier.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
    } catch (_) {
      // Corrupt payload — start clean rather than crash.
    }
    return const [];
  }

  static String _newId(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}';

  /// A few realistic Pakistani wholesale suppliers so the ledger is useful on
  /// first launch (a shopkeeper can clear these and add their own).
  static List<KhataSupplier> _sampleSuppliers() {
    final now = DateTime.now();
    KhataEntry p(String id, String note, int amt, int daysAgo) => KhataEntry(
          id: 'seed_$id',
          note: note,
          amount: amt,
          type: KhataEntryType.purchase,
          date: now.subtract(Duration(days: daysAgo)),
        );
    KhataEntry pay(String id, String note, int amt, int daysAgo) => KhataEntry(
          id: 'seed_$id',
          note: note,
          amount: amt,
          type: KhataEntryType.payment,
          date: now.subtract(Duration(days: daysAgo)),
        );

    return [
      KhataSupplier(
        id: 'seed_sup_1',
        name: 'Al-Karam Traders',
        market: 'Jodia Bazaar, Karachi',
        phone: '0300 1234567',
        entries: [
          p('1a', '20 cartons cooking oil', 84000, 12),
          pay('1b', 'Cash payment', 50000, 7),
          p('1c', '10 boris sugar', 42000, 3),
        ],
      ),
      KhataSupplier(
        id: 'seed_sup_2',
        name: 'Bismillah Wholesale',
        market: 'Akbari Mandi, Lahore',
        phone: '0321 7654321',
        entries: [
          p('2a', '15 cartons tea', 63000, 9),
          pay('2b', 'Easypaisa transfer', 63000, 2),
        ],
      ),
      KhataSupplier(
        id: 'seed_sup_3',
        name: 'Sindh Provisions',
        market: 'Sharea Faisal, Karachi',
        entries: [
          p('3a', '30 dozen soap', 27000, 5),
        ],
      ),
    ];
  }
}
