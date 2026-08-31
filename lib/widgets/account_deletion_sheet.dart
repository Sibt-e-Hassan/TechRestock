import 'package:flutter/material.dart';
import 'package:tech_restock/config/legal_urls.dart';
import 'package:tech_restock/theme/app_colors.dart';
import 'package:tech_restock/theme/app_theme.dart';
import 'package:tech_restock/utils/url_opener.dart';
import 'package:tech_restock/widgets/primary_button.dart';

/// Bottom sheet with in-app and email options for account deletion.
Future<void> showAccountDeletionSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusCard)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          AppTheme.spacingLg,
          0,
          AppTheme.spacingLg,
          AppTheme.spacingLg + MediaQuery.paddingOf(sheetContext).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Delete your account', style: Theme.of(sheetContext).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(
              'You can permanently delete your TechRestock account from the app:',
              style: Theme.of(sheetContext).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              '1. Open Profile → Delete account\n'
              '2. Enter your password to confirm\n'
              '3. Your profile, cart, and inquiry history will be removed',
              style: Theme.of(sheetContext).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Need help or want us to process a request? Contact support:',
              style: Theme.of(sheetContext).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              LegalUrls.supportEmail,
              style: Theme.of(sheetContext).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.tealDark,
                  ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Email support',
              onPressed: () {
                Navigator.of(sheetContext).pop();
                openSupportEmail(
                  context,
                  subject: 'TechRestock account deletion request',
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
