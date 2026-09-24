import 'menu_item_model.dart';

/// A cart entry held locally on the customer's device before checkout.
class CartItemModel {
  final MenuItemModel menuItem;
  int quantity;
  String specialInstructions;

  CartItemModel({
    required this.menuItem,
    this.quantity = 1,
    this.specialInstructions = '',
  });

  double get subtotal => menuItem.finalPrice * quantity;
}
