import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Result of a catalog seed operation.
class FirestoreSeedResult {
  const FirestoreSeedResult({
    required this.marketsWritten,
    required this.productsWritten,
    required this.shopsWritten,
    required this.skipped,
    this.message,
  });

  final int marketsWritten;
  final int productsWritten;
  final int shopsWritten;
  final bool skipped;
  final String? message;
}

/// Demo-only catalog seeder. Production data: add docs in Firebase Console using
/// the same field names as [_markets], [_shops], and [_products] — see
/// `docs/firestore_catalog_schema.md`.
abstract final class FirestoreSeed {
  static const _metaDocPath = '_meta/catalog_seed';

  /// Real market/shop photos hosted on Firebase Hosting (see
  /// tools/process_market_images.js + web_docs/media/).
  static const _shopMediaBase = 'https://bazaar-connect-c4487.web.app/media/shops';

  /// Populates [markets] and [products] with professional sample data.
  /// Uses fixed document IDs so you can run this multiple times safely (merge).
  static Future<FirestoreSeedResult> seedShopPandaCatalog({
    bool onlyIfEmpty = false,
  }) async {
    final firestore = FirebaseFirestore.instance;

    if (onlyIfEmpty) {
      final existing = await firestore.collection('markets').limit(1).get();
      if (existing.docs.isNotEmpty) {
        return const FirestoreSeedResult(
          marketsWritten: 0,
          productsWritten: 0,
          shopsWritten: 0,
          skipped: true,
          message: 'Catalog already has data. Use force seed to refresh.',
        );
      }
    }

    final batch = firestore.batch();
    var marketCount = 0;
    var productCount = 0;
    var shopCount = 0;

    for (final market in _markets) {
      final ref = firestore.collection('markets').doc(market['id'] as String);
      batch.set(ref, {
        'name': market['name'],
        'title': market['title'],
        'shopName': market['shopName'],
        'location': market['location'],
        'shopCount': market['shopCount'],
        'country': market['country'],
        if (market['city'] != null) 'city': market['city'],
        'badge': market['badge'],
        'imageUrl': market['imageUrl'],
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      marketCount++;
    }

    for (final product in _products) {
      final ref = firestore.collection('products').doc(product['id'] as String);
      final data = <String, dynamic>{
        'title': product['title'],
        'shopName': product['shopName'],
        'shopId': product['shopId'],
        'priceLabel': product['priceLabel'],
        'country': product['country'],
        if (product['city'] != null) 'city': product['city'],
        'imageUrl': product['imageUrl'],
        'updatedAt': FieldValue.serverTimestamp(),
      };
      final badge = product['badge'];
      if (badge != null) {
        data['badge'] = badge;
      }
      batch.set(ref, data, SetOptions(merge: true));
      productCount++;
    }

    for (final shop in _shops) {
      final ref = firestore.collection('shops').doc(shop['id'] as String);
      batch.set(ref, {
        'name': shop['name'],
        'category': shop['category'],
        'marketId': shop['marketId'],
        'imageUrl': shop['imageUrl'],
        'tags': shop['tags'] ?? [],
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      shopCount++;
    }

    batch.set(
      firestore.doc(_metaDocPath),
      {
        'version': 2,
        'seededAt': FieldValue.serverTimestamp(),
        'marketCount': marketCount,
        'productCount': productCount,
        'shopCount': shopCount,
      },
      SetOptions(merge: true),
    );

    await batch.commit();

    debugPrint(
      'FirestoreSeed: wrote $marketCount markets, $productCount products, and $shopCount shops.',
    );

    return FirestoreSeedResult(
      marketsWritten: marketCount,
      productsWritten: productCount,
      shopsWritten: shopCount,
      skipped: false,
      message: 'Seeded $marketCount markets, $productCount products, and $shopCount shops.',
    );
  }

  static final List<Map<String, dynamic>> _markets = [
    {
      'id': 'market_pk_saddar',
      'name': 'Saddar Market',
      'title': 'Saddar Market',
      'shopName': 'Karachi Bazaar Collective',
      'location': 'Karachi, Pakistan',
      'shopCount': 12,
      'country': 'Pakistan',
      'city': 'Karachi',
      'badge': 'Popular',
      'imageUrl':
          'https://bazaar-connect-c4487.web.app/media/markets/saddar.jpg',
    },
    {
      'id': 'market_pk_anarkali',
      'name': 'Anarkali Bazaar',
      'title': 'Anarkali Bazaar',
      'shopName': 'Lahore Heritage Bazar',
      'location': 'Lahore, Pakistan',
      'shopCount': 12,
      'country': 'Pakistan',
      'city': 'Lahore',
      'badge': 'Popular',
      'imageUrl':
          'https://bazaar-connect-c4487.web.app/media/markets/anarkali.jpg',
    },
    {
      'id': 'market_pk_centaurus',
      'name': 'Centaurus Mall',
      'title': 'Centaurus Mall',
      'shopName': 'Islamabad Premium Plaza',
      'location': 'Islamabad, Pakistan',
      'shopCount': 12,
      'country': 'Pakistan',
      'city': 'Islamabad',
      'badge': 'Trending',
      'imageUrl':
          'https://bazaar-connect-c4487.web.app/media/markets/centaurus.jpg',
    },
    {
      'id': 'market_pk_hussain',
      'name': 'Husain Agahi Bazaar',
      'title': 'Husain Agahi Bazaar',
      'shopName': 'Multan Souk Collective',
      'location': 'Multan, Pakistan',
      'shopCount': 12,
      'country': 'Pakistan',
      'city': 'Multan',
      'badge': 'Local Pick',
      'imageUrl':
          'https://bazaar-connect-c4487.web.app/media/markets/hussain.jpg',
    },
    {
      'id': 'market_ae_gold_souk',
      'name': 'Gold Souk · Deira',
      'title': 'Gold Souk · Deira',
      'shopName': 'Dubai Souk Traders',
      'location': 'Dubai, United Arab Emirates',
      'shopCount': 124,
      'country': 'United Arab Emirates',
      'city': 'Dubai',
      'badge': 'Trending',
      'imageUrl':
          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800&q=80',
    },
    {
      'id': 'market_qa_souq_waqif',
      'name': 'Souq Waqif',
      'title': 'Souq Waqif',
      'shopName': 'Doha Heritage Shops',
      'location': 'Doha, Qatar',
      'shopCount': 56,
      'country': 'Qatar',
      'city': 'Doha',
      'badge': 'Popular',
      'imageUrl':
          'https://images.unsplash.com/photo-1586724378053-2e8f3c1e2f8a?w=800&q=80',
    },
    {
      'id': 'market_in_chandni',
      'name': 'Chandni Chowk',
      'title': 'Chandni Chowk',
      'shopName': 'Old Delhi Textile Lane',
      'location': 'New Delhi, India',
      'shopCount': 210,
      'country': 'India',
      'city': 'New Delhi',
      'badge': 'Trending',
      'imageUrl':
          'https://images.unsplash.com/photo-1587970551846-0311a2e0f3e0?w=800&q=80',
    },
  ];

  static final List<Map<String, dynamic>> _products = [
    {
      'id': 'prod_pk_kurta',
      'title': 'Embroidered cotton kurta',
      'shopName': 'Junaid Jamshed Outlet',
      'shopId': 'shop_pk_jj_saddar',
      'priceLabel': 'PKR 4,200',
      'country': 'Pakistan',
      'city': 'Karachi',
      'badge': 'New',
      'imageUrl':
          'https://images.unsplash.com/photo-1594938298603-c8148c4dae35?w=800&q=80',
    },
    {
      'id': 'prod_pk_phone',
      'title': 'Galaxy A55 — unlocked',
      'shopName': 'Galaxy Mobile Hub',
      'shopId': 'shop_pk_galaxy_saddar',
      'priceLabel': 'PKR 89,999',
      'country': 'Pakistan',
      'city': 'Karachi',
      'badge': 'Popular',
      'imageUrl':
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800&q=80',
    },
    {
      'id': 'prod_pk_tote',
      'title': 'Handwoven jute tote bag',
      'shopName': 'Al-Haram Gems',
      'shopId': 'shop_pk_gems_saddar',
      'priceLabel': 'PKR 2,450',
      'country': 'Pakistan',
      'city': 'Karachi',
      'badge': null,
      'imageUrl':
          'https://images.unsplash.com/photo-1590874103328-eac3a0a473c2?w=800&q=80',
    },
    {
      'id': 'prod_pk_khussa',
      'title': 'Handmade velvet khussa',
      'shopName': 'Traditional Khussa Palace',
      'shopId': 'shop_pk_anarkali_khussa',
      'priceLabel': 'PKR 1,850',
      'country': 'Pakistan',
      'city': 'Lahore',
      'badge': 'Trending',
      'imageUrl':
          'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=800&q=80',
    },
    {
      'id': 'prod_pk_designer_suit',
      'title': 'Embellished silk lawn suit',
      'shopName': 'Zara Couture',
      'shopId': 'shop_pk_centaurus_designer',
      'priceLabel': 'PKR 14,500',
      'country': 'Pakistan',
      'city': 'Islamabad',
      'badge': 'New',
      'imageUrl':
          'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800&q=80',
    },
    {
      'id': 'prod_pk_halwa',
      'title': 'Premium Almond Sohan Halwa',
      'shopName': 'Rewari Sohan Halwa',
      'shopId': 'shop_pk_multan_halwa',
      'priceLabel': 'PKR 1,200',
      'country': 'Pakistan',
      'city': 'Multan',
      'badge': 'Famous',
      'imageUrl':
          'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?w=800&q=80',
    },
    {
      'id': 'prod_ae_overshirt',
      'title': 'Linen blend overshirt',
      'shopName': 'Marina Style',
      'shopId': 'shop_ae_marina_style',
      'priceLabel': 'AED 189',
      'country': 'United Arab Emirates',
      'city': 'Dubai',
      'badge': 'New',
      'imageUrl':
          'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=800&q=80',
    },
    {
      'id': 'prod_ae_oud',
      'title': 'Oud fragrance gift set',
      'shopName': 'Arabian Oud House',
      'shopId': 'shop_ae_oud_house',
      'priceLabel': 'AED 450',
      'country': 'United Arab Emirates',
      'city': 'Dubai',
      'badge': 'Popular',
      'imageUrl':
          'https://images.unsplash.com/photo-1541643600914-78b084683601?w=800&q=80',
    },
    {
      'id': 'prod_qa_ceramic',
      'title': 'Ceramic serving set (12 pc)',
      'shopName': 'Waqif Handicrafts',
      'shopId': 'shop_qa_handicrafts',
      'priceLabel': 'QAR 320',
      'country': 'Qatar',
      'city': 'Doha',
      'badge': null,
      'imageUrl':
          'https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=800&q=80',
    },
    {
      'id': 'prod_in_silk_scarf',
      'title': 'Handloom silk scarf',
      'shopName': 'Silk Weavers Lane',
      'shopId': 'shop_in_silk_weavers',
      'priceLabel': 'INR 1,850',
      'country': 'India',
      'city': 'New Delhi',
      'badge': 'Trending',
      'imageUrl':
          'https://images.unsplash.com/photo-1520903923513-f990884e5771?w=800&q=80',
    },
  ];

  static final List<Map<String, dynamic>> _shops = [
    // --- Saddar Market, Karachi (12 shops) ---
    {
      'id': 'shop_pk_jj_saddar',
      'name': 'Junaid Jamshed Outlet',
      'category': 'Clothing',
      'marketId': 'market_pk_saddar',
      'imageUrl': '$_shopMediaBase/shop_pk_jj_saddar.jpg',
      'tags': ['fashion', 'clothing', 'kurta', 'traditional'],
    },
    {
      'id': 'shop_pk_galaxy_saddar',
      'name': 'Galaxy Mobile Hub',
      'category': 'Electronics',
      'marketId': 'market_pk_saddar',
      'imageUrl': '$_shopMediaBase/shop_pk_galaxy_saddar.jpg',
      'tags': ['electronics', 'mobile', 'android', 'iphone', 'samsung'],
    },
    {
      'id': 'shop_pk_gems_saddar',
      'name': 'Al-Haram Gems',
      'category': 'Gems',
      'marketId': 'market_pk_saddar',
      'imageUrl': '$_shopMediaBase/shop_pk_gems_saddar.jpg',
      'tags': ['gems', 'jewelry', 'beauty', 'fashion'],
    },
    {
      'id': 'shop_pk_saddar_electronics2',
      'name': 'Saddar Electronics Bazaar',
      'category': 'Electronics',
      'marketId': 'market_pk_saddar',
      'imageUrl': '$_shopMediaBase/shop_pk_saddar_electronics2.jpg',
      'tags': ['electronics', 'mobile', 'accessories'],
    },
    {
      'id': 'shop_pk_saddar_fashion',
      'name': 'Karachi Fashion House',
      'category': 'Clothing',
      'marketId': 'market_pk_saddar',
      'imageUrl': '$_shopMediaBase/shop_pk_saddar_fashion.jpg',
      'tags': ['fashion', 'clothing', 'style'],
    },
    {
      'id': 'shop_pk_saddar_spices',
      'name': 'Saddar Spice Traders',
      'category': 'Food & Spices',
      'marketId': 'market_pk_saddar',
      'imageUrl': '$_shopMediaBase/shop_pk_saddar_spices.jpg',
      'tags': ['spices', 'food', 'grocery'],
    },
    {
      'id': 'shop_pk_saddar_crafts',
      'name': 'Sindh Handicrafts',
      'category': 'Home & Decor',
      'marketId': 'market_pk_saddar',
      'imageUrl': '$_shopMediaBase/shop_pk_saddar_crafts.jpg',
      'tags': ['decor', 'handicrafts', 'home'],
    },
    {
      'id': 'shop_pk_saddar_shoes',
      'name': 'Karachi Shoe Mart',
      'category': 'Clothing',
      'marketId': 'market_pk_saddar',
      'imageUrl': '$_shopMediaBase/shop_pk_saddar_shoes.jpg',
      'tags': ['shoes', 'clothing', 'footwear'],
    },
    {
      'id': 'shop_pk_saddar_spices2',
      'name': 'Bandar Road Spices',
      'category': 'Food & Spices',
      'marketId': 'market_pk_saddar',
      'imageUrl': '$_shopMediaBase/shop_pk_saddar_spices2.jpg',
      'tags': ['spices', 'food', 'market'],
    },
    {
      'id': 'shop_pk_saddar_perfume',
      'name': 'Saddar Perfume Gallery',
      'category': 'Fragrances',
      'marketId': 'market_pk_saddar',
      'imageUrl': '$_shopMediaBase/shop_pk_saddar_perfume.jpg',
      'tags': ['fragrance', 'perfume', 'beauty'],
    },
    {
      'id': 'shop_pk_saddar_sweets',
      'name': 'Karachi Sweet House',
      'category': 'Food & Spices',
      'marketId': 'market_pk_saddar',
      'imageUrl': '$_shopMediaBase/shop_pk_saddar_sweets.jpg',
      'tags': ['sweets', 'food', 'dessert'],
    },
    {
      'id': 'shop_pk_saddar_mobile',
      'name': 'Regal Mobile Center',
      'category': 'Electronics',
      'marketId': 'market_pk_saddar',
      'imageUrl': '$_shopMediaBase/shop_pk_saddar_mobile.jpg',
      'tags': ['electronics', 'mobile', 'repair'],
    },

    // --- Anarkali Bazaar, Lahore (12 shops) ---
    {
      'id': 'shop_pk_anarkali_khussa',
      'name': 'Traditional Khussa Palace',
      'category': 'Clothing',
      'marketId': 'market_pk_anarkali',
      'imageUrl': '$_shopMediaBase/shop_pk_anarkali_khussa.jpg',
      'tags': ['shoes', 'traditional', 'clothing', 'khussa'],
    },
    {
      'id': 'shop_pk_anarkali_bano_shoes',
      'name': 'Bano Shoes',
      'category': 'Clothing',
      'marketId': 'market_pk_anarkali',
      'imageUrl': '$_shopMediaBase/shop_pk_anarkali_bano_shoes.jpg',
      'tags': ['shoes', 'footwear', 'clothing'],
    },
    {
      'id': 'shop_pk_anarkali_silk_house',
      'name': 'Anarkali Silk House',
      'category': 'Clothing',
      'marketId': 'market_pk_anarkali',
      'imageUrl': '$_shopMediaBase/shop_pk_anarkali_silk_house.jpg',
      'tags': ['fashion', 'silk', 'clothing'],
    },
    {
      'id': 'shop_pk_anarkali_gems',
      'name': 'Anarkali Gems Gallery',
      'category': 'Gems',
      'marketId': 'market_pk_anarkali',
      'imageUrl': '$_shopMediaBase/shop_pk_anarkali_gems.jpg',
      'tags': ['gems', 'jewelry', 'beauty'],
    },
    {
      'id': 'shop_pk_anarkali_handicrafts',
      'name': 'Lahore Handicrafts',
      'category': 'Home & Decor',
      'marketId': 'market_pk_anarkali',
      'imageUrl': '$_shopMediaBase/shop_pk_anarkali_handicrafts.jpg',
      'tags': ['decor', 'handicrafts', 'home'],
    },
    {
      'id': 'shop_pk_anarkali_perfume',
      'name': 'Ittar House Anarkali',
      'category': 'Fragrances',
      'marketId': 'market_pk_anarkali',
      'imageUrl': '$_shopMediaBase/shop_pk_anarkali_perfume.jpg',
      'tags': ['fragrance', 'ittar', 'perfume'],
    },
    {
      'id': 'shop_pk_anarkali_sweets',
      'name': 'Anarkali Sweets Corner',
      'category': 'Food & Spices',
      'marketId': 'market_pk_anarkali',
      'imageUrl': '$_shopMediaBase/shop_pk_anarkali_sweets.jpg',
      'tags': ['sweets', 'food', 'dessert'],
    },
    {
      'id': 'shop_pk_anarkali_designer',
      'name': 'Anarkali Designer Studio',
      'category': 'Clothing',
      'marketId': 'market_pk_anarkali',
      'imageUrl': '$_shopMediaBase/shop_pk_anarkali_designer.jpg',
      'tags': ['fashion', 'designer', 'clothing'],
    },
    {
      'id': 'shop_pk_anarkali_jewelers',
      'name': 'Heritage Jewelers',
      'category': 'Gems',
      'marketId': 'market_pk_anarkali',
      'imageUrl': '$_shopMediaBase/shop_pk_anarkali_jewelers.jpg',
      'tags': ['gems', 'jewelry', 'gold'],
    },
    {
      'id': 'shop_pk_anarkali_crafts2',
      'name': 'Punjab Artisan Crafts',
      'category': 'Home & Decor',
      'marketId': 'market_pk_anarkali',
      'imageUrl': '$_shopMediaBase/shop_pk_anarkali_crafts2.jpg',
      'tags': ['decor', 'handicrafts', 'artisan'],
    },
    {
      'id': 'shop_pk_anarkali_mobile',
      'name': 'Anarkali Mobile Point',
      'category': 'Electronics',
      'marketId': 'market_pk_anarkali',
      'imageUrl': '$_shopMediaBase/shop_pk_anarkali_mobile.jpg',
      'tags': ['electronics', 'mobile', 'accessories'],
    },
    {
      'id': 'shop_pk_anarkali_bags',
      'name': 'Bagh-e-Fashion Bags',
      'category': 'Clothing',
      'marketId': 'market_pk_anarkali',
      'imageUrl': '$_shopMediaBase/shop_pk_anarkali_bags.jpg',
      'tags': ['bags', 'accessories', 'fashion'],
    },

    // --- Centaurus Mall, Islamabad (12 shops) ---
    {
      'id': 'shop_pk_centaurus_designer',
      'name': 'Zara Couture',
      'category': 'Clothing',
      'marketId': 'market_pk_centaurus',
      'imageUrl': '$_shopMediaBase/shop_pk_centaurus_designer.jpg',
      'tags': ['fashion', 'designer', 'luxury', 'clothing'],
    },
    {
      'id': 'shop_pk_centaurus_electronics',
      'name': 'Centaurus Electronics Hub',
      'category': 'Electronics',
      'marketId': 'market_pk_centaurus',
      'imageUrl': '$_shopMediaBase/shop_pk_centaurus_electronics.jpg',
      'tags': ['electronics', 'gadgets', 'mobile'],
    },
    {
      'id': 'shop_pk_centaurus_mobile2',
      'name': 'TechZone Mobiles',
      'category': 'Electronics',
      'marketId': 'market_pk_centaurus',
      'imageUrl': '$_shopMediaBase/shop_pk_centaurus_mobile2.jpg',
      'tags': ['electronics', 'mobile', 'tech'],
    },
    {
      'id': 'shop_pk_centaurus_jewelry',
      'name': 'Royal Jewelry House',
      'category': 'Gems',
      'marketId': 'market_pk_centaurus',
      'imageUrl': '$_shopMediaBase/shop_pk_centaurus_jewelry.jpg',
      'tags': ['gems', 'jewelry', 'luxury'],
    },
    {
      'id': 'shop_pk_centaurus_perfume',
      'name': 'Scent Avenue',
      'category': 'Fragrances',
      'marketId': 'market_pk_centaurus',
      'imageUrl': '$_shopMediaBase/shop_pk_centaurus_perfume.jpg',
      'tags': ['fragrance', 'perfume', 'beauty'],
    },
    {
      'id': 'shop_pk_centaurus_decor',
      'name': 'Modern Living Decor',
      'category': 'Home & Decor',
      'marketId': 'market_pk_centaurus',
      'imageUrl': '$_shopMediaBase/shop_pk_centaurus_decor.jpg',
      'tags': ['decor', 'furniture', 'home'],
    },
    {
      'id': 'shop_pk_centaurus_fashion2',
      'name': 'Urban Threads',
      'category': 'Clothing',
      'marketId': 'market_pk_centaurus',
      'imageUrl': '$_shopMediaBase/shop_pk_centaurus_fashion2.jpg',
      'tags': ['fashion', 'clothing', 'style'],
    },
    {
      'id': 'shop_pk_centaurus_gadgets',
      'name': 'Gadget World',
      'category': 'Electronics',
      'marketId': 'market_pk_centaurus',
      'imageUrl': '$_shopMediaBase/shop_pk_centaurus_gadgets.jpg',
      'tags': ['electronics', 'gadgets', 'tech'],
    },
    {
      'id': 'shop_pk_centaurus_shoes',
      'name': 'Footwear Gallery',
      'category': 'Clothing',
      'marketId': 'market_pk_centaurus',
      'imageUrl': '$_shopMediaBase/shop_pk_centaurus_shoes.jpg',
      'tags': ['shoes', 'footwear', 'clothing'],
    },
    {
      'id': 'shop_pk_centaurus_gold',
      'name': 'Gold & Co.',
      'category': 'Gems',
      'marketId': 'market_pk_centaurus',
      'imageUrl': '$_shopMediaBase/shop_pk_centaurus_gold.jpg',
      'tags': ['gems', 'gold', 'jewelry'],
    },
    {
      'id': 'shop_pk_centaurus_bakery',
      'name': 'Centaurus Bakers',
      'category': 'Food & Spices',
      'marketId': 'market_pk_centaurus',
      'imageUrl': '$_shopMediaBase/shop_pk_centaurus_bakery.jpg',
      'tags': ['bakery', 'food', 'sweets'],
    },
    {
      'id': 'shop_pk_centaurus_oud',
      'name': 'Oud Boutique',
      'category': 'Fragrances',
      'marketId': 'market_pk_centaurus',
      'imageUrl': '$_shopMediaBase/shop_pk_centaurus_oud.jpg',
      'tags': ['fragrance', 'oud', 'perfume'],
    },

    // --- Husain Agahi Bazaar, Multan (12 shops) ---
    {
      'id': 'shop_pk_multan_halwa',
      'name': 'Rewari Sohan Halwa',
      'category': 'Food & Spices',
      'marketId': 'market_pk_hussain',
      'imageUrl': '$_shopMediaBase/shop_pk_multan_halwa.jpg',
      'tags': ['food', 'sweets', 'spices', 'halwa'],
    },
    {
      'id': 'shop_pk_hussain_embroidery',
      'name': 'Multani Embroidery House',
      'category': 'Home & Decor',
      'marketId': 'market_pk_hussain',
      'imageUrl': '$_shopMediaBase/shop_pk_hussain_embroidery.jpg',
      'tags': ['embroidery', 'handicrafts', 'decor'],
    },
    {
      'id': 'shop_pk_hussain_crafts2',
      'name': 'Hussain Agahi Handicrafts',
      'category': 'Home & Decor',
      'marketId': 'market_pk_hussain',
      'imageUrl': '$_shopMediaBase/shop_pk_hussain_crafts2.jpg',
      'tags': ['handicrafts', 'decor', 'artisan'],
    },
    {
      'id': 'shop_pk_hussain_dryfruits',
      'name': 'Gurh Mandi Dry Fruits',
      'category': 'Food & Spices',
      'marketId': 'market_pk_hussain',
      'imageUrl': '$_shopMediaBase/shop_pk_hussain_dryfruits.jpg',
      'tags': ['dry fruits', 'food', 'spices'],
    },
    {
      'id': 'shop_pk_hussain_spices2',
      'name': 'Multan Spice Traders',
      'category': 'Food & Spices',
      'marketId': 'market_pk_hussain',
      'imageUrl': '$_shopMediaBase/shop_pk_hussain_spices2.jpg',
      'tags': ['spices', 'food', 'grocery'],
    },
    {
      'id': 'shop_pk_hussain_fabric',
      'name': 'Multani Fabric House',
      'category': 'Clothing',
      'marketId': 'market_pk_hussain',
      'imageUrl': '$_shopMediaBase/shop_pk_hussain_fabric.jpg',
      'tags': ['fabric', 'clothing', 'textile'],
    },
    {
      'id': 'shop_pk_hussain_fabric2',
      'name': 'Block Print Textiles',
      'category': 'Clothing',
      'marketId': 'market_pk_hussain',
      'imageUrl': '$_shopMediaBase/shop_pk_hussain_fabric2.jpg',
      'tags': ['textile', 'fabric', 'clothing'],
    },
    {
      'id': 'shop_pk_hussain_sweets2',
      'name': 'Multan Sweet Mart',
      'category': 'Food & Spices',
      'marketId': 'market_pk_hussain',
      'imageUrl': '$_shopMediaBase/shop_pk_hussain_sweets2.jpg',
      'tags': ['sweets', 'food', 'dessert'],
    },
    {
      'id': 'shop_pk_hussain_jewelry',
      'name': 'Agahi Jewelers',
      'category': 'Gems',
      'marketId': 'market_pk_hussain',
      'imageUrl': '$_shopMediaBase/shop_pk_hussain_jewelry.jpg',
      'tags': ['gems', 'jewelry', 'gold'],
    },
    {
      'id': 'shop_pk_hussain_shoes',
      'name': 'Multan Footwear',
      'category': 'Clothing',
      'marketId': 'market_pk_hussain',
      'imageUrl': '$_shopMediaBase/shop_pk_hussain_shoes.jpg',
      'tags': ['shoes', 'footwear', 'clothing'],
    },
    {
      'id': 'shop_pk_hussain_perfume',
      'name': 'Multan Ittar Gallery',
      'category': 'Fragrances',
      'marketId': 'market_pk_hussain',
      'imageUrl': '$_shopMediaBase/shop_pk_hussain_perfume.jpg',
      'tags': ['fragrance', 'ittar', 'perfume'],
    },
    {
      'id': 'shop_pk_hussain_lamps',
      'name': 'Multani Lamp House',
      'category': 'Home & Decor',
      'marketId': 'market_pk_hussain',
      'imageUrl': '$_shopMediaBase/shop_pk_hussain_lamps.jpg',
      'tags': ['decor', 'lamps', 'home'],
    },
    {
      'id': 'shop_ae_damas_gold',
      'name': 'Damas Gold Boutique',
      'category': 'Gems',
      'marketId': 'market_ae_gold_souk',
      'imageUrl':
          'https://images.unsplash.com/photo-1617038260897-41e9d3996f3c?w=800&q=80',
      'tags': ['gems', 'jewelry', 'gold', 'beauty'],
    },
    {
      'id': 'shop_ae_oud_house',
      'name': 'Arabian Oud House',
      'category': 'Fragrances',
      'marketId': 'market_ae_gold_souk',
      'imageUrl':
          'https://images.unsplash.com/photo-1541643600914-78b084683601?w=800&q=80',
      'tags': ['fragrance', 'perfume', 'oud', 'beauty'],
    },
    {
      'id': 'shop_ae_marina_style',
      'name': 'Marina Style',
      'category': 'Clothing',
      'marketId': 'market_ae_gold_souk',
      'imageUrl':
          'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800&q=80',
      'tags': ['fashion', 'clothing', 'modern', 'style'],
    },
    {
      'id': 'shop_qa_handicrafts',
      'name': 'Waqif Handicrafts',
      'category': 'Home & Decor',
      'marketId': 'market_qa_souq_waqif',
      'imageUrl':
          'https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=800&q=80',
      'tags': ['decor', 'furniture', 'handicrafts', 'home'],
    },
    {
      'id': 'shop_qa_spice_route',
      'name': 'Spice Route Stall',
      'category': 'Food & Spices',
      'marketId': 'market_qa_souq_waqif',
      'imageUrl':
          'https://images.unsplash.com/photo-1509440159596-0249088773ff?w=800&q=80',
      'tags': ['grocery', 'spices', 'food', 'market'],
    },
    {
      'id': 'shop_qa_doha_threads',
      'name': 'Doha Threads',
      'category': 'Clothing',
      'marketId': 'market_qa_souq_waqif',
      'imageUrl':
          'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=800&q=80',
      'tags': ['fashion', 'clothing', 'threads', 'tailor'],
    },
    {
      'id': 'shop_in_silk_weavers',
      'name': 'Silk Weavers Lane',
      'category': 'Clothing',
      'marketId': 'market_in_chandni',
      'imageUrl':
          'https://images.unsplash.com/photo-1520903923513-f990884e5771?w=800&q=80',
      'tags': ['fashion', 'clothing', 'silk', 'handwoven'],
    },
    {
      'id': 'shop_in_chandni_jewelers',
      'name': 'Chandni Jewelers',
      'category': 'Gems',
      'marketId': 'market_in_chandni',
      'imageUrl':
          'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=800&q=80',
      'tags': ['gems', 'jewelry', 'gold', 'diamonds'],
    },
    {
      'id': 'shop_in_tech_bazaar',
      'name': 'Tech Bazaar Corner',
      'category': 'Electronics',
      'marketId': 'market_in_chandni',
      'imageUrl':
          'https://images.unsplash.com/photo-1468495244123-6c6c332eeece?w=800&q=80',
      'tags': ['electronics', 'computer', 'gadgets', 'tech'],
    },
    {
      'id': 'shop_in_old_delhi_snacks',
      'name': 'Old Delhi Snacks',
      'category': 'Food & Spices',
      'marketId': 'market_in_chandni',
      'imageUrl':
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80',
      'tags': ['restaurant', 'cafe', 'snacks', 'food'],
    },
  ];
}
