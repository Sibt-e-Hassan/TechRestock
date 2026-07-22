/**
 * One-off catalog seeder for BazaarConnect (Firestore Admin SDK).
 *
 * Writes sample markets / shops / products to the NEW Firebase project,
 * bypassing security rules (Admin SDK has full access). Mirrors the data in
 * lib/utils/firestore_seed.dart. Uses fixed doc ids, so it is safe to re-run.
 *
 * Usage:
 *   1. Firebase Console (bazaar-connect-c4487) -> Project settings ->
 *      Service accounts -> "Generate new private key". Save the file as
 *      tools/service-account.json  (already git-ignored).
 *   2. From the project root:
 *        cd tools
 *        npm install firebase-admin
 *        node seed_catalog.js
 */

const { initializeApp, cert } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const path = require("path");

const serviceAccount = require(path.join(__dirname, "service-account.json"));

initializeApp({ credential: cert(serviceAccount) });
const db = getFirestore();
const now = FieldValue.serverTimestamp();

const MARKET_MEDIA = "https://bazaar-connect-c4487.web.app/media/markets";
const SHOP_MEDIA = "https://bazaar-connect-c4487.web.app/media/shops";

const markets = [
  { id: "market_pk_saddar", name: "Saddar Market", title: "Saddar Market", shopName: "Karachi Bazaar Collective", location: "Karachi, Pakistan", shopCount: 12, country: "Pakistan", city: "Karachi", badge: "Popular", imageUrl: `${MARKET_MEDIA}/saddar.jpg` },
  { id: "market_pk_anarkali", name: "Anarkali Bazaar", title: "Anarkali Bazaar", shopName: "Lahore Heritage Bazar", location: "Lahore, Pakistan", shopCount: 12, country: "Pakistan", city: "Lahore", badge: "Popular", imageUrl: `${MARKET_MEDIA}/anarkali.jpg` },
  { id: "market_pk_centaurus", name: "Centaurus Mall", title: "Centaurus Mall", shopName: "Islamabad Premium Plaza", location: "Islamabad, Pakistan", shopCount: 12, country: "Pakistan", city: "Islamabad", badge: "Trending", imageUrl: `${MARKET_MEDIA}/centaurus.jpg` },
  { id: "market_pk_hussain", name: "Husain Agahi Bazaar", title: "Husain Agahi Bazaar", shopName: "Multan Souk Collective", location: "Multan, Pakistan", shopCount: 12, country: "Pakistan", city: "Multan", badge: "Local Pick", imageUrl: `${MARKET_MEDIA}/hussain.jpg` },
  { id: "market_ae_gold_souk", name: "Gold Souk · Deira", title: "Gold Souk · Deira", shopName: "Dubai Souk Traders", location: "Dubai, United Arab Emirates", shopCount: 124, country: "United Arab Emirates", city: "Dubai", badge: "Trending", imageUrl: "https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=800&q=80" },
  { id: "market_qa_souq_waqif", name: "Souq Waqif", title: "Souq Waqif", shopName: "Doha Heritage Shops", location: "Doha, Qatar", shopCount: 56, country: "Qatar", city: "Doha", badge: "Popular", imageUrl: "https://images.unsplash.com/photo-1586724378053-2e8f3c1e2f8a?w=800&q=80" },
  { id: "market_in_chandni", name: "Chandni Chowk", title: "Chandni Chowk", shopName: "Old Delhi Textile Lane", location: "New Delhi, India", shopCount: 210, country: "India", city: "New Delhi", badge: "Trending", imageUrl: "https://images.unsplash.com/photo-1587970551846-0311a2e0f3e0?w=800&q=80" },
];

// ThokBazaar B2B catalog — wholesale FMCG stock a dukaan reorders. Each
// product carries `category` (must match lib/data/categories.dart), `brand`,
// `unit`, `minOrderQty`, optional `priceTiers` (bulk breaks), and an optional
// `badge` (shows in the Offers tab). `shopName` mirrors `brand` for the legacy
// display fallback.
// Product images and display names: lib/data/catalog_display.dart (_manifest).
const IMG = {
  dairy: "https://images.unsplash.com/photo-1550583724-b2692b85b150?w=800&q=80",
  confection: "https://images.unsplash.com/photo-1548907040-4baa42d10919?w=800&q=80",
  soap: "https://images.unsplash.com/photo-1584305574647-0cc949a2bb9f?w=800&q=80",
  shampoo: "https://images.unsplash.com/photo-1631729371254-42c2892f0e6e?w=800&q=80",
  sauce: "https://images.unsplash.com/photo-1607198179219-3a5c4a1a9b25?w=800&q=80",
  flour: "https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&q=80",
  sugar: "https://images.unsplash.com/photo-1610137764727-1c9b1a3b6b26?w=800&q=80",
  pulses: "https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=800&q=80",
  rice: "https://images.unsplash.com/photo-1586201375761-83865001e31c?w=800&q=80",
  pasta: "https://images.unsplash.com/photo-1551462147-ff29053bfc14?w=800&q=80",
  noodles: "https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=800&q=80",
  oil: "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=800&q=80",
  tea: "https://images.unsplash.com/photo-1594631252845-29fc4cc8cde9?w=800&q=80",
  beverage: "https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=800&q=80",
  snack: "https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=800&q=80",
  spice: "https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=800&q=80",
  cleaning: "https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=800&q=80",
};

// Helper keeps entries short. tiers is optional.
function wp(id, category, brand, title, price, unit, moq, image, badge = null, tiers = null) {
  const p = { id, category, brand, shopName: brand, title, priceLabel: price, unit, minOrderQty: moq, imageUrl: image };
  if (badge) p.badge = badge;
  if (tiers) p.priceTiers = tiers;
  return p;
}

const products = [
  // --- Dairy Products ---
  wp("prod_dairy_olpers_milk", "Dairy Products", "Dairy", "Full cream milk 1L — carton of 12", "Rs 2,760", "carton", 5, IMG.dairy, "Bulk",
     [ { minQty: 5, priceLabel: "Rs 2,760" }, { minQty: 20, priceLabel: "Rs 2,700" }, { minQty: 50, priceLabel: "Rs 2,640" } ]),
  wp("prod_dairy_nurpur_butter", "Dairy Products", "Dairy", "Butter 200g — pack of 24", "Rs 6,480", "carton", 3, IMG.dairy),
  wp("prod_dairy_adams_creamer", "Dairy Products", "Dairy", "Powdered tea whitener 400g — pack of 24", "Rs 5,760", "carton", 3, IMG.dairy, "New"),

  // --- Confectionery ---
  wp("prod_conf_candyland", "Confectionery", "Confectionery", "Assorted toffees — 1kg jar", "Rs 780", "jar", 6, IMG.confection),
  wp("prod_conf_bisconni", "Confectionery", "Confectionery", "Chocolate chip cookies — carton of 24", "Rs 3,600", "carton", 4, IMG.confection, "Deal",
     [ { minQty: 4, priceLabel: "Rs 3,600" }, { minQty: 12, priceLabel: "Rs 3,480" }, { minQty: 30, priceLabel: "Rs 3,360" } ]),
  wp("prod_conf_mayfair", "Confectionery", "Confectionery", "Chocolate éclairs — 900g pouch", "Rs 690", "pouch", 6, IMG.confection),

  // --- Soaps ---
  wp("prod_soap_lifebuoy", "Soaps", "Soap", "Antibacterial bar soap 130g — carton of 48", "Rs 4,320", "carton", 3, IMG.soap, "Bulk",
     [ { minQty: 3, priceLabel: "Rs 4,320" }, { minQty: 10, priceLabel: "Rs 4,220" }, { minQty: 25, priceLabel: "Rs 4,100" } ]),
  wp("prod_soap_safeguard", "Soaps", "Soap", "White bar soap 135g — carton of 48", "Rs 5,040", "carton", 3, IMG.soap),
  wp("prod_soap_lux", "Soaps", "Soap", "Moisturizing bar soap 128g — carton of 48", "Rs 4,560", "carton", 3, IMG.soap),

  // --- Shampoos ---
  wp("prod_sham_sunsilk", "Shampoos", "Shampoo", "Shampoo sachets 8ml — box of 72", "Rs 720", "box", 6, IMG.shampoo),
  wp("prod_sham_headshoulders", "Shampoos", "Shampoo", "Anti-dandruff shampoo 185ml — pack of 12", "Rs 5,880", "carton", 3, IMG.shampoo, "New"),
  wp("prod_sham_clear", "Shampoos", "Shampoo", "Menthol shampoo 185ml — pack of 12", "Rs 5,520", "carton", 3, IMG.shampoo),

  // --- Sauces ---
  wp("prod_sauce_shangrila", "Sauces", "Sauce", "Tomato ketchup 800g — pack of 12", "Rs 3,360", "carton", 3, IMG.sauce),
  wp("prod_sauce_national", "Sauces", "Sauce", "Chilli garlic sauce 775g — pack of 12", "Rs 3,600", "carton", 3, IMG.sauce, "Deal",
     [ { minQty: 3, priceLabel: "Rs 3,600" }, { minQty: 12, priceLabel: "Rs 3,480" }, { minQty: 30, priceLabel: "Rs 3,360" } ]),
  wp("prod_sauce_mitchells", "Sauces", "Sauce", "Soya sauce 300ml — pack of 24", "Rs 4,080", "carton", 3, IMG.sauce),

  // --- Flour ---
  wp("prod_flour_sunridge", "Flour", "Flour", "Wheat flour (atta) 10kg bag", "Rs 1,250", "bag", 10, IMG.flour, "Bulk",
     [ { minQty: 10, priceLabel: "Rs 1,250" }, { minQty: 30, priceLabel: "Rs 1,210" }, { minQty: 60, priceLabel: "Rs 1,180" } ]),
  wp("prod_flour_bakeparlor", "Flour", "Flour", "Refined flour (maida) 5kg bag", "Rs 720", "bag", 10, IMG.flour),

  // --- Sugar ---
  wp("prod_sugar_alarabia", "Sugar", "Sugar", "Refined white sugar 50kg bori", "Rs 8,600", "bori", 3, IMG.sugar, "Bulk",
     [ { minQty: 3, priceLabel: "Rs 8,600" }, { minQty: 10, priceLabel: "Rs 8,450" }, { minQty: 25, priceLabel: "Rs 8,300" } ]),
  wp("prod_sugar_brown", "Sugar", "Sugar", "Brown sugar 25kg bag", "Rs 5,200", "bag", 3, IMG.sugar),

  // --- Pulses ---
  wp("prod_pulse_masoor", "Pulses", "Pulses", "Red lentils (masoor) 25kg bag", "Rs 6,750", "bag", 2, IMG.pulses),
  wp("prod_pulse_chana", "Pulses", "Pulses", "Split chickpeas (chana daal) 25kg bag", "Rs 7,000", "bag", 2, IMG.pulses, "Deal"),

  // --- Rice ---
  wp("prod_rice_guard", "Rice", "Rice", "Basmati rice 40kg bag", "Rs 12,800", "bag", 2, IMG.rice, "Bulk",
     [ { minQty: 2, priceLabel: "Rs 12,800" }, { minQty: 8, priceLabel: "Rs 12,500" }, { minQty: 20, priceLabel: "Rs 12,200" } ]),
  wp("prod_rice_falak", "Rice", "Rice", "Sella basmati rice 40kg bag", "Rs 11,600", "bag", 2, IMG.rice),

  // --- Pasta ---
  wp("prod_pasta_bakeparlor", "Pasta", "Pasta", "Macaroni pasta 400g — carton of 24", "Rs 2,640", "carton", 4, IMG.pasta),
  wp("prod_pasta_italiano", "Pasta", "Pasta", "Spaghetti pasta 500g — carton of 20", "Rs 3,000", "carton", 4, IMG.pasta, "New"),

  // --- Noodles ---
  wp("prod_noodle_knorr", "Noodles", "Noodles", "Chicken instant noodles 66g — carton of 24", "Rs 1,680", "carton", 6, IMG.noodles, "Deal",
     [ { minQty: 6, priceLabel: "Rs 1,680" }, { minQty: 20, priceLabel: "Rs 1,620" }, { minQty: 50, priceLabel: "Rs 1,560" } ]),
  wp("prod_noodle_maggi", "Noodles", "Noodles", "Masala instant noodles 68g — carton of 24", "Rs 1,720", "carton", 6, IMG.noodles),
  wp("prod_noodle_shoop", "Noodles", "Noodles", "Chicken instant noodles 65g — carton of 24", "Rs 1,600", "carton", 6, IMG.noodles),

  // --- Cooking Oil ---
  wp("prod_oil_dalda", "Cooking Oil", "Cooking Oil", "Cooking oil 5L — carton of 4", "Rs 6,800", "carton", 3, IMG.oil, "Bulk",
     [ { minQty: 3, priceLabel: "Rs 6,800" }, { minQty: 12, priceLabel: "Rs 6,650" }, { minQty: 30, priceLabel: "Rs 6,500" } ]),
  wp("prod_oil_sufi", "Cooking Oil", "Cooking Oil", "Vegetable cooking oil 5L — carton of 4", "Rs 6,600", "carton", 3, IMG.oil),
  wp("prod_oil_habib", "Cooking Oil", "Cooking Oil", "Clarified butter (ghee) 5kg — carton of 4", "Rs 7,200", "carton", 3, IMG.oil),

  // --- Tea & Coffee ---
  wp("prod_tea_tapal", "Tea & Coffee", "Tea", "Loose leaf black tea 900g — carton of 12", "Rs 10,200", "carton", 4, IMG.tea, "Bulk",
     [ { minQty: 4, priceLabel: "Rs 10,200" }, { minQty: 15, priceLabel: "Rs 9,900" }, { minQty: 40, priceLabel: "Rs 9,600" } ]),
  wp("prod_tea_lipton", "Tea & Coffee", "Tea", "Black tea bags 950g — carton of 12", "Rs 10,800", "carton", 4, IMG.tea),
  wp("prod_tea_nescafe", "Tea & Coffee", "Coffee", "Instant coffee 200g — pack of 12", "Rs 12,000", "carton", 2, IMG.tea, "New"),

  // --- Beverages ---
  wp("prod_bev_pakola", "Beverages", "Beverages", "Cream soda 1.5L — pack of 6", "Rs 1,020", "pack", 6, IMG.beverage),
  wp("prod_bev_gourmet", "Beverages", "Beverages", "Cola drink 2.25L — pack of 6", "Rs 1,140", "pack", 6, IMG.beverage, "Deal"),

  // --- Snacks ---
  wp("prod_snack_lays", "Snacks", "Snacks", "Masala potato chips 32g — carton of 60", "Rs 3,000", "carton", 4, IMG.snack, "Deal",
     [ { minQty: 4, priceLabel: "Rs 3,000" }, { minQty: 12, priceLabel: "Rs 2,880" }, { minQty: 30, priceLabel: "Rs 2,760" } ]),
  wp("prod_snack_kurkure", "Snacks", "Snacks", "Spicy corn snacks 38g — carton of 60", "Rs 2,880", "carton", 4, IMG.snack),
  wp("prod_snack_supercrisp", "Snacks", "Snacks", "Crispy snack sticks 28g — carton of 60", "Rs 2,700", "carton", 4, IMG.snack),

  // --- Spices ---
  wp("prod_spice_national", "Spices", "Spices", "Chaat masala 800g — pack of 12", "Rs 4,560", "carton", 2, IMG.spice),
  wp("prod_spice_shan", "Spices", "Spices", "Biryani spice mix 50g — box of 144", "Rs 8,640", "box", 1, IMG.spice, "Bulk"),
  wp("prod_spice_mehran", "Spices", "Spices", "Turmeric powder 400g — pack of 24", "Rs 3,840", "carton", 2, IMG.spice),

  // --- Cleaning ---
  wp("prod_clean_surf", "Cleaning", "Cleaning", "Washing powder 1kg — carton of 9", "Rs 4,050", "carton", 3, IMG.cleaning, "Bulk",
     [ { minQty: 3, priceLabel: "Rs 4,050" }, { minQty: 12, priceLabel: "Rs 3,960" }, { minQty: 30, priceLabel: "Rs 3,870" } ]),
  wp("prod_clean_bonus", "Cleaning", "Cleaning", "Laundry detergent 1kg — carton of 9", "Rs 2,880", "carton", 3, IMG.cleaning),
  wp("prod_clean_vim", "Cleaning", "Cleaning", "Dishwashing bar 200g — carton of 48", "Rs 3,840", "carton", 3, IMG.cleaning),
];

const shops = [
  // --- Saddar Market, Karachi (12 shops) ---
  { id: "shop_pk_jj_saddar", name: "Junaid Jamshed Outlet", category: "Clothing", marketId: "market_pk_saddar", imageUrl: `${SHOP_MEDIA}/shop_pk_jj_saddar.jpg`, tags: ["fashion", "clothing", "kurta", "traditional"] },
  { id: "shop_pk_galaxy_saddar", name: "Galaxy Mobile Hub", category: "Electronics", marketId: "market_pk_saddar", imageUrl: `${SHOP_MEDIA}/shop_pk_galaxy_saddar.jpg`, tags: ["electronics", "mobile", "android", "iphone", "samsung"] },
  { id: "shop_pk_gems_saddar", name: "Al-Haram Gems", category: "Gems", marketId: "market_pk_saddar", imageUrl: `${SHOP_MEDIA}/shop_pk_gems_saddar.jpg`, tags: ["gems", "jewelry", "beauty", "fashion"] },
  { id: "shop_pk_saddar_electronics2", name: "Saddar Electronics Bazaar", category: "Electronics", marketId: "market_pk_saddar", imageUrl: `${SHOP_MEDIA}/shop_pk_saddar_electronics2.jpg`, tags: ["electronics", "mobile", "accessories"] },
  { id: "shop_pk_saddar_fashion", name: "Karachi Fashion House", category: "Clothing", marketId: "market_pk_saddar", imageUrl: `${SHOP_MEDIA}/shop_pk_saddar_fashion.jpg`, tags: ["fashion", "clothing", "style"] },
  { id: "shop_pk_saddar_spices", name: "Saddar Spice Traders", category: "Food & Spices", marketId: "market_pk_saddar", imageUrl: `${SHOP_MEDIA}/shop_pk_saddar_spices.jpg`, tags: ["spices", "food", "grocery"] },
  { id: "shop_pk_saddar_crafts", name: "Sindh Handicrafts", category: "Home & Decor", marketId: "market_pk_saddar", imageUrl: `${SHOP_MEDIA}/shop_pk_saddar_crafts.jpg`, tags: ["decor", "handicrafts", "home"] },
  { id: "shop_pk_saddar_shoes", name: "Karachi Shoe Mart", category: "Clothing", marketId: "market_pk_saddar", imageUrl: `${SHOP_MEDIA}/shop_pk_saddar_shoes.jpg`, tags: ["shoes", "clothing", "footwear"] },
  { id: "shop_pk_saddar_spices2", name: "Bandar Road Spices", category: "Food & Spices", marketId: "market_pk_saddar", imageUrl: `${SHOP_MEDIA}/shop_pk_saddar_spices2.jpg`, tags: ["spices", "food", "market"] },
  { id: "shop_pk_saddar_perfume", name: "Saddar Perfume Gallery", category: "Fragrances", marketId: "market_pk_saddar", imageUrl: `${SHOP_MEDIA}/shop_pk_saddar_perfume.jpg`, tags: ["fragrance", "perfume", "beauty"] },
  { id: "shop_pk_saddar_sweets", name: "Karachi Sweet House", category: "Food & Spices", marketId: "market_pk_saddar", imageUrl: `${SHOP_MEDIA}/shop_pk_saddar_sweets.jpg`, tags: ["sweets", "food", "dessert"] },
  { id: "shop_pk_saddar_mobile", name: "Regal Mobile Center", category: "Electronics", marketId: "market_pk_saddar", imageUrl: `${SHOP_MEDIA}/shop_pk_saddar_mobile.jpg`, tags: ["electronics", "mobile", "repair"] },

  // --- Anarkali Bazaar, Lahore (12 shops) ---
  { id: "shop_pk_anarkali_khussa", name: "Traditional Khussa Palace", category: "Clothing", marketId: "market_pk_anarkali", imageUrl: `${SHOP_MEDIA}/shop_pk_anarkali_khussa.jpg`, tags: ["shoes", "traditional", "clothing", "khussa"] },
  { id: "shop_pk_anarkali_bano_shoes", name: "Bano Shoes", category: "Clothing", marketId: "market_pk_anarkali", imageUrl: `${SHOP_MEDIA}/shop_pk_anarkali_bano_shoes.jpg`, tags: ["shoes", "footwear", "clothing"] },
  { id: "shop_pk_anarkali_silk_house", name: "Anarkali Silk House", category: "Clothing", marketId: "market_pk_anarkali", imageUrl: `${SHOP_MEDIA}/shop_pk_anarkali_silk_house.jpg`, tags: ["fashion", "silk", "clothing"] },
  { id: "shop_pk_anarkali_gems", name: "Anarkali Gems Gallery", category: "Gems", marketId: "market_pk_anarkali", imageUrl: `${SHOP_MEDIA}/shop_pk_anarkali_gems.jpg`, tags: ["gems", "jewelry", "beauty"] },
  { id: "shop_pk_anarkali_handicrafts", name: "Lahore Handicrafts", category: "Home & Decor", marketId: "market_pk_anarkali", imageUrl: `${SHOP_MEDIA}/shop_pk_anarkali_handicrafts.jpg`, tags: ["decor", "handicrafts", "home"] },
  { id: "shop_pk_anarkali_perfume", name: "Ittar House Anarkali", category: "Fragrances", marketId: "market_pk_anarkali", imageUrl: `${SHOP_MEDIA}/shop_pk_anarkali_perfume.jpg`, tags: ["fragrance", "ittar", "perfume"] },
  { id: "shop_pk_anarkali_sweets", name: "Anarkali Sweets Corner", category: "Food & Spices", marketId: "market_pk_anarkali", imageUrl: `${SHOP_MEDIA}/shop_pk_anarkali_sweets.jpg`, tags: ["sweets", "food", "dessert"] },
  { id: "shop_pk_anarkali_designer", name: "Anarkali Designer Studio", category: "Clothing", marketId: "market_pk_anarkali", imageUrl: `${SHOP_MEDIA}/shop_pk_anarkali_designer.jpg`, tags: ["fashion", "designer", "clothing"] },
  { id: "shop_pk_anarkali_jewelers", name: "Heritage Jewelers", category: "Gems", marketId: "market_pk_anarkali", imageUrl: `${SHOP_MEDIA}/shop_pk_anarkali_jewelers.jpg`, tags: ["gems", "jewelry", "gold"] },
  { id: "shop_pk_anarkali_crafts2", name: "Punjab Artisan Crafts", category: "Home & Decor", marketId: "market_pk_anarkali", imageUrl: `${SHOP_MEDIA}/shop_pk_anarkali_crafts2.jpg`, tags: ["decor", "handicrafts", "artisan"] },
  { id: "shop_pk_anarkali_mobile", name: "Anarkali Mobile Point", category: "Electronics", marketId: "market_pk_anarkali", imageUrl: `${SHOP_MEDIA}/shop_pk_anarkali_mobile.jpg`, tags: ["electronics", "mobile", "accessories"] },
  { id: "shop_pk_anarkali_bags", name: "Bagh-e-Fashion Bags", category: "Clothing", marketId: "market_pk_anarkali", imageUrl: `${SHOP_MEDIA}/shop_pk_anarkali_bags.jpg`, tags: ["bags", "accessories", "fashion"] },

  // --- Centaurus Mall, Islamabad (12 shops) ---
  { id: "shop_pk_centaurus_designer", name: "Zara Couture", category: "Clothing", marketId: "market_pk_centaurus", imageUrl: `${SHOP_MEDIA}/shop_pk_centaurus_designer.jpg`, tags: ["fashion", "designer", "luxury", "clothing"] },
  { id: "shop_pk_centaurus_electronics", name: "Centaurus Electronics Hub", category: "Electronics", marketId: "market_pk_centaurus", imageUrl: `${SHOP_MEDIA}/shop_pk_centaurus_electronics.jpg`, tags: ["electronics", "gadgets", "mobile"] },
  { id: "shop_pk_centaurus_mobile2", name: "TechZone Mobiles", category: "Electronics", marketId: "market_pk_centaurus", imageUrl: `${SHOP_MEDIA}/shop_pk_centaurus_mobile2.jpg`, tags: ["electronics", "mobile", "tech"] },
  { id: "shop_pk_centaurus_jewelry", name: "Royal Jewelry House", category: "Gems", marketId: "market_pk_centaurus", imageUrl: `${SHOP_MEDIA}/shop_pk_centaurus_jewelry.jpg`, tags: ["gems", "jewelry", "luxury"] },
  { id: "shop_pk_centaurus_perfume", name: "Scent Avenue", category: "Fragrances", marketId: "market_pk_centaurus", imageUrl: `${SHOP_MEDIA}/shop_pk_centaurus_perfume.jpg`, tags: ["fragrance", "perfume", "beauty"] },
  { id: "shop_pk_centaurus_decor", name: "Modern Living Decor", category: "Home & Decor", marketId: "market_pk_centaurus", imageUrl: `${SHOP_MEDIA}/shop_pk_centaurus_decor.jpg`, tags: ["decor", "furniture", "home"] },
  { id: "shop_pk_centaurus_fashion2", name: "Urban Threads", category: "Clothing", marketId: "market_pk_centaurus", imageUrl: `${SHOP_MEDIA}/shop_pk_centaurus_fashion2.jpg`, tags: ["fashion", "clothing", "style"] },
  { id: "shop_pk_centaurus_gadgets", name: "Gadget World", category: "Electronics", marketId: "market_pk_centaurus", imageUrl: `${SHOP_MEDIA}/shop_pk_centaurus_gadgets.jpg`, tags: ["electronics", "gadgets", "tech"] },
  { id: "shop_pk_centaurus_shoes", name: "Footwear Gallery", category: "Clothing", marketId: "market_pk_centaurus", imageUrl: `${SHOP_MEDIA}/shop_pk_centaurus_shoes.jpg`, tags: ["shoes", "footwear", "clothing"] },
  { id: "shop_pk_centaurus_gold", name: "Gold & Co.", category: "Gems", marketId: "market_pk_centaurus", imageUrl: `${SHOP_MEDIA}/shop_pk_centaurus_gold.jpg`, tags: ["gems", "gold", "jewelry"] },
  { id: "shop_pk_centaurus_bakery", name: "Centaurus Bakers", category: "Food & Spices", marketId: "market_pk_centaurus", imageUrl: `${SHOP_MEDIA}/shop_pk_centaurus_bakery.jpg`, tags: ["bakery", "food", "sweets"] },
  { id: "shop_pk_centaurus_oud", name: "Oud Boutique", category: "Fragrances", marketId: "market_pk_centaurus", imageUrl: `${SHOP_MEDIA}/shop_pk_centaurus_oud.jpg`, tags: ["fragrance", "oud", "perfume"] },

  // --- Husain Agahi Bazaar, Multan (12 shops) ---
  { id: "shop_pk_multan_halwa", name: "Rewari Sohan Halwa", category: "Food & Spices", marketId: "market_pk_hussain", imageUrl: `${SHOP_MEDIA}/shop_pk_multan_halwa.jpg`, tags: ["food", "sweets", "spices", "halwa"] },
  { id: "shop_pk_hussain_embroidery", name: "Multani Embroidery House", category: "Home & Decor", marketId: "market_pk_hussain", imageUrl: `${SHOP_MEDIA}/shop_pk_hussain_embroidery.jpg`, tags: ["embroidery", "handicrafts", "decor"] },
  { id: "shop_pk_hussain_crafts2", name: "Hussain Agahi Handicrafts", category: "Home & Decor", marketId: "market_pk_hussain", imageUrl: `${SHOP_MEDIA}/shop_pk_hussain_crafts2.jpg`, tags: ["handicrafts", "decor", "artisan"] },
  { id: "shop_pk_hussain_dryfruits", name: "Gurh Mandi Dry Fruits", category: "Food & Spices", marketId: "market_pk_hussain", imageUrl: `${SHOP_MEDIA}/shop_pk_hussain_dryfruits.jpg`, tags: ["dry fruits", "food", "spices"] },
  { id: "shop_pk_hussain_spices2", name: "Multan Spice Traders", category: "Food & Spices", marketId: "market_pk_hussain", imageUrl: `${SHOP_MEDIA}/shop_pk_hussain_spices2.jpg`, tags: ["spices", "food", "grocery"] },
  { id: "shop_pk_hussain_fabric", name: "Multani Fabric House", category: "Clothing", marketId: "market_pk_hussain", imageUrl: `${SHOP_MEDIA}/shop_pk_hussain_fabric.jpg`, tags: ["fabric", "clothing", "textile"] },
  { id: "shop_pk_hussain_fabric2", name: "Block Print Textiles", category: "Clothing", marketId: "market_pk_hussain", imageUrl: `${SHOP_MEDIA}/shop_pk_hussain_fabric2.jpg`, tags: ["textile", "fabric", "clothing"] },
  { id: "shop_pk_hussain_sweets2", name: "Multan Sweet Mart", category: "Food & Spices", marketId: "market_pk_hussain", imageUrl: `${SHOP_MEDIA}/shop_pk_hussain_sweets2.jpg`, tags: ["sweets", "food", "dessert"] },
  { id: "shop_pk_hussain_jewelry", name: "Agahi Jewelers", category: "Gems", marketId: "market_pk_hussain", imageUrl: `${SHOP_MEDIA}/shop_pk_hussain_jewelry.jpg`, tags: ["gems", "jewelry", "gold"] },
  { id: "shop_pk_hussain_shoes", name: "Multan Footwear", category: "Clothing", marketId: "market_pk_hussain", imageUrl: `${SHOP_MEDIA}/shop_pk_hussain_shoes.jpg`, tags: ["shoes", "footwear", "clothing"] },
  { id: "shop_pk_hussain_perfume", name: "Multan Ittar Gallery", category: "Fragrances", marketId: "market_pk_hussain", imageUrl: `${SHOP_MEDIA}/shop_pk_hussain_perfume.jpg`, tags: ["fragrance", "ittar", "perfume"] },
  { id: "shop_pk_hussain_lamps", name: "Multani Lamp House", category: "Home & Decor", marketId: "market_pk_hussain", imageUrl: `${SHOP_MEDIA}/shop_pk_hussain_lamps.jpg`, tags: ["decor", "lamps", "home"] },
  { id: "shop_ae_damas_gold", name: "Damas Gold Boutique", category: "Gems", marketId: "market_ae_gold_souk", imageUrl: "https://images.unsplash.com/photo-1617038260897-41e9d3996f3c?w=800&q=80", tags: ["gems", "jewelry", "gold", "beauty"] },
  { id: "shop_ae_oud_house", name: "Arabian Oud House", category: "Fragrances", marketId: "market_ae_gold_souk", imageUrl: "https://images.unsplash.com/photo-1541643600914-78b084683601?w=800&q=80", tags: ["fragrance", "perfume", "oud", "beauty"] },
  { id: "shop_ae_marina_style", name: "Marina Style", category: "Clothing", marketId: "market_ae_gold_souk", imageUrl: "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800&q=80", tags: ["fashion", "clothing", "modern", "style"] },
  { id: "shop_qa_handicrafts", name: "Waqif Handicrafts", category: "Home & Decor", marketId: "market_qa_souq_waqif", imageUrl: "https://images.unsplash.com/photo-1610701596007-11502861dcfa?w=800&q=80", tags: ["decor", "furniture", "handicrafts", "home"] },
  { id: "shop_qa_spice_route", name: "Spice Route Stall", category: "Food & Spices", marketId: "market_qa_souq_waqif", imageUrl: "https://images.unsplash.com/photo-1509440159596-0249088773ff?w=800&q=80", tags: ["grocery", "spices", "food", "market"] },
  { id: "shop_qa_doha_threads", name: "Doha Threads", category: "Clothing", marketId: "market_qa_souq_waqif", imageUrl: "https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=800&q=80", tags: ["fashion", "clothing", "threads", "tailor"] },
  { id: "shop_in_silk_weavers", name: "Silk Weavers Lane", category: "Clothing", marketId: "market_in_chandni", imageUrl: "https://images.unsplash.com/photo-1520903923513-f990884e5771?w=800&q=80", tags: ["fashion", "clothing", "silk", "handwoven"] },
  { id: "shop_in_chandni_jewelers", name: "Chandni Jewelers", category: "Gems", marketId: "market_in_chandni", imageUrl: "https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=800&q=80", tags: ["gems", "jewelry", "gold", "diamonds"] },
  { id: "shop_in_tech_bazaar", name: "Tech Bazaar Corner", category: "Electronics", marketId: "market_in_chandni", imageUrl: "https://images.unsplash.com/photo-1468495244123-6c6c332eeece?w=800&q=80", tags: ["electronics", "computer", "gadgets", "tech"] },
  { id: "shop_in_old_delhi_snacks", name: "Old Delhi Snacks", category: "Food & Spices", marketId: "market_in_chandni", imageUrl: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800&q=80", tags: ["restaurant", "cafe", "snacks", "food"] },
];

// Guard: this seeder must only ever write to the ThokBazaar project. If the
// service-account.json belongs to a different project, refuse — this prevents
// accidentally polluting another app's Firestore (e.g. Bazaar Connect).
const EXPECTED_PROJECT = "thokbazaar-4a79a";

async function main() {
  if (serviceAccount.project_id !== EXPECTED_PROJECT) {
    console.error(
      `Refusing to seed: service-account.json is for project '${serviceAccount.project_id}', ` +
      `but this seeder only targets '${EXPECTED_PROJECT}'. ` +
      `Generate a service account key from the ThokBazaar Firebase project and try again.`
    );
    process.exit(1);
  }

  const batch = db.batch();

  // ThokBazaar is a flat B2B catalog — products only (no markets/shops).
  for (const p of products) {
    const { id, badge, priceTiers, ...rest } = p;
    const data = { ...rest, updatedAt: now };
    if (badge != null) data.badge = badge;
    if (priceTiers != null) data.priceTiers = priceTiers;
    batch.set(db.collection("products").doc(id), data, { merge: true });
  }

  batch.set(db.doc("_meta/catalog_seed"), {
    version: 3, seededAt: now, productCount: products.length,
  }, { merge: true });

  await batch.commit();
  console.log(`Seeded ${products.length} products into ${serviceAccount.project_id}.`);
  process.exit(0);
}

// Only run when executed directly (never on require()), so importing this file
// for inspection cannot trigger writes.
if (require.main === module) {
  main().catch((e) => { console.error("Seed failed:", e); process.exit(1); });
}
