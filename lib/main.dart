import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'core/di/injection.dart';

/// ── Supabase credentials ──────────────────────────────────────
/// 1. Create a free project at https://supabase.com
/// 2. Go to Project Settings → API
/// 3. Copy "Project URL" and "anon public" key below
/// 4. Run the SQL schema in supabase/schema.sql via the SQL editor
const _supabaseUrl = 'https://vzmtwnqapyvrigeygpse.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ6bXR3bnFhcHl2cmlnZXlncHNlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ2MDk4NjIsImV4cCI6MjA5MDE4NTg2Mn0.gPQbri7Hil4qa6UOpAR9b-XfEfm3sYokZKVA6hX9ZwU';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  await configureDependencies();
  await configureSharedServices();

  runApp(const App());
}
