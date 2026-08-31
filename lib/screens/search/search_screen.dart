import 'package:flutter/material.dart';
import 'package:tech_restock/app.dart';
import 'package:tech_restock/data/media_urls.dart';
import 'package:tech_restock/data/models.dart';
import 'package:tech_restock/theme/app_colors.dart';
import 'package:tech_restock/theme/app_theme.dart';
import 'package:tech_restock/utils/catalog_search.dart';
import 'package:tech_restock/widgets/filter_chip.dart';
import 'package:tech_restock/widgets/brand_logo.dart';
import 'package:tech_restock/widgets/gradient_scaffold.dart';
import 'package:tech_restock/widgets/product_card.dart';
import 'package:tech_restock/widgets/product_network_image.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final Stream<CatalogSnapshot> _catalogStream = CatalogSearch.catalogStream();
  String _scope = CatalogSearch.scopeAll;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _scope = CatalogSearch.scopeAll;
      _query = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _query.trim().isNotEmpty;

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onClose ?? () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandLogo(size: 32, borderRadius: 8),
            const SizedBox(width: 10),
            Text('Search', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: Text('Clear filters', style: AppTheme.link.copyWith(fontSize: 13)),
          ),
        ],
      ),
      body: StreamBuilder<CatalogSnapshot>(
        stream: _catalogStream,
        builder: (context, catalogSnapshot) {
          if (catalogSnapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacingLg),
                child: Text('Failed to load catalog from Firestore.'),
              ),
            );
          }

          if (!catalogSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.teal));
          }

          final catalog = catalogSnapshot.data!;

          final results = hasQuery
              ? resolveSearchResults(catalog: catalog, query: _query, scope: _scope)
              : const SearchResults(products: [], shops: []);

          final indexLabel = hasQuery
              ? '${results.products.length} products found'
              : '${catalog.productCount} products indexed';

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingLg,
              0,
              AppTheme.spacingLg,
              AppTheme.spacingLg,
            ),
            children: [
              _SearchBar(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 10),
              Text(indexLabel, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 20),
              const _FilterLabel(icon: Icons.tune, label: 'Show'),
              const SizedBox(height: 10),
              FilterChipRow(
                options: CatalogSearch.scopeFilters,
                selected: _scope,
                onSelected: (scope) => setState(() => _scope = scope),
              ),
              if (!hasQuery) ...[
                const SizedBox(height: 32),
                const _EmptySearchPrompt(),
              ] else if (results.isEmpty) ...[
                const SizedBox(height: 32),
                _NoResults(query: _query.trim()),
              ] else ...[
                if (results.shops.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Shops', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ...results.shops.map(
                    (shop) => _SearchShopTile(
                      shop: shop,
                      onTap: () => Navigator.of(context).pushNamed(
                        ShoppandaApp.shopDetailRoute,
                        arguments: {
                          'shopId': shop.id,
                          'shopName': shop.name,
                          'category': shop.category,
                        },
                      ),
                    ),
                  ),
                ],
                if (results.products.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Products', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.58,
                    ),
                    itemCount: results.products.length,
                    itemBuilder: (context, index) {
                      final product = results.products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => Navigator.of(context).pushNamed(
                          ShoppandaApp.productRoute,
                          arguments: product.id,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  const _FilterLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.teal),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderInput.withValues(alpha: 0.6)),
        boxShadow: AppColors.cardShadow,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: const InputDecoration(
          hintText: 'Search by product, brand, or category…',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: AppColors.textLight),
        ),
      ),
    );
  }
}

class _SearchShopTile extends StatelessWidget {
  const _SearchShopTile({required this.shop, required this.onTap});

  final ShopItem shop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppColors.borderInput.withValues(alpha: 0.5)),
              boxShadow: AppColors.cardShadow,
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: ProductNetworkImage(
                      imageUrl: MediaUrls.shop(shop) ?? shop.imageUrl,
                      borderRadius: BorderRadius.circular(12),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(shop.category, style: Theme.of(context).textTheme.bodySmall),
                      if (shop.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: shop.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '#$tag',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 10,
                                      color: AppColors.teal,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textLight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptySearchPrompt extends StatelessWidget {
  const _EmptySearchPrompt();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.primarySoft.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            boxShadow: AppColors.cardShadow,
          ),
          child: const Icon(Icons.manage_search, size: 36, color: AppColors.teal),
        ),
        const SizedBox(height: 20),
        Text('Search TechRestock', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18)),
        const SizedBox(height: 8),
        Text(
          'Type a product, brand, or category to find wholesale stock.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.search_off, size: 48, color: AppColors.textLight),
        const SizedBox(height: 16),
        Text('No matches for "$query"', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Try another keyword or switch scope to shops and products.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
