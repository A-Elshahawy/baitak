import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../network/auth_events.dart';
import '../../features/auth/notifier/auth_notifier.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/apartments/screens/apartments_list_screen.dart';
import '../../features/apartments/screens/apartment_detail_screen.dart';
import '../../features/clients/screens/clients_screen.dart';
import '../../features/earnings/screens/earnings_screen.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (_, __) => notifyListeners());
    AuthEvents.onUnauthorized.listen((_) => notifyListeners());
  }

  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authNotifierProvider);
    if (authState.isLoading) return null;

    final isLoggedIn = authState.valueOrNull != null;
    final loc = state.matchedLocation;
    final isAuthRoute = loc == '/login' || loc == '/register';

    if (!isLoggedIn && !isAuthRoute) return '/login';
    if (isLoggedIn && isAuthRoute) return '/home';
    return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);
  return GoRouter(
    refreshListenable: notifier,
    redirect: notifier.redirect,
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/login',
        builder: (ctx, s) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (ctx, s) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (ctx, s, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (ctx, s) => const HomeScreen(),
          ),
          GoRoute(
            path: '/apartments',
            builder: (ctx, s) => const ApartmentsListScreen(),
          ),
          GoRoute(
            path: '/apartments/:id',
            builder: (ctx, s) => ApartmentDetailScreen(
              aptId: int.parse(s.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: '/clients',
            builder: (ctx, s) => const ClientsScreen(),
          ),
          GoRoute(
            path: '/earnings',
            builder: (ctx, s) => const EarningsScreen(),
          ),
        ],
      ),
    ],
  );
});
