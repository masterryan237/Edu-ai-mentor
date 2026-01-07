import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduai_mentor/services/ai_service.dart';
import 'package:eduai_mentor/services/db_service.dart';
import 'package:eduai_mentor/services/file_service.dart';
import 'package:eduai_mentor/services/search_algolia_service.dart';
import 'package:eduai_mentor/services/storage_service.dart';
import 'package:eduai_mentor/utilis/app_texts_utils.dart';
import 'package:eduai_mentor/views/ai/explaining_page.dart';
import 'package:eduai_mentor/views/user_profile/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';

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
  String algolia_app_id = dotenv.env['ALGOLIA_APP_ID']!;
  String algolia_admin_key = dotenv.env['ALGOLIA_ADMIN_KEY']!;
  String algolia_search_key = dotenv.env['ALGOLIA_SEARCH_KEY']!;
  int _currentIndex = 1;
  final userid = FirebaseAuth.instance.currentUser?.uid;

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppTexts.networkError(context))));
      }
    }
  }

  void _getRoute(int index) {
    switch (index) {
      case 0:
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home/', (route) => false);
      case 1:
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/Mycourse/', (route) => false);

      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
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

      final response = await AiService().generateExplanation(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTexts.myCourses(context))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: _dbService.getUploadedCourses(userid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                // Affiche l'erreur réelle dans la console pour débugger
                print("FIREBASE ERROR: ${snapshot.error}");
                return Text("Error: Check console for index link");
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(AppTexts.noCourse(context)),
                );
              }

              // Liste des cours
              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final courseData = doc.data() as Map<String, dynamic>;

                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 3,
                      ),
                      leading: Icon(
                        Icons.description,
                        color: Colors.blue,
                        size: 40,
                      ),
                      title: Text(
                        courseData['title'] ?? 'Untitled',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(courseData['topic'] ?? 'No topic'),
                      trailing: Wrap(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _handleViewFile(
                                courseData['downloadURL'],
                                courseData['title'],
                              );
                            },
                            child: const Text("View"),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                            ),
                            label: Text("AI"), // Icône style IA
                            onPressed: () {
                              generateAIExplanation(
                                courseData['downloadURL'],
                                courseData['title'] ?? 'Cours',
                                courseData["topic"],
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'delete') {
                                _confirmDeletion(
                                  context,
                                  doc.id,
                                  courseData['fileID'],
                                );
                              }
                            },
                            itemBuilder: (context) => [
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
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _getRoute(_currentIndex);
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
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
    );
  }
}
