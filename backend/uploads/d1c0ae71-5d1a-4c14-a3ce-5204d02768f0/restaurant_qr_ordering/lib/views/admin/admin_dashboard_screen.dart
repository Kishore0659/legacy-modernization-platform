import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../repositories/order_repository.dart';
import '../../services/firestore_service.dart';
import '../../viewmodels/admin_dashboard_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../splash/splash_screen.dart';
import 'manage_categories_screen.dart';
import 'manage_menu_screen.dart';
import 'manage_orders_screen.dart';
import 'manage_tables_screen.dart';
import 'qr_generator_screen.dart';

/// Admin dashboard: today's orders, revenue, popular items, and quick
/// navigation into menu/category/order/table management.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminDashboardViewModel(OrderRepository(FirestoreService())),
      child: const _AdminDashboardBody(),
    );
  }
}

class _AdminDashboardBody extends StatelessWidget {
  const _AdminDashboardBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminDashboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _statCard(context, 'Today\'s Orders', '${vm.todaysOrders.length}',
                        Icons.receipt_long, Colors.indigo),
                    _statCard(context, 'Revenue', CurrencyFormatter.format(vm.todaysRevenue),
                        Icons.currency_rupee, Colors.green),
                    _statCard(context, 'Pending', '${vm.pendingCount}',
                        Icons.hourglass_empty, Colors.orange),
                    _statCard(context, 'Completed', '${vm.completedCount}',
                        Icons.check_circle, Colors.teal),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Popular Items', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (vm.popularItems.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No sales data yet today.'),
                  )
                else
                  Card(
                    child: Column(
                      children: vm.popularItems
                          .map((e) => ListTile(
                                leading: const Icon(Icons.local_fire_department,
                                    color: Colors.deepOrange),
                                title: Text(e.key),
                                trailing: Text('${e.value} sold'),
                              ))
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 20),
                Text('Manage', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _navTile(context, Icons.restaurant_menu, 'Menu Items',
                    const ManageMenuScreen()),
                _navTile(context, Icons.category, 'Categories',
                    const ManageCategoriesScreen()),
                _navTile(context, Icons.receipt, 'Orders', const ManageOrdersScreen()),
                _navTile(context, Icons.table_bar, 'Tables', const ManageTablesScreen()),
                _navTile(context, Icons.qr_code_2, 'Generate Table QR Codes',
                    const QrGeneratorScreen()),
              ],
            ),
    );
  }

  Widget _statCard(
      BuildContext context, String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const Spacer(),
            Text(value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Theme.of(context).colorScheme.outline)),
          ],
        ),
      ),
    );
  }

  Widget _navTile(BuildContext context, IconData icon, String title, Widget screen) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      ),
    );
  }
}
