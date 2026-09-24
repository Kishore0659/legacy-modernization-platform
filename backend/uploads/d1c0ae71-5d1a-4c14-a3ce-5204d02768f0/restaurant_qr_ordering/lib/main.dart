import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'repositories/auth_repository.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/cart_viewmodel.dart';
import 'views/customer/customer_home_screen.dart';
import 'views/splash/splash_screen.dart';
import 'services/qr_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();
  runApp(const RestaurantApp());
}

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => AuthService()),
        ChangeNotifierProvider(
          create: (context) => AuthViewModel(AuthRepository(AuthService())),
        ),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
      ],
      child: MaterialApp(
        title: 'Restaurant QR Ordering',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const _DeepLinkGate(),
      ),
    );
  }
}

/// Listens for the QR deep link (restaurant://menu?table=N) both at cold
/// start and while the app is already running, and routes accordingly.
class _DeepLinkGate extends StatefulWidget {
  const _DeepLinkGate();

  @override
  State<_DeepLinkGate> createState() => _DeepLinkGateState();
}

class _DeepLinkGateState extends State<_DeepLinkGate> {
  final _appLinks = AppLinks();
  StreamSubscription? _linkSub;
  String? _initialLink;
  bool _resolved = false;

  @override
  void initState() {
    super.initState();
    _resolveInitialLink();
    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      final tableId = QrService.parseTableId(uri.toString());
      if (tableId != null && mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CustomerHomeScreen(tableId: tableId)),
        );
      }
    });
  }

  Future<void> _resolveInitialLink() async {
    try {
      final uri = await _appLinks.getInitialAppLink();
      _initialLink = uri?.toString();
    } catch (_) {
      _initialLink = null;
    }
    if (mounted) setState(() => _resolved = true);
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_resolved) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return SplashScreen(initialDeepLink: _initialLink);
  }
}
