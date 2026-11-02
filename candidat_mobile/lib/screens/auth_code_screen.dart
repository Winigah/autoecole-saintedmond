import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/candidat_service.dart';
import 'candidat_home_screen.dart';

class AuthCodeScreen extends StatefulWidget {
  const AuthCodeScreen({super.key});

  @override
  State<AuthCodeScreen> createState() => _AuthCodeScreenState();
}

class _AuthCodeScreenState extends State<AuthCodeScreen> {
  final TextEditingController _codeController = TextEditingController(text: 'K7B9-4X2M');
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _validerCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = "Veuillez saisir votre code d'accès");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final data = await CandidatService.authentifierParCode(code);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (data != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CandidatHomeScreen(portalData: data),
        ),
      );
    } else {
      setState(() {
        _errorMessage = "Code d'accès non reconnu. Vérifiez le code à 8 caractères fourni par votre secrétariat.";
      });
    }
  }

  void _remplirCodeDemo(String code) {
    _codeController.text = code;
    setState(() => _errorMessage = null);
  }

  void _afficherAideCode() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text('Où trouver mon code ?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Votre code d'accès unique à 8 caractères (ex: K7B9-4X2M) vous est remis lors de votre inscription par le Directeur Général ou la Secrétaire de votre auto-école.",
              style: TextStyle(fontSize: 14, height: 1.4, color: Color(0xFF334155)),
            ),
            SizedBox(height: 12),
            Text(
              "Il vous a également été transmis par SMS ou message WhatsApp dès la validation de votre dossier.",
              style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Compris', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo officiel AutoÉcole Pro
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'AutoÉcole Pro Candidat',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Espace Élève • Suivi & Révision',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 32),

                // Card Saisie Code
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF334155)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Votre Code d'Accès",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          GestureDetector(
                            onTap: _afficherAideCode,
                            child: const Row(
                              children: [
                                Icon(Icons.help_outline, size: 14, color: Color(0xFF38BDF8)),
                                SizedBox(width: 4),
                                Text(
                                  "Aide",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF38BDF8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Input avec formatage majuscule & espacement
                      TextField(
                        controller: _codeController,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(9),
                          _CodeInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          hintText: 'XXXX-XXXX',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.25),
                            letterSpacing: 4,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF475569)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                          ),
                        ),
                        onSubmitted: (_) => _validerCode(),
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7F1D1D).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFDC2626)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, size: 16, color: Color(0xFFFCA5A5)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // Bouton d'accès
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _validerCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock_open_rounded, size: 18, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Accéder à mon Espace',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Exemples de codes pour démonstration rapide
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155).withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Codes de démonstration (cliquez pour tester) :',
                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildCodeChip('K7B9-4X2M', 'Mawuli (Admis)'),
                          _buildCodeChip('A9X2-5M8K', 'Afi (En cours)'),
                          _buildCodeChip('M4P7-9T2B', 'Yao (Permis C)'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Note sécurité
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shield_outlined, size: 14, color: Color(0xFF10B981)),
                    SizedBox(width: 6),
                    Text(
                      'Données sécurisées • Consultation élève en direct',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeChip(String code, String label) {
    return ActionChip(
      backgroundColor: const Color(0xFF0F172A),
      side: const BorderSide(color: Color(0xFF475569)),
      label: Text(
        '$code ($label)',
        style: const TextStyle(fontSize: 11, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
      ),
      onPressed: () => _remplirCodeDemo(code),
    );
  }
}

/// Formatter qui met en majuscules et insère automatiquement le tiret au milieu
class _CodeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.toUpperCase().replaceAll('-', '').replaceAll(' ', '');
    if (text.length > 8) text = text.substring(0, 8);

    String formatted = '';
    if (text.length > 4) {
      formatted = '${text.substring(0, 4)}-${text.substring(4)}';
    } else {
      formatted = text;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
