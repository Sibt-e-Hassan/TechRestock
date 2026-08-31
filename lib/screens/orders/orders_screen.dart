import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tech_restock/data/models.dart';
import 'package:tech_restock/theme/app_colors.dart';
import 'package:tech_restock/theme/app_theme.dart';
import 'package:tech_restock/widgets/brand_logo.dart';
import 'package:tech_restock/widgets/gradient_scaffold.dart';
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key, this.showBack = true});

  /// When embedded as a bottom-nav tab there is nothing to pop back to.
  final bool showBack;

  Stream<List<OrderRecord>> _ordersStream(String uid) {
    return FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs
              .map((doc) => OrderRecord.fromMap(doc.id, doc.data()))
              .toList();
          orders.sort((a, b) {
            final aTime = a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });
          return orders;
        });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return GradientScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: showBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: showBack
            ? const Text('My orders')
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BrandLogo(size: 32, borderRadius: 8),
                  SizedBox(width: 10),
                  Text('My orders'),
                ],
              ),
        centerTitle: true,
      ),
      body: user == null
          ? const Center(child: Text('Sign in to view your orders.'))
          : StreamBuilder<List<OrderRecord>>(
              stream: _ordersStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppTheme.spacingLg),
                      child: Text('Failed to load orders from Firestore.'),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.teal));
                }

                final orders = snapshot.data!;
                if (orders.isEmpty) {
                  return const _EmptyOrders();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) => _OrderCard(order: orders[index]),
                );
              },
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderRecord order;

  String _formattedDate(BuildContext context) {
    final date = order.timestamp;
    if (date == null) {
      return 'Submitted recently';
    }
    final month = _monthLabel(date.month);
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$month ${date.day}, ${date.year} · $hour:$minute $period';
  }

  static String _monthLabel(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.borderInput),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined, color: AppColors.teal, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _formattedDate(context),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
                ),
              ),
              if (order.status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    order.status!.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.tealDark,
                          fontSize: 10,
                        ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(order.totalPrice, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• ${item.quantity > 1 ? '${item.quantity}× ' : ''}${item.title} (${item.shopName})',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BrandLogo(size: 48, borderRadius: 12),
            const SizedBox(height: 16),
            Text('No orders yet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Add wholesale items to your order sheet and tap Send order request to place your first order.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
