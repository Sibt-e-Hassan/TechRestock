import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_pandaa/app.dart';
import 'package:shop_pandaa/data/models.dart';
import 'package:shop_pandaa/theme/app_colors.dart';
import 'package:shop_pandaa/theme/app_theme.dart';
import 'package:shop_pandaa/widgets/app_card.dart';
import 'package:shop_pandaa/widgets/gradient_scaffold.dart';
import 'package:shop_pandaa/widgets/section_head.dart';

class MarketDetailScreen extends StatefulWidget {
  const MarketDetailScreen({
    super.key,
    required this.marketId,
    required this.marketName,
    this.location,
  });

  final String marketId;
  final String marketName;
  final String? location;

  @override
  State<MarketDetailScreen> createState() => _MarketDetailScreenState();
}

class _MarketDetailScreenState extends State<MarketDetailScreen> {
  String _selectedCategory = 'All';
  String? _selectedTag;

  static const List<String> _categories = [
    'All',
    'Electronics',
    'Furniture',
    'Mobile Shops',
    'Grocery Stores',
    'Clothing & Fashion',
    'Beauty & Cosmetics',
    'Restaurants & Cafes',
    'Pharmacy',
    'Hardware',
    'Home Appliances',
    'Books & Stationery',
    'Sports & Fitness',
    'Automotive',
    'Services',
    'Other',
  ];

  static const Map<String, IconData> _categoryIcons = {
    'All': Icons.grid_view,
    'Electronics': Icons.devices_other,
    'Furniture': Icons.weekend,
    'Mobile Shops': Icons.phone_android,
    'Grocery Stores': Icons.local_grocery_store,
    'Clothing & Fashion': Icons.checkroom,
    'Beauty & Cosmetics': Icons.face_retouching_natural,
    'Restaurants & Cafes': Icons.restaurant,
    'Pharmacy': Icons.local_pharmacy,
    'Hardware': Icons.build,
    'Home Appliances': Icons.kitchen,
    'Books & Stationery': Icons.menu_book,
    'Sports & Fitness': Icons.sports_soccer,
    'Automotive': Icons.directions_car,
    'Services': Icons.construction,
    'Other': Icons.widgets,
  };

  static const Map<String, String> _categoryMapping = {
    'clothing': 'Clothing & Fashion',
    'electronics': 'Electronics',
    'gems': 'Beauty & Cosmetics',
    'fragrances': 'Beauty & Cosmetics',
    'home & decor': 'Furniture',
    'food & spices': 'Grocery Stores',
    'mobile shops': 'Mobile Shops',
    'grocery stores': 'Grocery Stores',
    'clothing & fashion': 'Clothing & Fashion',
    'beauty & cosmetics': 'Beauty & Cosmetics',
    'restaurants & cafes': 'Restaurants & Cafes',
    'pharmacy': 'Pharmacy',
    'hardware': 'Hardware',
    'home appliances': 'Home Appliances',
    'books & stationery': 'Books & Stationery',
    'sports & fitness': 'Sports & Fitness',
    'automotive': 'Automotive',
    'services': 'Services',
  };

  String _getNormalizedCategory(String rawCategory) {
    final normalized = rawCategory.trim().toLowerCase();
    if (_categoryMapping.containsKey(normalized)) {
      return _categoryMapping[normalized]!;
    }
    for (final key in _categoryMapping.keys) {
      if (normalized.contains(key) || key.contains(normalized)) {
        return _categoryMapping[key]!;
      }
    }
    return 'Other';
  }

  Stream<List<ShopItem>> _shopsStream() {
    return FirebaseFirestore.instance
        .collection('shops')
        .where('marketId', isEqualTo: widget.marketId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ShopItem.fromMap(doc.id, doc.data()))
              .toList()
            ..sort((a, b) {
              final categoryCompare = a.category.compareTo(b.category);
              if (categoryCompare != 0) {
                return categoryCompare;
              }
              return a.name.compareTo(b.name);
            }),
        );
  }

  Map<String, List<ShopItem>> _groupByCategory(List<ShopItem> shops) {
    final grouped = <String, List<ShopItem>>{};
    for (final shop in shops) {
      grouped.putIfAbsent(shop.category, () => []).add(shop);
    }
    return grouped;
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedTag = null;
    });
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          final icon = _categoryIcons[category] ?? Icons.storefront;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.teal : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.tealMid : AppColors.borderInput.withValues(alpha: 0.8),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.teal.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : AppColors.cardShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: isSelected ? Colors.white : AppColors.teal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category,
                        style: GoogleFonts.ibmPlexSans(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveTagBanner() {
    if (_selectedTag == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tag, size: 18, color: AppColors.teal),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Active tag: #$_selectedTag',
              style: GoogleFonts.ibmPlexSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.tealDark,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedTag = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
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
        title: Text(widget.marketName),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ShopItem>>(
        stream: _shopsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppTheme.spacingLg),
                child: Text('Failed to load shops from Firestore.'),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.teal));
          }

          final shops = snapshot.data!;
          if (shops.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.storefront_outlined, size: 48, color: AppColors.teal),
                    const SizedBox(height: 16),
                    Text(
                      'No shops in this market yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No shops are listed for this market yet. Check back soon as new sellers join ThokBazaar.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          var filteredShops = shops;
          if (_selectedCategory != 'All') {
            filteredShops = filteredShops.where((shop) =>
                _getNormalizedCategory(shop.category) == _selectedCategory).toList();
          }
          if (_selectedTag != null) {
            filteredShops = filteredShops.where((shop) =>
                shop.tags.contains(_selectedTag)).toList();
          }

          final grouped = _groupByCategory(filteredShops);
          final categories = grouped.keys.toList()..sort();

          return ListView(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHead(
                      icon: Icons.store_mall_directory_outlined,
                      title: 'Shops & categories',
                      subtitle: 'Browse vendors inside this market by category.',
                    ),
                    if (widget.location != null && widget.location!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.location!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '${filteredShops.length} shops shown',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.teal,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCategorySelector(),
              const SizedBox(height: 16),
              _buildActiveTagBanner(),
              if (filteredShops.isEmpty)
                _EmptyShopsFilter(onClear: _clearFilters)
              else
                for (final category in categories) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      category.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.teal,
                          ),
                    ),
                  ),
                  ...grouped[category]!.map(
                    (shop) => _ShopListTile(
                      shop: shop,
                      marketName: widget.marketName,
                      selectedTag: _selectedTag,
                      onTagTap: (tag) {
                        setState(() {
                          _selectedTag = tag;
                        });
                      },
                      onTap: () => Navigator.of(context).pushNamed(
                        ShoppandaApp.shopDetailRoute,
                        arguments: {
                          'shopId': shop.id,
                          'shopName': shop.name,
                          'category': shop.category,
                          'marketName': widget.marketName,
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _ShopListTile extends StatelessWidget {
  const _ShopListTile({
    required this.shop,
    this.marketName,
    this.selectedTag,
    this.onTagTap,
    this.onTap,
  });

  final ShopItem shop;
  final String? marketName;
  final String? selectedTag;
  final ValueChanged<String>? onTagTap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: AppCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: shop.imageUrl != null && shop.imageUrl!.isNotEmpty
                      ? Image.network(
                          shop.imageUrl!,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shop.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (shop.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: shop.tags.map((tag) {
                            final isSelectedTag = selectedTag == tag;
                            return GestureDetector(
                              onTap: () => onTagTap?.call(tag),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isSelectedTag
                                      ? AppColors.teal
                                      : AppColors.primarySoft.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSelectedTag ? AppColors.tealMid : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: GoogleFonts.ibmPlexSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isSelectedTag ? Colors.white : AppColors.teal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Icon(Icons.chevron_right, color: AppColors.textLight),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            AppColors.primarySoft.withValues(alpha: 0.6),
            AppColors.bgMid.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: const Icon(Icons.storefront, color: AppColors.teal, size: 28),
    );
  }
}

class _EmptyShopsFilter extends StatelessWidget {
  const _EmptyShopsFilter({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.storefront_outlined, size: 48, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(
            'No matching shops',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t find any shops in this market that match your selected category or tag.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onClear,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }
}
