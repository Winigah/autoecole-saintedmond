import 'package:flutter/material.dart';
import '../models/candidat_info.dart';
import '../services/candidat_service.dart';
import 'auth_code_screen.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/planning_tab.dart';
import 'tabs/finances_tab.dart';
import 'tabs/revision_quiz_tab.dart';

class CandidatHomeScreen extends StatefulWidget {
  final CandidatPortalData portalData;

  const CandidatHomeScreen({super.key, required this.portalData});

  @override
  State<CandidatHomeScreen> createState() => _CandidatHomeScreenState();
}

class _CandidatHomeScreenState extends State<CandidatHomeScreen> {
  int _currentIndex = 0;
  late CandidatPortalData _portalData;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _portalData = widget.portalData;
    _actualiser(silencieux: true);
  }

  Future<void> _actualiser({bool silencieux = false}) async {
    final code = _portalData.candidat.codeAcces;
    if (code.isEmpty) return;
    if (!silencieux && mounted) {
      setState(() => _isRefreshing = true);
    }
    try {
      final fresh = await CandidatService.authentifierParCode(code);
      if (fresh != null && mounted) {
        setState(() {
          _portalData = fresh;
        });
        if (!silencieux) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Données actualisées avec succès !'),
              backgroundColor: Color(0xFF10B981),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  void _deconnexion() async {
    final conf = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Déconnexion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: const Text('Voulez-vous vous déconnecter de votre espace élève ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Déconnexion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (conf == true) {
      await CandidatService.deconnexion();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthCodeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ecole = _portalData.entreprise;
    final cand = _portalData.candidat;

    final List<Widget> tabs = [
      DashboardTab(
        data: _portalData,
        onNavToPlanning: () => setState(() => _currentIndex = 1),
        onNavToFinances: () => setState(() => _currentIndex = 2),
        onNavToRevision: () => setState(() => _currentIndex = 3),
      ),
      PlanningTab(data: _portalData),
      FinancesTab(data: _portalData),
      const RevisionQuizTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ecole.nom,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Text(
                        'Code : ',
                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      Text(
                        cand.codeAcces,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          _isRefreshing
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
                    ),
                  ),
                )
              : IconButton(
                  onPressed: () => _actualiser(silencieux: false),
                  icon: const Icon(Icons.refresh_rounded, color: Color(0xFF2563EB), size: 22),
                  tooltip: 'Actualiser',
                ),
          IconButton(
            onPressed: () => CandidatService.contacterAutoEcoleWhatsApp(
              telephone: ecole.telephone,
              nomCandidat: cand.nomComplet,
              codeAcces: cand.codeAcces,
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF10B981), size: 22),
            tooltip: 'WhatsApp Secrétariat',
          ),
          IconButton(
            onPressed: _deconnexion,
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B), size: 20),
            tooltip: 'Quitter',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) => setState(() => _currentIndex = idx),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2563EB),
          unselectedItemColor: const Color(0xFF64748B),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today_rounded),
              label: 'Planning',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Finances',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school_rounded),
              label: 'Révision',
            ),
          ],
        ),
      ),
    );
  }
}
