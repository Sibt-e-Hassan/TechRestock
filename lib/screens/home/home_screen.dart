import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tech_restock/app.dart';
import 'package:tech_restock/data/categories.dart';
import 'package:tech_restock/data/media_urls.dart';
import 'package:tech_restock/data/models.dart';
import 'package:tech_restock/screens/category/category_products_screen.dart';
import 'package:tech_restock/theme/app_colors.dart';
import 'package:tech_restock/theme/app_theme.dart';
import 'package:tech_restock/widgets/brand_logo.dart';
import 'package:tech_restock/widgets/cart_scope.dart';
import 'package:tech_restock/widgets/product_network_image.dart';

// Ink colours for the white lower sheet (theme text is white on the navy
// header, so this screen uses explicit dark tones for the paper area).
const _kInk = Color(0xFF1F2933);
const _kMuted = Color(0xFF52606D);
const _kChipBg = Color(0xFFEDEDE9);

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onSearchTap,
    this.onCartTap,
  });

  final VoidCallback? onSearchTap;
  final VoidCallback? onCartTap;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Currently selected category tag ('All' = no filter).
  String _tag = 'All';

  Stream<List<ProductItem>> _productsStream() {
    return FirebaseFirestore.instance.collection('products').snapshots().map(
          (snap) => snap.docs
              .map((d) => ProductItem.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Stream<Map<String, dynamic>?>? _profileStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.data());
  }

  String _firstName(Map<String, dynamic>? profile) {
    final full = (profile?['fullName'] as String?)?.trim();
    if (full != null && full.isNotEmpty) return full.split(' ').first;
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (email != null && email.contains('@')) return email.split('@').first;
    return 'there';
  }

  void _openCategory(String category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(category: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Column(
        children: [
          // ---------- Navy header: greeting + cart, then search below ----------
          Container(
            color: AppColors.header,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
                child: StreamBuilder<Map<String, dynamic>?>(
                  stream: _profileStream(),
                  builder: (context, snap) {
                    final profile = snap.data;
                    final dukaan = (profile?['dukaanName'] as String?)?.trim();
                    return Column(
                      children: [
                        Row(
                          children: [
                            const BrandLogo(size: 44, borderRadius: 12),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hi, ${_firstName(profile)} 👋',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.ibmPlexSans(
                                      color: Colors.white.withValues(alpha: 0.65),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    (dukaan != null && dukaan.isNotEmpty)
                                        ? dukaan
                                        : 'TechRestock',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.ibmPlexSans(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Wholesale catalogue · bulk pricing',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.ibmPlexSans(
                                      color: Colors.white.withValues(alpha: 0.55),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _CartHeaderButton(onTap: widget.onCartTap),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Search bar (opens the search screen).
                        GestureDetector(
                          onTap: widget.onSearchTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: _kMuted, size: 22),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    'Search products, brands, categories…',
                                    style: TextStyle(color: _kMuted, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          // ---------- White content sheet ----------
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              clipBehavior: Clip.antiAlias,
              child: StreamBuilder<List<ProductItem>>(
                stream: _productsStream(),
                builder: (context, snapshot) {
                  final products = snapshot.data ?? const <ProductItem>[];
                  final byCategory = _groupByCategory(products);

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                    children: [
                      // ---- Shop by category (icon grid) ----
                      Text(
                        'Shop by category',
                        style: GoogleFonts.ibmPlexSans(
                          color: _kInk,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _CategoryGrid(onTap: _openCategory),
                      const SizedBox(height: 24),

                      // ---- Category tag chips ----
                      SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _TagChip(
                              label: 'All',
                              selected: _tag == 'All',
                              onTap: () => setState(() => _tag = 'All'),
                            ),
                            for (final c in kWholesaleCategories) ...[
                              const SizedBox(width: 10),
                              _TagChip(
                                label: c.name,
                                selected: _tag == c.name,
                                onTap: () => setState(() => _tag = c.name),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ---- Product sections ----
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator(color: AppColors.teal)),
                        )
                      else if (snapshot.hasError)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text('Failed to load products from Firestore.',
                              style: TextStyle(color: _kMuted)),
                        )
                      else if (products.isEmpty)
                        const _EmptyCatalog()
                      else
                        ..._buildSections(byCategory),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<ProductItem>> _groupByCategory(List<ProductItem> products) {
    final map = <String, List<ProductItem>>{};
    for (final p in products) {
      final cat = (p.category == null || p.category!.trim().isEmpty)
          ? 'Other'
          : p.category!.trim();
      map.putIfAbsent(cat, () => []).add(p);
    }
    return map;
  }

  List<Widget> _buildSections(Map<String, List<ProductItem>> byCategory) {
    // Order sections by the canonical category order, then any extras.
    final order = kWholesaleCategories.map((c) => c.name).toList();
    final cats = byCategory.keys.toList()
      ..sort((a, b) {
        final ia = order.indexOf(a);
        final ib = order.indexOf(b);
        return (ia == -1 ? 999 : ia).compareTo(ib == -1 ? 999 : ib);
      });

    final visible = _tag == 'All'
        ? cats
        : cats.where((c) => c.toLowerCase() == _tag.toLowerCase()).toList();

    if (visible.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Center(
            child: Text('No products in "$_tag" yet.',
                style: const TextStyle(color: _kMuted)),
          ),
        ),
      ];
    }

    final sections = <Widget>[];
    for (final cat in visible) {
      final items = byCategory[cat]!;
      sections.add(_CategorySection(
        category: cat,
        products: items,
        onSeeAll: () => _openCategory(cat),
        onProductTap: (p) => Navigator.of(context).pushNamed(
          ShoppandaApp.productRoute,
          arguments: p.id,
        ),
      ));
      sections.add(const SizedBox(height: 22));
    }
    return sections;
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 14,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: kWholesaleCategories.length,
      itemBuilder: (context, i) {
        final c = kWholesaleCategories[i];
        return InkWell(
          onTap: () => onTap(c.name),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: Column(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(c.icon, color: AppColors.teal, size: 26),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  c.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ibmPlexSans(
                    color: _kInk,
                    fontSize: 10.5,
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.products,
    required this.onSeeAll,
    required this.onProductTap,
  });

  final String category;
  final List<ProductItem> products;
  final VoidCallback onSeeAll;
  final ValueChanged<ProductItem> onProductTap;

  @override
  Widget build(BuildContext context) {
    final preview = products.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(iconForCategory(category), size: 20, color: AppColors.teal),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                category,
                style: GoogleFonts.ibmPlexSans(
                  color: _kInk,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: const Text(
                'See all',
                style: TextStyle(
                  color: AppColors.teal,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 208,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: preview.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => _HProductCard(
              product: preview[i],
              onTap: () => onProductTap(preview[i]),
            ),
          ),
        ),
      ],
    );
  }
}

/// Fixed-width product card for horizontal category rails.
class _HProductCard extends StatelessWidget {
  const _HProductCard({required this.product, required this.onTap});

  final ProductItem product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: const Color(0xFFDDE1E6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 104,
                      child: ProductNetworkImage(
                        imageUrl: MediaUrls.product(product) ?? product.imageUrl,
                        borderRadius: BorderRadius.zero,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (product.isOffer)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            product.badge!.toUpperCase(),
                            style: GoogleFonts.ibmPlexSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.tealDark,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.brandLabel.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      SizedBox(
                        height: 32,
                        child: Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.ibmPlexSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _kInk,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.priceLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.mono(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tealDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal : _kChipBg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: GoogleFonts.ibmPlexSans(
            color: selected ? Colors.white : _kInk,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _CartHeaderButton extends StatelessWidget {
  const _CartHeaderButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartScope.of(context),
      builder: (context, _) {
        final count = CartScope.of(context).itemCount;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: Colors.white.withValues(alpha: 0.15),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.shopping_cart_outlined, size: 20, color: Colors.white),
                ),
              ),
            ),
            if (count > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                  decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                  child: Text(
                    '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.tealDark,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: const Icon(Icons.inventory_2_outlined, size: 34, color: AppColors.teal),
          ),
          const SizedBox(height: 16),
          const Text(
            'Catalog is being stocked',
            style: TextStyle(color: _kInk, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Products will appear here shortly. Pick a category above to browse.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _kMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
