import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../repositories/order_repository.dart';

/// Aggregates today's orders into the metrics shown on the admin dashboard:
/// revenue, popular items, pending/completed counts.
class AdminDashboardViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository;
  AdminDashboardViewModel(this._orderRepository) {
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

  List<OrderModel> get todaysOrders {
    final now = DateTime.now();
    return _allOrders
        .where((o) =>
            o.timestamp.year == now.year &&
            o.timestamp.month == now.month &&
            o.timestamp.day == now.day)
        .toList();
  }

  double get todaysRevenue => todaysOrders
      .where((o) => o.status == OrderStatus.completed)
      .fold(0.0, (sum, o) => sum + o.totalAmount);

  int get pendingCount =>
      todaysOrders.where((o) => o.status == OrderStatus.pending).length;

  int get completedCount =>
      todaysOrders.where((o) => o.status == OrderStatus.completed).length;

  /// Returns a map of menuItem name -> total quantity sold today, sorted
  /// descending (most popular first).
  List<MapEntry<String, int>> get popularItems {
    final Map<String, int> counts = {};
    for (final order in todaysOrders) {
      for (final item in order.orderItems) {
        counts[item.name] = (counts[item.name] ?? 0) + item.quantity;
      }
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).toList();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
