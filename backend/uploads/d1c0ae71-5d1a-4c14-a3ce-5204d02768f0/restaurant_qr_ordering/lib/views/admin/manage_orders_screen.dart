import 'package:flutter/material.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/order_card.dart';
import '../../models/order_model.dart';
import '../../repositories/order_repository.dart';
import '../../services/firestore_service.dart';

/// Admin-facing read-only view of all orders (with live status), useful
/// for oversight without giving the admin kitchen-only actions.
class ManageOrdersScreen extends StatelessWidget {
  const ManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = OrderRepository(FirestoreService());
    return Scaffold(
      appBar: AppBar(title: const Text('All Orders')),
      body: StreamBuilder<List<OrderModel>>(
        stream: repo.streamAllOrders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LoadingIndicator();
          final orders = snapshot.data!;
          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet.'));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, i) => OrderCard(order: orders[i]),
          );
        },
      ),
    );
  }
}
