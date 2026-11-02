import 'package:flutter/material.dart';
import '../../models/quiz_data.dart';

class RevisionQuizTab extends StatefulWidget {
  const RevisionQuizTab({super.key});

  @override
  State<RevisionQuizTab> createState() => _RevisionQuizTabState();
}

class _RevisionQuizTabState extends State<RevisionQuizTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Quiz state
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  bool _hasValidated = false;
  int _score = 0;
  bool _quizFinished = false;
  final List<QuestionQuiz> _questions = QuizDataBank.questions;

  // Panneaux state
  String _categoriePanneau = 'TOUS';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _validerReponse() {
    if (_selectedAnswerIndex == null) return;

    setState(() {
      _hasValidated = true;
      if (_selectedAnswerIndex == _questions[_currentQuestionIndex].reponseCorrecte) {
        _score++;
      }
    });
  }

  void _questionSuivante() {
    if (_currentQuestionIndex + 1 < _questions.length) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _hasValidated = false;
      });
    } else {
      setState(() {
        _quizFinished = true;
      });
    }
  }

  void _recommencerQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _selectedAnswerIndex = null;
      _hasValidated = false;
      _score = 0;
      _quizFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub-Tabs Header
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2563EB),
            unselectedLabelColor: const Color(0xFF64748B),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            indicatorColor: const Color(0xFF2563EB),
            indicatorWeight: 3,
            tabs: const [
              Tab(
                icon: Icon(Icons.quiz_outlined, size: 20),
                text: "Test Quiz (20 Q)",
              ),
              Tab(
                icon: Icon(Icons.traffic_outlined, size: 20),
                text: "Panneaux Routiers",
              ),
            ],
          ),
        ),

        // Tabs Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildQuizView(),
              _buildPanneauxView(),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // VUE QUIZ INTERACTIF
  // ==========================================
  Widget _buildQuizView() {
    if (_quizFinished) {
      final bool admis = _score >= 16;
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: admis ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  admis ? Icons.emoji_events_rounded : Icons.replay_rounded,
                  color: admis ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                  size: 48,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                admis ? "FÉLICITATIONS ! ADMIS 🎉" : "AJOURNÉ (À REPRENDRE)",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: admis ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Votre score final : $_score sur ${_questions.length}",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              Text(
                admis
                    ? "Excellent travail ! Vous avez le niveau requis pour réussir l'examen officiel de code."
                    : "Il faut au minimum 16 sur 20 pour valider l'examen. Révisez vos erreurs et réessayez !",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 220,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _recommencerQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  label: const Text('Recommencer la série', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final q = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête progression
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  q.categorie,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
              ),
              Text(
                "Question ${_currentQuestionIndex + 1} / ${_questions.length}",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
            ),
          ),
          const SizedBox(height: 18),

          // Intitulé de la question
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              q.question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.35),
            ),
          ),
          const SizedBox(height: 16),

          // Options de réponse
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: q.options.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final isSelected = _selectedAnswerIndex == idx;
              final isCorrect = idx == q.reponseCorrecte;

              Color borderCol = const Color(0xFFE2E8F0);
              Color bgCol = Colors.white;
              Color textCol = const Color(0xFF1E293B);

              if (_hasValidated) {
                if (isCorrect) {
                  borderCol = const Color(0xFF10B981);
                  bgCol = const Color(0xFFECFDF5);
                  textCol = const Color(0xFF065F46);
                } else if (isSelected && !isCorrect) {
                  borderCol = const Color(0xFFEF4444);
                  bgCol = const Color(0xFFFEF2F2);
                  textCol = const Color(0xFF991B1B);
                }
              } else if (isSelected) {
                borderCol = const Color(0xFF2563EB);
                bgCol = const Color(0xFFEFF6FF);
                textCol = const Color(0xFF1E3A8A);
              }

              return InkWell(
                onTap: _hasValidated
                    ? null
                    : () {
                        setState(() => _selectedAnswerIndex = idx);
                      },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: bgCol,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderCol, width: isSelected || (_hasValidated && isCorrect) ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                        ),
                        child: Text(
                          String.fromCharCode(65 + idx),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          q.options[idx],
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textCol),
                        ),
                      ),
                      if (_hasValidated && isCorrect)
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20)
                      else if (_hasValidated && isSelected && !isCorrect)
                        const Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 20),
                    ],
                  ),
                ),
              );
            },
          ),

          // Explication pédagogique après validation
          if (_hasValidated) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFD97706), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Explication du moniteur :',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          q.explication,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Bouton d'action (Valider ou Suivant)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _selectedAnswerIndex == null
                  ? null
                  : _hasValidated
                      ? _questionSuivante
                      : _validerReponse,
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasValidated ? const Color(0xFF0F172A) : const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Text(
                _hasValidated
                    ? (_currentQuestionIndex + 1 == _questions.length ? 'Terminer et voir le score' : 'Question suivante →')
                    : 'Valider ma réponse',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VUE PANNEAUX ROUTIERS
  // ==========================================
  Widget _buildPanneauxView() {
    final panneaux = QuizDataBank.panneaux.where((p) {
      if (_categoriePanneau == 'TOUS') return true;
      return p.categorie.toUpperCase() == _categoriePanneau;
    }).toList();

    return Column(
      children: [
        // Filtre catégories
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildPanneauChip('TOUS', 'Tous'),
                _buildPanneauChip('DANGER', 'Dangers (▲)'),
                _buildPanneauChip('INTERDICTION', 'Interdictions (●)'),
                _buildPanneauChip('OBLIGATION', 'Obligations (●)'),
                _buildPanneauChip('INDICATION', 'Indications (■)'),
              ],
            ),
          ),
        ),

        // Liste des panneaux
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: panneaux.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final p = panneaux[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: p.couleur.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: p.couleur.withValues(alpha: 0.3)),
                      ),
                      child: Icon(p.icone, color: p.couleur, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: p.couleur.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  p.categorie,
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: p.couleur),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.titre,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p.description,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPanneauChip(String id, String label) {
    final active = _categoriePanneau == id;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        selected: active,
        label: Text(label),
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: active ? FontWeight.bold : FontWeight.w500,
          color: active ? Colors.white : const Color(0xFF475569),
        ),
        backgroundColor: const Color(0xFFF1F5F9),
        selectedColor: const Color(0xFF2563EB),
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide.none,
        onSelected: (_) => setState(() => _categoriePanneau = id),
      ),
    );
  }
}
