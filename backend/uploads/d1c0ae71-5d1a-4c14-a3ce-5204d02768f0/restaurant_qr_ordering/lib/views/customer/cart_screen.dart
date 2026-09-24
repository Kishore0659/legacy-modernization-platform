import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/empty_state.dart';
import '../../viewmodels/cart_viewmodel.dart';
import 'checkout_screen.dart';

/// Shows all items added to cart, lets the customer adjust quantities,
/// view the running total, and proceed to checkout.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartVm = context.watch<CartViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: cartVm.isEmpty
          ? EmptyStateWidget(
              icon: Icons.shopping_cart_outlined,
              title: 'Your cart is empty',
              subtitle: 'Add some delicious food to get started!',
              action: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Browse Menu'),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: cartVm.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final cartItem = cartVm.items[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: cartItem.menuItem.image,
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) =>
                                      const Icon(Icons.restaurant),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cartItem.menuItem.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(CurrencyFormatter.format(
                                        cartItem.menuItem.finalPrice)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () => cartVm
                                        .decreaseQuantity(cartItem.menuItem.menuId),
                                  ),
                                  Text('${cartItem.quantity}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () => cartVm
                                        .increaseQuantity(cartItem.menuItem.menuId),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildSummary(context, cartVm),
              ],
            ),
    );
  }

  Widget _buildSummary(BuildContext context, CartViewModel cartVm) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontSize: 16)),
                Text(
                  CurrencyFormatter.format(cartVm.totalPrice),
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                ),
                child: const Text('Proceed to Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
