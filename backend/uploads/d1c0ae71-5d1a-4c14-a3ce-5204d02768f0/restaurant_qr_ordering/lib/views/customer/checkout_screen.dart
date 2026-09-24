import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../repositories/order_repository.dart';
import '../../services/firestore_service.dart';
import '../../services/notification_service.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/order_tracking_viewmodel.dart';
import 'order_tracking_screen.dart';

/// Order review + special instructions + place order.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _instructionsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cartVm = context.watch<CartViewModel>();

    return ChangeNotifierProvider(
      create: (_) => OrderTrackingViewModel(
        OrderRepository(FirestoreService()),
        NotificationService(),
      ),
      child: Builder(builder: (context) {
        final orderVm = context.watch<OrderTrackingViewModel>();
        return Scaffold(
          appBar: AppBar(title: const Text('Checkout')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Table ${cartVm.tableId}',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: [
                      ...cartVm.items.map(
                        (c) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('${c.quantity} x ${c.menuItem.name}'),
                          trailing: Text(CurrencyFormatter.format(c.subtotal)),
                        ),
                      ),
                      const Divider(),
                      TextField(
                        controller: _instructionsController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Special instructions (optional)',
                          hintText: 'e.g. less spicy, no onions...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total to Pay', style: TextStyle(fontSize: 16)),
                    Text(
                      CurrencyFormatter.format(cartVm.totalPrice),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: orderVm.isPlacingOrder
                        ? null
                        : () => _placeOrder(context, cartVm, orderVm),
                    child: orderVm.isPlacingOrder
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Place Order'),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _placeOrder(
    BuildContext context,
    CartViewModel cartVm,
    OrderTrackingViewModel orderVm,
  ) async {
    final orderId = await orderVm.placeOrder(
      tableId: cartVm.tableId ?? '1',
      cartItems: cartVm.items,
      specialInstructions: _instructionsController.text.trim(),
    );
    if (orderId != null && context.mounted) {
      cartVm.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(orderId: orderId, viewModel: orderVm),
        ),
        (route) => route.isFirst,
      );
    } else if (context.mounted && orderVm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: ${orderVm.errorMessage}')),
      );
    }
  }
}
