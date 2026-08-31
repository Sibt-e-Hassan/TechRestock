import 'package:flutter/material.dart';
import 'package:tech_restock/config/legal_urls.dart';
import 'package:tech_restock/theme/app_colors.dart';
import 'package:tech_restock/theme/app_theme.dart';
import 'package:tech_restock/utils/url_opener.dart';
import 'package:tech_restock/widgets/legal_link.dart';
import 'package:tech_restock/widgets/primary_button.dart';

class DividerOr extends StatelessWidget {
  const DividerOr({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingLg),
      child: Row(
        children: [
          Expanded(child: Divider(color: AppColors.borderInput)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('or', style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: Divider(color: AppColors.borderInput)),
        ],
      ),
    );
  }
}

class AuthLinksRow extends StatelessWidget {
  const AuthLinksRow({
    super.key,
    required this.onForgotPassword,
    required this.onCreateAccount,
  });

  final VoidCallback onForgotPassword;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final links = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _AuthLink(
              icon: Icons.lock_outline,
              label: 'Forgot password?',
              onTap: onForgotPassword,
            ),
            Container(
              width: 1,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              color: AppColors.borderInput,
            ),
            _AuthLink(
              icon: Icons.person_outline,
              label: 'Create account',
              onTap: onCreateAccount,
            ),
          ],
        );

        if (constraints.maxWidth == double.infinity) {
          return Center(child: links);
        }

        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: links,
          ),
        );
      },
    );
  }
}

class _AuthLink extends StatelessWidget {
  const _AuthLink({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.teal),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTheme.link.copyWith(fontSize: 13),
              maxLines: 1,
              softWrap: false,
            ),
          ],
        ),
      ),
    );
  }
}

class FooterLegal extends StatelessWidget {
  const FooterLegal({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        children: [
          Text(
            'By signing in, you agree to our',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              LegalLinkText(
                label: 'Terms of Service',
                url: LegalUrls.termsOfService,
                style: AppTheme.link.copyWith(fontSize: 12),
              ),
              Text(', ', style: Theme.of(context).textTheme.bodySmall),
              LegalLinkText(
                label: 'Privacy Policy',
                url: LegalUrls.privacyPolicy,
                style: AppTheme.link.copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

}

class LegalBlock extends StatelessWidget {
  const LegalBlock({super.key, this.onLegalCenter});

  final VoidCallback? onLegalCenter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'LEGAL',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SecondaryButton(
                label: 'Privacy Policy',
                onPressed: () => openExternalUrl(context, LegalUrls.privacyPolicy),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SecondaryButton(
                label: 'Terms',
                onPressed: () => openExternalUrl(context, LegalUrls.termsOfService),
              ),
            ),
          ],
        ),
        if (onLegalCenter != null) ...[
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: onLegalCenter,
              child: Text('Legal center in app', style: AppTheme.link),
            ),
          ),
        ],
      ],
    );
  }
}
