import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../services/qr_service.dart';
import '../auth/login_screen.dart';
import '../customer/customer_home_screen.dart';
import '../chef/chef_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';

/// First screen shown on launch.
/// - If launched via a QR deep link (restaurant://menu?table=X) -> customer flow.
/// - Otherwise shows a role picker (Scan QR / Staff Login) for demo purposes,
///   since real customers only ever arrive via the QR link.
class SplashScreen extends StatefulWidget {
  final String? initialDeepLink;
  const SplashScreen({super.key, this.initialDeepLink});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final tableId = widget.initialDeepLink != null
        ? QrService.parseTableId(widget.initialDeepLink!)
        : null;

    if (tableId != null) {
      final auth = context.read<AuthViewModel>();
      await auth.ensureCustomerSignedIn();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CustomerHomeScreen(tableId: tableId),
        ),
      );
      return;
    }

    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const RoleGateScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.restaurant_menu, size: 88, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              AppConstants.restaurantName,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              AppConstants.restaurantTagline,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

/// Fallback screen when the app isn't opened via a table QR code -
/// lets a demo user pick "I scanned a QR" (choose table) or staff login.
class RoleGateScreen extends StatelessWidget {
  const RoleGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, size: 72),
            const SizedBox(height: 16),
            const Text(
              'Please scan the QR code on your table to view the menu.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: List.generate(AppConstants.totalTables, (i) {
                final id = '${i + 1}';
                return OutlinedButton(
                  onPressed: () async {
                    await context.read<AuthViewModel>().ensureCustomerSignedIn();
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CustomerHomeScreen(tableId: id),
                      ),
                    );
                  },
                  child: Text('Simulate Table $id'),
                );
              }),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.badge),
              label: const Text('Staff Login (Chef / Admin)'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// After staff login, routes to the correct dashboard based on role.
class StaffRouter extends StatelessWidget {
  const StaffRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    if (auth.isChef) return const ChefDashboardScreen();
    if (auth.isAdmin) return const AdminDashboardScreen();
    return const LoginScreen();
  }
}
