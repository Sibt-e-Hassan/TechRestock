import 'package:shop_pandaa/data/models.dart';

/// Curated display manifest: generic product titles + verified image URLs.
/// Keeps Firestore prices/MOQ unchanged; overrides names and images at load time.
/// Sync with tools/seed_catalog.js when adding products.
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

  static const _manifest = <String, CatalogProductDisplay>{
    // Dairy — milk carton, butter, powdered creamer
    'prod_dairy_olpers_milk': CatalogProductDisplay(
      title: 'Full cream milk 1L — carton of 12',
      brand: 'Dairy',
      imageUrl:
          'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=800&q=80',
    ),
    'prod_dairy_nurpur_butter': CatalogProductDisplay(
      title: 'Butter 200g — pack of 24',
      brand: 'Dairy',
      imageUrl:
          'https://images.unsplash.com/photo-1551782450-17144efb9c50?w=800&q=80',
    ),
    'prod_dairy_adams_creamer': CatalogProductDisplay(
      title: 'Powdered tea whitener 400g — pack of 24',
      brand: 'Dairy',
      imageUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
    ),
    // Confectionery
    'prod_conf_candyland': CatalogProductDisplay(
      title: 'Assorted toffees — 1kg jar',
      brand: 'Confectionery',
      imageUrl:
          'https://images.unsplash.com/photo-1548907040-4baa42d10919?w=800&q=80',
    ),
    'prod_conf_bisconni': CatalogProductDisplay(
      title: 'Chocolate chip cookies — carton of 24',
      brand: 'Confectionery',
      imageUrl:
          'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=800&q=80',
    ),
    'prod_conf_mayfair': CatalogProductDisplay(
      title: 'Chocolate éclairs — 900g pouch',
      brand: 'Confectionery',
      imageUrl:
          'https://images.unsplash.com/photo-1551024506-0bccd828d307?w=800&q=80',
    ),
    // Soaps — bar soap
    'prod_soap_lifebuoy': CatalogProductDisplay(
      title: 'Antibacterial bar soap 130g — carton of 48',
      brand: 'Soap',
      imageUrl:
          'https://images.unsplash.com/photo-1584305574647-0cc949a2bb9f?w=800&q=80',
    ),
    'prod_soap_safeguard': CatalogProductDisplay(
      title: 'White bar soap 135g — carton of 48',
      brand: 'Soap',
      imageUrl:
          'https://images.unsplash.com/photo-1615529328331-f8917597711f?w=800&q=80',
    ),
    'prod_soap_lux': CatalogProductDisplay(
      title: 'Moisturizing bar soap 128g — carton of 48',
      brand: 'Soap',
      imageUrl:
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80',
    ),
    // Shampoos
    'prod_sham_sunsilk': CatalogProductDisplay(
      title: 'Shampoo sachets 8ml — box of 72',
      brand: 'Shampoo',
      imageUrl:
          'https://images.unsplash.com/photo-1631729371254-42c2892f0e6e?w=800&q=80',
    ),
    'prod_sham_headshoulders': CatalogProductDisplay(
      title: 'Anti-dandruff shampoo 185ml — pack of 12',
      brand: 'Shampoo',
      imageUrl:
          'https://images.pexels.com/photos/4113808/pexels-photo-4113808.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    'prod_sham_clear': CatalogProductDisplay(
      title: 'Menthol shampoo 185ml — pack of 12',
      brand: 'Shampoo',
      imageUrl:
          'https://images.pexels.com/photos/4113809/pexels-photo-4113809.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    // Sauces
    'prod_sauce_shangrila': CatalogProductDisplay(
      title: 'Tomato ketchup 800g — pack of 12',
      brand: 'Sauce',
      imageUrl:
          'https://images.pexels.com/photos/4113810/pexels-photo-4113810.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    'prod_sauce_national': CatalogProductDisplay(
      title: 'Chilli garlic sauce 775g — pack of 12',
      brand: 'Sauce',
      imageUrl:
          'https://images.pexels.com/photos/4198831/pexels-photo-4198831.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    'prod_sauce_mitchells': CatalogProductDisplay(
      title: 'Soya sauce 300ml — pack of 24',
      brand: 'Sauce',
      imageUrl:
          'https://images.pexels.com/photos/4198832/pexels-photo-4198832.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    // Flour
    'prod_flour_sunridge': CatalogProductDisplay(
      title: 'Wheat flour (atta) 10kg bag',
      brand: 'Flour',
      imageUrl:
          'https://images.pexels.com/photos/404059/pexels-photo-404059.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    'prod_flour_bakeparlor': CatalogProductDisplay(
      title: 'Refined flour (maida) 5kg bag',
      brand: 'Flour',
      imageUrl:
          'https://images.pexels.com/photos/404060/pexels-photo-404060.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    // Sugar
    'prod_sugar_alarabia': CatalogProductDisplay(
      title: 'Refined white sugar 50kg bori',
      brand: 'Sugar',
      imageUrl:
          'https://images.pexels.com/photos/4110257/pexels-photo-4110257.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    'prod_sugar_brown': CatalogProductDisplay(
      title: 'Brown sugar 25kg bag',
      brand: 'Sugar',
      imageUrl:
          'https://images.pexels.com/photos/4109943/pexels-photo-4109943.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    // Pulses
    'prod_pulse_masoor': CatalogProductDisplay(
      title: 'Red lentils (masoor) 25kg bag',
      brand: 'Pulses',
      imageUrl:
          'https://images.pexels.com/photos/4198019/pexels-photo-4198019.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    'prod_pulse_chana': CatalogProductDisplay(
      title: 'Split chickpeas (chana daal) 25kg bag',
      brand: 'Pulses',
      imageUrl:
          'https://images.pexels.com/photos/4110541/pexels-photo-4110541.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    // Rice
    'prod_rice_guard': CatalogProductDisplay(
      title: 'Basmati rice 40kg bag',
      brand: 'Rice',
      imageUrl:
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=800&q=80',
    ),
    'prod_rice_falak': CatalogProductDisplay(
      title: 'Sella basmati rice 40kg bag',
      brand: 'Rice',
      imageUrl:
          'https://images.pexels.com/photos/4198099/pexels-photo-4198099.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    // Pasta
    'prod_pasta_bakeparlor': CatalogProductDisplay(
      title: 'Macaroni pasta 400g — carton of 24',
      brand: 'Pasta',
      imageUrl:
          'https://images.unsplash.com/photo-1551462147-ff29053bfc14?w=800&q=80',
    ),
    'prod_pasta_italiano': CatalogProductDisplay(
      title: 'Spaghetti pasta 500g — carton of 20',
      brand: 'Pasta',
      imageUrl:
          'https://images.pexels.com/photos/2983101/pexels-photo-2983101.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    // Noodles
    'prod_noodle_knorr': CatalogProductDisplay(
      title: 'Chicken instant noodles 66g — carton of 24',
      brand: 'Noodles',
      imageUrl:
          'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=800&q=80',
    ),
    'prod_noodle_maggi': CatalogProductDisplay(
      title: 'Masala instant noodles 68g — carton of 24',
      brand: 'Noodles',
      imageUrl:
          'https://images.pexels.com/photos/2983099/pexels-photo-2983099.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    'prod_noodle_shoop': CatalogProductDisplay(
      title: 'Chicken instant noodles 65g — carton of 24',
      brand: 'Noodles',
      imageUrl:
          'https://images.pexels.com/photos/2983100/pexels-photo-2983100.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    // Cooking oil
    'prod_oil_dalda': CatalogProductDisplay(
      title: 'Cooking oil 5L — carton of 4',
      brand: 'Cooking Oil',
      imageUrl:
          'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=800&q=80',
    ),
    'prod_oil_sufi': CatalogProductDisplay(
      title: 'Vegetable cooking oil 5L — carton of 4',
      brand: 'Cooking Oil',
      imageUrl:
          'https://images.pexels.com/photos/3730760/pexels-photo-3730760.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    'prod_oil_habib': CatalogProductDisplay(
      title: 'Clarified butter (ghee) 5kg — carton of 4',
      brand: 'Cooking Oil',
      imageUrl:
          'https://images.pexels.com/photos/3737631/pexels-photo-3737631.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    // Tea and coffee
    'prod_tea_tapal': CatalogProductDisplay(
      title: 'Loose leaf black tea 900g — carton of 12',
      brand: 'Tea',
      imageUrl:
          'https://images.unsplash.com/photo-1594631252845-29fc4cc8cde9?w=800&q=80',
    ),
    'prod_tea_lipton': CatalogProductDisplay(
      title: 'Black tea bags 950g — carton of 12',
      brand: 'Tea',
      imageUrl:
          'https://images.pexels.com/photos/143133/pexels-photo-143133.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    'prod_tea_nescafe': CatalogProductDisplay(
      title: 'Instant coffee 200g — pack of 12',
      brand: 'Coffee',
      imageUrl:
          'https://images.pexels.com/photos/143134/pexels-photo-143134.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    // Beverages
    'prod_bev_pakola': CatalogProductDisplay(
      title: 'Cream soda 1.5L — pack of 6',
      brand: 'Beverages',
      imageUrl:
          'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=800&q=80',
    ),
    'prod_bev_gourmet': CatalogProductDisplay(
      title: 'Cola drink 2.25L — pack of 6',
      brand: 'Beverages',
      imageUrl:
          'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800&q=80',
    ),
    // Snacks
    'prod_snack_lays': CatalogProductDisplay(
      title: 'Masala potato chips 32g — carton of 60',
      brand: 'Snacks',
      imageUrl:
          'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=800&q=80',
    ),
    'prod_snack_kurkure': CatalogProductDisplay(
      title: 'Spicy corn snacks 38g — carton of 60',
      brand: 'Snacks',
      imageUrl:
          'https://images.pexels.com/photos/264636/pexels-photo-264636.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    'prod_snack_supercrisp': CatalogProductDisplay(
      title: 'Crispy snack sticks 28g — carton of 60',
      brand: 'Snacks',
      imageUrl:
          'https://images.pexels.com/photos/280453/pexels-photo-280453.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    // Spices
    'prod_spice_national': CatalogProductDisplay(
      title: 'Chaat masala 800g — pack of 12',
      brand: 'Spices',
      imageUrl:
          'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&q=80',
    ),
    'prod_spice_shan': CatalogProductDisplay(
      title: 'Biryani spice mix 50g — box of 144',
      brand: 'Spices',
      imageUrl:
          'https://images.pexels.com/photos/5632401/pexels-photo-5632401.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    'prod_spice_mehran': CatalogProductDisplay(
      title: 'Turmeric powder 400g — pack of 24',
      brand: 'Spices',
      imageUrl:
          'https://images.pexels.com/photos/5632402/pexels-photo-5632402.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    // Cleaning
    'prod_clean_surf': CatalogProductDisplay(
      title: 'Washing powder 1kg — carton of 9',
      brand: 'Cleaning',
      imageUrl:
          'https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=800&q=80',
    ),
    'prod_clean_bonus': CatalogProductDisplay(
      title: 'Laundry detergent 1kg — carton of 9',
      brand: 'Cleaning',
      imageUrl:
          'https://images.pexels.com/photos/5632403/pexels-photo-5632403.jpeg?auto=compress&cs=tinysrgb&w=800',
    ),
    'prod_clean_vim': CatalogProductDisplay(
      title: 'Dishwashing bar 200g — carton of 48',
      brand: 'Cleaning',
      imageUrl:
          'https://images.pexels.com/photos/5632404/pexels-photo-5632404.jpeg?auto=compress&cs=tinysrgb&w=800',
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
