import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'pages/game_page.dart';
import 'pages/home_page.dart';
import 'pages/legal_info_page.dart';
import 'pages/records_page.dart';
import 'pages/settings_page.dart';
import 'pages/splash_page.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Re-runs the router redirect whenever the auth session changes.
class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Stream<void> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<void> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

const _publicPages = {'/login', '/register'};
const _alwaysAllowed = {'/splash'};

final router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  refreshListenable: _AuthRefreshListenable(
    getIt<AuthRepository>().authStateChanges,
  ),
  redirect: (context, state) {
    final isLoggedIn = getIt<AuthRepository>().currentUser != null;
    final loc = state.matchedLocation;

    if (_alwaysAllowed.contains(loc)) return null;

    final isPublicPage = _publicPages.contains(loc);
    if (!isLoggedIn && !isPublicPage) return '/login';
    if (isLoggedIn && isPublicPage) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/game', builder: (context, state) => const GamePage()),
    GoRoute(path: '/records', builder: (context, state) => const RecordsPage()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
      routes: [
        GoRoute(
          path: 'about',
          builder: (context, state) =>
              const LegalInfoPage(kind: LegalInfoKind.about),
        ),
        GoRoute(
          path: 'privacy',
          builder: (context, state) =>
              const LegalInfoPage(kind: LegalInfoKind.privacy),
        ),
        GoRoute(
          path: 'terms',
          builder: (context, state) =>
              const LegalInfoPage(kind: LegalInfoKind.terms),
        ),
      ],
    ),
  ],
);
