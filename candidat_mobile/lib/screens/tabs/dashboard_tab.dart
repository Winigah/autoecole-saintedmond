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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte Profil Candidat & Jauge
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.3),
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
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Text(
                        cand.nom.isNotEmpty ? cand.nom[0] + (cand.prenom.isNotEmpty ? cand.prenom[0] : '') : 'CP',
                        style: const TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Permis ${cand.categoriePermis}',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  cand.langue,
                                  style: const TextStyle(color: Colors.white, fontSize: 11),
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

                // Barre de Progression
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progression vers le Permis',
                      style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '$progression%',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: cand.progressionPermis,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFBBF24)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  cand.typeFormation,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Prochaine Séance Prévue
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
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
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
                  if (prochaineSeance.notes != null) ...[
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

          // 2 Cartes KPIs : Conduites & Solde
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onNavToPlanning,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.speed_rounded, size: 18, color: Color(0xFF0284C7)),
                            SizedBox(width: 6),
                            Text('Conduite', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${cand.nbConduitesEffectuees} / ${cand.nbConduitesPrevues}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${cand.nbConduitesRestantes} restantes',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: onNavToFinances,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, size: 18, color: Color(0xFF10B981)),
                            SizedBox(width: 6),
                            Text('Scolarité', style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          cand.estSolde ? 'Soldé ✓' : '${cand.montantRestant.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} F',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: cand.estSolde ? const Color(0xFF10B981) : const Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cand.estSolde ? 'Tout réglé' : 'Reste à payer',
                          style: TextStyle(
                            fontSize: 11,
                            color: cand.estSolde ? const Color(0xFF10B981) : const Color(0xFFD97706),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Statut des Examens
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statut des Examens Officiels',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 14),
                _buildExamenRow('Examen de Code (Théorique)', cand.statutExamenCode, cand.dateExamenCode),
                const Divider(height: 20),
                _buildExamenRow('Examen de Conduite (Pratique)', cand.statutExamenConduite, cand.dateExamenConduite),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Bannière Révision Code & Quiz
          InkWell(
            onTap: onNavToRevision,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
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
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cours & Supports de Révision PDF',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Consultez et téléchargez les cours officiels partagés par votre auto-école.',
                          style: TextStyle(color: Color(0xFFE9D5FF), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Contact Rapide Auto-École
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ecole.nom,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ecole.telephone,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => CandidatService.contacterAutoEcoleWhatsApp(
                    telephone: ecole.telephone,
                    nomCandidat: cand.nomComplet,
                    codeAcces: cand.codeAcces,
                  ),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF10B981)),
                  tooltip: 'WhatsApp Auto-École',
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFFDCFCE7)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => CandidatService.appelerAutoEcole(ecole.telephone),
                  icon: const Icon(Icons.phone_outlined, color: Color(0xFF2563EB)),
                  tooltip: 'Appeler Auto-École',
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFFDBEAFE)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamenRow(String titre, String statut, String? dateStr) {
    Color badgeColor;
    Color textColor;
    String label;
    IconData icon;

    switch (statut) {
      case 'ADMIS':
        badgeColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        label = 'Admis 🎉';
        icon = Icons.check_circle_rounded;
        break;
      case 'PROGRAMME':
        badgeColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        label = dateStr != null ? 'Programmé : $dateStr' : 'Programmé';
        icon = Icons.calendar_today_rounded;
        break;
      case 'AJOURNE':
        badgeColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        label = 'Ajourné (Rattrapage)';
        icon = Icons.cancel_rounded;
        break;
      default:
        badgeColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF64748B);
        label = 'Non programmé';
        icon = Icons.schedule_rounded;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: textColor),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
