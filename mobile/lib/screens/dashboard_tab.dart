import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class DashboardTab extends StatelessWidget {
  final String role;
  final String selectedAnnexe;
  final Function(String) onAnnexeChanged;
  final Function(int)? onNavigateToTab;

  const DashboardTab({
    super.key,
    required this.role,
    required this.selectedAnnexe,
    required this.onAnnexeChanged,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService.instance;
    final candidats = db.getCandidats(annexe: selectedAnnexe);
    final depenses = db.getDepenses(annexe: selectedAnnexe, isSecretaire: role == 'SECRETAIRE');
    final recettes = db.getRecettes(annexe: selectedAnnexe);

    final totalRecettes = recettes.fold<int>(0, (sum, r) => sum + r.montant);
    final totalDepenses = depenses.fold<int>(0, (sum, d) => sum + d.montant);
    final soldeNet = totalRecettes - totalDepenses;

    final admisCount = candidats.where((c) => c.statut == 'ADMIS').length;
    final nonAdmisCount = candidats.where((c) => c.statut == 'NON_ADMIS').length;
    final enFormationCount = candidats.where((c) => c.statut == 'INSCRIT' || c.statut.isEmpty).length;

    final currencyFormat = NumberFormat('#,###', 'fr_FR');
    final evaluatedCount = admisCount + nonAdmisCount;
    final tauxReussite = evaluatedCount > 0 ? ((admisCount / evaluatedCount) * 100).round() : 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Header contextuel & Sélecteur d'annexe compact ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Vue d\'ensemble',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              // Compact Pill Selector
              Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Color(0xFF2563EB)),
                    const SizedBox(width: 4),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedAnnexe,
                        icon: const Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF64748B)),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        items: ['Toutes', ...db.annexes].map((a) {
                          return DropdownMenuItem(
                            value: a,
                            child: Text(a == 'Toutes' ? 'Toutes agences' : a),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) onAnnexeChanged(val);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── 2. Master Card : Trésorerie & Solde Net (Bleu Marine + Doré Saint Edmond) ──
          Container(
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
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
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
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.2), // Jaune doré
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Color(0xFFFBBF24), // Jaune Saint Edmond
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'TRÉSORERIE & CAISSE',
                          style: TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF34D399),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'En temps réel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Solde Net de Caisse',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      currencyFormat.format(soldeNet),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'FCFA',
                      style: TextStyle(
                        color: Color(0xFFFBBF24), // Jaune branding
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Flux Entrées & Sorties
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Entrées
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_downward_rounded,
                              color: Color(0xFF34D399),
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Recettes',
                                style: TextStyle(color: Colors.white60, fontSize: 10),
                              ),
                              Text(
                                '+${currencyFormat.format(totalRecettes)} F',
                                style: const TextStyle(
                                  color: Color(0xFF34D399),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                      // Sorties
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_upward_rounded,
                              color: Color(0xFFF87171),
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Dépenses',
                                style: TextStyle(color: Colors.white60, fontSize: 10),
                              ),
                              Text(
                                '-${currencyFormat.format(totalDepenses)} F',
                                style: const TextStyle(
                                  color: Color(0xFFF87171),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── 3. Raccourcis d'action rapide ──
          Row(
            children: [
              Expanded(
                child: _buildActionShortcut(
                  icon: Icons.person_add_alt_1_rounded,
                  label: '+ Candidat',
                  color: const Color(0xFF2563EB), // Bleu
                  bgColor: const Color(0xFFEFF6FF),
                  onTap: () => onNavigateToTab?.call(1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionShortcut(
                  icon: Icons.add_circle_outline_rounded,
                  label: '+ Encaisser',
                  color: const Color(0xFF059669), // Vert
                  bgColor: const Color(0xFFECFDF5),
                  onTap: () => onNavigateToTab?.call(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionShortcut(
                  icon: Icons.how_to_reg_rounded,
                  label: 'Pointage',
                  color: const Color(0xFFD97706), // Jaune / Ambre Saint Edmond
                  bgColor: const Color(0xFFFFFBEB),
                  onTap: () => onNavigateToTab?.call(3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // ── 4. Suivi des Candidats & Performance Examens ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Activité & Examens',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Text(
                  '${candidats.length} total',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3 cartes pédagogiques
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'EN COURS',
                  value: '$enFormationCount',
                  subtitle: 'Élèves actifs',
                  color: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFF8FAFF),
                  borderColor: const Color(0xFFE2E8F0),
                  icon: Icons.school_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  title: 'RÉUSSITE',
                  value: evaluatedCount > 0 ? '$tauxReussite%' : '$admisCount',
                  subtitle: '$admisCount admis',
                  color: const Color(0xFF10B981),
                  bgColor: const Color(0xFFF0FDF4),
                  borderColor: const Color(0xFFBBF7D0),
                  icon: Icons.emoji_events_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  title: 'AJOURNÉS',
                  value: '$nonAdmisCount',
                  subtitle: 'À rattraper',
                  color: const Color(0xFFF59E0B), // Jaune Saint Edmond
                  bgColor: const Color(0xFFFFFBEB),
                  borderColor: const Color(0xFFFDE68A),
                  icon: Icons.replay_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // ── 5. Graphique d'Évolution Mensuelle des Inscriptions ──
          Builder(
            builder: (context) {
              final now = DateTime.now();
              const monthNames = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
              final monthsList = List.generate(6, (i) {
                final mDate = DateTime(now.year, now.month - 5 + i, 1);
                final monthStr = '${mDate.year}-${mDate.month.toString().padLeft(2, '0')}';
                final count = candidats.where((c) => c.dateInscription.startsWith(monthStr)).length;
                return {'label': monthNames[mDate.month - 1], 'count': count, 'isCurrent': i == 5};
              });
              final maxInsc = monthsList.map((m) => m['count'] as int).fold<int>(1, (max, val) => val > max ? val : max);
              final total6Mois = monthsList.fold<int>(0, (sum, m) => sum + (m['count'] as int));

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.bar_chart_rounded,
                                color: Color(0xFF2563EB),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Inscriptions (6 mois)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7), // Jaune Saint Edmond
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Text(
                            '$total6Mois au total',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: monthsList.map((m) {
                        return _buildModernBar(
                          label: m['label'] as String,
                          value: m['count'] as int,
                          max: maxInsc,
                          isCurrent: m['isCurrent'] as bool,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Action rapide en 1 clic
  Widget _buildActionShortcut({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Carte métrique pédagogique
  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
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
              Text(
                title,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, size: 15, color: color),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Barre moderne pour le graphique
  Widget _buildModernBar({
    required String label,
    required int value,
    required int max,
    required bool isCurrent,
  }) {
    final heightRatio = (value / max).clamp(0.08, 1.0);
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isCurrent ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 6),
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: 22,
              height: 75,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Container(
              width: 22,
              height: 75 * heightRatio,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCurrent
                      ? [const Color(0xFF1E3A8A), const Color(0xFF2563EB), const Color(0xFF60A5FA)]
                      : [const Color(0xFF94A3B8), const Color(0xFFCBD5E1)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(6),
                border: isCurrent
                    ? Border.all(color: const Color(0xFFF59E0B), width: 1.5) // Accent Jaune Saint Edmond pour le mois courant
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isCurrent ? const Color(0xFF1E3A8A) : const Color(0xFF64748B),
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
