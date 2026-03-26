import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/di/injection.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import 'routes/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>(),
      child: MaterialApp.router(
        title: 'Where Am I?',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        routerConfig: appRouter,
        supportedLocales: const [
          Locale('en'),
          Locale('pt'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}
