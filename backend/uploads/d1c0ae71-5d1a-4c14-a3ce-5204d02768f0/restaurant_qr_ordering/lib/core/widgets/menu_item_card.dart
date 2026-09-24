import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/menu_item_model.dart';
import '../utils/currency_formatter.dart';

/// Reusable card showing a menu item's image, name, price & add button.
/// Used on the customer home / category grid.
class MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final int quantityInCart;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.quantityInCart,
    required this.onTap,
    required this.onAdd,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: item.image,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: theme.colorScheme.surfaceContainerHighest),
                    errorWidget: (_, __, ___) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.restaurant, size: 32),
                    ),
                  ),
                  if (item.hasOffer)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${item.offerPercent.toInt()}% OFF',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        item.isVeg ? Icons.eco : Icons.set_meal,
                        size: 14,
                        color: item.isVeg ? Colors.green : Colors.redAccent,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyFormatter.format(item.finalPrice),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      _buildCartControl(theme),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartControl(ThemeData theme) {
    if (quantityInCart == 0) {
      return InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 16),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepperButton(theme, Icons.remove, onDecrease),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('$quantityInCart',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        _stepperButton(theme, Icons.add, onIncrease),
      ],
    );
  }

  Widget _stepperButton(ThemeData theme, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: theme.colorScheme.onPrimaryContainer),
      ),
    );
  }
}
