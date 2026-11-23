import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/candidat_info.dart';
import '../../services/candidat_service.dart';

class DashboardTab extends StatelessWidget {
  final CandidatPortalData data;
  final VoidCallback onNavToPlanning;
  final VoidCallback onNavToFinances;
  final VoidCallback onNavToRevision;

  const DashboardTab({
    super.key,
    required this.data,
    required this.onNavToPlanning,
    required this.onNavToFinances,
    required this.onNavToRevision,
  });

  @override
  Widget build(BuildContext context) {
    final cand = data.candidat;
    final ecole = data.entreprise;
    final seancesPlanifiees = data.seances.where((s) => s.statut == 'PLANIFIE').toList();
    final prochaineSeance = seancesPlanifiees.isNotEmpty ? seancesPlanifiees.first : null;

    final progression = (cand.progressionPermis * 100).toInt();
    final currencyFormat = NumberFormat('#,###', 'fr_FR');

    final double ratioConduite = cand.nbConduitesPrevues > 0
        ? (cand.nbConduitesEffectuees / cand.nbConduitesPrevues).clamp(0.0, 1.0)
        : 0.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Carte Profil Candidat & Jauge Haute Définition (Bleu & Or Saint Edmond) ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFBBF24), // Anneau Jaune Doré Saint Edmond
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        backgroundImage: (cand.photoUrl != null && cand.photoUrl!.isNotEmpty)
                            ? NetworkImage(cand.photoUrl!)
                            : null,
                        child: (cand.photoUrl == null || cand.photoUrl!.isEmpty)
                            ? Text(
                                cand.nom.isNotEmpty
                                    ? cand.nom[0] + (cand.prenom.isNotEmpty ? cand.prenom[0] : '')
                                    : 'CE',
                                style: const TextStyle(
                                  color: Color(0xFF1E3A8A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cand.nomComplet,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              // Badge Permis
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  'Permis ${cand.categoriePermis}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Badge Type de formation
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFFBBF24).withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
                                  cand.typeFormationAffichee,
                                  style: const TextStyle(
                                    color: Color(0xFFFDE68A),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              // Badge Langue
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  cand.langue,
                                  style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Jauge de Progression vers le Permis
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.trending_up_rounded, color: Color(0xFFFBBF24), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Progression vers le Permis',
                          style: TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$progression%',
                      style: const TextStyle(
                        color: Color(0xFFFBBF24), // Jaune Saint Edmond
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: cand.progressionPermis,
                    minHeight: 9,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFBBF24)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ── 2. Prochaine Leçon Planifiée (si disponible) ──
          if (prochaineSeance != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              prochaineSeance.estConduite ? Icons.directions_car_rounded : Icons.menu_book_rounded,
                              color: const Color(0xFF2563EB),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Prochaine leçon : ${prochaineSeance.typeSeance}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A)),
                              ),
                              Text(
                                DateFormat('EEEE d MMMM à HH:mm', 'fr_FR').format(prochaineSeance.dateHeure),
                                style: const TextStyle(fontSize: 12, color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: onNavToPlanning,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text('Voir tout', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  if (prochaineSeance.notes != null && prochaineSeance.notes!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Objectif : ${prochaineSeance.notes!}",
                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569), fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // ── 3. Duo de Cartes Métriques : Conduite & Scolarité ──
          Row(
            children: [
              // Carte Conduite
              Expanded(
                child: InkWell(
                  onTap: onNavToPlanning,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                            const Text(
                              'Conduite',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEFF6FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.directions_car_rounded, size: 14, color: Color(0xFF2563EB)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${cand.nbConduitesEffectuees} / ${cand.nbConduitesPrevues}',
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratioConduite,
                            minHeight: 5,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${cand.nbConduitesRestantes} restantes',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Carte Scolarité
              Expanded(
                child: InkWell(
                  onTap: onNavToFinances,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
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
                            const Text(
                              'Scolarité',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                            ),
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: cand.estSolde ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                size: 14,
                                color: cand.estSolde ? const Color(0xFF10B981) : const Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cand.estSolde ? 'Soldé ✓' : '${currencyFormat.format(cand.montantRestant)} F',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: cand.estSolde ? const Color(0xFF10B981) : const Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: cand.estSolde ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            cand.estSolde ? 'Tout est réglé' : 'Reste à payer',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: cand.estSolde ? const Color(0xFF10B981) : const Color(0xFFD97706),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Sur ${currencyFormat.format(cand.montantTotal)} F',
                          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── 4. Parcours des Examens Officiels ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
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
                        Icon(Icons.military_tech_rounded, size: 20, color: Color(0xFF2563EB)),
                        SizedBox(width: 8),
                        Text(
                          'Examens Officiels',
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '2 Épreuves',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildExamenCard(
                  stepNum: '1',
                  titre: 'Examen de Code (Théorique)',
                  statut: cand.statutExamenCode,
                  dateStr: cand.dateExamenCode,
                  icon: Icons.menu_book_rounded,
                ),
                const SizedBox(height: 12),
                _buildExamenCard(
                  stepNum: '2',
                  titre: 'Examen de Conduite (Pratique)',
                  statut: cand.statutExamenConduite,
                  dateStr: cand.dateExamenConduite,
                  icon: Icons.directions_car_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── 5. Bannière Cours & Supports de Révision (Bleu & Or Saint Edmond) ──
          InkWell(
            onTap: onNavToRevision,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Color(0xFFFBBF24), // Jaune Saint Edmond
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Supports de Révision & Quiz',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Consultez les cours officiels et testez-vous avec nos quiz de code.',
                          style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 11.5, height: 1.25),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 15),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── 6. Carte Secrétariat & Contact Auto-École ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ecole.nom,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Secrétariat & Assistance Élève',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    Text(
                      ecole.telephone,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => CandidatService.contacterAutoEcoleWhatsApp(
                          telephone: ecole.telephone,
                          nomCandidat: cand.nomComplet,
                          codeAcces: cand.codeAcces,
                        ),
                        icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                        label: const Text('WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => CandidatService.appelerAutoEcole(ecole.telephone),
                        icon: const Icon(Icons.phone_rounded, size: 16),
                        label: const Text('Appeler', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFF2563EB)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Carte moderne pour chaque épreuve d'examen
  Widget _buildExamenCard({
    required String stepNum,
    required String titre,
    required String statut,
    required String? dateStr,
    required IconData icon,
  }) {
    Color badgeColor;
    Color textColor;
    String label;
    IconData statusIcon;

    switch (statut) {
      case 'ADMIS':
        badgeColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        label = 'Admis ✓';
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'PROGRAMME':
        badgeColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFB45309);
        label = dateStr != null ? 'Prévu le $dateStr' : 'Programmé';
        statusIcon = Icons.calendar_today_rounded;
        break;
      case 'AJOURNE':
        badgeColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        label = 'Ajourné (Rattrapage)';
        statusIcon = Icons.replay_rounded;
        break;
      default:
        badgeColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        label = 'Non programmé';
        statusIcon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 13, color: textColor),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
