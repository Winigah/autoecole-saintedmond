import 'package:flutter/material.dart';
import '../services/security_service.dart';
import 'dashboard_tab.dart';
import 'candidats_tab.dart';
import 'caisse_tab.dart';
import 'presence_tab.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String initialRole;

  const HomeScreen({super.key, required this.initialRole});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String _role;
  int _currentIndex = 0;
  String _selectedAnnexe = 'Toutes';

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole;
  }

  void _logout() async {
    await SecurityService.clearSession();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      DashboardTab(
        role: _role,
        selectedAnnexe: _selectedAnnexe,
        onAnnexeChanged: (a) => setState(() => _selectedAnnexe = a),
      ),
      CandidatsTab(
        role: _role,
        selectedAnnexe: _selectedAnnexe,
      ),
      CaisseTab(
        role: _role,
        selectedAnnexe: _selectedAnnexe,
      ),
      const PresenceTab(),
    ];

    final titles = ['Tableau de bord', 'Candidats', 'Caisse Mobile', 'Présences'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titles[_currentIndex],
              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _role == 'DG' ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Auto-École Saint Edmond • ${_role == 'DG' ? 'Direction' : 'Secrétariat'}',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Déconnexion',
            icon: const Icon(Icons.logout, color: Color(0xFFEF4444)),
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people), label: 'Candidats'),
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), activeIcon: Icon(Icons.point_of_sale), label: 'Caisse'),
          BottomNavigationBarItem(icon: Icon(Icons.how_to_reg_outlined), activeIcon: Icon(Icons.how_to_reg), label: 'Présence'),
        ],
      ),
    );
  }
}
