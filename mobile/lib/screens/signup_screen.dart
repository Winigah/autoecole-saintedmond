import 'package:flutter/material.dart';
import '../services/security_service.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _schoolNameController = TextEditingController();
  final _directorNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController(text: 'Lomé - Siège');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedPlan = 'Mensuel (15 000 F)';
  bool _isLoading = false;

  void _handleSignup() async {
    final school = _schoolNameController.text.trim();
    final director = _directorNameController.text.trim();
    final phone = _phoneController.text.trim();

    if (school.isEmpty || director.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir le nom de l\'école, le responsable et le contact.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 700));

    // Sauvegarde sécurisée de la session DG pour la nouvelle entreprise
    await SecurityService.saveSession(
      token: 'jwt_secure_token_${DateTime.now().millisecondsSinceEpoch}',
      role: 'DG',
    );

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(initialRole: 'DG'),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Créer mon Auto-École', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 14-days trial banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.stars, color: Color(0xFF2563EB), size: 24),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '14 jours d\'essai gratuit offert sans engagement. Accès direct à toutes les fonctionnalités.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _schoolNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom de l\'Auto-École',
                        hintText: 'Ex: Auto-École La Référence',
                        prefixIcon: Icon(Icons.business_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _directorNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom du Directeur / Responsable',
                        hintText: 'Ex: Koffi Mensah',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone / WhatsApp',
                        hintText: 'Ex: 90 XX XX XX',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Quartier / Ville du Siège',
                        hintText: 'Ex: Lomé - Tokoin',
                        prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email de connexion',
                        hintText: 'direction@autoecole.com',
                        prefixIcon: Icon(Icons.mail_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Mot de passe sécurisé',
                        prefixIcon: Icon(Icons.lock_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPlan,
                      decoration: const InputDecoration(
                        labelText: 'Formule après essai',
                        prefixIcon: Icon(Icons.card_membership_outlined, size: 20),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Mensuel (15 000 F)', child: Text('Mensuel (15 000 F / mois)')),
                        DropdownMenuItem(value: 'Trimestriel (40 000 F)', child: Text('Trimestriel (40 000 F / 3 mois)')),
                        DropdownMenuItem(value: 'Annuel (150 000 F)', child: Text('Annuel (150 000 F / an)')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedPlan = v);
                      },
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : const Text(
                                'Démarrer l\'essai gratuit 14 jours',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Déjà une auto-école enregistrée ? Se connecter', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
