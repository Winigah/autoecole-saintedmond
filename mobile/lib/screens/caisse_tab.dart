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
  bool _isSyncing = false;

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

  Future<void> _refreshData() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      await DatabaseService.instance.syncWithSupabase();
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  // ─────────────────────────────────────────────────────────
  // FORMULAIRE RECETTE — BOTTOM SHEET MODERNE
  // ─────────────────────────────────────────────────────────
  void _showAddRecetteSheet() {
    final intituleController = TextEditingController();
    final montantController = TextEditingController();
    String annexe = widget.selectedAnnexe == 'Toutes'
        ? 'Tokoin Ramco (Siège)'
        : widget.selectedAnnexe;
    bool isSaving = false;

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
                      const BorderSide(color: Color(0xFF10B981), width: 1.5),
                ),
              );

          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            maxChildSize: 0.92,
            minChildSize: 0.45,
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
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.arrow_downward,
                                  color: Color(0xFF10B981), size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Encaisser une Recette',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A)),
                                ),
                                Text(
                                  'Entrée en caisse • Auto-École Saint Edmond',
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

                  // Champs scrollables
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      children: [
                        const Text(
                          '🏷️ Détails de l\'encaissement',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF047857)),
                        ),
                        const SizedBox(height: 12),

                        fieldLabel('Intitulé ou Motif *'),
                        TextField(
                          controller: intituleController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: inputDeco(icon: Icons.receipt_long),
                        ),
                        const SizedBox(height: 16),

                        fieldLabel('Montant perçu en FCFA *'),
                        TextField(
                          controller: montantController,
                          keyboardType: TextInputType.number,
                          decoration: inputDeco(icon: Icons.payments_outlined),
                        ),
                        const SizedBox(height: 16),

                        fieldLabel('Annexe concernée'),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: annexe,
                              isExpanded: true,
                              items: DatabaseService.instance.annexes
                                  .map((a) => DropdownMenuItem(
                                      value: a, child: Text(a)))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setSheetState(() => annexe = v);
                                }
                              },
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF0F172A),
                                  fontFamily: 'Poppins'),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),
                        // Boutons actions
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
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                onPressed: isSaving
                                    ? null
                                    : () {
                                        final intitule =
                                            intituleController.text.trim();
                                        final montant = int.tryParse(
                                                montantController.text) ??
                                            0;

                                        if (intitule.isEmpty || montant <= 0) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Veuillez renseigner un motif et un montant valide'),
                                              backgroundColor:
                                                  Color(0xFFDC2626),
                                            ),
                                          );
                                          return;
                                        }

                                        setSheetState(() => isSaving = true);

                                        DatabaseService.instance.addRecette(
                                          Recette(
                                            id: DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString(),
                                            intitule: intitule,
                                            montant: montant,
                                            date: DateTime.now()
                                                .toIso8601String()
                                                .split('T')[0],
                                            annexe: annexe,
                                          ),
                                        );

                                        Navigator.pop(ctx);
                                        setState(() {});
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                '✅ Recette encaissée avec succès !'),
                                            backgroundColor: Color(0xFF059669),
                                            behavior:
                                                SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 18),
                                    SizedBox(width: 8),
                                    Text('Encaisser la Recette',
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
  // FORMULAIRE DÉPENSE — BOTTOM SHEET MODERNE
  // ─────────────────────────────────────────────────────────
  void _showAddDepenseSheet() {
    final intituleController = TextEditingController();
    final montantController = TextEditingController();
    String type = 'NORMALE';
    String annexe = widget.selectedAnnexe == 'Toutes'
        ? 'Tokoin Ramco (Siège)'
        : widget.selectedAnnexe;
    bool isSaving = false;

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
                      const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                ),
              );

          return DraggableScrollableSheet(
            initialChildSize: 0.82,
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
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.arrow_upward,
                                  color: Color(0xFFEF4444), size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Enregistrer une Dépense',
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A)),
                                ),
                                Text(
                                  'Sortie de caisse • Auto-École Saint Edmond',
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

                  // Champs scrollables
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      children: [
                        const Text(
                          '📂 Catégorisation & Motif',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB91C1C)),
                        ),
                        const SizedBox(height: 12),

                        fieldLabel('Catégorie de la dépense *'),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: type,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                    value: 'NORMALE',
                                    child: Text('NORMALE (Carburant, entretien)')),
                                DropdownMenuItem(
                                    value: 'FIXE',
                                    child: Text('FIXE (Loyer, salaires)')),
                                DropdownMenuItem(
                                    value: 'SPECIALE_DG',
                                    child: Text('SPÉCIALE DG')),
                                DropdownMenuItem(
                                    value: 'SECRETAIRE',
                                    child: Text('SECRÉTAIRE (Papeterie, divers)')),
                              ],
                              onChanged: (v) {
                                if (v != null) {
                                  setSheetState(() => type = v);
                                }
                              },
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF0F172A),
                                  fontFamily: 'Poppins'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        fieldLabel('Motif / Justification *'),
                        TextField(
                          controller: intituleController,
                          textCapitalization: TextCapitalization.sentences,
                          decoration:
                              inputDeco(icon: Icons.description_outlined),
                        ),
                        const SizedBox(height: 16),

                        fieldLabel('Montant décaissé en FCFA *'),
                        TextField(
                          controller: montantController,
                          keyboardType: TextInputType.number,
                          decoration: inputDeco(
                              icon: Icons.account_balance_wallet_outlined),
                        ),
                        const SizedBox(height: 16),

                        fieldLabel('Annexe concernée'),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: annexe,
                              isExpanded: true,
                              items: DatabaseService.instance.annexes
                                  .map((a) => DropdownMenuItem(
                                      value: a, child: Text(a)))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) {
                                  setSheetState(() => annexe = v);
                                }
                              },
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF0F172A),
                                  fontFamily: 'Poppins'),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),
                        // Boutons actions
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
                                  backgroundColor: const Color(0xFFEF4444),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                onPressed: isSaving
                                    ? null
                                    : () {
                                        final intitule =
                                            intituleController.text.trim();
                                        final montant = int.tryParse(
                                                montantController.text) ??
                                            0;

                                        if (intitule.isEmpty || montant <= 0) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Veuillez renseigner un motif et un montant valide'),
                                              backgroundColor:
                                                  Color(0xFFDC2626),
                                            ),
                                          );
                                          return;
                                        }

                                        setSheetState(() => isSaving = true);

                                        DatabaseService.instance.addDepense(
                                          Depense(
                                            id: DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString(),
                                            type: type,
                                            intitule: intitule,
                                            montant: montant,
                                            date: DateTime.now()
                                                .toIso8601String()
                                                .split('T')[0],
                                            annexe: annexe,
                                          ),
                                        );

                                        Navigator.pop(ctx);
                                        setState(() {});
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                '✅ Dépense enregistrée avec succès !'),
                                            backgroundColor: Color(0xFF059669),
                                            behavior:
                                                SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 18),
                                    SizedBox(width: 8),
                                    Text('Valider la Dépense',
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

  @override
  Widget build(BuildContext context) {
    final recettes =
        DatabaseService.instance.getRecettes(annexe: widget.selectedAnnexe);
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
                Tab(
                    icon: Icon(Icons.arrow_downward, size: 18),
                    text: 'Recettes (Entrées)'),
                Tab(
                    icon: Icon(Icons.arrow_upward, size: 18),
                    text: 'Dépenses (Sorties)'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── Onglet Recettes ──────────────────────────
                Scaffold(
                  backgroundColor: Colors.transparent,
                  floatingActionButton: FloatingActionButton.extended(
                    onPressed: _showAddRecetteSheet,
                    backgroundColor: const Color(0xFF10B981),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Encaisser',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  body: RefreshIndicator(
                    onRefresh: _refreshData,
                    color: const Color(0xFF10B981),
                    child: recettes.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 120),
                              Center(
                                child: Text('Aucune recette enregistrée.',
                                    style: TextStyle(color: Color(0xFF94A3B8))),
                              ),
                            ],
                          )
                        : ListView.builder(
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
                                  border:
                                      Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(r.intitule,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14)),
                                        const SizedBox(height: 4),
                                        Text('${r.date} • ${r.annexe}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF64748B))),
                                      ],
                                    ),
                                    Text(
                                      '+${currencyFormat.format(r.montant)} F',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: Color(0xFF10B981)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),

                // ── Onglet Dépenses ──────────────────────────
                Scaffold(
                  backgroundColor: Colors.transparent,
                  floatingActionButton: FloatingActionButton.extended(
                    onPressed: _showAddDepenseSheet,
                    backgroundColor: const Color(0xFFEF4444),
                    icon: const Icon(Icons.remove, color: Colors.white),
                    label: const Text('Dépense',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  body: RefreshIndicator(
                    onRefresh: _refreshData,
                    color: const Color(0xFFEF4444),
                    child: depenses.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 120),
                              Center(
                                child: Text('Aucune dépense enregistrée.',
                                    style: TextStyle(color: Color(0xFF94A3B8))),
                              ),
                            ],
                          )
                        : ListView.builder(
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
                                  border:
                                      Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color:
                                                    const Color(0xFFF1F5F9),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(d.type,
                                                  style: const TextStyle(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(d.intitule,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text('${d.date} • ${d.annexe}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF64748B))),
                                      ],
                                    ),
                                    Text(
                                      '-${currencyFormat.format(d.montant)} F',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: Color(0xFFEF4444)),
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
          ),
        ],
      ),
    );
  }
}
