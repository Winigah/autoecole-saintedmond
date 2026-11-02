import 'package:flutter/material.dart';
import '../../models/candidat_info.dart';
import '../../services/candidat_service.dart';

class FinancesTab extends StatelessWidget {
  final CandidatPortalData data;

  const FinancesTab({super.key, required this.data});

  String _formatFCFA(int montant) {
    return '${montant.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final cand = data.candidat;
    final ecole = data.entreprise;
    final paiements = data.paiements;

    final ratio = cand.montantTotal > 0 ? (cand.montantPaye / cand.montantTotal).clamp(0.0, 1.0) : 1.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte Récapitulative Scolarité
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: cand.estSolde
                    ? [const Color(0xFF065F46), const Color(0xFF10B981)]
                    : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (cand.estSolde ? const Color(0xFF10B981) : Colors.black).withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
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
                      'SITUATION DE SCOLARITÉ',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cand.estSolde ? Colors.white : const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        cand.estSolde ? 'COMPTE SOLDÉ ✓' : 'VERSEMENT EN COURS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: cand.estSolde ? const Color(0xFF065F46) : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text(
                  _formatFCFA(cand.montantPaye),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'sur un forfait total de ${_formatFCFA(cand.montantTotal)}',
                  style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
                ),

                const SizedBox(height: 18),

                // Jauge de paiement
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      cand.estSolde ? Colors.white : const Color(0xFFFBBF24),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                if (!cand.estSolde) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reste à payer :',
                        style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 13),
                      ),
                      Text(
                        _formatFCFA(cand.montantRestant),
                        style: const TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Votre scolarité est intégralement soldée.',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // En-tête Historique Reçus
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Historique des Règlements',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              Text(
                '${paiements.length} versement(s)',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Liste des reçus de versement
          if (paiements.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              alignment: Alignment.center,
              child: const Text(
                'Aucun reçu enregistré pour le moment.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paiements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final p = paiements[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF10B981), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.recuNumero ?? 'Reçu officiel',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${p.datePaiement} • ${p.moyenPaiement}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatFCFA(p.montant),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 24),

          // Bouton Demander une Attestation / Quittance
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => CandidatService.contacterAutoEcoleWhatsApp(
                telephone: ecole.telephone,
                nomCandidat: cand.nomComplet,
                codeAcces: cand.codeAcces,
                sujet: "Je souhaite obtenir une quittance ou attestation officielle de mes paiements de scolarité.",
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF2563EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF2563EB), size: 18),
              label: const Text(
                'Demander un reçu officiel au Secrétariat',
                style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
