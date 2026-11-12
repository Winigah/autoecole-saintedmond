import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class DashboardTab extends StatelessWidget {
  final String role;
  final String selectedAnnexe;
  final Function(String) onAnnexeChanged;

  const DashboardTab({
    super.key,
    required this.role,
    required this.selectedAnnexe,
    required this.onAnnexeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService.instance;
    final candidats = db.getCandidats(annexe: selectedAnnexe);
    final depenses = db.getDepenses(annexe: selectedAnnexe, isSecretaire: role == 'SECRETAIRE');
    final recettes = db.getRecettes(annexe: selectedAnnexe);

    final totalRecettes = recettes.fold<int>(0, (sum, r) => sum + r.montant);
    final totalDepenses = depenses.fold<int>(0, (sum, d) => sum + d.montant);
    final admisCount = candidats.where((c) => c.statut == 'ADMIS').length;
    final nonAdmisCount = candidats.where((c) => c.statut == 'NON_ADMIS').length;

    final currencyFormat = NumberFormat('#,###', 'fr_FR');
    final evaluatedCount = admisCount + nonAdmisCount;
    final tauxReussite = evaluatedCount > 0 ? ((admisCount / evaluatedCount) * 100).round() : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Annexe Filter Chip selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF2563EB)),
                const SizedBox(width: 8),
                const Text(
                  'Annexe :',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedAnnexe,
                      items: ['Toutes', ...db.annexes].map((a) {
                        return DropdownMenuItem(value: a, child: Text(a, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) onAnnexeChanged(val);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),



          // KPIs Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.45,
            children: [
              _buildKpiCard(
                title: 'INSCRITS',
                value: '${candidats.length}',
                subtitle: 'Élèves actifs',
                color: const Color(0xFF2563EB),
                icon: Icons.people_outline,
              ),
              _buildKpiCard(
                title: 'ADMIS',
                value: '$admisCount',
                subtitle: evaluatedCount > 0 ? 'Taux $tauxReussite%' : 'En attente',
                color: const Color(0xFF10B981),
                icon: Icons.emoji_events_outlined,
              ),
              _buildKpiCard(
                title: 'NON ADMIS',
                value: '$nonAdmisCount',
                subtitle: 'À rattraper',
                color: const Color(0xFFEF4444),
                icon: Icons.replay_outlined,
              ),
              _buildKpiCard(
                title: 'RECETTES',
                value: '${currencyFormat.format(totalRecettes)} F',
                subtitle: 'Entrées de caisse',
                color: const Color(0xFF10B981),
                icon: Icons.arrow_downward,
              ),
              if (role == 'DG')
                _buildKpiCard(
                  title: 'DÉPENSES',
                  value: '${currencyFormat.format(totalDepenses)} F',
                  subtitle: 'Sorties de caisse',
                  color: const Color(0xFFEF4444),
                  icon: Icons.arrow_upward,
                ),
              if (role == 'DG')
                _buildKpiCard(
                  title: 'SOLDE NET',
                  value: '${currencyFormat.format(totalRecettes - totalDepenses)} F',
                  subtitle: 'Marge dégagée',
                  color: const Color(0xFF2563EB),
                  icon: Icons.account_balance_wallet_outlined,
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Action Banner
          Builder(
            builder: (context) {
              final now = DateTime.now();
              const monthNames = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
              final monthsList = List.generate(6, (i) {
                final mDate = DateTime(now.year, now.month - 5 + i, 1);
                final monthStr = '${mDate.year}-${mDate.month.toString().padLeft(2, '0')}';
                final count = candidats.where((c) => c.dateInscription.startsWith(monthStr)).length;
                return {'label': monthNames[mDate.month - 1], 'count': count};
              });
              final maxInsc = monthsList.map((m) => m['count'] as int).fold<int>(1, (max, val) => val > max ? val : max);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Évolution Mensuelle des Inscriptions',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: monthsList.map((m) {
                        return _buildBar(m['label'] as String, m['count'] as int, maxInsc);
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, int value, int max) {
    final heightRatio = (value / max).clamp(0.1, 1.0);
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
        ),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 80 * heightRatio,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
