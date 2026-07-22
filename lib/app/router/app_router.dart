import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_paths.dart';
import 'route_names.dart';
import '../../features/auth/presentation/view_models/auth_view_model.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/account_blocked_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/play_market/presentation/screens/play_market_screen.dart';
import '../../features/contact_sync/presentation/screens/contact_sync_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: RoutePaths.home,
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isBlocked = authState.isBlocked;
      final isLoggingIn = state.matchedLocation == RoutePaths.login;
      final isRegistering = state.matchedLocation == RoutePaths.register;

      if (isBlocked) {
        if (state.matchedLocation != RoutePaths.accountBlocked) {
          return RoutePaths.accountBlocked;
        }
        return null;
      }

      if (!isAuth &&
          !isLoggingIn &&
          !isRegistering &&
          state.matchedLocation != RoutePaths.accountBlocked) {
        return RoutePaths.login;
      }

      if (isAuth && (isLoggingIn || isRegistering)) {
        return RoutePaths.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.accountBlocked,
        name: RouteNames.accountBlocked,
        builder: (context, state) => const AccountBlockedScreen(),
      ),
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.playMarket,
        name: RouteNames.playMarket,
        builder: (context, state) {
          final marketName = state.pathParameters['marketName'] ?? 'MILAN DAY';
          return PlayMarketScreen(marketName: marketName);
        },
      ),
      GoRoute(
        path: RoutePaths.contactsSync,
        name: RouteNames.contactsSync,
        builder: (context, state) => const ContactSyncScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
