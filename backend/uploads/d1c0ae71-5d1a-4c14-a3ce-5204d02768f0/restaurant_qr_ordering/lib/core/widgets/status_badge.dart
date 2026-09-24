import 'package:flutter/material.dart';
import '../../models/order_model.dart';

/// Colored pill showing an order's current status.
class StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const StatusBadge({super.key, required this.status});

  Color _color() {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.deepPurple;
      case OrderStatus.ready:
        return Colors.teal;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.rejected:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
