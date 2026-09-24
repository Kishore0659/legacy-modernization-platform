import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/menu_item_model.dart';
import '../../viewmodels/cart_viewmodel.dart';

/// Full detail view for a single food item: large image, description,
/// price, rating, prep time & add-to-cart control.
class FoodDetailsScreen extends StatefulWidget {
  final MenuItemModel item;
  const FoodDetailsScreen({super.key, required this.item});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final theme = Theme.of(context);
    final cartVm = context.watch<CartViewModel>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: item.image,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.restaurant, size: 48),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(item.isVeg ? Icons.eco : Icons.set_meal,
                          color: item.isVeg ? Colors.green : Colors.redAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(item.name,
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 18, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text('${item.rating}'),
                      const SizedBox(width: 16),
                      Icon(Icons.timer_outlined, size: 18, color: theme.colorScheme.outline),
                      const SizedBox(width: 4),
                      Text('${item.prepTimeMinutes} min'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(item.description, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        CurrencyFormatter.format(item.finalPrice),
                        style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                      ),
                      if (item.hasOffer) ...[
                        const SizedBox(width: 10),
                        Text(
                          CurrencyFormatter.format(item.price),
                          style: theme.textTheme.bodyMedium?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: theme.colorScheme.outline),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (!item.available)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Currently unavailable',
                          style: TextStyle(color: theme.colorScheme.onErrorContainer)),
                    )
                  else
                    Row(
                      children: [
                        _quantityStepper(theme),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              cartVm.addItem(item, quantity: _quantity);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${item.name} added to cart')),
                              );
                              Navigator.pop(context);
                            },
                            child: const Text('Add to Cart'),
                          ),
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

  Widget _quantityStepper(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => setState(() {
              if (_quantity > 1) _quantity--;
            }),
            icon: const Icon(Icons.remove),
          ),
          Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            onPressed: () => setState(() => _quantity++),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
