import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tech_restock/data/media_urls.dart';
import 'package:tech_restock/data/models.dart';

/// Device-local store for the shopkeeper's khata (running supplier credit).
/// Persisted in shared_preferences — a khata is private bookkeeping, so it
/// lives on the device rather than in Firestore. Singleton + ChangeNotifier
/// so any screen can `ListenableBuilder` on it.
class KhataService extends ChangeNotifier {
  KhataService._();
  static final KhataService instance = KhataService._();

  static const _prefsKey = 'techrestock_khata_v1';
  static const _seededKey = 'techrestock_khata_seeded_v1';
  static const _dataVersionKey = 'techrestock_khata_data_version';
  static const _currentDataVersion = 2;

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
      final decoded = _decode(raw);
      final hydrated = _hydrateSupplierImages(decoded);
      _suppliers = hydrated;
      if (_needsImagePersist(decoded, hydrated)) {
        await _persist();
      }
      final dataVersion = prefs.getInt(_dataVersionKey) ?? 1;
      if (dataVersion < _currentDataVersion) {
        _suppliers = _applySeedSupplierUpdates(_suppliers);
        await prefs.setInt(_dataVersionKey, _currentDataVersion);
        await _persist();
      }
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

  static List<KhataSupplier> _hydrateSupplierImages(List<KhataSupplier> list) {
    return list.map((supplier) {
      if (supplier.imageUrl?.trim().isNotEmpty == true) {
        return supplier;
      }
      final url = MediaUrls.khataSupplierById(supplier.id);
      if (url == null) {
        return supplier;
      }
      return supplier.copyWith(imageUrl: url);
    }).toList();
  }

  static bool _needsImagePersist(
    List<KhataSupplier> before,
    List<KhataSupplier> after,
  ) {
    if (before.length != after.length) {
      return false;
    }
    for (var i = 0; i < before.length; i++) {
      if (before[i].imageUrl != after[i].imageUrl) {
        return true;
      }
    }
    return false;
  }

  static String _newId(String prefix) =>
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}';

  static List<KhataSupplier> _applySeedSupplierUpdates(List<KhataSupplier> list) {
    final fresh = {for (final s in _sampleSuppliers()) s.id: s};
    return list.map((s) => fresh[s.id] ?? s).toList();
  }

  /// Pakistani wholesale suppliers seeded on first launch. Markets are real
  /// wholesale hubs; trader names are illustrative (not tied to any business).
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
        name: 'Karim Oil Traders',
        market: 'Jodia Bazaar, Karachi',
        phone: '+92 300 2123456',
        imageUrl: MediaUrls.khataSupplierById('seed_sup_1'),
        entries: [
          p('1a', '20 cartons Sufi cooking oil 5L', 84000, 12),
          pay('1b', 'Cash payment — partial', 50000, 7),
          p('1c', '10 boris Al-Arabia refined sugar 50kg', 42000, 3),
        ],
      ),
      KhataSupplier(
        id: 'seed_sup_2',
        name: 'Rehman Grain House',
        market: 'Akbari Mandi, Lahore',
        phone: '+92 321 7654321',
        imageUrl: MediaUrls.khataSupplierById('seed_sup_2'),
        entries: [
          p('2a', '15 cartons Tapal Danedar tea 900g', 63000, 9),
          pay('2b', 'Easypaisa transfer — full settlement', 63000, 2),
        ],
      ),
      KhataSupplier(
        id: 'seed_sup_3',
        name: 'Bolton Market Provisions',
        market: 'Bolton Market, Karachi',
        phone: '+92 333 4455667',
        imageUrl: MediaUrls.khataSupplierById('seed_sup_3'),
        entries: [
          p('3a', '30 dozen Lifebuoy soap 130g', 27000, 5),
        ],
      ),
    ];
  }
}
