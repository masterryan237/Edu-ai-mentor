import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduai_mentor/services/ai_service.dart';
import 'package:eduai_mentor/services/db_service.dart';
import 'package:eduai_mentor/services/file_service.dart';
import 'package:eduai_mentor/services/search_algolia_service.dart';
import 'package:eduai_mentor/services/storage_service.dart';
import 'package:eduai_mentor/utilis/app_texts_utils.dart';
import 'package:eduai_mentor/views/ai/explaining_page.dart';
import 'package:eduai_mentor/views/ai/generate_course.dart';
import 'package:eduai_mentor/views/user_profile/profile_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';

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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppTexts.networkError(context))));
      }
    }
  }

  void _saveNewCourse(String? localPath, PlatformFile? fileInfo) async {
    // 1. On fige les valeurs MAINTENANT
    final name = _courseName.text.trim();
    final topic = _topicName.text.trim();

    if (localPath == null || fileInfo == null || name.isEmpty) {
      // ... ton code d'erreur de champs vides
      return;
    }

    // 2. Affichage du loading
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 3. On passe les variables figées (name, topic) et non les controllers
      await _dbService.saveNewCourse(localPath, fileInfo, name, topic);

      if (mounted) {
        Navigator.of(context).pop(); // Ferme le loading
        Navigator.of(context).pop(); // Ferme le formulaire d'upload

        // 4. On nettoie SEULEMENT après confirmation de réussite
        _courseName.clear();
        _topicName.clear();
        setState(() => _fileInfos = null);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTexts.uploadSuccess(context)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Ferme le loading seulement
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")), // Affiche l'erreur réelle
        );
      }
    }
  }

  void _getRoute(int index) {
    if (index == _currentIndex && index == 0) return;
    switch (index) {
      case 0:
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home/', (route) => false);
        break;
      case 1:
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/Mycourse/', (route) => false);
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
        break;
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
        // --- NETTOYAGE FINAL DES SYMBOLES RÉSIDUELS ---
        String cleanExplanation = response.text!.replaceAll(
          RegExp(r'[\*\#\_]'),
          '',
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExplainingPage(
              title: title,
              explanation: cleanExplanation, // Envoi du texte propre
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

  late final HitsSearcher _searcher;
  bool _isSearching = false;
  final FocusNode _searchFocusNode = FocusNode();

  Widget _buildSearchResults() {
    return StreamBuilder<SearchResponse>(
      stream: _searcher.responses,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(AppTexts.searchError(context)));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final hits = snapshot.data?.hits.toList() ?? [];
        if (hits.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  const Icon(Icons.search_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    AppTexts.noResults(context, _searchText.text),
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: hits.map((hit) {
              final data = hit;
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.description,
                    color: Colors.blue,
                    size: 40,
                  ),
                  title: Text(
                    data['title'] ?? 'Untitled',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(data['topic'] ?? 'No topic'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            _handleViewFile(data['downloadURL'], data['title']),
                        child: const Text("View"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => generateAIExplanation(
                          data['downloadURL'],
                          data['title'],
                          data['topic'],
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildNormalHome() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              OutlinedButton(
                onPressed: () {
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
                                      labelText: AppTexts.courseNameLabel(
                                        context,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    controller: _topicName,
                                    decoration: InputDecoration(
                                      labelText: AppTexts.topicLabel(context),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final picked = await _fileService
                                          .pickFile();
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
                                  Text(
                                    _fileInfos ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _saveNewCourse(file?.path, file),
                                    label: Text(AppTexts.uploadBtn(context)),
                                    icon: const Icon(Icons.upload_file),
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.blue,
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
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue, width: 2.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 40,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.add, color: Colors.grey, size: 50),
                    Text(
                      AppTexts.uploadNewCourse(context),
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GenerateCourse(),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(AppTexts.generateNotes(context)),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Text(
                  AppTexts.recentCourses(context),
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: _dbService.getLatestCourses(userid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Error loading courses");
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(AppTexts.noCourseYet(context)),
                    );
                  }

                  return Column(
                    children: snapshot.data!.docs.map((doc) {
                      final courseData = doc.data() as Map<String, dynamic>;
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.description,
                            color: Colors.blue,
                            size: 40,
                          ),
                          title: Text(
                            courseData['title'] ?? 'Untitled',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(courseData['topic'] ?? 'No topic'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _handleViewFile(
                                  courseData['downloadURL'],
                                  courseData['title'],
                                ),
                                icon: const Icon(
                                  Icons.visibility,
                                  color: Colors.blue,
                                ),
                              ),
                              IconButton(
                                onPressed: () => generateAIExplanation(
                                  courseData['downloadURL'],
                                  courseData['title'],
                                  courseData['topic'],
                                ),
                                icon: const Icon(
                                  Icons.auto_awesome,
                                  color: Colors.red,
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (v) => _confirmDeletion(
                                  context,
                                  doc.id,
                                  courseData['fileID'],
                                ),
                                itemBuilder: (c) => [
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        SizedBox(width: 10),
                                        Text("Delete"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/Mycourse/', (route) => false),
          icon: const Icon(Icons.book),
          label: Text(AppTexts.viewAllCourses(context)),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _courseName = TextEditingController();
    _topicName = TextEditingController();
    _searchText = TextEditingController();
    _searcher = HitsSearcher(
      applicationID: algolia_app_id,
      apiKey: algolia_search_key,
      indexName: 'courses',
    );
    _searcher.applyState(
      (state) => state.copyWith(facetFilters: ['userId:$userid']),
    );
  }

  @override
  void dispose() {
    _courseName.dispose();
    _topicName.dispose();
    _searchText.dispose();
    _searcher.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTexts.home(context)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _getRoute(index);
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppTexts.home(context),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: AppTexts.myCourses(context),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppTexts.profile(context),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          if (_isSearching) {
            setState(() => _isSearching = false);
            _searchFocusNode.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchText,
                        focusNode: _searchFocusNode,
                        onTap: () => setState(() => _isSearching = true),
                        onChanged: (value) {
                          setState(() => _isSearching = value.isNotEmpty);
                          _searcher.applyState(
                            (state) => state.copyWith(query: value),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: AppTexts.searchHint(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => FocusScope.of(context).unfocus(),
                      icon: const Icon(Icons.search, color: Colors.white),
                      style: IconButton.styleFrom(backgroundColor: Colors.blue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _isSearching ? _buildSearchResults() : _buildNormalHome(),
            ],
          ),
        ),
      ),
    );
  }
}
