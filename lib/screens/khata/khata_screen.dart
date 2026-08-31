import 'package:flutter/material.dart';
import 'package:tech_restock/data/media_urls.dart';
import 'package:tech_restock/data/models.dart';
import 'package:tech_restock/services/khata_service.dart';
import 'package:tech_restock/theme/app_colors.dart';
import 'package:tech_restock/theme/app_theme.dart';
import 'package:tech_restock/screens/khata/supplier_ledger_screen.dart';
import 'package:tech_restock/widgets/brand_logo.dart';
import 'package:tech_restock/widgets/product_network_image.dart';
import 'package:tech_restock/widgets/primary_button.dart';

/// TechRestock's signature screen — the khata: a running udhaar (credit)
/// balance with each wholesale supplier. Lives in the bottom nav.
class KhataScreen extends StatefulWidget {
  const KhataScreen({super.key, this.showBack = false});

  final bool showBack;

  @override
  State<KhataScreen> createState() => _KhataScreenState();
}

class _KhataScreenState extends State<KhataScreen> {
  final _khata = KhataService.instance;

  @override
  void initState() {
    super.initState();
    _khata.load();
  }

  Future<void> _openAddSupplier() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (_) => const _AddSupplierSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _KhataHeader(showBack: widget.showBack),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.bgMid,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListenableBuilder(
              listenable: _khata,
              builder: (context, _) {
                final suppliers = _khata.suppliers;
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  children: [
                    _OutstandingCard(total: _khata.totalOutstanding),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Suppliers', style: Theme.of(context).textTheme.titleMedium),
                        TextButton.icon(
                          onPressed: _openAddSupplier,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                          style: TextButton.styleFrom(foregroundColor: AppColors.teal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (suppliers.isEmpty)
                      const _EmptyKhata()
                    else
                      ...suppliers.map((s) => _SupplierTile(supplier: s)),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _KhataHeader extends StatelessWidget {
  const _KhataHeader({required this.showBack});

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.header,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
          child: Row(
            children: [
              if (showBack)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              if (showBack) const SizedBox(width: 12),
              if (!showBack) ...[
                const BrandLogo(size: 44, borderRadius: 12),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Khata',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your running balance with each supplier',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white.withValues(alpha: 0.65)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.menu_book_outlined, color: AppColors.accent, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}

class _OutstandingCard extends StatelessWidget {
  const _OutstandingCard({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final owed = total > 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.logoGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            owed ? 'Total udhaar outstanding' : 'You are all cleared',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white.withValues(alpha: 0.75), letterSpacing: 0.3),
          ),
          const SizedBox(height: 8),
          Text(
            formatRupees(total),
            style: AppTheme.mono(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: total >= 0 ? AppColors.accent : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            owed
                ? 'Payable to your wholesale suppliers'
                : 'No pending balance with any supplier',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white.withValues(alpha: 0.65)),
          ),
        ],
      ),
    );
  }
}

class _SupplierTile extends StatelessWidget {
  const _SupplierTile({required this.supplier});

  final KhataSupplier supplier;

  @override
  Widget build(BuildContext context) {
    final balance = supplier.balance;
    final owed = balance > 0;
    final balanceColor = balance == 0
        ? AppColors.credit
        : (owed ? AppColors.debit : AppColors.credit);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SupplierLedgerScreen(supplierId: supplier.id),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: ProductNetworkImage(
                      imageUrl: MediaUrls.khataSupplier(supplier),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplier.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        supplier.market,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatRupees(balance),
                      style: AppTheme.mono(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: balanceColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      balance == 0 ? 'cleared' : (owed ? 'you owe' : 'in credit'),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: balanceColor, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyKhata extends StatelessWidget {
  const _EmptyKhata();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
            child: const Icon(Icons.menu_book_outlined, size: 34, color: AppColors.teal),
          ),
          const SizedBox(height: 16),
          Text('No suppliers yet', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            'Add a wholesale supplier to start tracking your udhaar.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _AddSupplierSheet extends StatefulWidget {
  const _AddSupplierSheet();

  @override
  State<_AddSupplierSheet> createState() => _AddSupplierSheetState();
}

class _AddSupplierSheetState extends State<_AddSupplierSheet> {
  final _name = TextEditingController();
  final _market = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _market.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final market = _market.text.trim();
    if (name.isEmpty || market.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a supplier name and market.')),
      );
      return;
    }
    await KhataService.instance.addSupplier(
      name: name,
      market: market,
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
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
          Text('Add supplier', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Supplier name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _market,
            decoration: const InputDecoration(labelText: 'Wholesale market'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone (optional)'),
          ),
          const SizedBox(height: 20),
          PrimaryButton(label: 'Save supplier', onPressed: _save),
        ],
      ),
    );
  }
}
