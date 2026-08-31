import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tech_restock/data/models.dart';

/// Live catalog + client-side text search for products and shops.
class CatalogSearch {
  CatalogSearch._();

  static const scopeAll = 'Shops & products';
  static const scopeShops = 'Shops only';
  static const scopeProducts = 'Products only';

  static const scopeFilters = [scopeAll, scopeShops, scopeProducts];

  static Stream<CatalogSnapshot> catalogStream() {
    final controller = StreamController<CatalogSnapshot>();
    
    StreamSubscription? marketsSub;
    StreamSubscription? productsSub;
    StreamSubscription? shopsSub;

    var pakMarketIds = <String>{};
    var marketCityMap = <String, String>{};
    var allProducts = <ProductItem>[];
    var allShops = <ShopItem>[];

    void emit() {
      if (!controller.isClosed) {
        final products = allProducts.where((p) => p.country == 'Pakistan').toList()
          ..sort((a, b) => a.title.compareTo(b.title));
        
        final shops = allShops.where((s) => pakMarketIds.contains(s.marketId)).toList()
          ..sort((a, b) => a.name.compareTo(b.name));

        controller.add(
          CatalogSnapshot(
            products: List.unmodifiable(products),
            shops: List.unmodifiable(shops),
            marketCityMap: Map.unmodifiable(marketCityMap),
          ),
        );
      }
    }

    marketsSub = FirebaseFirestore.instance
        .collection('markets')
        .where('country', isEqualTo: 'Pakistan')
        .snapshots()
        .listen(
      (snapshot) {
        pakMarketIds = snapshot.docs.map((doc) => doc.id).toSet();
        marketCityMap = {
          for (final doc in snapshot.docs)
            doc.id: (doc.data()['city'] as String? ?? '')
        };
        emit();
      },
      onError: controller.addError,
    );

    productsSub = FirebaseFirestore.instance
        .collection('products')
        .where('country', isEqualTo: 'Pakistan')
        .snapshots()
        .listen(
      (snapshot) {
        allProducts = snapshot.docs
            .map((doc) => ProductItem.fromMap(doc.id, doc.data()))
            .toList();
        emit();
      },
      onError: controller.addError,
    );

    shopsSub = FirebaseFirestore.instance.collection('shops').snapshots().listen(
      (snapshot) {
        allShops = snapshot.docs
            .map((doc) => ShopItem.fromMap(doc.id, doc.data()))
            .toList();
        emit();
      },
      onError: controller.addError,
    );

    controller.onCancel = () async {
      await marketsSub?.cancel();
      await productsSub?.cancel();
      await shopsSub?.cancel();
    };

    return controller.stream;
  }

  static List<ProductItem> filterProducts(List<ProductItem> catalog, String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) {
      return const [];
    }

    return catalog
        .where(
          (product) =>
              _contains(product.title, needle) ||
              _contains(product.shopName, needle) ||
              _contains(product.priceLabel, needle) ||
              _contains(product.country, needle) ||
              _contains(product.badge, needle),
        )
        .toList();
  }

  static List<ShopItem> filterShops(List<ShopItem> catalog, String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return const [];
    }

    final cleanQuery = trimmed.startsWith('#') ? trimmed.substring(1) : trimmed;
    if (cleanQuery.isEmpty) {
      return const [];
    }

    return catalog
        .where(
          (shop) =>
              _contains(shop.name, cleanQuery) ||
              _contains(shop.category, cleanQuery) ||
              shop.tags.any((tag) =>
                  tag.toLowerCase().contains(cleanQuery) ||
                  cleanQuery.contains(tag.toLowerCase())),
        )
        .toList();
  }

  static bool _contains(String? value, String needle) {
    if (value == null || value.isEmpty) {
      return false;
    }
    return value.toLowerCase().contains(needle);
  }
}

class CatalogSnapshot {
  const CatalogSnapshot({
    required this.products,
    required this.shops,
    required this.marketCityMap,
  });

  final List<ProductItem> products;
  final List<ShopItem> shops;
  final Map<String, String> marketCityMap;

  int get productCount => products.length;
  int get shopCount => shops.length;
}

class SearchResults {
  const SearchResults({
    required this.products,
    required this.shops,
  });

  final List<ProductItem> products;
  final List<ShopItem> shops;

  bool get isEmpty => products.isEmpty && shops.isEmpty;
  int get totalCount => products.length + shops.length;
}

SearchResults resolveSearchResults({
  required CatalogSnapshot catalog,
  required String query,
  required String scope,
}) {
  final products = scope == CatalogSearch.scopeShops
      ? const <ProductItem>[]
      : CatalogSearch.filterProducts(catalog.products, query);
  final shops = scope == CatalogSearch.scopeProducts
      ? const <ShopItem>[]
      : CatalogSearch.filterShops(catalog.shops, query);

  return SearchResults(products: products, shops: shops);
}
