import 'package:flutter/material.dart';
import 'package:shop_pandaa/screens/orders/orders_screen.dart';
import 'package:shop_pandaa/theme/app_colors.dart';
import 'package:shop_pandaa/theme/app_theme.dart';
import 'package:shop_pandaa/widgets/brand_logo.dart';
import 'package:shop_pandaa/widgets/gradient_scaffold.dart';
import 'package:shop_pandaa/widgets/primary_button.dart';

/// Full-screen result shown after a shopkeeper sends an order request:
/// a celebratory "accepted" state, or a "failed — try again" state.
class OrderResultScreen extends StatelessWidget {
  const OrderResultScreen._({
    required this.success,
    this.orderId,
    this.message,
    this.onTryAgain,
  });

  /// Order stored in Firestore successfully.
  factory OrderResultScreen.success({String? orderId}) =>
      OrderResultScreen._(success: true, orderId: orderId);

  /// Order submission failed.
  factory OrderResultScreen.failure({String? message, VoidCallback? onTryAgain}) =>
      OrderResultScreen._(success: false, message: message, onTryAgain: onTryAgain);

  final bool success;
  final String? orderId;
  final String? message;
  final VoidCallback? onTryAgain;

  void _backToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _trackOrder(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OrdersScreen(showBack: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            children: [
              const Spacer(),
              const BrandLogo(size: 40, borderRadius: 10),
              const SizedBox(height: 20),
              success ? const _SuccessMark() : const _FailureMark(),
              const SizedBox(height: 28),
              Text(
                success ? 'Your order has been accepted' : 'Oops! Order failed',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                success
                    ? 'Your order request has been placed and sent to ThokBazaar. '
                        'Our team will confirm price and delivery with you shortly.'
                    : (message == null || message!.isEmpty
                        ? 'Something went wrong while sending your order.'
                        : message!),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (success && orderId != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Order #${orderId!.substring(0, orderId!.length < 6 ? orderId!.length : 6).toUpperCase()}',
                    style: AppTheme.mono(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.tealDark,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (success)
                PrimaryButton(label: 'Track order', onPressed: () => _trackOrder(context))
              else
                PrimaryButton(
                  label: 'Please try again',
                  onPressed: onTryAgain ?? () => Navigator.of(context).pop(),
                ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _backToHome(context),
                style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
                child: const Text('Back to home', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Green check badge with a scattering of celebratory dots.
class _SuccessMark extends StatelessWidget {
  const _SuccessMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // confetti dots
          _dot(20, 30, AppColors.accent, 10),
          _dot(150, 24, AppColors.credit, 8),
          _dot(30, 130, AppColors.teal, 9),
          _dot(158, 140, AppColors.accent, 7),
          _dot(90, 8, AppColors.debit, 7),
          Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.credit,
              boxShadow: [
                BoxShadow(
                  color: AppColors.credit.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 62),
          ),
        ],
      ),
    );
  }

  Widget _dot(double left, double top, Color color, double size) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

/// Red-tinted failure badge.
class _FailureMark extends StatelessWidget {
  const _FailureMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      height: 118,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.danger.withValues(alpha: 0.12),
      ),
      child: const Icon(Icons.remove_shopping_cart_outlined,
          color: AppColors.danger, size: 54),
    );
  }
}
