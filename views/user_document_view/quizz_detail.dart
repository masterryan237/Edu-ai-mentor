import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eduai_mentor/utilis/app_texts_utils.dart';
import 'package:confetti/confetti.dart';

class QuizDetailPage extends StatefulWidget {
  final String quizId;
  final Map<String, dynamic>? quizData;
  final Function(int)?
  onQuizCompleted; // Callback pour mettre à jour les badges

  const QuizDetailPage({
    super.key,
    required this.quizId,
    this.quizData,
    this.onQuizCompleted,
  });

  @override
  _QuizDetailPageState createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late ConfettiController _confettiController;

  List<Map<String, dynamic>> _questions = [];
  final Map<int, int?> _userAnswers = {};
  Map<int, bool> _answerStatus = {};
  int _currentQuestionIndex = 0;
  bool _quizCompleted = false;
  int _score = 0;
  int _totalQuestions = 0;
  bool _isLoading = true;
  String _quizTitle = '';
  String _quizTopic = '';
  int _streakReward = 0;
  int _xpReward = 0;
  bool _showRewards = false;
  bool _hasSubmitted = false;

  // Nouveau : Contrôleur pour la liste de navigation
  final ScrollController _navigationScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _loadQuizData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _navigationScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadQuizData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      if (widget.quizData != null) {
        // Utiliser les données fournies
        _quizTitle = widget.quizData!['quizTitle'] ?? 'Quiz';
        _quizTopic = widget.quizData!['topic'] ?? 'General';
        _questions = List<Map<String, dynamic>>.from(
          widget.quizData!['questions'] ?? [],
        );
      } else {
        // Charger depuis Firestore
        final quizSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('quizzes')
            .doc(widget.quizId)
            .get();

        if (quizSnapshot.exists) {
          final data = quizSnapshot.data() as Map<String, dynamic>;
          _quizTitle = data['title'] ?? 'Quiz';
          _quizTopic = data['topic'] ?? 'General';
          _questions = List<Map<String, dynamic>>.from(data['questions'] ?? []);
        }
      }

      _totalQuestions = _questions.length;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading quiz: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectAnswer(int questionIndex, int answerIndex) {
    if (_hasSubmitted) return;

    setState(() {
      _userAnswers[questionIndex] = answerIndex;
    });
  }

  void _jumpToQuestion(int index) {
    setState(() {
      _currentQuestionIndex = index;
    });

    // Faire défiler vers la question sélectionnée
    Future.delayed(Duration(milliseconds: 100), () {
      _navigationScrollController.animateTo(
        index * 60.0, // Hauteur estimée de chaque élément
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  // Nouvelle fonction : Vérifier si toutes les questions sont répondues
  bool get _allQuestionsAnswered {
    if (_questions.isEmpty) return false;

    for (int i = 0; i < _questions.length; i++) {
      if (_userAnswers[i] == null) {
        return false;
      }
    }
    return true;
  }

  Future<void> _submitQuiz() async {
    if (_hasSubmitted) return;

    // Vérifier si toutes les questions sont répondues
    if (!_allQuestionsAnswered) {
      // Demander confirmation
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppTexts.quizzIncomplete(context)),
          content: Text(AppTexts.submitAnyway(context)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppTexts.continueBtn(context)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7B61FF),
              ),
              child: Text(
                AppTexts.submit(context),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    // Calculer le score
    int correctAnswers = 0;
    Map<int, bool> answerStatus = {};

    for (int i = 0; i < _questions.length; i++) {
      final correctAnswer = _questions[i]['correctAnswer'] ?? 0;
      final userAnswer = _userAnswers[i];

      bool isCorrect = userAnswer == correctAnswer;
      answerStatus[i] = isCorrect;

      if (isCorrect) {
        correctAnswers++;
      }
    }

    _score = ((correctAnswers / _questions.length) * 100).round();

    // Calculer les récompenses
    _calculateRewards(_score);

    // Sauvegarder l'historique
    await _saveQuizHistory();

    // Mettre à jour le streak de l'utilisateur
    await _updateUserStreak();

    // Notifier le parent des récompenses
    if (widget.onQuizCompleted != null) {
      widget.onQuizCompleted!(_streakReward);
    }

    setState(() {
      _answerStatus = answerStatus;
      _quizCompleted = true;
      _hasSubmitted = true;
    });

    // Afficher les récompenses avec une transition
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showRewards = true;
      });
      if (_streakReward > 0 || _xpReward > 0) {
        _confettiController.play();
      }
    });
  }

  void _calculateRewards(int score) {
    if (score >= 90) {
      _streakReward = 3;
      _xpReward = 100;
    } else if (score >= 70) {
      _streakReward = 2;
      _xpReward = 50;
    } else if (score >= 50) {
      _streakReward = 1;
      _xpReward = 25;
    } else {
      _streakReward = 0;
      _xpReward = 10; // XP minimal pour participation
    }
  }

  Future<void> _saveQuizHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('quiz_history')
          .add({
            'quizId': widget.quizId,
            'quizTitle': _quizTitle,
            'topic': _quizTopic,
            'score': _score,
            'totalQuestions': _totalQuestions,
            'correctAnswers': (_score / 100 * _totalQuestions).round(),
            'userAnswers': _userAnswers,
            'completedAt': FieldValue.serverTimestamp(),
            'streakReward': _streakReward,
            'xpReward': _xpReward,
            'duration': 0,
          });
    } catch (e) {
      if (kDebugMode) {
        print('Error saving quiz history: $e');
      }
    }
  }

  Future<void> _updateUserStreak() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userRef = _firestore.collection('users').doc(user.uid);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) return;

        final currentData = snapshot.data() as Map<String, dynamic>;
        final currentStreak = currentData['streak'] ?? 0;
        final currentXP = currentData['xp'] ?? 0;
        final lastStudyDate = currentData['lastStudyDate'] as Timestamp?;
        final now = DateTime.now();

        int newStreak = currentStreak;
        int newXP = currentXP + _xpReward;

        // Vérifier si le streak doit continuer
        if (lastStudyDate != null) {
          final lastDate = lastStudyDate.toDate();
          final difference = now.difference(lastDate).inDays;

          if (difference == 0) {
            // Déjà étudié aujourd'hui
          } else if (difference == 1) {
            // Streak continue
            newStreak = currentStreak + _streakReward;
          } else {
            // Nouveau streak
            newStreak = _streakReward;
          }
        } else {
          // Premier streak
          newStreak = _streakReward;
        }

        transaction.update(userRef, {
          'streak': newStreak,
          'xp': newXP,
          'lastStudyDate': FieldValue.serverTimestamp(),
          'totalQuizzes': FieldValue.increment(1),
          'totalXP': FieldValue.increment(_xpReward),
        });
      });
    } catch (e) {
      print('Error updating user streak: $e');
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  // Widget pour la navigation rapide
  Widget _buildQuestionNavigation() {
    return Container(
      height: 60,
      margin: EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        controller: _navigationScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _questions.length,
        itemBuilder: (context, index) {
          final isCurrent = index == _currentQuestionIndex;
          final isAnswered = _userAnswers[index] != null;
          final isCorrect = _answerStatus[index] ?? false;

          return GestureDetector(
            onTap: () => _jumpToQuestion(index),
            child: Container(
              width: 50,
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _quizCompleted
                    ? (isCorrect ? Colors.green : Colors.red).withOpacity(0.1)
                    : isCurrent
                    ? Color(0xFF7B61FF)
                    : isAnswered
                    ? Color(0xFF7B61FF).withOpacity(0.3)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isCurrent ? Color(0xFF7B61FF) : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: _quizCompleted
                        ? (isCorrect ? Colors.green : Colors.red)
                        : isCurrent
                        ? Colors.white
                        : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    // ... (votre code existant pour _buildQuestionCard reste le même)
    final question = _questions[index];
    final userAnswer = _userAnswers[index];
    final isCorrect = _answerStatus[index] ?? false;
    final isCurrent = index == _currentQuestionIndex;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCurrent ? Color(0xFF7B61FF) : Colors.grey[300]!,
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(0xFF7B61FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  question['question'] ?? 'Question',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              if (_quizCompleted)
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
            ],
          ),
          SizedBox(height: 16),
          ...List.generate(4, (optionIndex) {
            final option = question['options'][optionIndex];
            final isSelected = userAnswer == optionIndex;
            final isCorrectAnswer = optionIndex == question['correctAnswer'];

            Color backgroundColor = Colors.white;
            Color borderColor = Colors.grey[300]!;
            Color textColor = Color(0xFF333333);

            if (_quizCompleted) {
              if (isCorrectAnswer) {
                backgroundColor = Colors.green.withOpacity(0.1);
                borderColor = Colors.green;
                textColor = Colors.green;
              } else if (isSelected && !isCorrectAnswer) {
                backgroundColor = Colors.red.withOpacity(0.1);
                borderColor = Colors.red;
                textColor = Colors.red;
              }
            } else if (isSelected) {
              backgroundColor = Color(0xFF7B61FF).withOpacity(0.1);
              borderColor = Color(0xFF7B61FF);
              textColor = Color(0xFF7B61FF);
            }

            return GestureDetector(
              onTap: () => _selectAnswer(index, optionIndex),
              child: Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Color(0xFF7B61FF)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? Color(0xFF7B61FF)
                              : Colors.grey[400]!,
                        ),
                      ),
                      child: isSelected
                          ? Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(fontSize: 14, color: textColor),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (_quizCompleted && question['explanation'] != null)
            Container(
              margin: EdgeInsets.only(top: 16),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTexts.quizExplanations(context),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    question['explanation'],
                    style: TextStyle(color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRewardsPanel() {
    if (!_showRewards) return SizedBox();

    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFF3CD), Color(0xFFFFEAA7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFFFD700), width: 2),
      ),
      child: Column(
        children: [
          Text(
            AppTexts.congratulations(context),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B4513),
            ),
          ),
          SizedBox(height: 12),
          Text(
            AppTexts.scoreQuiz(context, _score),
            style: TextStyle(fontSize: 16, color: Color(0xFF8B4513)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),

          if (_streakReward > 0)
            AnimatedOpacity(
              opacity: _showRewards ? 1 : 0,
              duration: Duration(milliseconds: 300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_fire_department, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    AppTexts.streakDay(context, _streakReward),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
            ),

          if (_xpReward > 0)
            AnimatedOpacity(
              opacity: _showRewards ? 1 : 0,
              duration: Duration(milliseconds: 500),
              child: Padding(
                padding: EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.yellow[700]),
                    SizedBox(width: 8),
                    Text(
                      '+$_xpReward XP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(height: 20),
          Text(
            'Continuez vos efforts pour débloquer plus de récompenses!',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF8B4513),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _quizTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF7B61FF)),
          onPressed: () {
            // Retourner les récompenses gagnées
            Navigator.pop(context, {
              'streakReward': _streakReward,
              'xpReward': _xpReward,
              'score': _score,
            });
          },
        ),
        actions: [
          if (!_quizCompleted)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Color(0xFF7B61FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentQuestionIndex + 1}/$_totalQuestions',
                style: TextStyle(
                  color: Color(0xFF7B61FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading)
            Center(child: CircularProgressIndicator(color: Color(0xFF7B61FF)))
          else
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Navigation rapide
                  _buildQuestionNavigation(),

                  // Panel de récompenses
                  _buildRewardsPanel(),

                  // Liste des questions
                  ...List.generate(
                    _questions.length,
                    (index) => _buildQuestionCard(index),
                  ),

                  SizedBox(height: 20),

                  // Boutons de navigation
                  if (!_quizCompleted)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _previousQuestion,
                              icon: Icon(Icons.arrow_back, size: 18),
                              label: Text(AppTexts.previous(context)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Color(0xFF7B61FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Color(0xFF7B61FF)),
                                ),
                              ),
                            ),

                            ElevatedButton.icon(
                              onPressed:
                                  _currentQuestionIndex < _questions.length - 1
                                  ? _nextQuestion
                                  : null,
                              icon: Icon(Icons.arrow_forward, size: 18),
                              label: Text(AppTexts.next(context)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _currentQuestionIndex <
                                        _questions.length - 1
                                    ? Color(0xFF7B61FF)
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Bouton de soumission principal
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _submitQuiz,
                            icon: Icon(Icons.send, size: 20),
                            label: Text(
                              AppTexts.submitQuizz(context),
                              style: TextStyle(fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF7B61FF),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        // Indicateur de progression
                        SizedBox(height: 10),
                        Text(
                          '${_userAnswers.length}/$_totalQuestions questions répondues',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                  if (_quizCompleted)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context, {
                            'streakReward': _streakReward,
                            'xpReward': _xpReward,
                            'score': _score,
                          });
                        },
                        icon: Icon(Icons.home, size: 18),
                        label: Text(AppTexts.backHome(context)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF7B61FF),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 40),
                ],
              ),
            ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
