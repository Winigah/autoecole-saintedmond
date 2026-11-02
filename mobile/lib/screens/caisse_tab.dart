import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/finance.dart';
import '../services/database_service.dart';

class CaisseTab extends StatefulWidget {
  final String role;
  final String selectedAnnexe;

  const CaisseTab({
    super.key,
    required this.role,
    required this.selectedAnnexe,
  });

  @override
  State<CaisseTab> createState() => _CaisseTabState();
}

class _CaisseTabState extends State<CaisseTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currencyFormat = NumberFormat('#,###', 'fr_FR');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddRecetteDialog() {
    final intituleController = TextEditingController();
    final montantController = TextEditingController();
    String annexe = widget.selectedAnnexe == 'Toutes' ? 'Lomé – Bè' : widget.selectedAnnexe;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Encaisser une Recette', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: intituleController,
              decoration: const InputDecoration(labelText: 'Intitulé / Motif', hintText: 'Ex: Vente livret de code'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: montantController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Montant (FCFA)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () {
              final intitule = intituleController.text.trim();
              final montant = int.tryParse(montantController.text) ?? 0;
              if (intitule.isEmpty || montant <= 0) return;

              DatabaseService.instance.addRecette(
                Recette(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  intitule: intitule,
                  montant: montant,
                  date: DateTime.now().toIso8601String().split('T')[0],
                  annexe: annexe,
                ),
              );

              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recette encaissée !')));
            },
            child: const Text('Encaisser', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddDepenseDialog() {
    final intituleController = TextEditingController();
    final montantController = TextEditingController();
    String type = 'NORMALE';
    String annexe = widget.selectedAnnexe == 'Toutes' ? 'Lomé – Bè' : widget.selectedAnnexe;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Enregistrer une Dépense', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Type de dépense'),
                items: const [
                  DropdownMenuItem(value: 'NORMALE', child: Text('NORMALE (Carburant, entretien)')),
                  DropdownMenuItem(value: 'FIXE', child: Text('FIXE (Loyer, salaires)')),
                  DropdownMenuItem(value: 'SPECIALE_DG', child: Text('SPÉCIALE DG')),
                  DropdownMenuItem(value: 'SECRETAIRE', child: Text('SECRÉTAIRE (Papeterie)')),
                ],
                onChanged: (v) => setDialogState(() => type = v!),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: intituleController,
                decoration: const InputDecoration(labelText: 'Motif'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: montantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Montant (FCFA)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              onPressed: () {
                final intitule = intituleController.text.trim();
                final montant = int.tryParse(montantController.text) ?? 0;
                if (intitule.isEmpty || montant <= 0) return;

                DatabaseService.instance.addDepense(
                  Depense(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    type: type,
                    intitule: intitule,
                    montant: montant,
                    date: DateTime.now().toIso8601String().split('T')[0],
                    annexe: annexe,
                  ),
                );

                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dépense enregistrée !')));
              },
              child: const Text('Valider', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recettes = DatabaseService.instance.getRecettes(annexe: widget.selectedAnnexe);
    final depenses = DatabaseService.instance.getDepenses(
      annexe: widget.selectedAnnexe,
      isSecretaire: widget.role == 'SECRETAIRE',
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF2563EB),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: const Color(0xFF2563EB),
              tabs: const [
                Tab(icon: Icon(Icons.arrow_downward, size: 18), text: 'Recettes (Entrées)'),
                Tab(icon: Icon(Icons.arrow_upward, size: 18), text: 'Dépenses (Sorties)'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Recettes Tab
                Scaffold(
                  backgroundColor: Colors.transparent,
                  floatingActionButton: FloatingActionButton.extended(
                    onPressed: _showAddRecetteDialog,
                    backgroundColor: const Color(0xFF10B981),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Encaisser', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  body: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: recettes.length,
                    itemBuilder: (ctx, i) {
                      final r = recettes[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.intitule, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text('${r.date} • ${r.annexe}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              ],
                            ),
                            Text(
                              '+${currencyFormat.format(r.montant)} F',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF10B981)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Dépenses Tab
                Scaffold(
                  backgroundColor: Colors.transparent,
                  floatingActionButton: FloatingActionButton.extended(
                    onPressed: _showAddDepenseDialog,
                    backgroundColor: const Color(0xFFEF4444),
                    icon: const Icon(Icons.remove, color: Colors.white),
                    label: const Text('Dépense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  body: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: depenses.length,
                    itemBuilder: (ctx, i) {
                      final d = depenses[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(d.type, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(d.intitule, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('${d.date} • ${d.annexe}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                              ],
                            ),
                            Text(
                              '-${currencyFormat.format(d.montant)} F',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFFEF4444)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
