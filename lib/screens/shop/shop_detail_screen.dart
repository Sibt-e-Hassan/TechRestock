import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tech_restock/app.dart';
import 'package:tech_restock/data/models.dart';
import 'package:tech_restock/theme/app_colors.dart';
import 'package:tech_restock/theme/app_theme.dart';
import 'package:tech_restock/widgets/app_card.dart';
import 'package:tech_restock/widgets/gradient_scaffold.dart';
import 'package:tech_restock/widgets/product_card.dart';
import 'package:tech_restock/widgets/section_head.dart';

class ShopDetailScreen extends StatelessWidget {
  const ShopDetailScreen({
    super.key,
    required this.shopId,
    required this.shopName,
    this.category,
    this.marketName,
  });

  final String shopId;
  final String shopName;
  final String? category;
  final String? marketName;

  Stream<List<ProductItem>> _productsStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .where('shopId', isEqualTo: shopId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductItem.fromMap(doc.id, doc.data()))
              .toList()
            ..sort((a, b) => a.title.compareTo(b.title)),
        );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(shopName),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ProductItem>>(
        stream: _productsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacingLg),
                child: Text('Failed to load products from Firestore.'),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.teal));
          }

          final products = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                sliver: SliverToBoxAdapter(
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHead(
                          icon: Icons.inventory_2_outlined,
                          title: 'Shop catalog',
                          subtitle: 'Products listed by this shop in real time.',
                        ),
                        if (category != null && category!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            category!.toUpperCase(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: AppColors.teal,
                                ),
                          ),
                        ],
                        if (marketName != null && marketName!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            marketName!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          '${products.length} products',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingLg),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 48, color: AppColors.teal),
                          const SizedBox(height: 16),
                          Text(
                            'No products yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This shop has no products listed yet. Check back soon for new arrivals.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spacingLg,
                    0,
                    AppTheme.spacingLg,
                    AppTheme.spacingLg,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.58,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          onTap: () => Navigator.of(context).pushNamed(
                            ShoppandaApp.productRoute,
                            arguments: product.id,
                          ),
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
