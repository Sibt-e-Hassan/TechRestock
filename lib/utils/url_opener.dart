import 'package:flutter/material.dart';
import 'package:tech_restock/config/legal_urls.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> openExternalUrl(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    _showError(context, 'Invalid link.');
    return false;
  }

  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      _showError(context, 'Could not open link in browser.');
    }
    return launched;
  } catch (_) {
    if (context.mounted) {
      _showError(context, 'Could not open link in browser.');
    }
    return false;
  }
}

Future<bool> openSupportEmail(
  BuildContext context, {
  String subject = 'TechRestock support',
  String body = '',
}) async {
  final uri = Uri(
    scheme: 'mailto',
    path: LegalUrls.supportEmail,
  ).replace(
    queryParameters: {
      if (subject.isNotEmpty) 'subject': subject,
      if (body.isNotEmpty) 'body': body,
    },
  );

  try {
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      _showError(context, 'Could not open your email app. Email us at ${LegalUrls.supportEmail}.');
    }
    return launched;
  } catch (_) {
    if (context.mounted) {
      _showError(context, 'Could not open your email app. Email us at ${LegalUrls.supportEmail}.');
    }
    return false;
  }
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
