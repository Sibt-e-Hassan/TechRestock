import 'package:flutter/material.dart';

/// A wholesale tech product category shown on the TechRestock home screen. Each
/// category carries an icon that represents it in the grid and section
/// headers. Product docs reference a category by its [name].
class WholesaleCategory {
  const WholesaleCategory({required this.name, required this.icon});

  final String name;
  final IconData icon;
}

/// Canonical list of categories a tech retailer orders from TechRestock.
const List<WholesaleCategory> kWholesaleCategories = [
  WholesaleCategory(name: 'Chargers & Power', icon: Icons.power_outlined),
  WholesaleCategory(name: 'Cables & Adapters', icon: Icons.cable_outlined),
  WholesaleCategory(name: 'Cases & Covers', icon: Icons.smartphone_outlined),
  WholesaleCategory(name: 'Screen Glass', icon: Icons.screen_lock_portrait_outlined),
  WholesaleCategory(name: 'Audio & Earbuds', icon: Icons.headphones_outlined),
  WholesaleCategory(name: 'Power Banks', icon: Icons.battery_charging_full_outlined),
  WholesaleCategory(name: 'Car Accessories', icon: Icons.directions_car_outlined),
  WholesaleCategory(name: 'Memory & Storage', icon: Icons.sd_card_outlined),
  WholesaleCategory(name: 'Repair Parts', icon: Icons.build_outlined),
  WholesaleCategory(name: 'Smart Gadgets', icon: Icons.watch_outlined),
];

/// Icon for a category name (case-insensitive); a generic box if unknown.
IconData iconForCategory(String? name) {
  if (name == null) return Icons.inventory_2_outlined;
  final match = name.trim().toLowerCase();
  for (final c in kWholesaleCategories) {
    if (c.name.toLowerCase() == match) return c.icon;
  }
  return Icons.inventory_2_outlined;
}

