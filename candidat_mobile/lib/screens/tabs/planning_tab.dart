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
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── RÉCAPITULATIF CONDUITE ÉPURÉ & MODERNE ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.directions_car_rounded, color: Color(0xFF2563EB), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Volume de Conduite Pratique',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Permis ${cand.categoriePermis}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Prévues', '${cand.nbConduitesPrevues}', const Color(0xFF64748B)),
                    Container(height: 28, width: 1, color: const Color(0xFFE2E8F0)),
                    _buildStatItem('Effectuées', '${cand.nbConduitesEffectuees}', const Color(0xFF10B981)),
                    Container(height: 28, width: 1, color: const Color(0xFFE2E8F0)),
                    _buildStatItem('Restantes', '${cand.nbConduitesRestantes}', const Color(0xFF2563EB)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── EN-TÊTE CALENDRIER & FILTRES EN PILULES FINES ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calendrier des Séances',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(9),
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

          const SizedBox(height: 10),

          // ── LISTE DES SÉANCES ──
          if (seancesFiltrees.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.event_available_outlined, size: 36, color: Color(0xFFCBD5E1)),
                  SizedBox(height: 8),
                  Text(
                    'Aucune séance programmée dans cette vue.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: seancesFiltrees.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final s = seancesFiltrees[index];
                return _buildSeanceCard(s, ecole, cand);
              },
            ),

          const SizedBox(height: 16),

          // ── CRÉNEAUX DISPONIBLES EN ACCORDÉON COMPACT ──
          _buildHorairesDisponiblesAccordeon(ecole, cand),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 1),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFilterBtn(String id, String label) {
    final active = _filtreType == id;
    return InkWell(
      onTap: () => setState(() => _filtreType = id),
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 3)]
              : null,
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPlanifie ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
          width: isPlanifie ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: s.estConduite ? const Color(0xFFEFF6FF) : const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(
                        s.estConduite ? Icons.directions_car_rounded : Icons.menu_book_rounded,
                        color: s.estConduite ? const Color(0xFF2563EB) : const Color(0xFF9333EA),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Séance de ${s.typeSeance}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1.5),
                          Text(
                            '${s.dureeMinutes} min • ${s.moniteurNom}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isEffectue
                      ? const Color(0xFFDCFCE7)
                      : isPlanifie
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isEffectue
                          ? Icons.check_circle_rounded
                          : (isPlanifie ? Icons.schedule_rounded : Icons.cancel_rounded),
                      size: 11,
                      color: isEffectue
                          ? const Color(0xFF166534)
                          : isPlanifie
                              ? const Color(0xFF92400E)
                              : const Color(0xFF991B1B),
                    ),
                    const SizedBox(width: 3.5),
                    Text(
                      isEffectue
                          ? 'Effectué'
                          : isPlanifie
                              ? 'À venir'
                              : s.statut,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isEffectue
                            ? const Color(0xFF166534)
                            : isPlanifie
                                ? const Color(0xFF92400E)
                                : const Color(0xFF991B1B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
              const SizedBox(width: 5),
              Text(
                DateFormat('EEEE d MMMM yyyy à HH:mm', 'fr_FR').format(s.dateHeure),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
          if (s.notes != null && s.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                s.notes!,
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHorairesDisponiblesAccordeon(AutoEcoleInfo ecole, CandidatDetails cand) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.schedule_rounded, color: Color(0xFF2563EB), size: 18),
          ),
          title: const Text(
            'Horaires & Créneaux de cours',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
          ),
          subtitle: const Text(
            'Consulter les plages de Code et Conduite',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
          children: [
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 12),
            // Code
            _buildCreneauLigne(
              icon: Icons.menu_book_rounded,
              titre: 'Code (Salle & Visio)',
              horaire: 'Lun-Ven : 08h-10h | 10h-12h | 15h-17h | 18h-20h • Sam : 08h-12h',
              color: const Color(0xFF9333EA),
              bg: const Color(0xFFF3E8FF),
            ),
            const SizedBox(height: 8),
            // Conduite
            _buildCreneauLigne(
              icon: Icons.directions_car_rounded,
              titre: 'Conduite Pratique',
              horaire: 'Du Lundi au Samedi : 06h30 à 18h00 (séances de 1h ou 2h)',
              color: const Color(0xFF2563EB),
              bg: const Color(0xFFEFF6FF),
            ),
            const SizedBox(height: 14),
            // Bouton WhatsApp rapide
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: () => CandidatService.contacterAutoEcoleWhatsApp(
                  telephone: ecole.telephone,
                  nomCandidat: cand.nomComplet,
                  codeAcces: cand.codeAcces,
                  sujet: "Bonjour, je souhaite réserver ou ajuster un créneau de séance.",
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                label: const Text(
                  'Demander un créneau au secrétariat',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreneauLigne({
    required IconData icon,
    required String titre,
    required String horaire,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF1E293B))),
                const SizedBox(height: 1.5),
                Text(horaire, style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569), height: 1.25)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
