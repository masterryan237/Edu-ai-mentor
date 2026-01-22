import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduai_mentor/services/ai_service.dart';
import 'package:eduai_mentor/services/db_service.dart';
import 'package:eduai_mentor/services/file_service.dart';
import 'package:eduai_mentor/services/search_algolia_service.dart';
import 'package:eduai_mentor/services/storage_service.dart';
import 'package:eduai_mentor/utilis/app_texts_utils.dart';
import 'package:eduai_mentor/views/ai/explaining_page.dart';
import 'package:eduai_mentor/views/user_document_view/quizz_detail.dart';
import 'package:eduai_mentor/views/user_init_infos/avatar_picker.dart';
import 'package:eduai_mentor/views/user_init_infos/avatar_store.dart';
import 'package:eduai_mentor/views/user_profile/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyCoursesTab extends StatefulWidget {
  const MyCoursesTab({super.key});

  @override
  State<MyCoursesTab> createState() => _MyCoursesTabState();
}

class _MyCoursesTabState extends State<MyCoursesTab> {
  final _dbService = DbService();
  final _fileService = FileService();
  final _storageService = StorageService();
  final _algoliaService = SearchAlgoliaService();
  final _aiService = AiService();
  String algolia_app_id = dotenv.env['ALGOLIA_APP_ID']!;
  String algolia_admin_key = dotenv.env['ALGOLIA_ADMIN_KEY']!;
  String algolia_search_key = dotenv.env['ALGOLIA_SEARCH_KEY']!;

  int _currentIndex = 1;
  final userid = FirebaseAuth.instance.currentUser?.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Variables pour les données
  List<Map<String, dynamic>> _courses = [];
  int _totalCourses = 0;
  int _streakDays = 0;
  DateTime? _lastStudyDate;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            _streakDays = userDoc.data()?['streak'] ?? 0;
            final lastStudyTimestamp =
                userDoc.data()?['lastStudyDate'] as Timestamp?;
            _lastStudyDate = lastStudyTimestamp?.toDate();
          });
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  void _confirmDeletion(BuildContext context, String docId, String fileID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTexts.confirmDeletion(context)),
        content: Text(AppTexts.deleteConfirmMsg(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTexts.cancel(context)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCourse(docId, fileID);
            },
            child: Text(
              AppTexts.delete(context),
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCourse(String docId, String fileID) async {
    try {
      // 1. SUPPRESSION SUPABASE
      await _storageService.deleteCourseFromSupabase(docId, fileID);

      // 2. SUPPRESSION ALGOLIA
      await _algoliaService.deleteCourseFromALgolia(docId, fileID);

      // 3. SUPPRESSION FIRESTORE
      await _dbService.deleteCourseFromFirestore(docId, fileID);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTexts.deleteSuccess(context))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTexts.networkErrorDeletion(context))),
        );
      }
    }
  }

  // Fonction pour modifier le nom/topic d'un cours
  Future<void> _updateCourseInfo(
    BuildContext context,
    String docId,
    Map<String, dynamic> currentData,
  ) async {
    final TextEditingController titleController = TextEditingController(
      text: currentData['title'] ?? '',
    );
    final TextEditingController topicController = TextEditingController(
      text: currentData['topic'] ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTexts.modifyCourse(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: AppTexts.courseTitleLabel(context),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: topicController,
              decoration: InputDecoration(
                labelText: AppTexts.courseTopicLabel(context),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTexts.cancel(context)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty) return;

              try {
                await _firestore
                    .collection('users')
                    .doc(userid)
                    .collection('courses')
                    .doc(docId)
                    .update({
                      'title': titleController.text.trim(),
                      'topic': topicController.text.trim(),
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

                // Mettre à jour Algolia
                await _algoliaService.updateCourseInAlgolia(docId, {
                  'title': titleController.text.trim(),
                  'topic': topicController.text.trim(),
                });

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppTexts.courseUpdated(context)),
                      backgroundColor: Colors.green,
                    ),
                  );
                  setState(() {}); // Rafraîchir l'UI
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF7B61FF)),
            child: Text(
              AppTexts.save(context),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour générer un quiz à partir d'un cours
  // Fonction pour générer un quiz à partir d'un cours
  Future<void> _generateQuizFromCourse(
    BuildContext context,
    String docId,
    Map<String, dynamic> courseData,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      String? url = courseData['downloadURL'];
      String title = courseData['title'] ?? 'Cours';
      String topic = courseData['topic'] ?? 'Général';

      // Utiliser la nouvelle fonction qui extrait le texte PDF automatiquement
      final result = await _aiService.generateQuizFromPdfUrl(
        url ?? '',
        context,
        courseTitle: title,
        courseTopic: topic,
        courseId: docId,
      );

      if (mounted) {
        Navigator.pop(context); // Fermer le loading

        if (result['success'] == true) {
          // Afficher le quiz généré avec un design amélioré
          _showGeneratedQuizDialog(
            context,
            result['quizData'],
            title,
            result['quizId'] ??
                'generated_quiz_${DateTime.now().millisecondsSinceEpoch}', // Passer l'ID
          );
        } else {
          // Afficher l'erreur
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? "Unknown Error"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Quizz Generation Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Fonction pour afficher le quiz généré - MODIFIÉE
  void _showGeneratedQuizDialog(
    BuildContext context,
    Map<String, dynamic> quizData,
    String courseTitle,
    String quizId, // AJOUTÉ: Recevoir l'ID du quiz
  ) {
    final questions = quizData['questions'] as List<dynamic>;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.quiz, color: Color(0xFF7B61FF)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                quizData['quizTitle'] ?? AppTexts.quizGeneratedSuccess(context),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "✅ ${AppTexts.quizGeneratedSuccess(context)}",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 10),
              Text(
                AppTexts.questionsCreated(context, questions.length),
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 10),
              Divider(),
              SizedBox(height: 10),

              // Aperçu des premières questions
              Text(
                AppTexts.quizPreview(context),
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              SizedBox(height: 10),

              ...questions.take(2).map((question) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "• ${question['question']}",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    Text(
                      "   ✓ ${question['options'][question['correctAnswer']]}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                  ],
                );
              }).toList(),

              if (questions.length > 2)
                Text(
                  AppTexts.otherQuestions(context, questions.length - 2),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),

              SizedBox(height: 20),
              Text(
                AppTexts.quizSavedInfo(context),
                style: TextStyle(fontSize: 12, color: Colors.blue[700]),
              ),
              SizedBox(height: 5),
              Text(
                AppTexts.quizAccessInfo(context),
                style: TextStyle(fontSize: 12, color: Colors.blue[700]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppTexts.close(context)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fermer le dialogue

              // Navigation vers la page du quiz avec les arguments
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      QuizDetailPage(quizId: quizId, quizData: quizData),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF7B61FF)),
            child: Text(
              AppTexts.startQuiz(context),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleViewFile(String? url, String fileName) async {
    if (url == null || url.isEmpty) return;
    try {
      await _fileService.handleViewFile(url, fileName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppTexts.fileError(context))));
      }
    }
  }

  Future<void> generateAIExplanation(
    String? url,
    String title,
    String topic,
  ) async {
    if (url == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      String textToAnalyze = "";

      // Utiliser la nouvelle fonction d'extraction PDF de AiService
      if (url.toLowerCase().contains('.pdf')) {
        textToAnalyze = await _aiService.extractTextFromPdf(url);
      } else {
        textToAnalyze =
            "Document: $title, Topic: $topic. Please provide a general explanation based on these keywords.";
      }

      final response = await _aiService.generateExplanation(
        textToAnalyze,
        context,
      );

      if (mounted) Navigator.pop(context);

      if (response.text != null && mounted) {
        String cleanExplanation = response.text!.replaceAll(
          RegExp(r'[\*\#\_]'),
          '',
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExplainingPage(
              title: title,
              explanation: cleanExplanation,
              topic: topic,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppTexts.aiFailed(context))));
      }
    }
  }

  // Fonction pour obtenir la couleur selon le sujet
  Color _getSubjectColor(String? subject) {
    final colors = [
      Color(0xFF7B61FF), // Math
      Color(0xFF4CAF50), // Physics
      Color(0xFFFF9800), // English
      Color(0xFF2196F3), // Science
      Color(0xFFE91E63), // History
      Color(0xFF9C27B0), // Art
    ];

    if (subject == null || subject.isEmpty) return colors[0];
    final hash = subject.hashCode;
    return colors[hash % colors.length];
  }

  // Fonction pour obtenir l'icône selon le type de fichier
  IconData _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_fields;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildStreakBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFFFA500).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.local_fire_department, color: Colors.white, size: 18),
          SizedBox(width: 4),
          Text(
            "$_streakDays",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
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
              AppTexts.myCourses(context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              AppTexts.myCoursesSubtitle(context),
              style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
          ],
        ),
        actions: [_buildStreakBadge(), SizedBox(width: 16)],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dbService.getUploadedCourses(userid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("FIREBASE ERROR: ${snapshot.error}");
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  SizedBox(height: 16),
                  Text(
                    AppTexts.loadingError(context),
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFF7B61FF)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7B61FF).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.library_books_outlined,
                        size: 80,
                        color: Color(0xFF7B61FF),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppTexts.noCourses(context),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppTexts.uploadFirstCourse(context),
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            );
          }

          final courses = snapshot.data!.docs;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppTexts.allCourses(context, courses.length),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          Icon(Icons.library_books, color: Color(0xFF7B61FF)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Divider(),
                      SizedBox(height: 8),
                      ...courses.map((doc) {
                        final courseData = doc.data() as Map<String, dynamic>;
                        final color = _getSubjectColor(courseData['topic']);

                        return Container(
                          margin: EdgeInsets.only(bottom: 16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getFileTypeIcon(
                                        courseData['fileType'] ?? 'unknown',
                                      ),
                                      color: color,
                                      size: 28,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          courseData['title'] ?? 'Untitled',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF333333),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: color.withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                courseData['topic'] ??
                                                    'General',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: color,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                (courseData['fileType'] ??
                                                        'unknown')
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (courseData['uploadDate'] != null)
                                          Padding(
                                            padding: EdgeInsets.only(top: 4),
                                            child: Text(
                                              "${AppTexts.uploaded(context)} ${_formatDate((courseData['uploadDate'] as Timestamp).toDate())}",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Divider(color: Colors.grey[200]),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Bouton View
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: () => _handleViewFile(
                                        courseData['downloadURL'],
                                        courseData['title'],
                                      ),
                                      icon: Icon(
                                        Icons.visibility,
                                        size: 18,
                                        color: Color(0xFF7B61FF),
                                      ),
                                      label: Text(
                                        AppTexts.view(context),
                                        style: TextStyle(
                                          color: Color(0xFF7B61FF),
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                  VerticalDivider(width: 1),
                                  // Bouton AI Explanation
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: () => generateAIExplanation(
                                        courseData['downloadURL'],
                                        courseData['title'],
                                        courseData['topic'],
                                      ),
                                      icon: Icon(
                                        Icons.auto_awesome,
                                        size: 18,
                                        color: Colors.orange,
                                      ),
                                      label: Text(
                                        AppTexts.explain(context),
                                        style: TextStyle(color: Colors.orange),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                  VerticalDivider(width: 1),
                                  // Bouton Generate Quiz
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: () => _generateQuizFromCourse(
                                        context,
                                        doc.id,
                                        courseData,
                                      ),
                                      icon: Icon(
                                        Icons.quiz,
                                        size: 18,
                                        color: Colors.green,
                                      ),
                                      label: Text(
                                        AppTexts.quiz(context),
                                        style: TextStyle(color: Colors.green),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Bouton Edit
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _updateCourseInfo(
                                        context,
                                        doc.id,
                                        courseData,
                                      ),
                                      icon: Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.blue,
                                      ),
                                      label: Text(
                                        AppTexts.edit(context),
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        side: BorderSide(color: Colors.blue),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  // Bouton Delete
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _confirmDeletion(
                                        context,
                                        doc.id,
                                        courseData['fileID'],
                                      ),
                                      icon: Icon(
                                        Icons.delete,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                      label: Text(
                                        AppTexts.delete(context),
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        side: BorderSide(color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/home/', (route) => false);
              break;
            case 1:
              // Déjà sur MyCourses
              break;
            case 2:
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/QuizzTab/', (route) => false);
              break;
            case 3:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
                (route) => false, // Supprime toutes les routes
              );
              break;
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
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Quizz'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppTexts.profile(context),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return AppTexts.today(context);
    } else if (difference.inDays == 1) {
      return AppTexts.yesterday(context);
    } else if (difference.inDays < 7) {
      return AppTexts.daysAgo(context, difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
