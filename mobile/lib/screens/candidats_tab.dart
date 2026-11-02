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
  final currencyFormat = NumberFormat('#,###', 'fr_FR');

  void _showAddCandidatDialog() {
    final nomController = TextEditingController();
    final prenomController = TextEditingController();
    final contactController = TextEditingController();
    final adresseController = TextEditingController();
    final emailController = TextEditingController();
    final totalController = TextEditingController(text: '120000');
    final payeController = TextEditingController(text: '40000');
    String selectedCat = 'B';
    String selectedAnnexe = widget.selectedAnnexe == 'Toutes' ? 'Lomé – Bè' : widget.selectedAnnexe;
    String selectedLangue = 'FRANCAIS';
    int selectedDureeMois = 3;

    final languesDisponibles = {
      'FRANCAIS': 'Français',
      'EWE': 'Ewé',
      'MINA': 'Mina',
      'MOBA': 'Moba',
      'KOTOKOLI': 'Kotokoli',
      'KABYE': 'Kabyè',
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Inscrire un Candidat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Nom de famille', isDense: true),
                ),
                TextField(
                  controller: prenomController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Prénom', isDense: true),
                ),
                TextField(
                  controller: contactController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Téléphone (Contact)', isDense: true),
                ),
                TextField(
                  controller: adresseController,
                  decoration: const InputDecoration(labelText: 'Adresse / Ville du candidat', isDense: true),
                ),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email / Optionnel', isDense: true),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedCat,
                  decoration: const InputDecoration(labelText: 'Permis', isDense: true),
                  items: ['A', 'B', 'C', 'D', 'E'].map((c) => DropdownMenuItem(value: c, child: Text('Catégorie $c'))).toList(),
                  onChanged: (v) => setDialogState(() => selectedCat = v!),
                ),
                DropdownButtonFormField<String>(
                  initialValue: selectedLangue,
                  decoration: const InputDecoration(labelText: 'Langue', isDense: true),
                  items: languesDisponibles.entries.map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value))).toList(),
                  onChanged: (v) => setDialogState(() => selectedLangue = v!),
                ),
                DropdownButtonFormField<int>(
                  initialValue: selectedDureeMois,
                  decoration: const InputDecoration(labelText: 'Durée de Formation en Mois', isDense: true),
                  items: List.generate(12, (index) => index + 1)
                      .map((m) => DropdownMenuItem(value: m, child: Text('$m mois')))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedDureeMois = v!),
                ),
                DropdownButtonFormField<String>(
                  initialValue: selectedAnnexe,
                  decoration: const InputDecoration(labelText: 'Annexe', isDense: true),
                  items: DatabaseService.instance.annexes.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                  onChanged: (v) => setDialogState(() => selectedAnnexe = v!),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: totalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Montant Total en FCFA', isDense: true),
                ),
                TextField(
                  controller: payeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Montant Payé en FCFA', isDense: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              onPressed: () {
                final nom = nomController.text.trim();
                final prenom = prenomController.text.trim();
                final contact = contactController.text.trim();
                final total = int.tryParse(totalController.text) ?? 120000;
                final paye = int.tryParse(payeController.text) ?? 0;

                if (nom.isEmpty || prenom.isEmpty || contact.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez remplir nom, prénom et contact')),
                  );
                  return;
                }

                final newCand = Candidat(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  nom: nom.toUpperCase(),
                  prenom: prenom,
                  contact: contact,
                  email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                  adresse: adresseController.text.trim().isEmpty ? null : adresseController.text.trim(),
                  annexe: selectedAnnexe,
                  categorie: selectedCat,
                  langue: selectedLangue,
                  sexe: 'MASCULIN',
                  montantTotal: total,
                  montantPaye: paye,
                  dateInscription: DateTime.now().toIso8601String().split('T')[0],
                  dureeFormationMois: selectedDureeMois,
                  statut: 'INSCRIT',
                );

                DatabaseService.instance.addCandidat(newCand, premierVersement: paye);
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Candidat ${newCand.nom} inscrit avec succès !')),
                );
              },
              child: const Text('Enregistrer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSupplementConduiteDialog(Candidat c) {
    final nbSeancesController = TextEditingController(text: '4');
    final montantTotalController = TextEditingController(text: '20000');
    final montantVerseController = TextEditingController(text: '20000');
    String selectedMotif = 'Perfectionnement créneau et manœuvres';

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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_car, color: Color(0xFFD97706), size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Séances Supplémentaires', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Ajouter des heures de conduite', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${c.nom} ${c.prenom}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        'Cat. ${c.categorie}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Nombre de séances :', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(
                  children: [2, 4, 6, 10].map((preset) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            setDialogState(() {
                              nbSeancesController.text = preset.toString();
                              final total = preset * 5000;
                              montantTotalController.text = total.toString();
                              montantVerseController.text = total.toString();
                            });
                          },
                          child: Text('+$preset', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nbSeancesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Séances à ajouter', isDense: true),
                  onChanged: (val) {
                    final nb = int.tryParse(val) ?? 0;
                    setDialogState(() {
                      final total = nb * 5000;
                      montantTotalController.text = total.toString();
                      montantVerseController.text = total.toString();
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: montantTotalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Montant Total Supplément (FCFA)', isDense: true),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: montantVerseController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Montant Versé ce jour (FCFA)', isDense: true),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: selectedMotif,
                  decoration: const InputDecoration(labelText: 'Motif', isDense: true),
                  items: [
                    'Perfectionnement créneau et manœuvres',
                    'Heures supplémentaires post-ajournement',
                    'Renforcement circulation et route',
                    'À la demande du candidat',
                  ].map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (v) => setDialogState(() => selectedMotif = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final nb = int.tryParse(nbSeancesController.text) ?? 0;
                final total = int.tryParse(montantTotalController.text) ?? 0;
                final paye = int.tryParse(montantVerseController.text) ?? 0;

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
                    content: Text('+$nb séances de conduite enregistrées pour ${c.nom} ${c.prenom}'),
                    backgroundColor: const Color(0xFF059669),
                  ),
                );
              },
              child: const Text('Valider Supplément'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final candidats = DatabaseService.instance.getCandidats(
      annexe: widget.selectedAnnexe,
      query: _searchQuery,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCandidatDialog,
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Inscrire', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Rechercher un candidat...',
                prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
          ),

          // List of candidates
          Expanded(
            child: candidats.isEmpty
                ? const Center(
                    child: Text('Aucun candidat trouvé.', style: TextStyle(color: Color(0xFF94A3B8))),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${c.nom} ${c.prenom}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: c.statut == 'ADMIS'
                                        ? const Color(0xFFD1FAE5)
                                        : c.statut == 'NON_ADMIS'
                                            ? const Color(0xFFFFE4E6)
                                            : const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(20),
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
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                            if (c.adresse != null && c.adresse!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  c.adresse!,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                ),
                              ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Payé: ${currencyFormat.format(c.montantPaye)} / ${currencyFormat.format(c.montantTotal)} F',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                    ),
                                    if (reste > 0)
                                      Text(
                                        'Reste: ${currencyFormat.format(reste)} F',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFD97706)),
                                      ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.add_road, size: 20, color: Color(0xFFD97706)),
                                      tooltip: 'Acheter séances de conduite',
                                      onPressed: () => _showAddSupplementConduiteDialog(c),
                                      style: IconButton.styleFrom(backgroundColor: const Color(0xFFFEF3C7)),
                                    ),
                                    const SizedBox(width: 6),
                                    IconButton(
                                      icon: const Icon(Icons.phone, size: 20, color: Color(0xFF2563EB)),
                                      onPressed: () => DatabaseService.launchCall(c.contact),
                                      style: IconButton.styleFrom(backgroundColor: const Color(0xFFEFF6FF)),
                                    ),
                                    const SizedBox(width: 6),
                                    IconButton(
                                      icon: const Icon(Icons.chat_bubble_outline, size: 20, color: Color(0xFF10B981)),
                                      onPressed: () => DatabaseService.launchWhatsApp(c.contact, c.prenom),
                                      style: IconButton.styleFrom(backgroundColor: const Color(0xFFECFDF5)),
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
        ],
      ),
    );
  }
}
