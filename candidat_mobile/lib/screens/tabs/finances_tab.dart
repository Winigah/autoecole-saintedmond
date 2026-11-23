import 'package:flutter/material.dart';
import '../../models/candidat_info.dart';
import '../../services/candidat_service.dart';

class FinancesTab extends StatelessWidget {
  final CandidatPortalData data;

  const FinancesTab({super.key, required this.data});

  String _formatFCFA(int montant) {
    final s = montant.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return '${s.replaceAllMapped(reg, (m) => '${m[1]} ')} F';
  }

  /// Nettoie l'intitulé du paiement pour enlever le nom de l'élève répété
  Map<String, String> _analyserIntitule(String? raw, String nomCandidat) {
    if (raw == null || raw.trim().isEmpty) {
      return {'titre': 'Versement scolarité', 'note': ''};
    }

    String texte = raw.trim();

    // Extraire une éventuelle note entre crochets [Note]
    String note = '';
    final matchCrochets = RegExp(r'\[(.*?)\]').firstMatch(texte);
    if (matchCrochets != null) {
      note = matchCrochets.group(1)?.trim() ?? '';
      texte = texte.replaceAll(matchCrochets.group(0)!, '').trim();
    }

    // Retirer le nom du candidat si présent (ex: " - KALIBOU Winigah")
    if (nomCandidat.isNotEmpty) {
      final partiesNom = nomCandidat.split(' ');
      for (final part in partiesNom) {
        if (part.length >= 3) {
          texte = texte.replaceAll(RegExp(r'\s*-\s*' + RegExp.escape(part), caseSensitive: false), '');
          texte = texte.replaceAll(RegExp(RegExp.escape(part), caseSensitive: false), '');
        }
      }
    }

    // Nettoyer les tirets orphelins en fin ou milieu
    texte = texte.replaceAll(RegExp(r'\s*-\s*$'), '').replaceAll(RegExp(r'^\s*-\s*'), '').trim();

    if (texte.isEmpty) {
      texte = 'Versement scolarité';
    }

    return {'titre': texte, 'note': note};
  }

  @override
  Widget build(BuildContext context) {
    final cand = data.candidat;
    final ecole = data.entreprise;
    final paiements = data.paiements;

    final double ratio = cand.montantTotal > 0
        ? (cand.montantPaye / cand.montantTotal).clamp(0.0, 1.0)
        : 1.0;
    final int pourcentage = (ratio * 100).toInt();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── CARTE BANCAIRE FINANCIÈRE MODERNE & AÉRÉE ──
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: cand.estSolde
                    ? [const Color(0xFF065F46), const Color(0xFF047857)]
                    : [const Color(0xFF0F172A), const Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (cand.estSolde ? const Color(0xFF047857) : const Color(0xFF1E3A8A))
                      .withValues(alpha: 0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ligne En-tête de la carte
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'SCOLARITÉ & FORFAIT',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: cand.estSolde
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cand.estSolde ? 'Soldé ✓' : '$pourcentage% Réglé',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Montant payé & Forfait
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _formatFCFA(cand.montantPaye),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '/ ${_formatFCFA(cand.montantTotal)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Jauge fine moderne
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      cand.estSolde ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Mini récapitulatif 2 colonnes
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Payé : ${_formatFCFA(cand.montantPaye)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(height: 14, width: 1, color: Colors.white24),
                      Row(
                        children: [
                          Icon(
                            cand.estSolde ? Icons.verified_rounded : Icons.pending_rounded,
                            color: cand.estSolde ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cand.estSolde ? 'Aucun reste' : 'Reste : ${_formatFCFA(cand.montantRestant)}',
                            style: TextStyle(
                              color: cand.estSolde ? const Color(0xFF34D399) : const Color(0xFFFDE68A),
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
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

          const SizedBox(height: 20),

          // ── EN-TÊTE HISTORIQUE DES RÈGLEMENTS ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Historique des Versements',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${paiements.length} reçu${paiements.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── LISTE ÉPURÉE DES REÇUS ──
          if (paiements.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.receipt_long_outlined, size: 40, color: Color(0xFFCBD5E1)),
                  SizedBox(height: 8),
                  Text(
                    'Aucun versement enregistré pour le moment.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paiements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final p = paiements[index];
                final info = _analyserIntitule(p.recuNumero, cand.nomComplet);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.015),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_downward_rounded,
                          color: Color(0xFF10B981),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              info['titre']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (info['note']!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                info['note']!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF2563EB),
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 2),
                            Text(
                              '${p.datePaiement} • Caisse locale',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+ ${_formatFCFA(p.montant)}',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          const SizedBox(height: 20),

          // ── ACTION REÇU OFFICIEL (FIN & ÉLÉGANT) ──
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () => CandidatService.contacterAutoEcoleWhatsApp(
                telephone: ecole.telephone,
                nomCandidat: cand.nomComplet,
                codeAcces: cand.codeAcces,
                sujet: "Bonjour, je souhaite obtenir une quittance ou attestation officielle de mes versements de scolarité.",
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF2563EB), size: 16),
              label: const Text(
                'Demander un reçu officiel au Secrétariat',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
