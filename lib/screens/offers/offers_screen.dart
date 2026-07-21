import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shop_pandaa/app.dart';
import 'package:shop_pandaa/data/models.dart';
import 'package:shop_pandaa/theme/app_colors.dart';
import 'package:shop_pandaa/theme/app_theme.dart';
import 'package:shop_pandaa/widgets/brand_logo.dart';
import 'package:shop_pandaa/widgets/product_card.dart';

/// Offers tab — bulk deals and badged products across the ThokBazaar catalog.
/// A product is an "offer" when it carries a `badge` (e.g. "Bulk", "Deal").
class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  Stream<List<ProductItem>> _offersStream() {
    return FirebaseFirestore.instance.collection('products').snapshots().map(
          (snap) => snap.docs
              .map((d) => ProductItem.fromMap(d.id, d.data()))
              .where((p) => p.isOffer)
              .toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Column(
        children: [
          Container(
            color: AppColors.header,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                child: Row(
                  children: [
                    const BrandLogo(size: 44, borderRadius: 12),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Offers',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Bulk deals and wholesale discounts',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.65),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.local_offer_outlined, color: AppColors.accent, size: 26),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              clipBehavior: Clip.antiAlias,
              child: StreamBuilder<List<ProductItem>>(
                stream: _offersStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Failed to load offers from Firestore.'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.teal));
                  }
                  final offers = snapshot.data!;
                  if (offers.isEmpty) {
                    return const _EmptyOffers();
                  }
                  return ListView(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    children: [
                      _OfferBanner(count: offers.length),
                      const SizedBox(height: 20),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.62,
                        ),
                        itemCount: offers.length,
                        itemBuilder: (context, i) => ProductCard(
                          product: offers[i],
                          onTap: () => Navigator.of(context).pushNamed(
                            ShoppandaApp.productRoute,
                            arguments: offers[i].id,
                          ),
                        ),
                      ),
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
}

class _OfferBanner extends StatelessWidget {
  const _OfferBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.logoGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wholesale deals live now',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count product(s) on bulk offer — order more, pay less.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(Icons.savings_outlined, color: AppColors.tealDark, size: 28),
          ),
        ],
      ),
    );
  }
}

class _EmptyOffers extends StatelessWidget {
  const _EmptyOffers();

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
              child: const Icon(Icons.local_offer_outlined, size: 34, color: AppColors.teal),
            ),
            const SizedBox(height: 16),
            Text('No offers right now', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Check back soon — bulk deals and discounts show up here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
