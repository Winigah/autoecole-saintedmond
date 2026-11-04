import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/revision_service.dart';

class GestionRevisionsScreen extends StatefulWidget {
  final String role;

  const GestionRevisionsScreen({super.key, required this.role});

  @override
  State<GestionRevisionsScreen> createState() => _GestionRevisionsScreenState();
}

class _GestionRevisionsScreenState extends State<GestionRevisionsScreen> {
  List<RevisionDocStaff> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocs();
  }

  Future<void> _loadDocs() async {
    setState(() => _isLoading = true);
    final list = await RevisionServiceStaff.fetchDocuments();
    if (!mounted) return;
    setState(() {
      _documents = list;
      _isLoading = false;
    });
  }

  void _ouvrirUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir le lien : $e')),
        );
      }
    }
  }

  void _supprimerDoc(RevisionDocStaff doc) async {
    final conf = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer ce support ?'),
        content: Text('Voulez-vous retirer "${doc.titre}" de l\'espace des candidats ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (conf == true) {
      final ok = await RevisionServiceStaff.deleteDocument(doc.id);
      if (ok) {
        _loadDocs();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Support de révision retiré avec succès.')),
          );
        }
      }
    }
  }

  void _dialogAjouterDoc() {
    final titreCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final tailleCtrl = TextEditingController(text: '2.0 Mo');
    String categorie = 'CODE';
    bool isSaving = false;
    String? error;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.post_add_rounded, color: Color(0xFF2563EB), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Partager un Cours PDF',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
                  ),
                  const SizedBox(height: 10),
                ],

                const Text('Titre du document *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextField(
                  controller: titreCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Catégorie *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  initialValue: categorie,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'CODE', child: Text('Code de la Route')),
                    DropdownMenuItem(value: 'CONDUITE', child: Text('Conduite Pratique')),
                    DropdownMenuItem(value: 'PANNEAUX', child: Text('Panneaux & Signalisation')),
                    DropdownMenuItem(value: 'MECANIQUE', child: Text('Notions Mécaniques')),
                    DropdownMenuItem(value: 'GENERAL', child: Text('Généralités')),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => categorie = val);
                  },
                ),
                const SizedBox(height: 12),

                const Text('Lien direct vers le fichier PDF (URL) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextField(
                  controller: urlCtrl,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Description ou Consignes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Taille indicative', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextField(
                  controller: tailleCtrl,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: isSaving
                        ? null
                        : () async {
                            final titre = titreCtrl.text.trim();
                            final url = urlCtrl.text.trim();
                            if (titre.isEmpty || url.isEmpty) {
                              setModalState(() => error = 'Veuillez renseigner le titre et l\'URL du PDF.');
                              return;
                            }
                            if (!url.startsWith('http://') && !url.startsWith('https://')) {
                              setModalState(() => error = 'L\'adresse doit débuter par https:// ou http://');
                              return;
                            }

                            setModalState(() {
                              isSaving = true;
                              error = null;
                            });

                            final messenger = ScaffoldMessenger.of(context);
                            final ok = await RevisionServiceStaff.addDocument(
                              titre: titre,
                              description: descCtrl.text.trim(),
                              categorie: categorie,
                              urlPdf: url,
                              taille: tailleCtrl.text.trim(),
                            );

                            if (!ctx.mounted) return;

                            if (ok) {
                              Navigator.pop(ctx);
                              _loadDocs();
                              messenger.showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color(0xFF10B981),
                                  content: Text('Le cours PDF a été partagé aux élèves avec succès !'),
                                ),
                              );
                            } else {
                              setModalState(() {
                                isSaving = false;
                                error = 'Erreur lors de la publication sur le cloud.';
                              });
                            }
                          },
                    icon: isSaving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.cloud_upload_rounded, color: Colors.white),
                    label: Text(
                      isSaving ? 'Publication...' : 'Publier pour les élèves',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Supports de Révision PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Gestion des cours partagés aux candidats', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocs,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _dialogAjouterDoc,
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouveau Cours PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _documents.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.menu_book_rounded, size: 48, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucun support de révision publié',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Cliquez sur "Nouveau Cours PDF" ci-dessous pour partager un document que tous vos élèves pourront ouvrir depuis leur application.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _documents.length,
                  itemBuilder: (ctx, i) {
                    final d = _documents[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      elevation: 0,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.picture_as_pdf, color: Color(0xFFDC2626), size: 24),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        d.titre,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      Text(
                                        'Catégorie : ${d.categorie} • Ajouté le ${d.dateAjout}',
                                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                                  tooltip: 'Supprimer',
                                  onPressed: () => _supprimerDoc(d),
                                ),
                              ],
                            ),
                            if (d.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                d.description,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                              ),
                            ],
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _ouvrirUrl(d.urlPdf),
                              child: Row(
                                children: [
                                  const Icon(Icons.link, size: 14, color: Color(0xFF2563EB)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      d.urlPdf,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF2563EB), decoration: TextDecoration.underline),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('Tester l\'ouverture', style: TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
