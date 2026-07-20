import 'package:flutter/material.dart';

/// A wholesale product category shown on the ThokBazaar home screen. Each
/// category carries an icon "logo" that represents it in the grid and section
/// headers. Product docs reference a category by its [name].
class WholesaleCategory {
  const WholesaleCategory({required this.name, required this.icon});

  final String name;
  final IconData icon;
}

/// Canonical list of the categories a dukaan orders from ThokBazaar. The
/// `name` is what a product's `category` field must match (case-insensitive).
const List<WholesaleCategory> kWholesaleCategories = [
  WholesaleCategory(name: 'Dairy Products', icon: Icons.egg_alt_outlined),
  WholesaleCategory(name: 'Confectionery', icon: Icons.cake_outlined),
  WholesaleCategory(name: 'Soaps', icon: Icons.soap_outlined),
  WholesaleCategory(name: 'Shampoos', icon: Icons.shower_outlined),
  WholesaleCategory(name: 'Sauces', icon: Icons.lunch_dining_outlined),
  WholesaleCategory(name: 'Flour', icon: Icons.bakery_dining_outlined),
  WholesaleCategory(name: 'Sugar', icon: Icons.cookie_outlined),
  WholesaleCategory(name: 'Pulses', icon: Icons.grass_outlined),
  WholesaleCategory(name: 'Rice', icon: Icons.rice_bowl_outlined),
  WholesaleCategory(name: 'Pasta', icon: Icons.dinner_dining_outlined),
  WholesaleCategory(name: 'Noodles', icon: Icons.ramen_dining_outlined),
  WholesaleCategory(name: 'Cooking Oil', icon: Icons.water_drop_outlined),
  WholesaleCategory(name: 'Tea & Coffee', icon: Icons.coffee_outlined),
  WholesaleCategory(name: 'Beverages', icon: Icons.local_drink_outlined),
  WholesaleCategory(name: 'Snacks', icon: Icons.fastfood_outlined),
  WholesaleCategory(name: 'Spices', icon: Icons.soup_kitchen_outlined),
  WholesaleCategory(name: 'Cleaning', icon: Icons.cleaning_services_outlined),
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
