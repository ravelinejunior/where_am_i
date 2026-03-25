import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_names.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/missing_persons/presentation/screens/missing_list_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      name: RouteNames.splashName,
      pageBuilder: (context, state) => _fade(const SplashScreen(), state),
    ),
    GoRoute(
      path: RouteNames.missingList,
      name: RouteNames.missingListName,
      pageBuilder: (context, state) => _slide(const MissingListScreen(), state),
    ),
    GoRoute(
      path: RouteNames.missingDetail,
      name: RouteNames.missingDetailName,
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        // DetailScreen will be added in commit #8
        return _slide(
          Scaffold(
            appBar: AppBar(title: const Text('Detail')),
            body: Center(child: Text('Case: $id')),
          ),
          state,
        );
      },
    ),
    GoRoute(
      path: RouteNames.settings,
      name: RouteNames.settingsName,
      pageBuilder: (context, state) => _slide(const SettingsScreen(), state),
    ),
    GoRoute(
      path: RouteNames.login,
      name: RouteNames.loginName,
      pageBuilder: (context, state) => _fade(
        const Scaffold(
            body: Center(child: Text('Login — coming in commit #10'))),
        state,
      ),
    ),
    GoRoute(
      path: RouteNames.reportCase,
      name: RouteNames.reportCaseName,
      pageBuilder: (context, state) => _slide(
        const Scaffold(
            body: Center(child: Text('Report — coming in commit #11'))),
        state,
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Route not found: ${state.uri}'),
    ),
  ),
);

CustomTransitionPage<void> _fade(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 350),
  );
}

CustomTransitionPage<void> _slide(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, animation, __, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 320),
  );
}
