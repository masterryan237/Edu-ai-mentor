import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduai_mentor/services/ai_service.dart';
import 'package:eduai_mentor/services/db_service.dart';
import 'package:eduai_mentor/services/file_service.dart';
import 'package:eduai_mentor/services/search_algolia_service.dart';
import 'package:eduai_mentor/services/storage_service.dart';
import 'package:eduai_mentor/utilis/app_texts_utils.dart';
import 'package:eduai_mentor/views/ai/explaining_page.dart';
import 'package:eduai_mentor/views/ai/generate_course.dart';
import 'package:eduai_mentor/views/user_init_infos/avatar_store.dart';
import 'package:eduai_mentor/views/user_profile/profile_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:eduai_mentor/views/user_init_infos/avatar_picker.dart';

// Classe temporaire pour représenter les données du cours
class CourseData {
  final String id;
  final String title;
  final String? topic;
  final String fileName;
  final String fileType;
  final String downloadURL;
  final String fileID;
  final Timestamp? uploadDate;

  CourseData({
    required this.id,
    required this.title,
    this.topic,
    required this.fileName,
    required this.fileType,
    required this.downloadURL,
    required this.fileID,
    this.uploadDate,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _aiService = AiService();
  final _dbService = DbService();
  final _fileService = FileService();
  final _storageService = StorageService();
  final _algoliaService = SearchAlgoliaService();
  String gemini_api_key = dotenv.env['GEMINI_API_KEY']!;
  String algolia_app_id = dotenv.env['ALGOLIA_APP_ID']!;
  String algolia_admin_key = dotenv.env['ALGOLIA_ADMIN_KEY']!;
  String algolia_search_key = dotenv.env['ALGOLIA_SEARCH_KEY']!;
  int _currentIndex = 0;
  dynamic file;
  String? _fileInfos;
  late final TextEditingController _courseName;
  late final TextEditingController _topicName;
  late final TextEditingController _searchText;
  final userid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Variables pour les données
  List<CourseData> _courses = [];
  Map<String, List<CourseData>> _coursesBySubject = {};
  int _totalCourses = 0;
  int _streakDays = 0;
  DateTime? _lastStudyDate;
  bool _isSearching = false;
  final FocusNode _searchFocusNode = FocusNode();

  // Variables pour la recherche filtrée
  List<Map<String, dynamic>> _searchResults = [];
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _courseName = TextEditingController();
    _topicName = TextEditingController();
    _searchText = TextEditingController();

    _fetchUserData();
    _fetchCourses();

    // Écouter les changements de recherche avec debounce
    _searchText.addListener(() {
      _searchDebounce?.cancel();

      if (_searchText.text.isNotEmpty) {
        // Délai de 300ms pour éviter trop de requêtes
        _searchDebounce = Timer(const Duration(milliseconds: 300), () {
          _performSearchWithFilter(_searchText.text);
        });
      } else {
        setState(() {
          _isSearching = false;
          _searchResults.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _courseName.dispose();
    _topicName.dispose();
    _searchText.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // Fonction pour effectuer une recherche avec filtre userId
  Future<void> _performSearchWithFilter(String query) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _searchAlgoliaWithUserFilter(query, userId);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Search error: $e');
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults.clear();
        });
      }
    }
  }

  // Recherche Algolia avec filtre userId
  Future<List<Map<String, dynamic>>> _searchAlgoliaWithUserFilter(
    String query,
    String userId,
  ) async {
    try {
      final url = Uri.parse(
        'https://$algolia_app_id.algolia.net/1/indexes/courses/query',
      );

      final response = await http.post(
        url,
        headers: {
          'X-Algolia-Application-Id': algolia_app_id,
          'X-Algolia-API-Key': algolia_search_key,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'query': query,
          'filters': 'userId:"$userId"', // Filtre par userId
          'hitsPerPage': 20,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['hits'] ?? []);
      } else {
        print('Algolia search failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Algolia search error: $e');
      return [];
    }
  }

  void _confirmDeletion(BuildContext context, String docId, String fileID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTexts.confirmTitle(context)),
        content: Text(AppTexts.confirmDeleteMsg(context)),
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
        // Rafraîchir les cours après suppression
        await _fetchCourses();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTexts.networkErrorDeletion(context))),
        );
      }
    }
  }

  void _saveNewCourse(String? localPath, PlatformFile? fileInfo) async {
    final name = _courseName.text.trim();
    final topic = _topicName.text.trim();

    if (localPath == null || fileInfo == null || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Try to fill all fields before submit")),
      );
      return;
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await _dbService.saveNewCourse(localPath, fileInfo, name, topic);

      if (mounted) {
        Navigator.of(context).pop(); // Ferme le loading
        Navigator.of(context).pop(); // Ferme le formulaire d'upload

        _courseName.clear();
        _topicName.clear();
        setState(() => _fileInfos = null);

        // Rafraîchir les cours après l'ajout
        await _fetchCourses();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTexts.uploadSuccess(context)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppTexts.error(context)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Error:$e"),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
          ),
        );
      }
    }
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
      if (url.toLowerCase().contains('.pdf')) {
        final response = await http
            .get(Uri.parse(url))
            .timeout(const Duration(seconds: 15));
        final PdfDocument document = PdfDocument(
          inputBytes: response.bodyBytes,
        );
        int pageCount = document.pages.count > 3 ? 3 : document.pages.count;
        textToAnalyze = PdfTextExtractor(
          document,
        ).extractText(startPageIndex: 0, endPageIndex: pageCount - 1);
        document.dispose();
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppTexts.error(context)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppTexts.aiFailed(context)),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
          ),
        );
      }
    }
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

  Future<void> _fetchCourses() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('courses')
          .orderBy('uploadDate', descending: true)
          .get();

      List<CourseData> courses = [];
      Map<String, List<CourseData>> coursesBySubject = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final course = CourseData(
          id: doc.id,
          title: data['title'] ?? AppTexts.untitledQuiz(context),
          topic: data['topic'],
          fileName: data['fileName'] ?? 'Unknown File',
          fileType: data['fileType'] ?? 'unknown',
          downloadURL: data['downloadURL'] ?? '',
          fileID: data['fileID'] ?? '',
          uploadDate: data['uploadDate'],
        );
        courses.add(course);

        final subject = course.topic ?? AppTexts.general(context);
        if (!coursesBySubject.containsKey(subject)) {
          coursesBySubject[subject] = [];
        }
        coursesBySubject[subject]!.add(course);
      }

      setState(() {
        _courses = courses;
        _coursesBySubject = coursesBySubject;
        _totalCourses = courses.length;
      });
    } catch (e) {
      print('Error fetching courses: $e');
    }
  }

  double _calculateSubjectProgress(String subject) {
    if (!_coursesBySubject.containsKey(subject) ||
        _coursesBySubject[subject]!.isEmpty) {
      return 0.0;
    }

    final totalCourses = _coursesBySubject[subject]!.length;
    double progress = totalCourses * 0.25;
    return progress > 1.0 ? 1.0 : progress;
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

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: Color(0xFF7B61FF)),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Color(0xFF7B61FF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off,
                  size: 60,
                  color: Color(0xFF7B61FF),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppTexts.noResults(context, _searchText.text),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppTexts.tryDifferentKeywords(context),
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: _searchResults.map((data) {
          final color = _getSubjectColor(
            data['topic'] ?? AppTexts.general(context),
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getFileTypeIcon(data['fileType'] ?? 'unknown'),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? AppTexts.untitledQuiz(context),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['topic'] ?? AppTexts.general(context),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              (data['fileType'] ?? 'unknown').toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (data['uploadDate'] != null)
                            Text(
                              _formatDate(DateTime.parse(data['uploadDate'])),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF999999),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () =>
                          _handleViewFile(data['downloadURL'], data['title']),
                      icon: Icon(Icons.visibility, color: Color(0xFF7B61FF)),
                    ),
                    IconButton(
                      onPressed: () => generateAIExplanation(
                        data['downloadURL'],
                        data['title'],
                        data['topic'],
                      ),
                      icon: Icon(Icons.auto_awesome, color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Fonction pour ouvrir le dialogue d'upload
  void _openUploadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(AppTexts.uploadTitle(context)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _courseName,
                      decoration: InputDecoration(
                        labelText: AppTexts.courseNameLabel(context),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurpleAccent,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _topicName,
                      decoration: InputDecoration(
                        labelText: AppTexts.topicLabel(context),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.deepPurpleAccent,
                            width: 2.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await _fileService.pickFile();
                        if (picked != null) {
                          setDialogState(() {
                            file = picked;
                            _fileInfos =
                                "${file.name}.${file.extension?.toUpperCase()}";
                          });
                        }
                      },
                      label: Text(AppTexts.selectDoc(context)),
                      icon: const Icon(Icons.upload_file),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _fileInfos ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7B61FF),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _saveNewCourse(file?.path, file),
                      label: Text(AppTexts.uploadBtn(context)),
                      icon: const Icon(Icons.upload_file),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Color(0xFF7B61FF),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        AppTexts.cancel(context),
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
              AppTexts.helloUser(
                context,
                _auth.currentUser?.displayName?.split(' ').first ??
                    AppTexts.student(context),
              ),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              AppTexts.letsLearn(context),
              style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
          ],
        ),
        actions: [_buildStreakBadge(), const SizedBox(width: 16)],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchUserData();
          await _fetchCourses();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barre de recherche
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Color(0xFF7B61FF)),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchText,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: AppTexts.searchHint(context),
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ),
                    if (_searchText.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchText.clear();
                          setState(() {
                            _isSearching = false;
                            _searchResults.clear();
                          });
                        },
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Si recherche active
              if (_searchText.text.isNotEmpty)
                _buildSearchResults()
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section du Mentor IA avec message dynamique
                    _buildMentorSection(),
                    SizedBox(height: 24),

                    // Section de bienvenue si pas de cours
                    if (_totalCourses == 0) _buildWelcomeSection(),

                    // Progression par sujet
                    if (_coursesBySubject.isNotEmpty) _buildProgressSection(),
                    SizedBox(height: 24),

                    // Cours récents
                    if (_courses.isNotEmpty) _buildRecentCourses(),
                    SizedBox(height: 24),

                    // Statistiques
                    _buildStatisticsSection(),
                    SizedBox(height: 32),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openUploadDialog,
        backgroundColor: Color(0xFF7B61FF),
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
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

  Widget _buildMentorSection() {
    String mentorMessage;
    if (_totalCourses == 0) {
      mentorMessage = AppTexts.mentorMessageNoCourses(context);
    } else if (_lastStudyDate == null ||
        DateTime.now().difference(_lastStudyDate!).inDays > 1) {
      mentorMessage = AppTexts.mentorMessageNoStudy(context, _totalCourses);
    } else {
      mentorMessage = AppTexts.mentorMessageStreak(context, _streakDays);
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7B61FF), Color(0xFF9378FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundImage: AssetImage(
                AvatarStore.selectedAvatarImg ?? 'assets/images/owl.png',
              ),
              backgroundColor: Colors.white,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AvatarStore.selectedAvatarName ??
                      AppTexts.professorOwl(context),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  mentorMessage,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GenerateCourse(),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFF6B6B),
                        minimumSize: Size(120, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            AppTexts.generateNotes(context),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
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
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: EdgeInsets.all(20),
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
          Icon(
            Icons.school,
            size: 60,
            color: Color(0xFF7B61FF).withOpacity(0.3),
          ),
          SizedBox(height: 16),
          Text(
            AppTexts.startLearningJourney(context),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 8),
          Text(
            AppTexts.uploadFirstCourseHint(context),
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF666666)),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _openUploadDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF7B61FF),
              minimumSize: Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Text(
              AppTexts.addFirstCourse(context),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    List<Widget> progressCards = [];

    _coursesBySubject.forEach((subject, courses) {
      if (subject.isNotEmpty) {
        progressCards.add(
          _buildSubjectProgressCard(
            subject: subject,
            progress: _calculateSubjectProgress(subject),
            courseCount: courses.length,
          ),
        );
      }
    });

    if (_courses.any(
      (course) => course.topic == null || course.topic!.isEmpty,
    )) {
      final generalCourses = _courses
          .where((c) => c.topic == null || c.topic!.isEmpty)
          .toList();
      progressCards.add(
        _buildSubjectProgressCard(
          subject: AppTexts.general(context),
          progress: _calculateSubjectProgress(AppTexts.general(context)),
          courseCount: generalCourses.length,
        ),
      );
    }

    if (progressCards.isEmpty) return SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppTexts.yourProgress(context),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF7B61FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppTexts.subjectsCount(context, _coursesBySubject.length),
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
        Wrap(spacing: 12, runSpacing: 12, children: progressCards),
      ],
    );
  }

  Widget _buildSubjectProgressCard({
    required String subject,
    required double progress,
    required int courseCount,
  }) {
    final color = _getSubjectColor(subject);

    return Container(
      width: 150,
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
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            subject,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Text(
            "$courseCount course${courseCount != 1 ? 's' : ''}",
            style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    final colors = [
      Color(0xFF7B61FF), // Math
      Color(0xFF4CAF50), // Physics
      Color(0xFFFF9800), // English
      Color(0xFF2196F3), // Science
      Color(0xFFE91E63), // History
      Color(0xFF9C27B0), // Art
    ];

    final hash = subject.hashCode;
    return colors[hash % colors.length];
  }

  Widget _buildRecentCourses() {
    final recentCourses = _courses.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppTexts.recentCourses(context),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigation vers l'écran de tous les cours
                // Navigator.pushNamed(context, '/Mycourse/');
              },
              child: Text(
                AppTexts.seeAll(context),
                style: TextStyle(
                  color: Color(0xFF7B61FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Column(
          children: recentCourses.map((course) {
            final color = _getSubjectColor(
              course.topic ?? AppTexts.general(context),
            );

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getFileTypeIcon(course.fileType),
                      color: color,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          course.topic ?? AppTexts.general(context),
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF666666),
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                course.fileType.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: color,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            if (course.uploadDate != null)
                              Text(
                                _formatDate(course.uploadDate!.toDate()),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF999999),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () =>
                            _handleViewFile(course.downloadURL, course.title),
                        icon: Icon(Icons.visibility, color: Color(0xFF7B61FF)),
                      ),
                      IconButton(
                        onPressed: () => generateAIExplanation(
                          course.downloadURL,
                          course.title,
                          course.topic ?? AppTexts.general(context),
                        ),
                        icon: Icon(Icons.auto_awesome, color: Colors.red),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') {
                            _confirmDeletion(context, course.id, course.fileID);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 20),
                                SizedBox(width: 10),
                                Text(AppTexts.delete(context)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

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

  Widget _buildStatisticsSection() {
    return Container(
      padding: EdgeInsets.all(20),
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
                AppTexts.learningStatistics(context),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              Icon(Icons.analytics, color: Color(0xFF7B61FF)),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                value: _totalCourses.toString(),
                label: AppTexts.coursesLabel(context),
                icon: Icons.library_books,
                color: Color(0xFF7B61FF),
              ),
              _buildStatItem(
                value: _coursesBySubject.length.toString(),
                label: AppTexts.subjectsLabel(context),
                icon: Icons.category,
                color: Color(0xFF4CAF50),
              ),
              _buildStatItem(
                value: _streakDays.toString(),
                label: AppTexts.dayStreak(context),
                icon: Icons.local_fire_department,
                color: Color(0xFFFF9800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
      ],
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        // Navigation vers les différentes pages
        if (index == 0) {
          // Home - déjà sur la page
        } else if (index == 1) {
          // My Courses
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/Mycourse/', (route) => false);
        } else if (index == 2) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/QuizzTab/', (route) => false);
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
    );
  }
}
