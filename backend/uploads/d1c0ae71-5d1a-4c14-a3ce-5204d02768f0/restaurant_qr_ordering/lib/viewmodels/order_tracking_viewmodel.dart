import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../repositories/order_repository.dart';
import '../services/notification_service.dart';

/// Places a new order from the cart and tracks its live status afterwards.
class OrderTrackingViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;
  final NotificationService _notificationService;

  OrderTrackingViewModel(this._orderRepository, this._notificationService);

  OrderModel? currentOrder;
  bool isPlacingOrder = false;
  String? errorMessage;
  StreamSubscription? _orderSub;

  Future<String?> placeOrder({
    required String tableId,
    required List<CartItemModel> cartItems,
    required String specialInstructions,
  }) async {
    isPlacingOrder = true;
    errorMessage = null;
    notifyListeners();

    try {
      final orderNumber = 'ORD-${DateTime.now().millisecondsSinceEpoch % 100000}';
      final orderItems = cartItems
          .map((c) => OrderItemModel(
                orderItemId: c.menuItem.menuId,
                menuId: c.menuItem.menuId,
                name: c.menuItem.name,
                image: c.menuItem.image,
                quantity: c.quantity,
                price: c.menuItem.finalPrice,
              ))
          .toList();
      final total = cartItems.fold(0.0, (sum, c) => sum + c.subtotal);

      final order = OrderModel(
        orderId: '',
        orderNumber: orderNumber,
        tableId: tableId,
        status: OrderStatus.pending,
        timestamp: DateTime.now(),
        totalAmount: total,
        orderItems: orderItems,
        specialInstructions: specialInstructions,
      );

      final orderId = await _orderRepository.placeOrder(order);
      await _notificationService.registerTokenForOrder(orderId);
      trackOrder(orderId);
      isPlacingOrder = false;
      notifyListeners();
      return orderId;
    } catch (e) {
      errorMessage = e.toString();
      isPlacingOrder = false;
      notifyListeners();
      return null;
    }
  }

  /// Subscribes to real-time updates for a given order id - drives the
  /// order tracking screen's status stepper.
  void trackOrder(String orderId) {
    _orderSub?.cancel();
    _orderSub = _orderRepository.streamOrder(orderId).listen((order) {
      currentOrder = order;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _orderSub?.cancel();
    super.dispose();
  }
}
