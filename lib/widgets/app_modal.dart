import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:tech_restock/theme/app_colors.dart';
import 'package:tech_restock/theme/app_theme.dart';

Future<T?> showAppModal<T>(BuildContext context, {required Widget child}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(color: Colors.transparent),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Material(
                color: Colors.transparent,
                child: FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.96, end: 1).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                    ),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

class AppModalCard extends StatelessWidget {
  const AppModalCard({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final Widget? actions;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: 340, maxHeight: maxHeight),
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.borderInput),
        boxShadow: AppColors.modalShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 22)),
          const SizedBox(height: 12),
          Flexible(
            child: SingleChildScrollView(
              child: child,
            ),
          ),
          if (actions != null) ...[const SizedBox(height: 12), actions!],
        ],
      ),
    );
  }
}
