import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'models/candidat_info.dart';
import 'services/candidat_service.dart';
import 'screens/auth_code_screen.dart';
import 'screens/candidat_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  // Vérification d'une session hors-ligne mémorisée
  final cachedSession = await CandidatService.getCachedSession();

  runApp(AutoEcoleProCandidatApp(initialData: cachedSession));
}

class AutoEcoleProCandidatApp extends StatelessWidget {
  final CandidatPortalData? initialData;

  const AutoEcoleProCandidatApp({super.key, this.initialData});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saint Edmond Candidat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          surface: const Color(0xFFF8FAFC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
        ),
      ),
      home: initialData != null
          ? CandidatHomeScreen(portalData: initialData!)
          : const AuthCodeScreen(),
    );
  }
}
