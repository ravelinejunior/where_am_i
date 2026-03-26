import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/missing_persons/presentation/screens/missing_list_screen.dart';
import '../../features/missing_persons/presentation/screens/missing_detail_screen.dart';
import '../../features/missing_persons/domain/entities/missing_person_entity.dart';
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
      pageBuilder: (context, state) => _fade(const MissingListScreen(), state),
    ),
    GoRoute(
      path: RouteNames.missingDetail,
      name: RouteNames.missingDetailName,
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        final prefetched = state.extra as MissingPersonEntity?;
        return _slide(
          MissingDetailScreen(id: id, prefetched: prefetched),
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
            body: Center(child: Text('Login — coming in commit #5'))),
        state,
      ),
    ),
    GoRoute(
      path: RouteNames.reportCase,
      name: RouteNames.reportCaseName,
      pageBuilder: (context, state) => _slide(
        const Scaffold(
            body: Center(child: Text('Report — coming in commit #6'))),
        state,
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Route not found: ${state.uri}')),
  ),
);

CustomTransitionPage<void> _fade(Widget child, GoRouterState state) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (_, animation, __, child) =>
        FadeTransition(opacity: animation, child: child),
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
      return SlideTransition(position: animation.drive(tween), child: child);
    },
    transitionDuration: const Duration(milliseconds: 320),
  );
}
