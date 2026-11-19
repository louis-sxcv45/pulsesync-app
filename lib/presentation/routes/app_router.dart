import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/monitor_screen.dart';

class AppRoutes {
  static const monitor = '/';
  static const monitorName = 'monitor';
}

class AppRouter {
  AppRouter._();

  /// Created once (static) so it is not rebuilt on every widget rebuild.
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.monitor,
    routes: [
      GoRoute(
        path: AppRoutes.monitor,
        name: AppRoutes.monitorName,
        builder: (context, state) => const MonitorScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Halaman tidak ditemukan: ${state.uri}')),
    ),
  );
}
