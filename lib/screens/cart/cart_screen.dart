import 'package:flutter/material.dart';
import 'package:shop_pandaa/app.dart';
import 'package:shop_pandaa/data/media_urls.dart';
import 'package:shop_pandaa/data/models.dart';
import 'package:shop_pandaa/screens/order/order_result_screen.dart';
import 'package:shop_pandaa/services/cart_service.dart';
import 'package:shop_pandaa/theme/app_colors.dart';
import 'package:shop_pandaa/theme/app_theme.dart';
import 'package:shop_pandaa/widgets/brand_logo.dart';
import 'package:shop_pandaa/widgets/cart_scope.dart';
import 'package:shop_pandaa/widgets/gradient_scaffold.dart';
import 'package:shop_pandaa/widgets/primary_button.dart';
import 'package:shop_pandaa/widgets/product_network_image.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isSubmitting = false;

  Future<void> _submitInquiry(CartService cart) async {
    setState(() => _isSubmitting = true);
    try {
      // Writes the order to Firestore (users' order-request record) and clears
      // the order sheet on success.
      final orderId = await cart.submitInquiry();
      if (!mounted) return;
      // Success → celebratory result screen (replaces the cart in the stack).
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderResultScreen.success(orderId: orderId),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('StateError: ', '');
      // Failure → "try again" result screen kept on top of the cart, so
      // "Please try again" pops back and re-submits the still-intact order.
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrderResultScreen.failure(
            message: message,
            onTryAgain: () {
              Navigator.of(context).pop();
              _submitInquiry(cart);
            },
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);

    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Order sheet'),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          final items = cart.items;
          final isBusy = _isSubmitting || cart.isSubmitting;

          return SafeArea(
            child: items.isEmpty
                ? const _EmptyCart()
                : ListView(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    children: [
                      Text(
                        'Bulk items ready to send to your suppliers as an order request',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                    ...items.map(
                      (line) => _CartLineTile(
                        line: line,
                        onRemove: () => cart.removeItem(line.productId),
                        onOpenProduct: () => Navigator.of(context).pushNamed(
                          ShoppandaApp.productRoute,
                          arguments: line.productId,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${cart.itemCount} items · ${CartService.formatOrderTotal(items)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Send order request',
                      isLoading: isBusy,
                      onPressed: isBusy ? () {} : () => _submitInquiry(cart),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Order requests are non-binding. Suppliers confirm price & delivery directly.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
          );
        },
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({
    required this.line,
    required this.onRemove,
    required this.onOpenProduct,
  });

  final CartLineItem line;
  final VoidCallback onRemove;
  final VoidCallback onOpenProduct;

  @override
  Widget build(BuildContext context) {
    final product = line.product;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderInput),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onOpenProduct,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: ProductNetworkImage(
                  imageUrl: MediaUrls.product(product) ?? product.imageUrl,
                  borderRadius: BorderRadius.circular(12),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onOpenProduct,
                  child: Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${product.shopName} · ${product.priceLabel}${line.quantity > 1 ? ' · Qty ${line.quantity}' : ''}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Remove'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandLogo(size: 48, borderRadius: 12),
            const SizedBox(height: 16),
            Text('Your order sheet is empty', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Browse wholesale products and tap Add to order to build a bulk order.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
