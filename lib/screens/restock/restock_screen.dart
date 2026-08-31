import 'package:flutter/material.dart';
import 'package:tech_restock/data/models.dart';
import 'package:tech_restock/services/restock_service.dart';
import 'package:tech_restock/theme/app_colors.dart';
import 'package:tech_restock/theme/app_theme.dart';
import 'package:tech_restock/widgets/gradient_scaffold.dart';

/// Manage scheduled restock reminders — the "never run out of stock" tool for
/// shopkeepers. Reminders are added from a product's detail screen.
class RestockScreen extends StatefulWidget {
  const RestockScreen({super.key});

  @override
  State<RestockScreen> createState() => _RestockScreenState();
}

class _RestockScreenState extends State<RestockScreen> {
  final _restock = RestockService.instance;

  @override
  void initState() {
    super.initState();
    _restock.load();
  }

  static String _dueLabel(RestockReminder r) {
    final days = r.daysUntil;
    if (r.isDue) return 'Due now';
    if (days == 0) return 'Due today';
    if (days == 1) return 'Due tomorrow';
    return 'Due in $days days';
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Restock reminders'),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: _restock,
        builder: (context, _) {
          final reminders = _restock.reminders;
          if (reminders.isEmpty) {
            return const _EmptyRestock();
          }
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              children: [
                Text(
                  '${reminders.length} reminder(s) scheduled — we’ll nudge you when '
                  'it’s time to reorder.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ...reminders.map((r) => _ReminderTile(
                      reminder: r,
                      dueLabel: _dueLabel(r),
                      onRestocked: () => _restock.markRestocked(r.id),
                      onRemove: () => _restock.removeReminder(r.id),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  const _ReminderTile({
    required this.reminder,
    required this.dueLabel,
    required this.onRestocked,
    required this.onRemove,
  });

  final RestockReminder reminder;
  final String dueLabel;
  final VoidCallback onRestocked;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final due = reminder.isDue;
    final statusColor = due ? AppColors.accent : AppColors.teal;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: due ? AppColors.accent : AppColors.borderInput),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.event_repeat, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.productTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${reminder.supplierName} · every ${reminder.everyDays} days',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    dueLabel,
                    style: TextStyle(
                      color: due ? AppColors.tealDark : statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRestocked,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Mark restocked'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.credit,
                      side: const BorderSide(color: AppColors.borderInput),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                  tooltip: 'Remove',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRestock extends StatelessWidget {
  const _EmptyRestock();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.event_repeat, size: 34, color: AppColors.teal),
            ),
            const SizedBox(height: 16),
            Text('No restock reminders yet',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Open any product and tap “Set restock reminder” to never run out of '
              'your fast-moving stock.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
