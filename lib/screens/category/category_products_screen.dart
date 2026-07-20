import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_pandaa/app.dart';
import 'package:shop_pandaa/data/categories.dart';
import 'package:shop_pandaa/data/models.dart';
import 'package:shop_pandaa/theme/app_colors.dart';
import 'package:shop_pandaa/theme/app_theme.dart';
import 'package:shop_pandaa/widgets/gradient_scaffold.dart';
import 'package:shop_pandaa/widgets/product_card.dart';

/// All products in a wholesale category, grouped by brand. Reached from the
/// home category grid, "See all" section links, and category tag chips.
class CategoryProductsScreen extends StatelessWidget {
  const CategoryProductsScreen({super.key, required this.category});

  final String category;

  Stream<List<ProductItem>> _stream() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ProductItem.fromMap(d.id, d.data())).toList());
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconForCategory(category), size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(child: Text(category, overflow: TextOverflow.ellipsis)),
          ],
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ProductItem>>(
        stream: _stream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load products from Firestore.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.teal));
          }
          final products = snapshot.data!;
          if (products.isEmpty) {
            return _EmptyCategory(category: category);
          }

          // Group products by brand for a supplier-catalog feel.
          final byBrand = <String, List<ProductItem>>{};
          for (final p in products) {
            byBrand.putIfAbsent(p.brandLabel, () => []).add(p);
          }
          final brands = byBrand.keys.toList()..sort();

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              children: [
                Text(
                  '${products.length} product(s) · ${brands.length} brand(s)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                for (final brand in brands) ...[
                  Row(
                    children: [
                      const Icon(Icons.verified_outlined, size: 16, color: AppColors.teal),
                      const SizedBox(width: 6),
                      Text(brand, style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.62,
                    ),
                    itemCount: byBrand[brand]!.length,
                    itemBuilder: (context, i) {
                      final p = byBrand[brand]![i];
                      return ProductCard(
                        product: p,
                        onTap: () => Navigator.of(context).pushNamed(
                          ShoppandaApp.productRoute,
                          arguments: p.id,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory({required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(iconForCategory(category), size: 34, color: AppColors.teal),
            ),
            const SizedBox(height: 16),
            Text('No $category yet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Products in this category will appear here soon.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
