import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../repositories/order_repository.dart';

/// Powers the chef dashboard: 4 real-time tabs (Incoming / Preparing /
/// Ready / Completed) plus status transition actions.
class ChefDashboardViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;
  ChefDashboardViewModel(this._orderRepository) {
    _listenAllOrders();
  }

  List<OrderModel> _allOrders = [];
  bool isLoading = true;
  StreamSubscription? _sub;

  void _listenAllOrders() {
    _sub = _orderRepository.streamAllOrders().listen((orders) {
      _allOrders = orders;
      isLoading = false;
      notifyListeners();
    });
  }

  List<OrderModel> get incoming =>
      _allOrders.where((o) => o.status == OrderStatus.pending).toList();

  List<OrderModel> get accepted =>
      _allOrders.where((o) => o.status == OrderStatus.accepted).toList();

  List<OrderModel> get preparing =>
      _allOrders.where((o) => o.status == OrderStatus.preparing).toList();

  List<OrderModel> get ready =>
      _allOrders.where((o) => o.status == OrderStatus.ready).toList();

  List<OrderModel> get completed =>
      _allOrders.where((o) => o.status == OrderStatus.completed).toList();

  Future<void> acceptOrder(String orderId) =>
      _orderRepository.updateStatus(orderId, OrderStatus.accepted);

  Future<void> rejectOrder(String orderId) =>
      _orderRepository.updateStatus(orderId, OrderStatus.rejected);

  Future<void> markPreparing(String orderId) =>
      _orderRepository.updateStatus(orderId, OrderStatus.preparing);

  Future<void> markReady(String orderId) =>
      _orderRepository.updateStatus(orderId, OrderStatus.ready);

  Future<void> markCompleted(String orderId) =>
      _orderRepository.updateStatus(orderId, OrderStatus.completed);

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
