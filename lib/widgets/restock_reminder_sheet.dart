import 'package:flutter/material.dart';
import 'package:tech_restock/services/restock_service.dart';
import 'package:tech_restock/theme/app_colors.dart';
import 'package:tech_restock/theme/app_theme.dart';
import 'package:tech_restock/widgets/primary_button.dart';

/// Bottom sheet to schedule a recurring restock reminder for a product.
class RestockReminderSheet extends StatefulWidget {
  const RestockReminderSheet({
    super.key,
    required this.productTitle,
    required this.supplierName,
    this.productId,
  });

  final String productTitle;
  final String supplierName;
  final String? productId;

  static Future<void> show(
    BuildContext context, {
    required String productTitle,
    required String supplierName,
    String? productId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (_) => RestockReminderSheet(
        productTitle: productTitle,
        supplierName: supplierName,
        productId: productId,
      ),
    );
  }

  @override
  State<RestockReminderSheet> createState() => _RestockReminderSheetState();
}

class _RestockReminderSheetState extends State<RestockReminderSheet> {
  int _everyDays = 7;

  static const _options = <({String label, int days})>[
    (label: 'Weekly', days: 7),
    (label: 'Every 2 weeks', days: 14),
    (label: 'Monthly', days: 30),
    (label: 'Every 45 days', days: 45),
  ];

  Future<void> _save() async {
    await RestockService.instance.addReminder(
      productTitle: widget.productTitle,
      supplierName: widget.supplierName,
      everyDays: _everyDays,
      productId: widget.productId,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Restock reminder set — every $_everyDays days.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Restock reminder', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            widget.productTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text('Remind me to reorder', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _options.map((o) {
              final selected = _everyDays == o.days;
              return GestureDetector(
                onTap: () => setState(() => _everyDays = o.days),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.teal : AppColors.bgSoft,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected ? AppColors.teal : AppColors.borderInput,
                    ),
                  ),
                  child: Text(
                    o.label,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Set reminder', onPressed: _save),
        ],
      ),
    );
  }
}
