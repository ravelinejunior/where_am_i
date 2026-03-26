import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/missing_persons/domain/entities/missing_person_entity.dart';
import '../../features/missing_persons/presentation/screens/missing_detail_screen.dart';
import '../../features/missing_persons/presentation/screens/missing_list_screen.dart';
import '../../features/report_case/presentation/screens/report_case_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  debugLogDiagnostics: false,
  routes: [
    GoRoute(
      path: RouteNames.splash,
      name: RouteNames.splashName,
      pageBuilder: (ctx, state) => _fade(const SplashScreen(), state),
    ),
    GoRoute(
      path: RouteNames.missingList,
      name: RouteNames.missingListName,
      pageBuilder: (ctx, state) =>
          _fade(const MissingListScreen(), state),
    ),
    GoRoute(
      path: RouteNames.missingDetail,
      name: RouteNames.missingDetailName,
      pageBuilder: (ctx, state) {
        final id = state.pathParameters['id']!;
        final prefetched = state.extra as MissingPersonEntity?;
        return _slide(
            MissingDetailScreen(id: id, prefetched: prefetched), state);
      },
    ),
    GoRoute(
      path: RouteNames.login,
      name: RouteNames.loginName,
      pageBuilder: (ctx, state) {
        final redirect = state.uri.queryParameters['redirect'];
        return _slide(LoginScreen(redirectTo: redirect), state);
      },
    ),
    GoRoute(
      path: RouteNames.reportCase,
      name: RouteNames.reportCaseName,
      pageBuilder: (ctx, state) =>
          _slide(const ReportCaseScreen(), state),
    ),
    GoRoute(
      path: RouteNames.settings,
      name: RouteNames.settingsName,
      pageBuilder: (ctx, state) =>
          _slide(const SettingsScreen(), state),
    ),
  ],
  errorBuilder: (ctx, state) => Scaffold(
    body: Center(child: Text('Route not found: ${state.uri}')),
  ),
);

CustomTransitionPage<void> _fade(Widget child, GoRouterState state) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, a, __, c) =>
          FadeTransition(opacity: a, child: c),
      transitionDuration: const Duration(milliseconds: 350),
    );

CustomTransitionPage<void> _slide(Widget child, GoRouterState state) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, a, __, c) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: a.drive(tween), child: c);
      },
      transitionDuration: const Duration(milliseconds: 320),
    );
