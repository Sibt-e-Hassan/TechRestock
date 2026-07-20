import 'package:flutter/material.dart';
import 'package:shop_pandaa/config/legal_urls.dart';
import 'package:shop_pandaa/theme/app_theme.dart';
import 'package:shop_pandaa/utils/url_opener.dart';
import 'package:shop_pandaa/widgets/account_deletion_sheet.dart';
import 'package:shop_pandaa/widgets/app_card.dart';
import 'package:shop_pandaa/widgets/gradient_scaffold.dart';
import 'package:shop_pandaa/widgets/primary_button.dart';
import 'package:shop_pandaa/widgets/section_head.dart';

class LegalCenterScreen extends StatelessWidget {
  const LegalCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Legal center'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        children: [
          const SectionHead(
            icon: Icons.gavel_outlined,
            title: 'Policies and account',
            subtitle: 'Review how we handle data and how to manage your account.',
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Privacy Policy', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'How we collect and use account data, inquiries, and your privacy rights. Opens the full policy in your browser.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SecondaryButton(
                  label: 'Open Privacy Policy',
                  onPressed: () => openExternalUrl(context, LegalUrls.privacyPolicy),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Terms of Service', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Rules for using ThokBazaar as a discovery and inquiry app, including account creation and agreement to these terms and the Privacy Policy. Opens full terms in your browser.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SecondaryButton(
                  label: 'Open Terms of Service',
                  onPressed: () => openExternalUrl(context, LegalUrls.termsOfService),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Account deletion', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  'Delete your account in the app (Profile) or contact support by email for help with account removal.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                SecondaryButton(
                  label: 'Account deletion help',
                  onPressed: () => showAccountDeletionSheet(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Support: ${LegalUrls.supportEmail}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
