import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../models/order_model.dart';
import '../../viewmodels/order_tracking_viewmodel.dart';

/// Real-time order status tracker. Shows a visual stepper across the
/// pending -> accepted -> preparing -> ready -> completed flow, updating
/// live as the chef changes the order's status in Firestore.
class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  final OrderTrackingViewModel? viewModel;

  const OrderTrackingScreen({super.key, required this.orderId, this.viewModel});

  static const _steps = [
    OrderStatus.pending,
    OrderStatus.accepted,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final vm = viewModel ?? context.watch<OrderTrackingViewModel>();
    final order = vm.currentOrder;

    return Scaffold(
      appBar: AppBar(title: const Text('Track Your Order')),
      body: order == null
          ? const LoadingIndicator(label: 'Loading order...')
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(order.orderNumber,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text('Table ${order.tableId}'),
                const SizedBox(height: 24),
                if (order.status == OrderStatus.rejected)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.cancel_outlined),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                                'Sorry, your order was rejected by the kitchen. Please contact staff for assistance.'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  _buildStepper(context, order.status),
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Summary',
                            style: Theme.of(context).textTheme.titleMedium),
                        const Divider(),
                        ...order.orderItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${item.quantity} x ${item.name}'),
                                Text(CurrencyFormatter.format(item.subtotal)),
                              ],
                            ),
                          ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              CurrencyFormatter.format(order.totalAmount),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStepper(BuildContext context, OrderStatus current) {
    final currentIndex = _steps.indexOf(current);
    final theme = Theme.of(context);
    return Column(
      children: List.generate(_steps.length, (i) {
        final step = _steps[i];
        final isDone = i <= currentIndex;
        final isCurrent = i == currentIndex;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor:
                      isDone ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    isDone ? Icons.check : Icons.circle,
                    size: 14,
                    color: isDone ? Colors.white : theme.colorScheme.outline,
                  ),
                ),
                if (i != _steps.length - 1)
                  Container(
                    width: 2,
                    height: 40,
                    color: isDone ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                step.label,
                style: TextStyle(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  fontSize: isCurrent ? 16 : 14,
                  color: isDone ? theme.colorScheme.onSurface : theme.colorScheme.outline,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
