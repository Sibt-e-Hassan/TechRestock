// License-safe remote image URLs for TechRestock (Unsplash + Pexels free licenses).
// Product images and display names: lib/data/catalog_display.dart (sync with tools/seed_catalog.js).
import 'package:tech_restock/data/catalog_display.dart';
import 'package:tech_restock/data/models.dart';

class MediaUrls {
  MediaUrls._();

  static const _byCategory = <String, String>{
    'Dairy Products':
        'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=800&q=80',
    'Confectionery':
        'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=800&q=80',
    'Soaps':
        'https://images.unsplash.com/photo-1584305574647-0cc949a2bb9f?w=800&q=80',
    'Shampoos':
        'https://images.unsplash.com/photo-1631729371254-42c2892f0e6e?w=800&q=80',
    'Sauces':
        'https://images.pexels.com/photos/4113810/pexels-photo-4113810.jpeg?auto=compress&cs=tinysrgb&w=800',
    'Flour':
        'https://images.pexels.com/photos/404059/pexels-photo-404059.jpeg?auto=compress&cs=tinysrgb&w=800',
    'Sugar':
        'https://images.pexels.com/photos/4110257/pexels-photo-4110257.jpeg?auto=compress&cs=tinysrgb&w=800',
    'Pulses':
        'https://images.pexels.com/photos/4198019/pexels-photo-4198019.jpeg?auto=compress&cs=tinysrgb&w=800',
    'Rice':
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=800&q=80',
    'Pasta':
        'https://images.unsplash.com/photo-1551462147-ff29053bfc14?w=800&q=80',
    'Noodles':
        'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=800&q=80',
    'Cooking Oil':
        'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=800&q=80',
    'Tea & Coffee':
        'https://images.unsplash.com/photo-1594631252845-29fc4cc8cde9?w=800&q=80',
    'Beverages':
        'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=800&q=80',
    'Snacks':
        'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=800&q=80',
    'Spices':
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&q=80',
    'Cleaning':
        'https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=800&q=80',
  };

  static const _idPrefixCategory = <String, String>{
    'prod_dairy_': 'Dairy Products',
    'prod_conf_': 'Confectionery',
    'prod_soap_': 'Soaps',
    'prod_sham_': 'Shampoos',
    'prod_sauce_': 'Sauces',
    'prod_flour_': 'Flour',
    'prod_sugar_': 'Sugar',
    'prod_pulse_': 'Pulses',
    'prod_rice_': 'Rice',
    'prod_pasta_': 'Pasta',
    'prod_noodle_': 'Noodles',
    'prod_oil_': 'Cooking Oil',
    'prod_tea_': 'Tea & Coffee',
    'prod_bev_': 'Beverages',
    'prod_snack_': 'Snacks',
    'prod_spice_': 'Spices',
    'prod_clean_': 'Cleaning',
  };

  static const _khataById = <String, String>{
    'seed_sup_1':
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&q=80',
    'seed_sup_2':
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&q=80',
    'seed_sup_3':
        'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=800&q=80',
  };

  static const _shopByCategory = <String, String>{
    'Clothing':
        'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&q=80',
    'Electronics':
        'https://images.unsplash.com/photo-1468495244123-6c6c332eeece?w=800&q=80',
    'Gems':
        'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=800&q=80',
    'Food & Spices':
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&q=80',
    'Home & Decor':
        'https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=800&q=80',
    'Fragrances':
        'https://images.unsplash.com/photo-1541643600914-78b084683601?w=800&q=80',
  };

  static const _marketById = <String, String>{
    'market_pk_saddar':
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&q=80',
    'market_pk_anarkali':
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&q=80',
    'market_pk_centaurus':
        'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800&q=80',
    'market_pk_hussain':
        'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&q=80',
    'market_ae_gold_souk':
        'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800&q=80',
    'market_qa_souq_waqif':
        'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80',
    'market_in_chandni':
        'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800&q=80',
  };

  static const _defaultShop =
      'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&q=80';

  static String? productById(String id) {
    final fromManifest = CatalogDisplay.imageUrlFor(id);
    if (fromManifest != null) return fromManifest;
    for (final entry in _idPrefixCategory.entries) {
      if (id.startsWith(entry.key)) {
        return _byCategory[entry.value];
      }
    }
    return null;
  }

  static String? product(ProductItem item) =>
      productById(item.id) ??
      item.imageUrl ??
      (item.category != null ? _byCategory[item.category] : null);

  static String? resolveProduct({
    required String id,
    String? category,
    String? legacyUrl,
  }) {
    return productById(id) ??
        (category != null ? _byCategory[category] : null) ??
        legacyUrl;
  }

  static String? khataSupplier(KhataSupplier supplier) =>
      _khataById[supplier.id] ??
      (supplier.imageUrl?.trim().isNotEmpty == true ? supplier.imageUrl : null);

  static String? khataSupplierById(String id) => _khataById[id];

  static String? orderLine(OrderLineItem item) =>
      productById(item.productId) ?? item.imageUrl;

  static String? shop(ShopItem item) =>
      _shopByCategory[item.category] ?? _defaultShop;

  static String? market(MarketItem item) =>
      _marketById[item.id] ?? _defaultShop;
}
