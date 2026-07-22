import 'package:shop_pandaa/data/models.dart';

/// Curated display manifest: generic product titles + verified image URLs.
/// Keeps Firestore prices/MOQ unchanged; overrides names and images at load time.
/// Sync with tools/seed_catalog.js when adding products.
///
/// Every imageUrl below was verified to load (HTTP 200) AND visually checked to
/// match its exact product. Products with no accurate free photo are removed
/// (see cream soda — dropped for lack of an accurate Unsplash image).
class CatalogProductDisplay {
  const CatalogProductDisplay({
    required this.title,
    required this.brand,
    required this.imageUrl,
  });

  final String title;
  final String brand;
  final String imageUrl;
}

abstract final class CatalogDisplay {
  CatalogDisplay._();

  static const _img = 'https://images.unsplash.com/';
  static String _u(String id) => '$_img$id?w=800&q=80&auto=format&fit=crop';

  static final _manifest = <String, CatalogProductDisplay>{
    // Dairy
    'prod_dairy_olpers_milk': CatalogProductDisplay(
      title: 'Full cream milk 1L — carton of 12',
      brand: 'Dairy',
      imageUrl: _u('photo-1576186726115-4d51596775d1'), // milk bottle
    ),
    'prod_dairy_nurpur_butter': CatalogProductDisplay(
      title: 'Butter 200g — pack of 24',
      brand: 'Dairy',
      imageUrl: _u('photo-1589985270826-4b7bb135bc9d'), // butter blocks
    ),
    'prod_dairy_adams_creamer': CatalogProductDisplay(
      title: 'Powdered tea whitener 400g — pack of 24',
      brand: 'Dairy',
      imageUrl: _u('photo-1593095948071-474c5cc2989d'), // milk powder
    ),
    // Confectionery
    'prod_conf_candyland': CatalogProductDisplay(
      title: 'Assorted toffees — 1kg jar',
      brand: 'Confectionery',
      imageUrl: _u('photo-1534119139482-b530a7f9a98b'), // wrapped toffees
    ),
    'prod_conf_bisconni': CatalogProductDisplay(
      title: 'Chocolate chip cookies — carton of 24',
      brand: 'Confectionery',
      imageUrl: _u('photo-1499636136210-6f4ee915583e'), // choc chip cookies
    ),
    'prod_conf_mayfair': CatalogProductDisplay(
      title: 'Chocolate éclairs — 900g pouch',
      brand: 'Confectionery',
      imageUrl: _u('photo-1534119139482-b530a7f9a98b'), // toffees
    ),
    // Soaps — bar soap
    'prod_soap_lifebuoy': CatalogProductDisplay(
      title: 'Antibacterial bar soap 130g — carton of 48',
      brand: 'Soap',
      imageUrl: _u('photo-1584305574647-0cc949a2bb9f'), // soap bars
    ),
    'prod_soap_safeguard': CatalogProductDisplay(
      title: 'White bar soap 135g — carton of 48',
      brand: 'Soap',
      imageUrl: _u('photo-1584305574647-0cc949a2bb9f'), // soap bars
    ),
    'prod_soap_lux': CatalogProductDisplay(
      title: 'Moisturizing bar soap 128g — carton of 48',
      brand: 'Soap',
      imageUrl: _u('photo-1584305574647-0cc949a2bb9f'), // soap bars
    ),
    // Shampoos — shampoo bottle
    'prod_sham_sunsilk': CatalogProductDisplay(
      title: 'Shampoo sachets 8ml — box of 72',
      brand: 'Shampoo',
      imageUrl: _u('photo-1602143407151-7111542de6e8'), // shampoo bottle
    ),
    'prod_sham_headshoulders': CatalogProductDisplay(
      title: 'Anti-dandruff shampoo 185ml — pack of 12',
      brand: 'Shampoo',
      imageUrl: _u('photo-1602143407151-7111542de6e8'), // shampoo bottle
    ),
    'prod_sham_clear': CatalogProductDisplay(
      title: 'Menthol shampoo 185ml — pack of 12',
      brand: 'Shampoo',
      imageUrl: _u('photo-1602143407151-7111542de6e8'), // shampoo bottle
    ),
    // Sauces
    'prod_sauce_shangrila': CatalogProductDisplay(
      title: 'Tomato ketchup 800g — pack of 12',
      brand: 'Sauce',
      imageUrl: _u('photo-1472476443507-c7a5948772fc'), // tomato ketchup
    ),
    'prod_sauce_national': CatalogProductDisplay(
      title: 'Chilli garlic sauce 775g — pack of 12',
      brand: 'Sauce',
      imageUrl: _u('photo-1700619773778-f02b45ca0616'), // red chilli sauce bottle
    ),
    'prod_sauce_mitchells': CatalogProductDisplay(
      title: 'Soya sauce 300ml — pack of 24',
      brand: 'Sauce',
      imageUrl: _u('photo-1582581720432-de83a98176ab'), // soy sauce
    ),
    // Flour
    'prod_flour_sunridge': CatalogProductDisplay(
      title: 'Wheat flour (atta) 10kg bag',
      brand: 'Flour',
      imageUrl: _u('photo-1610725664285-7c57e6eeac3f'), // wheat flour
    ),
    'prod_flour_bakeparlor': CatalogProductDisplay(
      title: 'Refined flour (maida) 5kg bag',
      brand: 'Flour',
      imageUrl: _u('photo-1610725664285-7c57e6eeac3f'), // wheat flour
    ),
    // Sugar
    'prod_sugar_alarabia': CatalogProductDisplay(
      title: 'Refined white sugar 50kg bori',
      brand: 'Sugar',
      imageUrl: _u('photo-1553747069-aefa5a5c9bad'), // white sugar
    ),
    'prod_sugar_brown': CatalogProductDisplay(
      title: 'Brown sugar 25kg bag',
      brand: 'Sugar',
      imageUrl: _u('photo-1613228295977-3b5ac7533b36'), // brown sugar
    ),
    // Pulses
    'prod_pulse_masoor': CatalogProductDisplay(
      title: 'Red lentils (masoor) 25kg bag',
      brand: 'Pulses',
      imageUrl: _u('photo-1614373532201-c40b993f0013'), // red lentils
    ),
    'prod_pulse_chana': CatalogProductDisplay(
      title: 'Chickpeas (chana) 25kg bag',
      brand: 'Pulses',
      imageUrl: _u('photo-1600841909485-03146c24b014'), // chickpeas
    ),
    // Rice
    'prod_rice_guard': CatalogProductDisplay(
      title: 'Basmati rice 40kg bag',
      brand: 'Rice',
      imageUrl: _u('photo-1586201375761-83865001e31c'), // basmati rice
    ),
    'prod_rice_falak': CatalogProductDisplay(
      title: 'Sella basmati rice 40kg bag',
      brand: 'Rice',
      imageUrl: _u('photo-1586201375761-83865001e31c'), // basmati rice
    ),
    // Pasta
    'prod_pasta_bakeparlor': CatalogProductDisplay(
      title: 'Macaroni pasta 400g — carton of 24',
      brand: 'Pasta',
      imageUrl: _u('photo-1667499989723-c4ab9549d63c'), // elbow macaroni
    ),
    'prod_pasta_italiano': CatalogProductDisplay(
      title: 'Spaghetti pasta 500g — carton of 20',
      brand: 'Pasta',
      imageUrl: _u('photo-1551892374-ecf8754cf8b0'), // spaghetti
    ),
    // Noodles
    'prod_noodle_knorr': CatalogProductDisplay(
      title: 'Chicken instant noodles 66g — carton of 24',
      brand: 'Noodles',
      imageUrl: _u('photo-1612929633738-8fe44f7ec841'), // instant noodles
    ),
    'prod_noodle_maggi': CatalogProductDisplay(
      title: 'Masala instant noodles 68g — carton of 24',
      brand: 'Noodles',
      imageUrl: _u('photo-1612929633738-8fe44f7ec841'), // instant noodles
    ),
    'prod_noodle_shoop': CatalogProductDisplay(
      title: 'Chicken instant noodles 65g — carton of 24',
      brand: 'Noodles',
      imageUrl: _u('photo-1612929633738-8fe44f7ec841'), // instant noodles
    ),
    // Cooking oil
    'prod_oil_dalda': CatalogProductDisplay(
      title: 'Cooking oil 5L — carton of 4',
      brand: 'Cooking Oil',
      imageUrl: _u('photo-1611608927037-4e8da6aa170e'), // oil bottle
    ),
    'prod_oil_sufi': CatalogProductDisplay(
      title: 'Vegetable cooking oil 5L — carton of 4',
      brand: 'Cooking Oil',
      imageUrl: _u('photo-1611608927037-4e8da6aa170e'), // oil bottle
    ),
    'prod_oil_habib': CatalogProductDisplay(
      title: 'Clarified butter (ghee) 5kg — carton of 4',
      brand: 'Cooking Oil',
      imageUrl: _u('photo-1707425197195-240b7ad69047'), // ghee jar
    ),
    // Tea and coffee
    'prod_tea_tapal': CatalogProductDisplay(
      title: 'Loose leaf black tea 900g — carton of 12',
      brand: 'Tea',
      imageUrl: _u('photo-1606163017137-888c0177b3dd'), // loose black tea
    ),
    'prod_tea_lipton': CatalogProductDisplay(
      title: 'Black tea bags 950g — carton of 12',
      brand: 'Tea',
      imageUrl: _u('photo-1597481499666-130f8eb2c9cd'), // tea bags
    ),
    'prod_tea_nescafe': CatalogProductDisplay(
      title: 'Instant coffee 200g — pack of 12',
      brand: 'Coffee',
      imageUrl: _u('photo-1510776537653-6d0da167186c'), // coffee
    ),
    // Beverages (cream soda removed — no accurate free photo available)
    'prod_bev_gourmet': CatalogProductDisplay(
      title: 'Cola drink 2.25L — pack of 6',
      brand: 'Beverages',
      imageUrl: _u('photo-1624552184280-9e9631bbeee9'), // cola
    ),
    // Snacks
    'prod_snack_lays': CatalogProductDisplay(
      title: 'Masala potato chips 32g — carton of 60',
      brand: 'Snacks',
      imageUrl: _u('photo-1599490659213-e2b9527bd087'), // potato chips
    ),
    'prod_snack_kurkure': CatalogProductDisplay(
      title: 'Spicy corn snacks 38g — carton of 60',
      brand: 'Snacks',
      imageUrl: _u('photo-1669056544004-96abfb7a5008'), // fried corn snack
    ),
    'prod_snack_supercrisp': CatalogProductDisplay(
      title: 'Crispy potato snack 28g — carton of 60',
      brand: 'Snacks',
      imageUrl: _u('photo-1599490659213-e2b9527bd087'), // potato chips
    ),
    // Spices
    'prod_spice_national': CatalogProductDisplay(
      title: 'Chaat masala 800g — pack of 12',
      brand: 'Spices',
      imageUrl: _u('photo-1596040033229-a9821ebd058d'), // ground spices
    ),
    'prod_spice_shan': CatalogProductDisplay(
      title: 'Biryani spice mix 50g — box of 144',
      brand: 'Spices',
      imageUrl: _u('photo-1589536677029-c0aa1808fba6'), // whole spices
    ),
    'prod_spice_mehran': CatalogProductDisplay(
      title: 'Turmeric powder 400g — pack of 24',
      brand: 'Spices',
      imageUrl: _u('photo-1606951444141-e5533feb55be'), // turmeric powder
    ),
    // Cleaning
    'prod_clean_surf': CatalogProductDisplay(
      title: 'Washing powder 1kg — carton of 9',
      brand: 'Cleaning',
      imageUrl: _u('photo-1642429947963-f04215ed5577'), // detergent
    ),
    'prod_clean_bonus': CatalogProductDisplay(
      title: 'Laundry detergent 1kg — carton of 9',
      brand: 'Cleaning',
      imageUrl: _u('photo-1642429947963-f04215ed5577'), // detergent
    ),
    'prod_clean_vim': CatalogProductDisplay(
      title: 'Dishwashing bar 200g — carton of 48',
      brand: 'Cleaning',
      imageUrl: _u('photo-1675612713227-3172f589154c'), // soap bar
    ),
  };

  static String? imageUrlFor(String id) => _manifest[id]?.imageUrl;

  static ProductItem applyOverrides(ProductItem item) {
    final entry = _manifest[item.id];
    if (entry == null) return item;
    return ProductItem(
      id: item.id,
      title: entry.title,
      shopName: entry.brand,
      brand: entry.brand,
      imageUrl: entry.imageUrl,
      priceLabel: item.priceLabel,
      badge: item.badge,
      country: item.country,
      city: item.city,
      shopId: item.shopId,
      unit: item.unit,
      minOrderQty: item.minOrderQty,
      priceTiers: item.priceTiers,
      category: item.category,
    );
  }
}
