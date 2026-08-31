import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_restock/data/catalog_display.dart';

/// A wholesale price break: buy [minQty] or more of a unit and pay
/// [priceLabel] per unit. Powers TechRestock's bulk-pricing table.
class PriceTier {
  const PriceTier({required this.minQty, required this.priceLabel});

  final int minQty;
  final String priceLabel;

  factory PriceTier.fromMap(Map<String, dynamic> map) {
    return PriceTier(
      minQty: (map['minQty'] as num?)?.toInt() ?? 1,
      priceLabel: (map['priceLabel'] ?? '') as String,
    );
  }
}

class ProductItem {
  const ProductItem({
    required this.id,
    required this.title,
    required this.shopName,
    required this.priceLabel,
    this.badge,
    this.country,
    this.city,
    this.shopId,
    this.imageUrl,
    this.unit,
    this.minOrderQty = 1,
    this.priceTiers = const [],
    this.brand,
    this.category,
  });

  final String id;
  final String title;
  final String shopName;
  final String priceLabel;
  final String? badge;
  final String? country;
  final String? city;
  final String? shopId;
  final String? imageUrl;

  // --- TechRestock wholesale fields (optional; backward-compatible) ---
  /// Selling unit for wholesale, e.g. "carton", "dozen", "kg", "bori".
  final String? unit;

  /// Minimum order quantity (MOQ) a wholesaler will accept.
  final int minOrderQty;

  /// Optional bulk price breaks; empty when the supplier lists a flat price.
  final List<PriceTier> priceTiers;

  /// Product brand, e.g. "Olpers", "Tapal", "Sufi". Shown on cards.
  final String? brand;

  /// Wholesale category this product belongs to (see AppCategories).
  final String? category;

  factory ProductItem.fromMap(String id, Map<String, dynamic> map) {
    final rawTiers = map['priceTiers'];
    final tiers = rawTiers is List
        ? rawTiers
            .whereType<Map>()
            .map((t) => PriceTier.fromMap(Map<String, dynamic>.from(t)))
            .toList()
        : <PriceTier>[];
    return CatalogDisplay.applyOverrides(
      ProductItem(
        id: id,
        title: (map['title'] ?? '') as String,
        shopName: (map['shopName'] ?? '') as String,
        priceLabel: (map['priceLabel'] ?? '') as String,
        badge: map['badge'] as String?,
        country: map['country'] as String?,
        city: map['city'] as String?,
        shopId: map['shopId'] as String?,
        imageUrl: map['imageUrl'] as String?,
        unit: map['unit'] as String?,
        minOrderQty: (map['minOrderQty'] as num?)?.toInt() ?? 1,
        priceTiers: tiers,
        brand: map['brand'] as String?,
        category: map['category'] as String?,
      ),
    );
  }

  /// Label for the selling unit, defaulting to "unit".
  String get unitLabel => (unit == null || unit!.trim().isEmpty) ? 'unit' : unit!;

  /// Brand to show on cards — falls back to the legacy shopName field.
  String get brandLabel =>
      (brand != null && brand!.trim().isNotEmpty) ? brand! : shopName;

  /// True when this product carries a promotional badge/offer.
  bool get isOffer => badge != null && badge!.trim().isNotEmpty;
}

class MarketItem {
  const MarketItem({
    required this.id,
    required this.name,
    required this.location,
    required this.shopCount,
    this.country,
    this.city,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String location;
  final int shopCount;
  final String? country;
  final String? city;
  final String? imageUrl;

  factory MarketItem.fromMap(String id, Map<String, dynamic> map) {
    return MarketItem(
      id: id,
      name: (map['name'] ?? '') as String,
      location: (map['location'] ?? '') as String,
      shopCount: (map['shopCount'] ?? 0) as int,
      country: map['country'] as String?,
      city: map['city'] as String?,
      imageUrl: map['imageUrl'] as String?,
    );
  }
}

class ShopItem {
  const ShopItem({
    required this.id,
    required this.name,
    required this.category,
    required this.marketId,
    this.imageUrl,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String category;
  final String marketId;
  final String? imageUrl;
  final List<String> tags;

  factory ShopItem.fromMap(String id, Map<String, dynamic> map) {
    return ShopItem(
      id: id,
      name: (map['name'] ?? '') as String,
      category: (map['category'] ?? '') as String,
      marketId: (map['marketId'] ?? '') as String,
      imageUrl: map['imageUrl'] as String?,
      tags: map['tags'] is List
          ? List<String>.from(map['tags'] as List)
          : <String>[],
    );
  }
}

class CartLineItem {
  const CartLineItem({
    required this.product,
    this.quantity = 1,
  });

  final ProductItem product;
  final int quantity;

  String get productId => product.id;

  factory CartLineItem.fromFirestore(String docId, Map<String, dynamic> data) {
    return CartLineItem(
      product: ProductItem(
        id: docId,
        title: (data['title'] ?? '') as String,
        shopName: (data['shopName'] ?? '') as String,
        priceLabel: (data['priceLabel'] ?? '') as String,
        shopId: data['shopId'] as String?,
        imageUrl: data['imageUrl'] as String?,
        country: data['country'] as String?,
        city: data['city'] as String?,
        badge: data['badge'] as String?,
      ),
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toFirestorePayload() {
    return {
      'productId': product.id,
      'title': product.title,
      'shopName': product.shopName,
      'priceLabel': product.priceLabel,
      if (product.shopId != null) 'shopId': product.shopId,
      if (product.country != null) 'country': product.country,
      if (product.city != null) 'city': product.city,
      if (product.badge != null) 'badge': product.badge,
      'quantity': quantity,
    };
  }
}

class OrderLineItem {
  const OrderLineItem({
    required this.productId,
    required this.title,
    required this.shopName,
    required this.priceLabel,
    this.quantity = 1,
    this.imageUrl,
    this.shopId,
  });

  final String productId;
  final String title;
  final String shopName;
  final String priceLabel;
  final int quantity;
  final String? imageUrl;
  final String? shopId;

  factory OrderLineItem.fromMap(Map<String, dynamic> map) {
    return OrderLineItem(
      productId: (map['productId'] ?? '') as String,
      title: (map['title'] ?? '') as String,
      shopName: (map['shopName'] ?? '') as String,
      priceLabel: (map['priceLabel'] ?? '') as String,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      imageUrl: map['imageUrl'] as String?,
      shopId: map['shopId'] as String?,
    );
  }
}

class OrderRecord {
  const OrderRecord({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    this.itemCount,
    this.timestamp,
    this.status,
  });

  final String id;
  final String userId;
  final List<OrderLineItem> items;
  final String totalPrice;
  final int? itemCount;
  final DateTime? timestamp;
  final String? status;

  factory OrderRecord.fromMap(String id, Map<String, dynamic> map) {
    final rawItems = map['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((item) => OrderLineItem.fromMap(Map<String, dynamic>.from(item)))
            .toList()
        : <OrderLineItem>[];

    final timestamp = map['timestamp'];
    DateTime? createdAt;
    if (timestamp is Timestamp) {
      createdAt = timestamp.toDate();
    }

    return OrderRecord(
      id: id,
      userId: (map['userId'] ?? '') as String,
      items: items,
      totalPrice: (map['totalPrice'] ?? '') as String,
      itemCount: (map['itemCount'] as num?)?.toInt(),
      timestamp: createdAt,
      status: map['status'] as String?,
    );
  }
}

// ===========================================================================
// TechRestock B2B models — stored locally (shared_preferences), not Firestore.
// The khata (running supplier credit) is the shopkeeper's private ledger; the
// restock reminders are personal scheduling. Both are device-local by design.
// ===========================================================================

/// One line in a supplier's khata: either goods taken on udhaar (a purchase,
/// which increases what you owe) or a payment made (which reduces it).
enum KhataEntryType { purchase, payment }

class KhataEntry {
  const KhataEntry({
    required this.id,
    required this.note,
    required this.amount,
    required this.type,
    required this.date,
  });

  final String id;
  final String note;

  /// Rupee amount, always a positive integer.
  final int amount;
  final KhataEntryType type;
  final DateTime date;

  bool get isPurchase => type == KhataEntryType.purchase;

  Map<String, dynamic> toJson() => {
        'id': id,
        'note': note,
        'amount': amount,
        'type': type.name,
        'date': date.toIso8601String(),
      };

  factory KhataEntry.fromJson(Map<String, dynamic> json) {
    return KhataEntry(
      id: (json['id'] ?? '') as String,
      note: (json['note'] ?? '') as String,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      type: KhataEntryType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => KhataEntryType.purchase,
      ),
      date: DateTime.tryParse((json['date'] ?? '') as String) ?? DateTime.now(),
    );
  }
}

/// A supplier the shopkeeper keeps a running balance (udhaar) with.
class KhataSupplier {
  const KhataSupplier({
    required this.id,
    required this.name,
    required this.market,
    this.phone,
    this.imageUrl,
    this.entries = const [],
  });

  final String id;
  final String name;

  /// Wholesale market the supplier trades from, e.g. "Jodia Bazaar".
  final String market;
  final String? phone;

  /// Local-only avatar URL (SharedPreferences); not stored in Firestore.
  final String? imageUrl;
  final List<KhataEntry> entries;

  /// Outstanding udhaar in Rs: purchases minus payments. Positive = you owe
  /// the supplier; negative = you are in credit (advance paid).
  int get balance => entries.fold<int>(
        0,
        (running, e) => running + (e.isPurchase ? e.amount : -e.amount),
      );

  List<KhataEntry> get entriesNewestFirst {
    final list = [...entries]..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  KhataSupplier copyWith({
    List<KhataEntry>? entries,
    String? imageUrl,
  }) =>
      KhataSupplier(
        id: id,
        name: name,
        market: market,
        phone: phone,
        imageUrl: imageUrl ?? this.imageUrl,
        entries: entries ?? this.entries,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'market': market,
        if (phone != null) 'phone': phone,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'entries': entries.map((e) => e.toJson()).toList(),
      };

  factory KhataSupplier.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'];
    final entries = rawEntries is List
        ? rawEntries
            .whereType<Map>()
            .map((e) => KhataEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <KhataEntry>[];
    return KhataSupplier(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      market: (json['market'] ?? '') as String,
      phone: json['phone'] as String?,
      imageUrl: json['imageUrl'] as String?,
      entries: entries,
    );
  }
}

/// A scheduled reminder to restock a product every [everyDays] days.
class RestockReminder {
  const RestockReminder({
    required this.id,
    required this.productTitle,
    required this.supplierName,
    required this.everyDays,
    required this.nextDate,
    this.productId,
  });

  final String id;
  final String productTitle;
  final String supplierName;

  /// Restock cadence in days (e.g. 7 = weekly, 30 = monthly).
  final int everyDays;
  final DateTime nextDate;
  final String? productId;

  int get daysUntil => nextDate.difference(DateTime.now()).inDays;
  bool get isDue => nextDate.isBefore(DateTime.now()) ||
      nextDate.difference(DateTime.now()).inHours <= 24;

  RestockReminder bumpToNextCycle() {
    return RestockReminder(
      id: id,
      productTitle: productTitle,
      supplierName: supplierName,
      everyDays: everyDays,
      nextDate: DateTime.now().add(Duration(days: everyDays)),
      productId: productId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productTitle': productTitle,
        'supplierName': supplierName,
        'everyDays': everyDays,
        'nextDate': nextDate.toIso8601String(),
        if (productId != null) 'productId': productId,
      };

  factory RestockReminder.fromJson(Map<String, dynamic> json) {
    return RestockReminder(
      id: (json['id'] ?? '') as String,
      productTitle: (json['productTitle'] ?? '') as String,
      supplierName: (json['supplierName'] ?? '') as String,
      everyDays: (json['everyDays'] as num?)?.toInt() ?? 7,
      nextDate:
          DateTime.tryParse((json['nextDate'] ?? '') as String) ?? DateTime.now(),
      productId: json['productId'] as String?,
    );
  }
}

/// Formats a rupee integer as "Rs 12,500" with thousands separators.
String formatRupees(int amount) {
  final negative = amount < 0;
  final digits = amount.abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return '${negative ? '-' : ''}Rs $buf';
}
