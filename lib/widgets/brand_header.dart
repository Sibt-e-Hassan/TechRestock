import 'package:flutter/material.dart';
import 'package:tech_restock/theme/app_theme.dart';
import 'package:tech_restock/widgets/brand_logo.dart';

class BrandHeaderCenter extends StatelessWidget {
  const BrandHeaderCenter({
    super.key,
    this.subtitle = 'Welcome back.',
    this.logoSize = 72,
  });

  final String subtitle;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BrandLogo(size: logoSize),
        const SizedBox(height: 16),
        Text('TechRestock', style: AppTheme.brandSerif),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class BrandHeaderInline extends StatelessWidget {
  const BrandHeaderInline({
    super.key,
    this.subtitle = 'Discover markets & shops',
    this.compact = false,
  });

  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 40.0 : 48.0;
    return Row(
      children: [
        BrandLogo(size: logoSize, borderRadius: compact ? 12 : 14),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TechRestock',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.brandSerif.copyWith(
                  fontSize: compact ? 20 : 22,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
