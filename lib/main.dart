import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/di/injection.dart';

/// ── Supabase credentials ──────────────────────────────────────
/// As chaves são injetadas em tempo de build via --dart-define
/// para não ficarem expostas no repositório.
///
/// Desenvolvimento local — crie um arquivo .env e rode com:
///flutter run \--dart-define=SUPABASE_URL=https://xxxx.supabase.co \ --dart-define=SUPABASE_ANON_KEY=eyJhbG...
///
/// CI/CD (GitHub Actions, Codemagic, Bitrise):
///   Adicione SUPABASE_URL e SUPABASE_ANON_KEY como secrets
///   e passe via --dart-define no step de build.
///
/// Fallback para desenvolvimento (valores de dev são aceitáveis
/// em repositórios públicos pois são chaves anon com RLS):

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final supabaseUrl =
      dotenv.env['SUPABASE_URL'] ?? 'https://vzmtwnqapyvrigeygpse.supabase.co';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  debugPrint('supabaseUrl = $supabaseUrl');
  debugPrint('supabaseAnonKey = $supabaseAnonKey');

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  await configureDependencies();
  await configureSharedServices();

  runApp(const App());
}
