import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tech_restock/theme/app_colors.dart';

/// Loads a remote catalog or supplier image with loading and error states.
/// URLs are resolved via [MediaUrls] in the app — not Firebase Storage.
class ProductNetworkImage extends StatelessWidget {
  const ProductNetworkImage({
    super.key,
    required this.imageUrl,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(24)),
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final BorderRadius borderRadius;
  final BoxFit fit;

  static const _placeholderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF0F0F0), Color(0xFFE0E0E0), Color(0xFFD8D8D8)],
  );

  bool get _hasUrl {
    final url = imageUrl?.trim();
    return url != null && url.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: _hasUrl
          ? CachedNetworkImage(
              imageUrl: imageUrl!.trim(),
              fit: fit,
              width: double.infinity,
              height: double.infinity,
              placeholder: (_, __) => _loadingPlaceholder(),
              errorWidget: (_, __, ___) => _errorPlaceholder(),
            )
          : _fallbackPlaceholder(),
    );
  }

  Widget _loadingPlaceholder() {
    return Container(
      decoration: const BoxDecoration(gradient: _placeholderGradient),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.teal,
        ),
      ),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      decoration: const BoxDecoration(gradient: _placeholderGradient),
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        size: 40,
        color: AppColors.textLight,
      ),
    );
  }

  Widget _fallbackPlaceholder() {
    return Container(
      decoration: const BoxDecoration(gradient: _placeholderGradient),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 40,
        color: AppColors.textLight,
      ),
    );
  }
}
