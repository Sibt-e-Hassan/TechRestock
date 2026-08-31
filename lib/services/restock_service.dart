import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tech_restock/data/models.dart';

/// Device-local store for scheduled restock reminders. Singleton +
/// ChangeNotifier so product detail, the reminders screen, and the profile
/// can all react to changes.
class RestockService extends ChangeNotifier {
  RestockService._();
  static final RestockService instance = RestockService._();

  static const _prefsKey = 'techrestock_restock_v1';

  List<RestockReminder> _reminders = const [];
  bool _loaded = false;

  bool get isLoaded => _loaded;

  /// Reminders sorted by soonest due first.
  List<RestockReminder> get reminders {
    final list = [..._reminders]..sort((a, b) => a.nextDate.compareTo(b.nextDate));
    return list;
  }

  int get dueCount => _reminders.where((r) => r.isDue).length;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) _reminders = _decode(raw);
    _loaded = true;
    notifyListeners();
  }

  bool hasReminderForProduct(String? productId) {
    if (productId == null) return false;
    return _reminders.any((r) => r.productId == productId);
  }

  Future<void> addReminder({
    required String productTitle,
    required String supplierName,
    required int everyDays,
    String? productId,
  }) async {
    final reminder = RestockReminder(
      id: 'rem_${DateTime.now().microsecondsSinceEpoch}',
      productTitle: productTitle,
      supplierName: supplierName,
      everyDays: everyDays,
      nextDate: DateTime.now().add(Duration(days: everyDays)),
      productId: productId,
    );
    _reminders = [..._reminders, reminder];
    await _persist();
    notifyListeners();
  }

  Future<void> markRestocked(String id) async {
    _reminders = _reminders
        .map((r) => r.id == id ? r.bumpToNextCycle() : r)
        .toList();
    await _persist();
    notifyListeners();
  }

  Future<void> removeReminder(String id) async {
    _reminders = _reminders.where((r) => r.id != id).toList();
    await _persist();
    notifyListeners();
  }

  // --- internals ---

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _encode(_reminders));
  }

  static String _encode(List<RestockReminder> list) =>
      jsonEncode(list.map((r) => r.toJson()).toList());

  static List<RestockReminder> _decode(String raw) {
    try {
      final data = jsonDecode(raw);
      if (data is List) {
        return data
            .whereType<Map>()
            .map((m) => RestockReminder.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
    } catch (_) {
      // Corrupt payload — start clean.
    }
    return const [];
  }
}
