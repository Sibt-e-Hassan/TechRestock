import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_pandaa/data/media_urls.dart';
import 'package:shop_pandaa/data/models.dart';
import 'package:shop_pandaa/theme/app_colors.dart';
import 'package:shop_pandaa/theme/app_theme.dart';
import 'package:shop_pandaa/widgets/app_card.dart';
import 'package:shop_pandaa/widgets/cart_scope.dart';
import 'package:shop_pandaa/widgets/gradient_scaffold.dart';
import 'package:shop_pandaa/widgets/primary_button.dart';
import 'package:shop_pandaa/widgets/product_network_image.dart';
import 'package:shop_pandaa/widgets/restock_reminder_sheet.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Product'),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('products').doc(productId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load product from Firestore.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data();
          if (data == null) {
            return const Center(child: Text('Product not found'));
          }

          final product = ProductItem.fromMap(snapshot.data!.id, data);
          return _ProductBody(product: product);
        },
      ),
    );
  }
}

class _ProductBody extends StatefulWidget {
  const _ProductBody({required this.product});

  final ProductItem product;

  @override
  State<_ProductBody> createState() => _ProductBodyState();
}

class _ProductBodyState extends State<_ProductBody> {
  late int _qty = widget.product.minOrderQty < 1 ? 1 : widget.product.minOrderQty;
  bool _isAdding = false;

  ProductItem get _product => widget.product;

  /// Best (lowest) per-unit price applicable at [_qty], based on tiers.
  String get _activePriceLabel {
    final tiers = _product.priceTiers;
    if (tiers.isEmpty) return _product.priceLabel;
    final sorted = [...tiers]..sort((a, b) => a.minQty.compareTo(b.minQty));
    String label = sorted.first.priceLabel;
    for (final t in sorted) {
      if (_qty >= t.minQty) label = t.priceLabel;
    }
    return label;
  }

  /// Parses the first number out of a price label like "Rs 1,200" → 1200.
  int? get _activeUnitPrice {
    final digits = RegExp(r'[\d,]+')
        .firstMatch(_activePriceLabel)
        ?.group(0)
        ?.replaceAll(',', '');
    return digits == null ? null : int.tryParse(digits);
  }

  void _setQty(int value) {
    final min = _product.minOrderQty < 1 ? 1 : _product.minOrderQty;
    setState(() => _qty = value < min ? min : value);
  }

  Future<void> _addToOrder() async {
    setState(() => _isAdding = true);
    try {
      await CartScope.of(context).addProduct(_product, quantity: _qty);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added $_qty ${_product.unitLabel}(s) to your order')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('StateError: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final unitPrice = _activeUnitPrice;
    final lineTotal = unitPrice == null ? null : unitPrice * _qty;

    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      children: [
        AspectRatio(
          aspectRatio: 4 / 5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              boxShadow: AppColors.cardShadow,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ProductNetworkImage(
                  imageUrl: MediaUrls.product(product) ?? product.imageUrl,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                ),
                if (product.badge != null)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.badge!.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.tealDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          product.shopName.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.teal,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          product.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 26),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              _activePriceLabel,
              style: AppTheme.mono(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.tealDark,
              ),
            ),
            const SizedBox(width: 6),
            Text('/ ${product.unitLabel}', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 20),

        // ---- Wholesale terms (MOQ + unit) ----
        Row(
          children: [
            Expanded(
              child: _TermChip(
                icon: Icons.inventory_2_outlined,
                label: 'Min order',
                value: '${product.minOrderQty} ${product.unitLabel}(s)',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TermChip(
                icon: Icons.local_shipping_outlined,
                label: 'Sold by',
                value: product.unitLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ---- Bulk pricing tiers ----
        if (product.priceTiers.isNotEmpty) ...[
          _BulkTierTable(product: product, activeQty: _qty),
          const SizedBox(height: 16),
        ],

        // ---- Quantity stepper + live line total ----
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Order quantity', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QtyStepper(
                    qty: _qty,
                    min: product.minOrderQty < 1 ? 1 : product.minOrderQty,
                    onChanged: _setQty,
                  ),
                  if (lineTotal != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Estimated total',
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 2),
                        Text(
                          formatRupees(lineTotal),
                          style: AppTheme.mono(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.credit,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Wholesale details', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Stocked by ${product.shopName}. Add cartons to your order sheet, '
                'then send the supplier a bulk order request — pricing and delivery '
                'are confirmed directly with the supplier.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        PrimaryButton(
          label: 'Add to order',
          isLoading: _isAdding,
          onPressed: _isAdding ? () {} : _addToOrder,
        ),
        const SizedBox(height: 12),
        SecondaryButton(
          label: 'Set restock reminder',
          onPressed: () => RestockReminderSheet.show(
            context,
            productTitle: product.title,
            supplierName: product.shopName,
            productId: product.id,
          ),
        ),
      ],
    );
  }
}

class _TermChip extends StatelessWidget {
  const _TermChip({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.borderInput),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 1),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BulkTierTable extends StatelessWidget {
  const _BulkTierTable({required this.product, required this.activeQty});

  final ProductItem product;
  final int activeQty;

  @override
  Widget build(BuildContext context) {
    final tiers = [...product.priceTiers]..sort((a, b) => a.minQty.compareTo(b.minQty));
    // Determine which tier is active at the current quantity (highest minQty
    // that the quantity satisfies).
    int activeIndex = 0;
    for (var i = 0; i < tiers.length; i++) {
      if (activeQty >= tiers[i].minQty) activeIndex = i;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.borderInput),
        boxShadow: AppColors.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: AppColors.primarySoft,
            child: Row(
              children: [
                const Icon(Icons.savings_outlined, size: 18, color: AppColors.teal),
                const SizedBox(width: 8),
                Text('Bulk pricing — more cartons, lower rate',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 13, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          for (var i = 0; i < tiers.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              color: i == activeIndex ? AppColors.accentSoft : Colors.transparent,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      i == tiers.length - 1
                          ? '${tiers[i].minQty}+ ${product.unitLabel}s'
                          : '${tiers[i].minQty}–${tiers[i + 1].minQty - 1} ${product.unitLabel}s',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.text,
                            fontWeight: i == activeIndex ? FontWeight.w700 : FontWeight.w500,
                          ),
                    ),
                  ),
                  Text(
                    tiers[i].priceLabel,
                    style: AppTheme.mono(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: i == activeIndex ? AppColors.tealDark : AppColors.textMuted,
                    ),
                  ),
                  if (i == activeIndex) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text('YOUR RATE',
                          style: AppTheme.mono(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.tealDark,
                          )),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({required this.qty, required this.min, required this.onChanged});

  final int qty;
  final int min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSoft,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.borderInput),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            enabled: qty > min,
            onTap: () => onChanged(qty - 1),
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 52),
            alignment: Alignment.center,
            child: Text(
              '$qty',
              style: AppTheme.mono(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            enabled: true,
            onTap: () => onChanged(qty + 1),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.enabled, required this.onTap});

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.teal : AppColors.textLight,
        ),
      ),
    );
  }
}
