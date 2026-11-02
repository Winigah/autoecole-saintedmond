import 'package:flutter/material.dart';

class CoursTab extends StatelessWidget {
  const CoursTab({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      {'title': 'Panneaux de Signalisation & Dangers', 'type': 'Vidéo HD', 'count': '14 leçons', 'icon': Icons.play_circle_fill, 'color': Color(0xFF2563EB)},
      {'title': 'Priorités & Règles d\'Intersection', 'type': 'PDF', 'count': '32 pages', 'icon': Icons.picture_as_pdf, 'color': Color(0xFFEF4444)},
      {'title': 'Quiz Blanc Examen Permis B', 'type': 'Quiz', 'count': '40 QCM', 'icon': Icons.quiz, 'color': Color(0xFF10B981)},
      {'title': 'Manœuvres de Conduite & Stationnement', 'type': 'Vidéo HD', 'count': '8 leçons', 'icon': Icons.play_circle_fill, 'color': Color(0xFF8B5CF6)},
      {'title': 'Contrôles Véhicule & Sécurité', 'type': 'Fiche', 'count': '12 fiches', 'icon': Icons.menu_book, 'color': Color(0xFFF59E0B)},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: modules.length,
      itemBuilder: (ctx, i) {
        final m = modules[i];
        final color = m['color'] as Color;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          color: Colors.white,
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(m['icon'] as IconData, color: color, size: 26),
            ),
            title: Text(
              m['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                '${m['type']} • ${m['count']}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Module ${m['title']} ouvert avec succès')),
              );
            },
          ),
        );
      },
    );
  }
}
