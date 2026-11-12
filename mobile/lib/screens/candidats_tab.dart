import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/candidat.dart';
import '../services/database_service.dart';

class CandidatsTab extends StatefulWidget {
  final String role;
  final String selectedAnnexe;

  const CandidatsTab({
    super.key,
    required this.role,
    required this.selectedAnnexe,
  });

  @override
  State<CandidatsTab> createState() => _CandidatsTabState();
}

class _CandidatsTabState extends State<CandidatsTab> {
  String _searchQuery = '';
  bool _isSyncing = false;
  final currencyFormat = NumberFormat('#,###', 'fr_FR');

  @override
  void initState() {
    super.initState();
    // Sync cloud au démarrage et rafraîchit l'UI
    _syncAndRefresh();
  }

  /// Synchronise avec Supabase puis rafraîchit l'affichage
  Future<void> _syncAndRefresh() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      await DatabaseService.instance.syncWithSupabase();
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  // ─────────────────────────────────────────────────────────
  // FORMULAIRE D'INSCRIPTION — BOTTOM SHEET MODERNE
  // ─────────────────────────────────────────────────────────
  void _showAddCandidatSheet() {
    final nomController = TextEditingController();
    final prenomController = TextEditingController();
    final contactController = TextEditingController();
    final adresseController = TextEditingController();
    final emailController = TextEditingController();
    final totalController = TextEditingController();
    final payeController = TextEditingController();

    String selectedCat = 'B';
    String selectedTypeFormation = 'Formation Complète';
    String selectedAnnexe =
        widget.selectedAnnexe == 'Toutes' ? 'Tokoin Ramco (Siège)' : widget.selectedAnnexe;
    String selectedLangue = 'FRANCAIS';
    String selectedSexe = 'MASCULIN';
    int selectedDureeMois = 3;
    bool isSaving = false;

    final languesDisponibles = {
      'FRANCAIS': 'Français',
      'EWE': 'Ewé',
      'MINA': 'Mina',
      'MOBA': 'Moba',
      'KOTOKOLI': 'Kotokoli',
      'KABYE': 'Kabyè',
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          // Widgets helpers
          Widget fieldLabel(String text) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              );

          InputDecoration inputDeco({IconData? icon}) =>
              InputDecoration(
                prefixIcon: icon != null
                    ? Icon(icon, size: 18, color: const Color(0xFF94A3B8))
                    : null,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                ),
              );

          return DraggableScrollableSheet(
            initialChildSize: 0.92,
            maxChildSize: 0.97,
            minChildSize: 0.5,
            expand: false,
            builder: (_, scrollController) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // ── Handle + En-tête ──────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.person_add,
                                  color: Color(0xFF2563EB), size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Inscrire un Candidat',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A)),
                                ),
                                Text(
                                  'Auto-École Saint Edmond',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFFE2E8F0)),
                      ],
                    ),
                  ),

                  // ── Formulaire scrollable ─────────────────────
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      children: [
                        // Section Identité
                        _sectionTitle('Identité du Candidat'),
                        const SizedBox(height: 10),

                        fieldLabel('Nom de famille *'),
                        TextField(
                          controller: nomController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: inputDeco(icon: Icons.badge_outlined),
                        ),
                        const SizedBox(height: 14),

                        fieldLabel('Prénom *'),
                        TextField(
                          controller: prenomController,
                          textCapitalization: TextCapitalization.words,
                          decoration: inputDeco(icon: Icons.person_outline),
                        ),
                        const SizedBox(height: 14),

                        fieldLabel('Sexe'),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: ['MASCULIN', 'FEMININ'].map((sexe) {
                              final isSelected = selectedSexe == sexe;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setSheetState(() => selectedSexe = sexe),
                                  child: Container(
                                    margin: const EdgeInsets.all(4),
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF2563EB)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          sexe == 'MASCULIN'
                                              ? Icons.male
                                              : Icons.female,
                                          size: 18,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF64748B),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          sexe == 'MASCULIN' ? 'Masculin' : 'Féminin',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? Colors.white
                                                : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 14),

                        fieldLabel('Téléphone *'),
                        TextField(
                          controller: contactController,
                          keyboardType: TextInputType.phone,
                          decoration: inputDeco(icon: Icons.phone_outlined),
                        ),
                        const SizedBox(height: 14),

                        fieldLabel('Adresse / Ville'),
                        TextField(
                          controller: adresseController,
                          decoration:
                              inputDeco(icon: Icons.location_on_outlined),
                        ),
                        const SizedBox(height: 14),

                        fieldLabel('Email (optionnel)'),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration:
                              inputDeco(icon: Icons.email_outlined),
                        ),

                        const SizedBox(height: 20),
                        // Section Formation
                        _sectionTitle('Formation & Permis'),
                        const SizedBox(height: 10),

                        fieldLabel('Type de Formation'),
                        _styledDropdown<String>(
                          value: selectedTypeFormation,
                          items: [
                            'Formation Complète',
                            'Achat de Conduite Uniquement',
                            'Recyclage',
                          ]
                              .map((t) => DropdownMenuItem(
                                  value: t, child: Text(t)))
                              .toList(),
                          onChanged: (v) =>
                              setSheetState(() => selectedTypeFormation = v!),
                        ),
                        const SizedBox(height: 14),

                        fieldLabel('Catégorie de Permis'),
                        _styledDropdown<String>(
                          value: selectedCat,
                          items: ['A', 'B', 'C', 'D', 'E']
                              .map((c) => DropdownMenuItem(
                                  value: c, child: Text('Permis $c')))
                              .toList(),
                          onChanged: (v) =>
                              setSheetState(() => selectedCat = v!),
                        ),
                        const SizedBox(height: 14),

                        fieldLabel('Langue de formation'),
                        _styledDropdown<String>(
                          value: selectedLangue,
                          items: languesDisponibles.entries
                              .map((e) => DropdownMenuItem(
                                  value: e.key, child: Text(e.value)))
                              .toList(),
                          onChanged: (v) =>
                              setSheetState(() => selectedLangue = v!),
                        ),
                        const SizedBox(height: 14),

                        fieldLabel('Durée de Formation'),
                        _styledDropdown<int>(
                          value: selectedDureeMois,
                          items: List.generate(12, (i) => i + 1)
                              .map((m) => DropdownMenuItem(
                                  value: m, child: Text('$m mois')))
                              .toList(),
                          onChanged: (v) =>
                              setSheetState(() => selectedDureeMois = v!),
                        ),
                        const SizedBox(height: 14),

                        fieldLabel('Annexe'),
                        _styledDropdown<String>(
                          value: selectedAnnexe,
                          items: DatabaseService.instance.annexes
                              .map((a) =>
                                  DropdownMenuItem(value: a, child: Text(a)))
                              .toList(),
                          onChanged: (v) =>
                              setSheetState(() => selectedAnnexe = v!),
                        ),

                        const SizedBox(height: 20),
                        // Section Paiement
                        _sectionTitle('Règlement & Scolarité'),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  fieldLabel('Montant Total (FCFA)'),
                                  TextField(
                                    controller: totalController,
                                    keyboardType: TextInputType.number,
                                    decoration: inputDeco(
                                        icon: Icons.payments_outlined),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  fieldLabel('Montant Payé (FCFA)'),
                                  TextField(
                                    controller: payeController,
                                    keyboardType: TextInputType.number,
                                    decoration: inputDeco(
                                        icon: Icons.account_balance_wallet_outlined),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),
                        // Boutons action
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  side: const BorderSide(
                                      color: Color(0xFFCBD5E1)),
                                ),
                                onPressed: isSaving
                                    ? null
                                    : () => Navigator.pop(ctx),
                                child: const Text('Annuler',
                                    style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                onPressed: isSaving
                                    ? null
                                    : () async {
                                        final nom = nomController.text.trim();
                                        final prenom =
                                            prenomController.text.trim();
                                        final contact =
                                            contactController.text.trim();
                                        final total =
                                            int.tryParse(totalController.text) ??
                                                120000;
                                        final paye =
                                            int.tryParse(payeController.text) ??
                                                0;

                                        if (nom.isEmpty ||
                                            prenom.isEmpty ||
                                            contact.isEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Veuillez remplir nom, prénom et contact'),
                                              backgroundColor:
                                                  Color(0xFFDC2626),
                                            ),
                                          );
                                          return;
                                        }

                                        final messenger = ScaffoldMessenger.of(context);
                                        setSheetState(() => isSaving = true);

                                        final newCand = Candidat(
                                          id: DateTime.now()
                                              .millisecondsSinceEpoch
                                              .toString(),
                                          nom: nom.toUpperCase(),
                                          prenom: prenom,
                                          contact: contact,
                                          email: emailController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : emailController.text.trim(),
                                          adresse: adresseController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : adresseController.text.trim(),
                                          annexe: selectedAnnexe,
                                          categorie: selectedCat,
                                          langue: selectedLangue,
                                          sexe: selectedSexe,
                                          montantTotal: total,
                                          montantPaye: paye,
                                          dateInscription: DateTime.now()
                                              .toIso8601String()
                                              .split('T')[0],
                                          dureeFormationMois: selectedDureeMois,
                                          statut: 'INSCRIT',
                                        );

                                        await DatabaseService.instance.addCandidatAsync(
                                            newCand,
                                            premierVersement: paye);

                                        if (ctx.mounted) {
                                          Navigator.pop(ctx);
                                        }
                                        if (mounted) {
                                          setState(() {});
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  '✅ ${newCand.nom} ${newCand.prenom} inscrit(e) avec succès !'),
                                              backgroundColor:
                                                  const Color(0xFF059669),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      },
                                child: isSaving
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.check_circle_outline,
                                              size: 18),
                                          SizedBox(width: 8),
                                          Text('Enregistrer',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15)),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E40AF),
            letterSpacing: 0.3,
          ),
        ),
      );

  Widget _styledDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            items: items,
            onChanged: onChanged,
            style: const TextStyle(
                fontSize: 14, color: Color(0xFF0F172A), fontFamily: 'Poppins'),
            icon: const Icon(Icons.keyboard_arrow_down,
                color: Color(0xFF94A3B8)),
          ),
        ),
      );

  // ─────────────────────────────────────────────────────────
  // FORMULAIRE SUPPLÉMENT CONDUITE — BOTTOM SHEET MODERNE
  // ─────────────────────────────────────────────────────────
  void _showAddSupplementConduiteDialog(Candidat c) {
    final nbSeancesController = TextEditingController(text: '4');
    final montantTotalController = TextEditingController(text: '20000');
    final montantVerseController = TextEditingController(text: '20000');
    String selectedMotif = 'Perfectionnement créneau et manœuvres';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          Widget fieldLabel(String text) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              );

          InputDecoration inputDeco({IconData? icon}) => InputDecoration(
                prefixIcon: icon != null
                    ? Icon(icon, size: 18, color: const Color(0xFF94A3B8))
                    : null,
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFD97706), width: 1.5),
                ),
              );

          return DraggableScrollableSheet(
            initialChildSize: 0.88,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (_, scrollController) => Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle + En-tête
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.directions_car,
                                  color: Color(0xFFD97706), size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Séances Supplémentaires',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A)),
                                ),
                                Text(
                                  'Ajout d\'heures de conduite',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFFE2E8F0)),
                      ],
                    ),
                  ),

                  // Contenu scrollable
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      children: [
                        // Candidat concerné
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFF2563EB),
                                child: Text(
                                  c.prenom.isNotEmpty ? c.prenom[0].toUpperCase() : 'C',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${c.nom} ${c.prenom}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF0F172A)),
                                    ),
                                    Text(
                                      'Contact : ${c.contact}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Cat. ${c.categorie}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2563EB),
                                      fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Section Séances
                        _sectionTitle('Heures de Conduite'),
                        const SizedBox(height: 10),

                        fieldLabel('Raccourcis rapides :'),
                        Row(
                          children: [2, 4, 6, 10].map((preset) {
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 3.0),
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 10),
                                    backgroundColor:
                                        nbSeancesController.text == preset.toString()
                                            ? const Color(0xFFFEF3C7)
                                            : Colors.transparent,
                                    side: BorderSide(
                                      color: nbSeancesController.text ==
                                              preset.toString()
                                          ? const Color(0xFFD97706)
                                          : const Color(0xFFCBD5E1),
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                  onPressed: () {
                                    setSheetState(() {
                                      nbSeancesController.text = preset.toString();
                                      final total = preset * 5000;
                                      montantTotalController.text =
                                          total.toString();
                                      montantVerseController.text =
                                          total.toString();
                                    });
                                  },
                                  child: Text('+$preset',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: nbSeancesController.text ==
                                                  preset.toString()
                                              ? const Color(0xFFB45309)
                                              : const Color(0xFF475569))),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),

                        fieldLabel('Nombre total de séances supplémentaires :'),
                        TextField(
                          controller: nbSeancesController,
                          keyboardType: TextInputType.number,
                          decoration: inputDeco(icon: Icons.add_circle_outline),
                          onChanged: (val) {
                            final nb = int.tryParse(val) ?? 0;
                            setSheetState(() {
                              final total = nb * 5000;
                              montantTotalController.text = total.toString();
                              montantVerseController.text = total.toString();
                            });
                          },
                        ),
                        const SizedBox(height: 14),

                        fieldLabel('Motif du perfectionnement :'),
                        _styledDropdown<String>(
                          value: selectedMotif,
                          items: [
                            'Perfectionnement créneau et manœuvres',
                            'Heures supplémentaires post-ajournement',
                            'Renforcement circulation et route',
                            'À la demande du candidat',
                          ]
                              .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(m,
                                      style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (v) =>
                              setSheetState(() => selectedMotif = v!),
                        ),

                        const SizedBox(height: 20),
                        // Section Règlement
                        _sectionTitle('Règlement'),
                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  fieldLabel('Montant Total (FCFA)'),
                                  TextField(
                                    controller: montantTotalController,
                                    keyboardType: TextInputType.number,
                                    decoration: inputDeco(
                                        icon: Icons.payments_outlined),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  fieldLabel('Montant Versé ce jour'),
                                  TextField(
                                    controller: montantVerseController,
                                    keyboardType: TextInputType.number,
                                    decoration: inputDeco(
                                        icon: Icons.account_balance_wallet_outlined),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),
                        // Boutons validation
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  side: const BorderSide(
                                      color: Color(0xFFCBD5E1)),
                                ),
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Annuler',
                                    style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD97706),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  final nb = int.tryParse(
                                          nbSeancesController.text) ??
                                      0;
                                  final total = int.tryParse(
                                          montantTotalController.text) ??
                                      0;
                                  final paye = int.tryParse(
                                          montantVerseController.text) ??
                                      0;

                                  if (nb <= 0 || total <= 0) return;

                                  DatabaseService.instance.addSupplementConduite(
                                    candidatId: c.id,
                                    nbSeances: nb,
                                    montantSupplement: total,
                                    montantVerse: paye,
                                    motif: selectedMotif,
                                  );

                                  Navigator.pop(ctx);
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '✅ +$nb séances enregistrées pour ${c.nom} ${c.prenom}'),
                                      backgroundColor: const Color(0xFF059669),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 18),
                                    SizedBox(width: 8),
                                    Text('Valider Supplément',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // BUILD PRINCIPAL
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final candidats = DatabaseService.instance.getCandidats(
      annexe: widget.selectedAnnexe,
      query: _searchQuery,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCandidatSheet,
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Inscrire',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Barre de recherche + bouton sync
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un candidat...',
                      prefixIcon: const Icon(Icons.search,
                          size: 20, color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Bouton rafraîchir
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: IconButton(
                    onPressed: _isSyncing ? null : _syncAndRefresh,
                    tooltip: 'Synchroniser avec le cloud',
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF2563EB)),
                          )
                        : const Icon(Icons.cloud_sync,
                            color: Color(0xFF2563EB), size: 22),
                  ),
                ),
              ],
            ),
          ),

          // Compteur + info sync
          if (candidats.isNotEmpty || _isSyncing)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                children: [
                  Text(
                    '${candidats.length} candidat${candidats.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  if (_isSyncing)
                    const Text('Synchro cloud...',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2563EB),
                            fontStyle: FontStyle.italic)),
                ],
              ),
            ),

          // Liste des candidats avec pull-to-refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: _syncAndRefresh,
              color: const Color(0xFF2563EB),
              child: candidats.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: 300,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline,
                                    size: 56,
                                    color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                const Text('Aucun candidat trouvé.',
                                    style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 15)),
                                const SizedBox(height: 6),
                                const Text(
                                    'Tirez vers le bas pour synchroniser.',
                                    style: TextStyle(
                                        color: Color(0xFFCBD5E1),
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: candidats.length,
                      itemBuilder: (ctx, i) {
                        final c = candidats[i];
                        final reste = c.resteAPayer;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${c.nom} ${c.prenom}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF0F172A)),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: c.statut == 'ADMIS'
                                          ? const Color(0xFFD1FAE5)
                                          : c.statut == 'NON_ADMIS'
                                              ? const Color(0xFFFFE4E6)
                                              : const Color(0xFFFEF3C7),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      c.statut,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: c.statut == 'ADMIS'
                                            ? const Color(0xFF059669)
                                            : c.statut == 'NON_ADMIS'
                                                ? const Color(0xFFE11D48)
                                                : const Color(0xFFD97706),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Permis ${c.categorie} • ${c.langue} • ${c.annexe}${c.dureeFormationMois != null ? " • ${c.dureeFormationMois} mois" : ""}',
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF64748B)),
                              ),
                              if (c.adresse != null && c.adresse!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    c.adresse!,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF94A3B8)),
                                  ),
                                ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Payé: ${currencyFormat.format(c.montantPaye)} / ${currencyFormat.format(c.montantTotal)} F',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A)),
                                      ),
                                      if (reste > 0)
                                        Text(
                                          'Reste: ${currencyFormat.format(reste)} F',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFD97706)),
                                        ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.add_road,
                                            size: 20,
                                            color: Color(0xFFD97706)),
                                        tooltip:
                                            'Acheter séances de conduite',
                                        onPressed: () =>
                                            _showAddSupplementConduiteDialog(
                                                c),
                                        style: IconButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFFEF3C7)),
                                      ),
                                      const SizedBox(width: 6),
                                      IconButton(
                                        icon: const Icon(Icons.phone,
                                            size: 20,
                                            color: Color(0xFF2563EB)),
                                        onPressed: () =>
                                            DatabaseService.launchCall(
                                                c.contact),
                                        style: IconButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFEFF6FF)),
                                      ),
                                      const SizedBox(width: 6),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.chat_bubble_outline,
                                            size: 20,
                                            color: Color(0xFF10B981)),
                                        onPressed: () =>
                                            DatabaseService.launchWhatsApp(
                                                c.contact, c.prenom),
                                        style: IconButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFECFDF5)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
