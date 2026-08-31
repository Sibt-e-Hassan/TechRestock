import 'package:flutter/material.dart';
import 'package:tech_restock/theme/app_theme.dart';
import 'package:tech_restock/utils/url_opener.dart';

/// Tappable legal text that opens a URL in the device browser.
class LegalLinkText extends StatelessWidget {
  const LegalLinkText({
    super.key,
    required this.label,
    required this.url,
    this.style,
  });

  final String label;
  final String url;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openExternalUrl(context, url),
      child: Text(
        label,
        style: style ?? AppTheme.link.copyWith(fontSize: 13),
      ),
    );
  }
}
