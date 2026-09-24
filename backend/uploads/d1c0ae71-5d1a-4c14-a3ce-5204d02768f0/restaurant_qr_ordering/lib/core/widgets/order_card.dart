import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import 'status_badge.dart';

/// Card used on the chef dashboard to display a single order with all
/// required fields: order number, table, items, quantity, total, time,
/// special instructions, plus action buttons passed in by the caller.
class OrderCard extends StatelessWidget {
  final OrderModel order;
  final List<Widget> actions;

  const OrderCard({super.key, required this.order, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(order.orderNumber,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                StatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.table_bar, size: 16, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Text('Table ${order.tableId}', style: theme.textTheme.bodyMedium),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: theme.colorScheme.outline),
                const SizedBox(width: 4),
                Text(DateFormatter.time(order.timestamp),
                    style: theme.textTheme.bodyMedium),
              ],
            ),
            const Divider(height: 20),
            ...order.orderItems.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('${item.quantity} x ${item.name}',
                          style: theme.textTheme.bodyMedium),
                    ),
                    Text(CurrencyFormatter.format(item.subtotal)),
                  ],
                ),
              ),
            ),
            if (order.specialInstructions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notes, size: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text(order.specialInstructions)),
                  ],
                ),
              ),
            ],
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total (${order.totalItemCount} items)',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  CurrencyFormatter.format(order.totalAmount),
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ],
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}
