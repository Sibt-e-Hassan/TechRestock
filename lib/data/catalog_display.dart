import 'package:tech_restock/data/models.dart';

/// Curated display manifest: TechRestock wholesale product titles & image URLs.
/// Keeps Firestore prices/MOQ unchanged; overrides names and images at load time.
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
    // Chargers & Power
    'prod_charger_gan65w': CatalogProductDisplay(
      title: 'GaN 65W Dual Port Fast Charger — Carton of 20',
      brand: 'VoltPro',
      imageUrl: _u('photo-1583863788434-e58a36330cf0'), // wall charger
    ),
    'prod_charger_20w_wall': CatalogProductDisplay(
      title: '20W PD Type-C Power Adapter — Box of 50',
      brand: 'AnkerTech',
      imageUrl: _u('photo-1583863788434-e58a36330cf0'),
    ),
    'prod_charger_car_fast': CatalogProductDisplay(
      title: 'Dual Metal 45W Car Charger — Pack of 30',
      brand: 'DriveGear',
      imageUrl: _u('photo-1541899481282-d53bffe3c35d'),
    ),

    // Cables & Adapters
    'prod_cable_typec_100w': CatalogProductDisplay(
      title: 'Braided Type-C to Type-C 100W Cable (1.2m) — Box of 50',
      brand: 'VoltPro',
      imageUrl: _u('photo-1544716278-ca5e3f4abd8c'), // cable wires
    ),
    'prod_cable_mfi_lightning': CatalogProductDisplay(
      title: 'MFi Certified USB to Lightning Cable (1m) — Box of 50',
      brand: 'AppleSync',
      imageUrl: _u('photo-1544716278-ca5e3f4abd8c'),
    ),
    'prod_adapter_otg_usb3': CatalogProductDisplay(
      title: 'Aluminum USB-A to Type-C OTG Adapters — Pack of 100',
      brand: 'LinkTech',
      imageUrl: _u('photo-1544716278-ca5e3f4abd8c'),
    ),

    // Cases & Covers
    'prod_case_silicone_clear': CatalogProductDisplay(
      title: 'Transparent Anti-Yellowing TPU Phone Cases — Lot of 100',
      brand: 'ShieldCraft',
      imageUrl: _u('photo-1601784551446-20c9e07cdbdb'), // phone case
    ),
    'prod_case_magsafe_armor': CatalogProductDisplay(
      title: 'Magnetic Armor Kickstand Phone Case — Box of 30',
      brand: 'ShieldCraft',
      imageUrl: _u('photo-1601784551446-20c9e07cdbdb'),
    ),

    // Screen Glass
    'prod_screen_9h_glass': CatalogProductDisplay(
      title: '9H Full Glue Tempered Glass Screen Protectors — Lot of 100',
      brand: 'GlassGuard',
      imageUrl: _u('photo-1511707171634-5f897ff02aa9'), // phone screen
    ),
    'prod_screen_privacy_glass': CatalogProductDisplay(
      title: 'Anti-Spy Privacy Tempered Glass — Pack of 50',
      brand: 'GlassGuard',
      imageUrl: _u('photo-1511707171634-5f897ff02aa9'),
    ),

    // Audio & Earbuds
    'prod_audio_tws_pro': CatalogProductDisplay(
      title: 'True Wireless Stereo Earbuds with ANC — Carton of 20',
      brand: 'SoundWave',
      imageUrl: _u('photo-1590658268037-6bf12165a8df'), // wireless earbuds
    ),
    'prod_audio_bt_neckband': CatalogProductDisplay(
      title: 'Magnetic Sports Bluetooth Neckband 30hr — Inner Box of 25',
      brand: 'SoundWave',
      imageUrl: _u('photo-1505740420928-5e560c06d30e'), // headphones
    ),

    // Power Banks
    'prod_power_20000mah': CatalogProductDisplay(
      title: '20000mAh 22.5W Fast Charge Power Bank — Carton of 12',
      brand: 'VoltPro',
      imageUrl: _u('photo-1609592424074-87856d305d21'), // power bank
    ),
    'prod_power_10000mah_slim': CatalogProductDisplay(
      title: '10000mAh Slim Pocket Power Bank — Carton of 20',
      brand: 'VoltPro',
      imageUrl: _u('photo-1609592424074-87856d305d21'),
    ),

    // Repair Parts
    'prod_repair_toolkit': CatalogProductDisplay(
      title: '64-in-1 Precision Magnetic Screwdriver Repair Kit — Set of 10',
      brand: 'FixMaster',
      imageUrl: _u('photo-1581092160607-ee22621dd758'), // tools
    ),
    'prod_repair_mat_silicone': CatalogProductDisplay(
      title: 'Heat Resistant Silicone Repair Work Mat — Box of 15',
      brand: 'FixMaster',
      imageUrl: _u('photo-1581092160607-ee22621dd758'),
    ),

    // Smart Gadgets
    'prod_smart_watch_ultra': CatalogProductDisplay(
      title: 'Bluetooth Calling Smartwatch HD Display — Box of 15',
      brand: 'GearPro',
      imageUrl: _u('photo-1523275335684-37898b6baf30'), // smartwatch
    ),
    'prod_smart_fitness_band': CatalogProductDisplay(
      title: 'OLED Fitness Tracker Band — Inner Box of 25',
      brand: 'GearPro',
      imageUrl: _u('photo-1523275335684-37898b6baf30'),
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

