import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';

/// All order data access lives here. Real-time streams power both the
/// chef dashboard (all active orders) and the customer tracking screen
/// (a single order by id).
class OrderRepository {
  final FirestoreService _service;
  OrderRepository(this._service);

  Future<String> placeOrder(OrderModel order) async {
    final ref = await _service.add(
      AppConstants.ordersCollection,
      order.toMap(),
    );
    return ref.id;
  }

  /// Live stream of ALL orders for the chef dashboard, most recent first.
  Stream<List<OrderModel>> streamAllOrders() {
    return _service
        .streamCollection(
      AppConstants.ordersCollection,
      query: (q) => q.orderBy('timestamp', descending: true),
    )
        .map((snap) =>
        snap.docs.map((d) => OrderModel.fromMap(d.data(), d.id)).toList());
  }

  /// Live stream of orders filtered by status - used for dashboard tabs
  /// (Incoming / Preparing / Ready / Completed).
  Stream<List<OrderModel>> streamOrdersByStatus(OrderStatus status) {
    return _service
        .streamCollection(
      AppConstants.ordersCollection,
      query: (q) => q
          .where('status', isEqualTo: status.name)
          .orderBy('timestamp', descending: true),
    )
        .map((snap) =>
        snap.docs.map((d) => OrderModel.fromMap(d.data(), d.id)).toList());
  }

  /// Live stream of a single order - used for customer order tracking.
  Stream<OrderModel?> streamOrder(String orderId) {
    return _service.streamDoc(AppConstants.ordersCollection, orderId).map(
          (doc) => doc.exists ? OrderModel.fromMap(doc.data()!, doc.id) : null,
    );
  }

  /// Orders for a given table (order history at the table level).
  Stream<List<OrderModel>> streamOrdersForTable(String tableId) {
    return _service
        .streamCollection(
      AppConstants.ordersCollection,
      query: (q) => q
          .where('tableId', isEqualTo: tableId)
          .orderBy('timestamp', descending: true),
    )
        .map((snap) =>
        snap.docs.map((d) => OrderModel.fromMap(d.data(), d.id)).toList());
  }

  Future<void> updateStatus(String orderId, OrderStatus status) {
    return _service.update(
      AppConstants.ordersCollection,
      orderId,
      {'status': status.name},
    );
  }

  /// Orders placed "today" for the admin dashboard revenue widget.
  Future<List<OrderModel>> fetchTodaysOrders() async {
    final startOfDay = DateTime.now().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
    );
    final snap = await _service
        .collection(AppConstants.ordersCollection)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('timestamp', descending: true)
        .get();
    return snap.docs.map((d) => OrderModel.fromMap(d.data(), d.id)).toList();
  }
}
