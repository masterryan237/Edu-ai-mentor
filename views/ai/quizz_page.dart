import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduai_mentor/utilis/app_texts_utils.dart';
import 'package:eduai_mentor/views/user_document_view/quizz_detail.dart';
import 'package:eduai_mentor/views/user_init_infos/avatar_store.dart';
import 'package:eduai_mentor/views/user_profile/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eduai_mentor/views/user_init_infos/avatar_picker.dart';
import 'package:eduai_mentor/services/ai_service.dart';

class QuizzTab extends StatefulWidget {
  const QuizzTab({super.key});

  @override
  State<QuizzTab> createState() => _QuizzTabState();
}

class _QuizzTabState extends State<QuizzTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AiService _aiService = AiService();
  int _currentIndex = 2;

  List<Map<String, dynamic>> _quizzes = [];
  bool _isLoading = true;
  bool _isGeneratingQuiz = false;
  String _selectedFilter = 'all';
  List<String> _categories = [];

  // Contrôleurs pour les formulaires
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quizTitleController = TextEditingController();
  final TextEditingController _quizTopicController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _quizTitleController.dispose();
    _quizTopicController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuizzes() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final quizzesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('quizzes')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> quizzes = [];
      Set<String> categories = {'all'};

      for (var doc in quizzesSnapshot.docs) {
        final data = doc.data();

        // Vérifier si le quiz a des questions
        final questions = (data['questions'] as List?) ?? [];
        final hasQuestions = questions.isNotEmpty;

        final quizData = {
          'id': doc.id,
          'title': data['title'] ?? AppTexts.untitledQuiz(context),
          'topic': data['topic'] ?? AppTexts.general(context),
          'description':
              data['description'] ?? AppTexts.testYourKnowledge(context),
          'questionCount': questions.length,
          'createdAt': data['createdAt'] ?? Timestamp.now(),
          'difficulty': data['difficulty'] ?? 'medium',
          'completed': data['completed'] ?? false,
          'score': data['score'] ?? 0,
          'streakReward': data['streakReward'] ?? 0,
          'questions': questions,
          'hasQuestions': hasQuestions,
        };
        quizzes.add(quizData);
        categories.add(data['topic'] ?? AppTexts.general(context));
      }

      setState(() {
        _quizzes = quizzes;
        _categories = categories.toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching quizzes: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return '#4CAF50';
      case 'medium':
        return '#FF9800';
      case 'hard':
        return '#F44336';
      default:
        return '#7B61FF';
    }
  }

  String _getDifficultyEmoji(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return '😊';
      case 'medium':
        return '😐';
      case 'hard':
        return '😰';
      default:
        return '📝';
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return AppTexts.today(context);
    } else if (difference.inDays == 1) {
      return AppTexts.yesterday(context);
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final isSelected = _selectedFilter == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(
                category == 'all' ? AppTexts.allTopics(context) : category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Color(0xFF333333),
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = category;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Color(0xFF7B61FF),
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected ? Color(0xFF7B61FF) : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              checkmarkColor: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    final difficulty = quiz['difficulty'] ?? 'medium';
    final color = Color(
      int.parse(_getDifficultyColor(difficulty).substring(1, 7), radix: 16) +
          0xFF000000,
    );
    final isCompleted = quiz['completed'] ?? false;
    final score = quiz['score'] ?? 0;
    final questionCount = quiz['questionCount'] ?? 0;
    final hasQuestions = quiz['hasQuestions'] ?? false;

    return GestureDetector(
      onTap: () {
        if (!hasQuestions) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppTexts.noQuestionsAvailable(context)),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizDetailPage(
              quizId: quiz['id'],
              quizData: quiz,
              onQuizCompleted: (streakReward) {
                // Rafraîchir la liste après complétion
                _fetchQuizzes();
              },
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header avec titre et difficulté
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getDifficultyEmoji(difficulty),
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz['title'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          quiz['topic'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      difficulty.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenu de la carte
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz['description'],
                    style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),

                  // Warning si pas de questions
                  if (!hasQuestions)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppTexts.noQuestionsAvailable(context),
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    // Stats du quiz
                    Row(
                      children: [
                        _buildStatItem(
                          icon: Icons.question_answer,
                          value: '$questionCount',
                          label: AppTexts.questions(context),
                          color: Color(0xFF7B61FF),
                        ),
                        SizedBox(width: 16),
                        _buildStatItem(
                          icon: Icons.timer,
                          value: '${questionCount * 2}',
                          label: AppTexts.minutes(context),
                          color: Color(0xFFFF9800),
                        ),
                        SizedBox(width: 16),
                        _buildStatItem(
                          icon: Icons.local_fire_department,
                          value: '${quiz['streakReward'] ?? 0}',
                          label: AppTexts.streak(context),
                          color: Color(0xFFFF5722),
                        ),
                      ],
                    ),
                  SizedBox(height: 12),

                  // Progression/Score
                  if (isCompleted && hasQuestions)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Color(0xFF4CAF50),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppTexts.completedQuizScore(context, score),
                              style: TextStyle(
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (hasQuestions)
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF7B61FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: Color(0xFF7B61FF),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppTexts.startQuizInstruction(context),
                              style: TextStyle(
                                color: Color(0xFF7B61FF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF7B61FF),
                            size: 16,
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(quiz['createdAt']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                      if (isCompleted && hasQuestions)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 12,
                                color: Color(0xFF4CAF50),
                              ),
                              SizedBox(width: 4),
                              Text(
                                AppTexts.completed(context).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFF7B61FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.quiz, size: 60, color: Color(0xFF7B61FF)),
            ),
            SizedBox(height: 24),
            Text(
              AppTexts.noQuizzesYet(context),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            SizedBox(height: 12),
            Text(
              AppTexts.createFirstQuiz(context),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _showCreateQuizDialog();
              },
              icon: Icon(Icons.auto_awesome, size: 18),
              label: Text(AppTexts.createNewQuiz(context)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7B61FF),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateQuizDialog() async {
    // Réinitialiser les contrôleurs
    _descriptionController.clear();
    _quizTitleController.clear();
    _quizTopicController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppTexts.createNewQuizTitle(context),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.description, color: Color(0xFF7B61FF)),
              title: Text(AppTexts.fromDescription(context)),
              subtitle: Text(AppTexts.generateFromDescription(context)),
              onTap: () {
                Navigator.pop(context);
                _createQuizFromDescription();
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.library_books, color: Color(0xFF7B61FF)),
              title: Text(AppTexts.fromUploadedCourse(context)),
              subtitle: Text(AppTexts.generateFromCourse(context)),
              onTap: () {
                Navigator.pop(context);
                _createQuizFromCourse();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppTexts.cancel(context),
              style: TextStyle(color: Color(0xFF666666)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createQuizFromDescription() async {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              AppTexts.createQuizFromDescription(context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _quizTitleController,
                    decoration: InputDecoration(
                      labelText:
                          AppTexts.quiz(context) +
                          " " +
                          AppTexts.titleLabel(context),
                      hintText: AppTexts.quizTitleHint(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _quizTopicController,
                    decoration: InputDecoration(
                      labelText: AppTexts.topicLabel(context),
                      hintText: AppTexts.topicHint(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: AppTexts.description(context),
                      hintText: AppTexts.descriptionHint(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppTexts.cancel(context),
                  style: TextStyle(color: Color(0xFF666666)),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_descriptionController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppTexts.enterDescription(context)),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  final title = _quizTitleController.text.isNotEmpty
                      ? _quizTitleController.text
                      : "${AppTexts.quiz(context)} on ${_descriptionController.text.split(' ').take(3).join(' ')}...";

                  final topic = _quizTopicController.text.isNotEmpty
                      ? _quizTopicController.text
                      : AppTexts.general(context);

                  Navigator.pop(context);
                  _showGeneratingDialog();
                  await _generateQuizFromDescription(
                    title: title,
                    topic: topic,
                    description: _descriptionController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7B61FF),
                  foregroundColor: Colors.white,
                ),
                child: Text(AppTexts.newQuiz(context)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createQuizFromCourse() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Récupérer les cours de l'utilisateur avec plus de données
      final coursesSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .orderBy('uploadDate', descending: true)
          .get();

      if (coursesSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTexts.noCoursesFound(context)),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            AppTexts.selectCourse(context),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          content: SizedBox(
            width: 350,
            height: 400,
            child: ListView.builder(
              itemCount: coursesSnapshot.docs.length,
              itemBuilder: (context, index) {
                final course = coursesSnapshot.docs[index];
                final data = course.data();
                final hasPdf = (data['pdfUrl'] ?? data['documentUrl']) != null;
                final hasContent = data['content'] != null;

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: hasPdf
                            ? Colors.red.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          hasPdf ? Icons.picture_as_pdf : Icons.library_books,
                          color: hasPdf ? Colors.red : Colors.blue,
                          size: 20,
                        ),
                      ),
                    ),
                    title: Text(
                      data['title'] ?? 'Untitled Course',
                      style: TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['topic'] ?? AppTexts.general(context)),
                        if (hasPdf)
                          Row(
                            children: [
                              Icon(
                                Icons.picture_as_pdf,
                                size: 12,
                                color: Colors.red,
                              ),
                              SizedBox(width: 4),
                              Text(
                                AppTexts.pdfAvailable(context),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    trailing: Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF7B61FF),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showCourseQuizForm(course.id, {
                        ...data,
                        'id': course.id, // Ajouter l'ID du document
                      });
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppTexts.cancel(context),
                style: TextStyle(color: Color(0xFF666666)),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error fetching courses: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.errorLoadingCourses(context)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCourseQuizForm(String courseId, Map<String, dynamic> courseData) {
    // Pré-remplir avec les données du cours
    _quizTitleController.text =
        "${courseData['title'] ?? 'Course'} ${AppTexts.quiz(context)}";
    _quizTopicController.text =
        courseData['topic'] ?? AppTexts.general(context);
    _descriptionController.text =
        "${AppTexts.quiz(context)} based on ${courseData['title'] ?? 'the course'}";

    // Vérifier si le cours a un PDF
    final hasPdf = (courseData['pdfUrl'] ?? courseData['documentUrl']) != null;
    final hasContent = courseData['content'] != null;

    showDialog(
      context: context,
      barrierDismissible: false, // Empêcher la fermeture pendant la génération
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  hasPdf ? Icons.picture_as_pdf : Icons.library_books,
                  color: Color(0xFF7B61FF),
                  size: 24,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppTexts.createQuizFromCourse(context),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF7B61FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          courseData['title'] ?? 'Course',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF7B61FF),
                          ),
                        ),
                        SizedBox(height: 4),
                        if (hasPdf)
                          Row(
                            children: [
                              Icon(
                                Icons.picture_as_pdf,
                                size: 16,
                                color: Colors.red,
                              ),
                              SizedBox(width: 4),
                              Text(
                                AppTexts.pdfAvailable(context),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        if (!hasPdf && hasContent)
                          Row(
                            children: [
                              Icon(
                                Icons.text_snippet,
                                size: 16,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 4),
                              Text(
                                AppTexts.textContentAvailable(context),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Afficher soit le formulaire, soit l'indicateur de chargement
                  if (!_isGeneratingQuiz) ...[
                    TextField(
                      controller: _quizTitleController,
                      decoration: InputDecoration(
                        labelText:
                            AppTexts.quiz(context) +
                            " " +
                            AppTexts.titleLabel(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _quizTopicController,
                      decoration: InputDecoration(
                        labelText: AppTexts.topicLabel(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: AppTexts.description(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTexts.generationMethod(context),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            hasPdf
                                ? AppTexts.willExtractFromPdf(context)
                                : AppTexts.willUseCourseContent(context),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Indicateur de chargement
                    Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF7B61FF),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            AppTexts.generatingQuiz(context),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            AppTexts.analyzingContent(context),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF666666),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            AppTexts.mayTake2030Seconds(context),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF999999),
                            ),
                          ),
                          SizedBox(height: 16),
                          LinearProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF7B61FF),
                            ),
                            backgroundColor: Color(0xFF7B61FF).withOpacity(0.1),
                            minHeight: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              if (!_isGeneratingQuiz) ...[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppTexts.cancel(context),
                    style: TextStyle(color: Color(0xFF666666)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Démarrer la génération
                    setState(() {
                      _isGeneratingQuiz = true;
                    });

                    // Attendre un peu pour que l'UI se mette à jour
                    await Future.delayed(Duration(milliseconds: 100));

                    try {
                      await _generateQuizFromCourse(
                        courseData: courseData,
                        title: _quizTitleController.text,
                        topic: _quizTopicController.text,
                        description: _descriptionController.text,
                      );

                      // Ne pas fermer ici - la fermeture se fait dans _generateQuizFromCourse
                    } catch (e) {
                      // En cas d'erreur, réinitialiser l'état
                      setState(() {
                        _isGeneratingQuiz = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppTexts.errorGeneratingQuiz(context, e.toString()),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7B61FF),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppTexts.newQuiz(context)),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _generateQuizFromDescription({
    required String title,
    required String topic,
    required String description,
  }) async {
    try {
      // Utiliser votre fonction existante generateQuizz
      final questions = await _aiService.generateQuizz(description, context);

      // Convertir les QuizQuestion en format Firestore
      final firestoreQuestions = questions
          .map(
            (q) => {
              'question': q.question,
              'options': q.options,
              'correctAnswer': q.correctIndex,
              'explanation': q.explanation,
            },
          )
          .toList();

      // Sauvegarder dans Firestore
      await _saveQuizToFirestore(
        title: title,
        topic: topic,
        description: description,
        questions: firestoreQuestions,
      );
    } catch (e) {
      Navigator.pop(context); // Fermer le dialog de génération
      print('Error generating quiz from description: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.errorGeneratingQuiz(context, e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generateQuizFromCourse({
    required Map<String, dynamic> courseData,
    required String title,
    required String topic,
    required String description,
  }) async {
    try {
      // Vérifier si le cours a un document PDF
      final pdfUrl = courseData['pdfUrl'] ?? courseData['documentUrl'];

      if (pdfUrl == null || pdfUrl.toString().isEmpty) {
        // Si pas de PDF, utiliser la description textuelle
        Navigator.pop(context); // Fermer le dialog de génération
        await _generateQuizFromTextCourse(
          courseData: courseData,
          title: title,
          topic: topic,
          description: description,
        );
        return;
      }

      // Générer le quiz à partir du PDF
      final result = await _aiService.generateQuizFromPdfUrl(
        pdfUrl.toString(),
        context,
        courseTitle: title,
        courseTopic: topic,
        courseId: courseData['id'] ?? '',
      );

      if (result['success'] == true) {
        Navigator.pop(context); // Fermer le dialog de génération

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? AppTexts.quizCreatedSuccessfully(context),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Rafraîchir la liste des quiz
        await _fetchQuizzes();
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? AppTexts.error(context)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      print('Error generating quiz from course PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.errorGeneratingQuiz(context, e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Méthode alternative pour les cours sans PDF
  Future<void> _generateQuizFromTextCourse({
    required Map<String, dynamic> courseData,
    required String title,
    required String topic,
    required String description,
  }) async {
    try {
      // Utiliser le contenu textuel du cours si disponible
      final courseContent =
          courseData['content'] ??
          courseData['description'] ??
          courseData['title'] ??
          "${AppTexts.quiz(context)} about ${courseData['topic'] ?? 'the course'}";

      // Générer le quiz à partir du contenu textuel
      final result = await _aiService.generateQuizFromContent(
        courseContent,
        context,
        courseTitle: title,
        courseTopic: topic,
        courseId: courseData['id'] ?? '',
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? AppTexts.quizCreatedSuccessfully(context),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Rafraîchir la liste des quiz
        await _fetchQuizzes();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? AppTexts.error(context)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error generating quiz from text course: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.errorGeneratingQuiz(context, e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _saveQuizToFirestore({
    required String title,
    required String topic,
    required String description,
    required List<Map<String, dynamic>> questions,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Sauvegarder dans Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('quizzes')
          .add({
            'title': title,
            'topic': topic,
            'description': description,
            'difficulty': 'medium', // Par défaut
            'questions': questions,
            'questionCount': questions.length,
            'createdAt': Timestamp.now(),
            'completed': false,
            'score': 0,
            'streakReward': 0,
            'userId': user.uid,
          });

      Navigator.pop(context); // Fermer le dialog de génération

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.quizCreatedSuccessfully(context)),
          backgroundColor: Colors.green,
        ),
      );

      // Rafraîchir la liste des quiz
      await _fetchQuizzes();
    } catch (e) {
      Navigator.pop(context);
      print('Error saving quiz: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTexts.errorCreatingQuiz(context, e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showGeneratingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          AppTexts.generatingQuiz(context),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: Color(0xFF7B61FF),
              ),
            ),
            SizedBox(height: 16),
            Text(
              AppTexts.aiIsCreatingQuiz(context),
              style: TextStyle(color: Color(0xFF666666)),
            ),
            SizedBox(height: 8),
            Text(
              AppTexts.thisMayTakeFewMoments(context),
              style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredQuizzes = _selectedFilter == 'all'
        ? _quizzes
        : _quizzes.where((quiz) => quiz['topic'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AvatarPickerScreen()),
            ),
            child: CircleAvatar(
              backgroundImage: AssetImage(
                AvatarStore.selectedAvatarImg ?? 'assets/images/owl.png',
              ),
              backgroundColor: Color(0xFF7B61FF).withOpacity(0.1),
              child: _auth.currentUser?.photoURL != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(
                        _auth.currentUser!.photoURL!,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTexts.aiQuizz(context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              AppTexts.testYourKnowledge(context),
              style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              _fetchQuizzes();
            },
            icon: Icon(Icons.refresh, color: Color(0xFF7B61FF)),
            tooltip: AppTexts.refresh(context),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchQuizzes();
        },
        color: Color(0xFF7B61FF),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats en-tête
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF7B61FF),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF7B61FF).withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHeaderStat(
                      value: _quizzes.length.toString(),
                      label: AppTexts.totalQuizzes(context),
                      icon: Icons.library_books,
                    ),
                    _buildHeaderStat(
                      value: _quizzes
                          .where((q) => q['completed'] == true)
                          .length
                          .toString(),
                      label: AppTexts.completed(context),
                      icon: Icons.check_circle,
                    ),
                    _buildHeaderStat(
                      value: _categories.length.toString(),
                      label: AppTexts.topics(context),
                      icon: Icons.category,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Filtres par catégorie
              Text(
                AppTexts.browseByTopic(context),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 12),
              _buildCategoryChips(),
              SizedBox(height: 24),

              if (_isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: Color(0xFF7B61FF)),
                  ),
                )
              else if (filteredQuizzes.isEmpty)
                _buildEmptyState()
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppTexts.yourQuizzes(context),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF7B61FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            AppTexts.quizzesCount(
                              context,
                              filteredQuizzes.length,
                            ),
                            style: TextStyle(
                              color: Color(0xFF7B61FF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ...filteredQuizzes.map((quiz) => _buildQuizCard(quiz)),
                  ],
                ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateQuizDialog();
        },
        backgroundColor: Color(0xFF7B61FF),
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
        label: Text(AppTexts.newQuiz(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Navigation vers les différentes pages
          if (index == 0) {
            // Home
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/home/', (route) => false);
          } else if (index == 1) {
            // My Courses
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/Mycourse/', (route) => false);
          } else if (index == 2) {
            // Quizz - déjà sur cette page
          } else if (index == 3) {
            // profile
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
              (route) => false, // Supprime toutes les routes
            );
          }
        },
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF7B61FF),
        unselectedItemColor: Color(0xFF999999),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppTexts.home(context),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: AppTexts.myCourses(context),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: AppTexts.quizz(context),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppTexts.profile(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }
}

// Ajout de méthodes manquantes dans AppTexts (pour la complétude)
