import 'package:flutter/material.dart';
import 'package:shop_pandaa/data/models.dart';
import 'package:shop_pandaa/services/khata_service.dart';
import 'package:shop_pandaa/theme/app_colors.dart';
import 'package:shop_pandaa/theme/app_theme.dart';
import 'package:shop_pandaa/widgets/gradient_scaffold.dart';
import 'package:shop_pandaa/widgets/primary_button.dart';

/// Per-supplier khata: the running ledger of purchases (udhaar taken) and
/// payments made, with the outstanding balance at the top.
class SupplierLedgerScreen extends StatefulWidget {
  const SupplierLedgerScreen({super.key, required this.supplierId});

  final String supplierId;

  @override
  State<SupplierLedgerScreen> createState() => _SupplierLedgerScreenState();
}

class _SupplierLedgerScreenState extends State<SupplierLedgerScreen> {
  final _khata = KhataService.instance;

  Future<void> _openEntrySheet(KhataEntryType type) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (_) => _AddEntrySheet(supplierId: widget.supplierId, type: type),
    );
  }

  static String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Supplier khata'),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _khata,
        builder: (context, _) {
          final supplier = _khata.supplierById(widget.supplierId);
          if (supplier == null) {
            return const Center(child: Text('Supplier not found.'));
          }
          final entries = supplier.entriesNewestFirst;
          final balance = supplier.balance;
          final owed = balance > 0;
          final balanceColor = balance == 0
              ? AppColors.credit
              : (owed ? AppColors.debit : AppColors.credit);

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    children: [
                      // Supplier + balance card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                          border: Border.all(color: AppColors.borderInput),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(supplier.name,
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 2),
                            Text(supplier.market,
                                style: Theme.of(context).textTheme.bodyMedium),
                            if (supplier.phone != null) ...[
                              const SizedBox(height: 2),
                              Text('☎ ${supplier.phone}',
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                            const Divider(height: 26, color: AppColors.borderInput),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  balance == 0
                                      ? 'Cleared'
                                      : (owed ? 'Outstanding udhaar' : 'In credit'),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  formatRupees(balance),
                                  style: AppTheme.mono(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: balanceColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Ledger', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      if (entries.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No entries yet. Record a purchase or a payment below.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        )
                      else
                        ...entries.map((e) => _LedgerRow(entry: e, dateLabel: _fmtDate(e.date))),
                    ],
                  ),
                ),
                // Action bar
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.borderInput)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openEntrySheet(KhataEntryType.purchase),
                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                          label: const Text('Add udhaar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.debit,
                            side: const BorderSide(color: AppColors.borderInput),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Record payment',
                          onPressed: () => _openEntrySheet(KhataEntryType.payment),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.entry, required this.dateLabel});

  final KhataEntry entry;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    final isPurchase = entry.isPurchase;
    final color = isPurchase ? AppColors.debit : AppColors.credit;
    final sign = isPurchase ? '+' : '−';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: AppColors.borderInput),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Icon(
                isPurchase ? Icons.south_west : Icons.check_circle_outline,
                size: 18,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.note.isEmpty
                        ? (isPurchase ? 'Goods on udhaar' : 'Payment')
                        : entry.note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text('$dateLabel · ${isPurchase ? 'Purchase' : 'Payment'}',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$sign${formatRupees(entry.amount)}',
              style: AppTheme.mono(fontSize: 14, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddEntrySheet extends StatefulWidget {
  const _AddEntrySheet({required this.supplierId, required this.type});

  final String supplierId;
  final KhataEntryType type;

  @override
  State<_AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<_AddEntrySheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();

  bool get _isPurchase => widget.type == KhataEntryType.purchase;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = int.tryParse(_amount.text.trim().replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }
    await KhataService.instance.addEntry(
      supplierId: widget.supplierId,
      amount: amount,
      type: widget.type,
      note: _note.text.trim(),
    );
    if (mounted) Navigator.of(context).pop();
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
          Text(
            _isPurchase ? 'Add goods on udhaar' : 'Record a payment',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            _isPurchase
                ? 'Increases what you owe this supplier.'
                : 'Reduces your outstanding balance.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (Rs)',
              prefixText: 'Rs ',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            decoration: InputDecoration(
              labelText: _isPurchase ? 'What did you buy? (optional)' : 'Note (optional)',
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: _isPurchase ? 'Add udhaar' : 'Record payment',
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
