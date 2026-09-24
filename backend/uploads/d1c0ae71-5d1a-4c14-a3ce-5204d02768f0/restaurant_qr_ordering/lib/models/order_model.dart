import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item_model.dart';

/// Order lifecycle - matches the requirement's status flow.
enum OrderStatus { pending, accepted, preparing, ready, completed, rejected }

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.rejected:
        return 'Rejected';
    }
  }
}

OrderStatus orderStatusFromString(String value) {
  return OrderStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => OrderStatus.pending,
  );
}

class OrderModel {
  final String orderId;
  final String orderNumber; // human friendly, e.g. "ORD-1042"
  final String tableId;
  final OrderStatus status;
  final DateTime timestamp;
  final double totalAmount;
  final List<OrderItemModel> orderItems;
  final String specialInstructions;

  const OrderModel({
    required this.orderId,
    required this.orderNumber,
    required this.tableId,
    required this.status,
    required this.timestamp,
    required this.totalAmount,
    required this.orderItems,
    this.specialInstructions = '',
  });

  int get totalItemCount =>
      orderItems.fold(0, (sum, item) => sum + item.quantity);

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      orderId: id,
      orderNumber: map['orderNumber'] ?? id.substring(0, 6),
      tableId: map['tableId'] ?? '',
      status: orderStatusFromString(map['status'] ?? 'pending'),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      orderItems: (map['orderItems'] as List<dynamic>? ?? [])
          .map((e) => OrderItemModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      specialInstructions: map['specialInstructions'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'tableId': tableId,
      'status': status.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'totalAmount': totalAmount,
      'orderItems': orderItems.map((e) => e.toMap()).toList(),
      'specialInstructions': specialInstructions,
    };
  }
}
