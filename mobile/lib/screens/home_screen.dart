import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/security_service.dart';
import 'dashboard_tab.dart';
import 'candidats_tab.dart';
import 'caisse_tab.dart';
import 'presence_tab.dart';
import 'gestion_revisions_screen.dart';
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

  void _showSecurityDialog() async {
    final currentLogin = await MobileAuthService.getCurrentLogin(_role);
    if (!mounted) return;

    final loginCtrl = TextEditingController(text: currentLogin);
    final oldPwdCtrl = TextEditingController();
    final newPwdCtrl = TextEditingController();
    final confPwdCtrl = TextEditingController();
    String? dialogError;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.key, color: Color(0xFFD97706), size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Modifier mes accès',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compte : ${_role == 'DG' ? 'Direction Générale (DG)' : 'Secrétariat'}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 14),

                if (dialogError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF87171)),
                    ),
                    child: Text(
                      dialogError!,
                      style: const TextStyle(color: Color(0xFF991B1B), fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const Text('Identifiant personnalisé', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextField(
                  controller: loginCtrl,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Mot de passe actuel (obligatoire)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextField(
                  controller: oldPwdCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Nouveau mot de passe', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextField(
                  controller: newPwdCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Confirmer nouveau mot de passe', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextField(
                  controller: confPwdCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (oldPwdCtrl.text.isEmpty) {
                        setDialogState(() => dialogError = 'Veuillez saisir votre mot de passe actuel.');
                        return;
                      }
                      if (newPwdCtrl.text.length < 4) {
                        setDialogState(() => dialogError = 'Le nouveau mot de passe doit comporter au moins 4 caractères.');
                        return;
                      }
                      if (newPwdCtrl.text != confPwdCtrl.text) {
                        setDialogState(() => dialogError = 'Les deux nouveaux mots de passe ne correspondent pas.');
                        return;
                      }

                      setDialogState(() {
                        isSaving = true;
                        dialogError = null;
                      });

                      final ok = await MobileAuthService.changeCredentials(
                        role: _role,
                        oldPassword: oldPwdCtrl.text,
                        newPassword: newPwdCtrl.text,
                        newLogin: loginCtrl.text.trim(),
                      );

                      if (!ok) {
                        setDialogState(() {
                          isSaving = false;
                          dialogError = 'Mot de passe actuel incorrect.';
                        });
                        return;
                      }

                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Color(0xFF10B981),
                          content: Text('Vos accès ont été mis à jour et sécurisés avec succès !'),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Enregistrer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
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
            tooltip: 'Supports de Révision PDF',
            icon: const Icon(Icons.menu_book, color: Color(0xFF2563EB)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GestionRevisionsScreen(role: _role),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Modifier mes accès',
            icon: const Icon(Icons.lock_reset, color: Color(0xFF2563EB)),
            onPressed: _showSecurityDialog,
          ),
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
