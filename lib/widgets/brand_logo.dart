import 'package:flutter/material.dart';
import 'package:shop_pandaa/theme/app_colors.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 72, this.borderRadius = 18});

  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: AppColors.logoGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.tealDark.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomPaint(painter: _ThokBazaarPainter()),
    );
  }
}

/// ThokBazaar mark: a khata (ledger) page — ruled entry lines with a bold
/// mustard "running balance" underline at the foot. Signals wholesale
/// bookkeeping rather than a consumer storefront. White + mustard on navy.
class _ThokBazaarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Ledger page.
    final pageRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.26, h * 0.22, w * 0.48, h * 0.56),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(
      pageRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.96)
        ..isAntiAlias = true,
    );

    // Ruled entry lines.
    final rulePaint = Paint()
      ..color = AppColors.tealMid.withValues(alpha: 0.55)
      ..strokeWidth = w * 0.028
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    final lx1 = w * 0.34;
    final lx2 = w * 0.66;
    for (final t in [0.36, 0.47, 0.58]) {
      canvas.drawLine(Offset(lx1, h * t), Offset(lx2, h * t), rulePaint);
    }

    // Mustard "running balance" underline at the foot of the page.
    final balancePaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawLine(Offset(lx1, h * 0.69), Offset(w * 0.60, h * 0.69), balancePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
