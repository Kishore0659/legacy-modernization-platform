import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/order_card.dart';
import '../../models/order_model.dart';
import '../../repositories/order_repository.dart';
import '../../services/firestore_service.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/chef_dashboard_viewmodel.dart';
import '../splash/splash_screen.dart';

/// Chef's real-time order management dashboard with 4 tabs:
/// Incoming, Preparing, Ready, Completed.
class ChefDashboardScreen extends StatelessWidget {
  const ChefDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChefDashboardViewModel(OrderRepository(FirestoreService())),
      child: const _ChefDashboardBody(),
    );
  }
}

class _ChefDashboardBody extends StatefulWidget {
  const _ChefDashboardBody();

  @override
  State<_ChefDashboardBody> createState() => _ChefDashboardBodyState();
}

class _ChefDashboardBodyState extends State<_ChefDashboardBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChefDashboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chef Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: 'Incoming (${vm.incoming.length})'),
            Tab(text: 'Preparing (${vm.accepted.length + vm.preparing.length})'),
            Tab(text: 'Ready (${vm.ready.length})'),
            Tab(text: 'Completed (${vm.completed.length})'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthViewModel>().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const RoleGateScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: vm.isLoading
          ? const LoadingIndicator()
          : TabBarView(
              controller: _tabController,
              children: [
                _incomingList(vm),
                _preparingList(vm),
                _readyList(vm),
                _completedList(vm),
              ],
            ),
    );
  }

  Widget _incomingList(ChefDashboardViewModel vm) {
    if (vm.incoming.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.inbox_outlined,
        title: 'No incoming orders',
        subtitle: 'New orders will appear here instantly',
      );
    }
    return ListView.builder(
      itemCount: vm.incoming.length,
      itemBuilder: (context, i) {
        final order = vm.incoming[i];
        return OrderCard(
          order: order,
          actions: [
            OutlinedButton(
              onPressed: () async {
                final confirmed = await ConfirmationDialog.show(
                  context,
                  title: 'Reject Order',
                  message: 'Reject order ${order.orderNumber}?',
                  confirmLabel: 'Reject',
                  isDestructive: true,
                );
                if (confirmed) vm.rejectOrder(order.orderId);
              },
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reject'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => vm.acceptOrder(order.orderId),
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  Widget _preparingList(ChefDashboardViewModel vm) {
    final orders = [...vm.accepted, ...vm.preparing];
    if (orders.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.soup_kitchen_outlined,
        title: 'Nothing being prepared',
        subtitle: 'Accepted orders will show up here',
      );
    }
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, i) {
        final order = orders[i];
        final isAccepted = order.status == OrderStatus.accepted;
        return OrderCard(
          order: order,
          actions: [
            FilledButton(
              onPressed: () => isAccepted
                  ? vm.markPreparing(order.orderId)
                  : vm.markReady(order.orderId),
              child: Text(isAccepted ? 'Start Preparing' : 'Mark Ready'),
            ),
          ],
        );
      },
    );
  }

  Widget _readyList(ChefDashboardViewModel vm) {
    if (vm.ready.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.done_all,
        title: 'No orders ready',
        subtitle: 'Orders ready to serve will appear here',
      );
    }
    return ListView.builder(
      itemCount: vm.ready.length,
      itemBuilder: (context, i) {
        final order = vm.ready[i];
        return OrderCard(
          order: order,
          actions: [
            FilledButton(
              onPressed: () => vm.markCompleted(order.orderId),
              child: const Text('Mark Completed'),
            ),
          ],
        );
      },
    );
  }

  Widget _completedList(ChefDashboardViewModel vm) {
    if (vm.completed.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.check_circle_outline,
        title: 'No completed orders yet',
        subtitle: 'Completed orders will be listed here',
      );
    }
    return ListView.builder(
      itemCount: vm.completed.length,
      itemBuilder: (context, i) => OrderCard(order: vm.completed[i]),
    );
  }
}
