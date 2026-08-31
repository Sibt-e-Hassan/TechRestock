import 'package:flutter/material.dart';
import 'package:tech_restock/theme/app_colors.dart';
import 'package:tech_restock/theme/app_theme.dart';
import 'package:tech_restock/widgets/gradient_scaffold.dart';

/// A simple titled information screen (used for Help and About), rendered as a
/// list of heading + body sections.
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key, required this.title, required this.sections});

  final String title;
  final List<({String heading, String body})> sections;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          itemCount: sections.length,
          separatorBuilder: (_, __) => const SizedBox(height: 18),
          itemBuilder: (context, i) {
            final s = sections[i];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: AppColors.borderInput),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.heading, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(s.body, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Help content for TechRestock.
const List<({String heading, String body})> kHelpSections = [
  (
    heading: 'How ordering works',
    body:
        'Browse products by category, add cartons to your order sheet, then send '
        'an order request. A TechRestock rep confirms the price and delivery with '
        'you directly — you are not charged in the app.'
  ),
  (
    heading: 'Bulk pricing',
    body:
        'Many products have bulk tiers — the more cartons you order, the lower the '
        'per-unit rate. Your current rate is highlighted on the product screen.'
  ),
  (
    heading: 'Restock reminders',
    body:
        'Set a reminder on any product to be nudged when it is time to reorder, so '
        'fast-moving stock never runs out.'
  ),
  (
    heading: 'Need more help?',
    body: 'Email shankhaan0001@gmail.com and we will get back to you.'
  ),
];

/// About content for TechRestock.
const List<({String heading, String body})> kAboutSections = [
  (
    heading: 'TechRestock',
    body:
        'Wholesale mobile accessories & tech supplies ordering for retail stores and repair shops. '
        'Restock your store at wholesale rates — order fast chargers, cables, cases, and repair parts in bulk.'
  ),
  (
    heading: 'Who it is for',
    body:
        'Mobile accessory stores, electronics retailers, and tech repair shops that restock regularly from '
        'wholesale importers and hardware distributors.'
  ),
  (heading: 'Version', body: 'TechRestock v2.0.5'),
];
