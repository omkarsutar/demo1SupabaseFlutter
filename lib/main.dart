import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'core/globals.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
  }

  final SupabaseClient _supabaseClient = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    _supabaseClient.auth.onAuthStateChange.listen((event) {
      final session = _supabaseClient.auth.currentSession;

      if (session == null) {
        appRouter.go('/'); // User logged out — navigate to welcome page
      }
    });

    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      routerConfig: appRouter,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
    );
  }
}
