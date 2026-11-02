import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/candidat_info.dart';
import '../../services/candidat_service.dart';

class PlanningTab extends StatefulWidget {
  final CandidatPortalData data;

  const PlanningTab({super.key, required this.data});

  @override
  State<PlanningTab> createState() => _PlanningTabState();
}

class _PlanningTabState extends State<PlanningTab> {
  String _filtreType = 'TOUS';

  @override
  Widget build(BuildContext context) {
    final cand = widget.data.candidat;
    final ecole = widget.data.entreprise;

    final seancesFiltrees = widget.data.seances.where((s) {
      if (_filtreType == 'CONDUITE') return s.estConduite;
      if (_filtreType == 'CODE') return !s.estConduite;
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Récapitulatif Conduite (Compteurs)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.directions_car_rounded, color: Color(0xFF2563EB), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Volume de Conduite Pratique',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Prévues', '${cand.nbConduitesPrevues}', const Color(0xFF64748B)),
                    Container(height: 36, width: 1, color: const Color(0xFFE2E8F0)),
                    _buildStatItem('Effectuées', '${cand.nbConduitesEffectuees}', const Color(0xFF10B981)),
                    Container(height: 36, width: 1, color: const Color(0xFFE2E8F0)),
                    _buildStatItem('Restantes', '${cand.nbConduitesRestantes}', const Color(0xFF2563EB)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // En-tête de section & Filtres
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calendrier des Séances',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              // Segmented Filter
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildFilterBtn('TOUS', 'Tous'),
                    _buildFilterBtn('CONDUITE', 'Conduite'),
                    _buildFilterBtn('CODE', 'Code'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Liste des séances
          if (seancesFiltrees.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.calendar_month_outlined, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'Aucune séance programmée pour ce filtre.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: seancesFiltrees.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final s = seancesFiltrees[index];
                return _buildSeanceCard(s, ecole, cand);
              },
            ),

          const SizedBox(height: 20),

          // Grille des Horaires & Créneaux disponibles de l'Auto-École
          _buildHorairesDisponibles(ecole, cand),

          const SizedBox(height: 18),

          // Information importante
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Règle d\'absence ou de report :',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E3A8A)),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Toute séance doit être annulée ou reportée au moins 24h à l\'avance auprès du secrétariat, faute de quoi elle sera décomptée.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF), height: 1.3),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => CandidatService.contacterAutoEcoleWhatsApp(
                          telephone: ecole.telephone,
                          nomCandidat: cand.nomComplet,
                          codeAcces: cand.codeAcces,
                          sujet: "Je souhaite demander un aménagement ou un report d'une séance de conduite.",
                        ),
                        child: const Text(
                          'Contacter l\'auto-école par WhatsApp →',
                          style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFilterBtn(String id, String label) {
    final active = _filtreType == id;
    return InkWell(
      onTap: () => setState(() => _filtreType = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? const Color(0xFF2563EB) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildSeanceCard(SeanceCandidat s, AutoEcoleInfo ecole, CandidatDetails cand) {
    final isPlanifie = s.statut == 'PLANIFIE';
    final isEffectue = s.statut == 'EFFECTUE';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPlanifie ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
          width: isPlanifie ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: s.estConduite ? const Color(0xFFEFF6FF) : const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      s.estConduite ? Icons.directions_car_rounded : Icons.menu_book_rounded,
                      color: s.estConduite ? const Color(0xFF2563EB) : const Color(0xFF9333EA),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Séance de ${s.typeSeance}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        '${s.dureeMinutes} minutes • ${s.moniteurNom}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: isEffectue
                      ? const Color(0xFFDCFCE7)
                      : isPlanifie
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isEffectue
                      ? 'Effectué ✓'
                      : isPlanifie
                          ? 'À venir ⏳'
                          : s.statut,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isEffectue
                        ? const Color(0xFF166534)
                        : isPlanifie
                            ? const Color(0xFF92400E)
                            : const Color(0xFF991B1B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 5),
              Text(
                DateFormat('EEEE d MMMM yyyy à HH:mm', 'fr_FR').format(s.dateHeure),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
              ),
            ],
          ),
          if (s.notes != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                s.notes!,
                style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHorairesDisponibles(AutoEcoleInfo ecole, CandidatDetails cand) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.schedule_rounded, color: Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Créneaux Disponibles • ${ecole.nom}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    const Text(
                      'Horaires des cours en salle & conduites pratiques',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Cours de Code
          _buildCreneauBloc(
            icon: Icons.menu_book_rounded,
            iconColor: const Color(0xFF9333EA),
            bgColor: const Color(0xFFF3E8FF),
            titre: 'Cours de Code de la Route (Salle & Visio)',
            details: [
              '• Du Lundi au Vendredi : 08h00 - 10h00  |  10h00 - 12h00',
              '• Soir (Spécial travailleurs) : 15h00 - 17h00  |  18h00 - 20h00',
              '• Samedi : 08h00 - 12h00 (Examen blanc & Grand récapitulatif)',
            ],
          ),

          const SizedBox(height: 12),

          // 2. Conduite Pratique
          _buildCreneauBloc(
            icon: Icons.directions_car_rounded,
            iconColor: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
            titre: 'Séances Pratiques de Conduite (Circuits & Ville)',
            details: [
              '• Du Lundi au Samedi : 06h30 à 18h00 (sur réservation)',
              '• Créneaux individuels au choix : 1h ou 2h par séance',
              '• Formation à Domicile : Horaires sur mesure avec votre moniteur',
            ],
          ),

          const SizedBox(height: 14),

          // Bouton Réserver
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => CandidatService.contacterAutoEcoleWhatsApp(
                telephone: ecole.telephone,
                nomCandidat: cand.nomComplet,
                codeAcces: cand.codeAcces,
                sujet: "Bonjour, je souhaite réserver ou ajuster un créneau de séance (Code/Conduite).",
              ),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text('Demander un créneau au secrétariat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreneauBloc({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String titre,
    required List<String> details,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titre,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E293B)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...details.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                d,
                style: const TextStyle(fontSize: 11, color: Color(0xFF475569), height: 1.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
