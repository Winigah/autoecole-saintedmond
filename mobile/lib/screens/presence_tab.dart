import 'package:flutter/material.dart';
import '../services/database_service.dart';

class PresenceTab extends StatefulWidget {
  const PresenceTab({super.key});

  @override
  State<PresenceTab> createState() => _PresenceTabState();
}

class _PresenceTabState extends State<PresenceTab> {
  @override
  Widget build(BuildContext context) {
    final db = DatabaseService.instance;
    final staff = db.staffPresences;
    final candidats = db.getCandidats().take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pointage Journalier',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sélectionnez le statut de présence des moniteurs et des élèves',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),

          // Moniteurs Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.badge_outlined, size: 18, color: Color(0xFF2563EB)),
                    SizedBox(width: 8),
                    Text('Moniteurs & Administration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const Divider(height: 20),
                ...staff.entries.map((e) {
                  final present = e.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        InkWell(
                          onTap: () {
                            setState(() {
                              staff[e.key] = !present;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: present ? const Color(0xFFD1FAE5) : const Color(0xFFFFE4E6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              present ? '✓ Présent' : '✗ Absent',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: present ? const Color(0xFF059669) : const Color(0xFFE11D48),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Candidats Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.school_outlined, size: 18, color: Color(0xFF2563EB)),
                    SizedBox(width: 8),
                    Text('Candidats Convoqués Aujourd\'hui', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                const Divider(height: 20),
                ...candidats.map((c) {
                  final present = db.candidatPresences[c.id] ?? false;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${c.nom} ${c.prenom}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text('Permis ${c.categorie} • ${c.annexe}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              db.candidatPresences[c.id] = !present;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: present ? const Color(0xFFD1FAE5) : const Color(0xFFFFE4E6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              present ? '✓ Présent' : '✗ Absent',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: present ? const Color(0xFF059669) : const Color(0xFFE11D48),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
