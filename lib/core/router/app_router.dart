import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../screens/login_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/cart_screen.dart';
import '../../screens/orders_screen.dart';
import '../../screens/lojista_dashboard.dart';
import '../../screens/profile_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }

      if (isAuthenticated && isLoginRoute) {
        return '/';
      }

      // Check for Lojista specific routes
      if (isAuthenticated && state.matchedLocation.startsWith('/lojista') && !authProvider.isLojista) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/lojista',
        builder: (context, state) => const LojistaDashboard(),
      ),
    ],
  );
}
