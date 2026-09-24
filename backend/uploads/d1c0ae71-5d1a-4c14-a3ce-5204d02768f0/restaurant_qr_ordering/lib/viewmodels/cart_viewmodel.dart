import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/menu_item_model.dart';

/// Holds the customer's in-progress cart for the current table session.
class CartViewModel extends ChangeNotifier {
  final Map<String, CartItemModel> _items = {}; // keyed by menuId
  String? tableId;

  List<CartItemModel> get items => _items.values.toList();

  int get totalItemCount =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + item.subtotal);

  bool get isEmpty => _items.isEmpty;

  void setTable(String id) {
    tableId = id;
  }

  void addItem(MenuItemModel menuItem, {int quantity = 1}) {
    if (_items.containsKey(menuItem.menuId)) {
      _items[menuItem.menuId]!.quantity += quantity;
    } else {
      _items[menuItem.menuId] =
          CartItemModel(menuItem: menuItem, quantity: quantity);
    }
    notifyListeners();
  }

  void increaseQuantity(String menuId) {
    if (_items.containsKey(menuId)) {
      _items[menuId]!.quantity++;
      notifyListeners();
    }
  }

  void decreaseQuantity(String menuId) {
    if (!_items.containsKey(menuId)) return;
    final item = _items[menuId]!;
    if (item.quantity <= 1) {
      _items.remove(menuId);
    } else {
      item.quantity--;
    }
    notifyListeners();
  }

  void updateInstructions(String menuId, String instructions) {
    if (_items.containsKey(menuId)) {
      _items[menuId]!.specialInstructions = instructions;
      notifyListeners();
    }
  }

  int quantityOf(String menuId) => _items[menuId]?.quantity ?? 0;

  void removeItem(String menuId) {
    _items.remove(menuId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
