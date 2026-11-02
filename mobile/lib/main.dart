import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/security_service.dart';
import 'services/database_service.dart';
import 'services/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de la persistance offline-first
  await DatabaseService.instance.init();

  // Initialisation Supabase si clés configurées
  await SupabaseConfig.initialize();

  // Vérification de session active persistée dans KeyStore
  final token = await SecurityService.getToken();
  final role = await SecurityService.getRole();

  runApp(AutoEcoleProApp(
    initialScreen: token != null
        ? HomeScreen(initialRole: role)
        : const LoginScreen(),
  ));
}

class AutoEcoleProApp extends StatelessWidget {
  final Widget initialScreen;

  const AutoEcoleProApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto-École Saint Edmond',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
        ),
      ),
      home: initialScreen,
    );
  }
}
