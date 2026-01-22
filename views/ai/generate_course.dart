import 'package:eduai_mentor/services/ai_service.dart';
import 'package:eduai_mentor/services/db_service.dart';
import 'package:eduai_mentor/services/file_service.dart';
import 'package:eduai_mentor/utilis/app_texts_utils.dart';
import 'package:eduai_mentor/views/user_init_infos/avatar_store.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eduai_mentor/views/user_init_infos/avatar_picker.dart';

class GenerateCourse extends StatefulWidget {
  const GenerateCourse({super.key});

  @override
  State<GenerateCourse> createState() => _GenerateCourseState();
}

class _GenerateCourseState extends State<GenerateCourse> {
  final _aiService = AiService();
  final _fileService = FileService();
  final _auth = FirebaseAuth.instance;
  String generatedContent = "";
  String? downloadUrl;
  bool isGenerating = false;
  bool _isLoading = false;
  late final TextEditingController _topicController;

  Future<void> startGeneration(String description) async {
    if (description.isEmpty) {
      _showSnackBar(AppTexts.pleaseEnterDescription(context));
      return;
    }

    setState(() {
      _isLoading = true;
      generatedContent = "";
      downloadUrl = null;
    });

    try {
      // 1. Génération du contenu avec Gemini
      String courseText = await _aiService.startCourseGeneration(
        description,
        context,
      );

      // 2. Création du PDF (Version multipage)
      List<int> bytes = await _fileService.createPdfFile(courseText);

      // 3. Upload vers Supabase Storage
      String publicUrl = await DbService().saveGeneratedCourseToFirestore(
        description,
        bytes,
      );

      setState(() {
        _isLoading = false;
        generatedContent = courseText;
        downloadUrl = publicUrl;
      });

      _showSnackBar(AppTexts.courseGeneratedSuccess(context), Colors.green);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog("${AppTexts.failedToGenerateCourse(context)}: $e");
    }
  }

  void _showSnackBar(String message, [Color color = Colors.red]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 10),
            Text(
              AppTexts.error(context),
              style: TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(error, style: TextStyle(color: Color(0xFF666666))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppTexts.close(context),
              style: TextStyle(color: Color(0xFF7B61FF)),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  void initState() {
    _topicController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Widget _buildLoadingOverlay() {
    if (!_isLoading) return SizedBox();

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B61FF)),
                ),
              ),
              SizedBox(height: 12),
              Text(
                AppTexts.aiGenerating(context),
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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
              AppTexts.aiGeneratingCourse(context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              AppTexts.createWithAiAssistant(context),
              style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close, color: Color(0xFF666666)),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section de description
                Container(
                  padding: EdgeInsets.all(16),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF7B61FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF7B61FF),
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              AppTexts.describeWhatYouWantToLearn(context),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _topicController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: AppTexts.describeCourseExample(context),
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Color(0xFFF8F9FF),
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        AppTexts.beSpecificForBetterResults(context),
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Bouton de génération
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => startGeneration(_topicController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF7B61FF),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 20),
                        SizedBox(width: 10),
                        Text(
                          AppTexts.generateCourseWithAi(context),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Bouton de téléchargement
                if (downloadUrl != null)
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: Color(0xFF4CAF50).withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(0xFF4CAF50).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.download_done,
                                color: Color(0xFF4CAF50),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppTexts.courseReady(context),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  Text(
                                    AppTexts.aiCourseReadyForDownload(context),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final Uri url = Uri.parse(downloadUrl!);
                              await launchUrl(url);
                            },
                            icon: Icon(Icons.download, size: 18),
                            label: Text(AppTexts.downloadPdf(context)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: downloadUrl != null ? 20 : 0),

                // Contenu généré
                if (generatedContent.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(16),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(0xFFFF9800).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.description,
                                color: Color(0xFFFF9800),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              AppTexts.generatedContentPreview(context),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF8F9FF),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              generatedContent,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF333333),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          AppTexts.scrollToPreviewFullContent(context),
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Section d'instructions si vide
                if (generatedContent.isEmpty && !_isLoading)
                  Container(
                    margin: EdgeInsets.only(top: 40),
                    padding: EdgeInsets.all(24),
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
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Color(0xFF7B61FF).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.auto_awesome_motion,
                            size: 50,
                            color: Color(0xFF7B61FF),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          AppTexts.aiCourseGenerator(context),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          AppTexts.describeAndAiWillCreate(context),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                            height: 1.6,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFeatureItem(
                              icon: Icons.lightbulb,
                              text: AppTexts.smartAi(context),
                              color: Color(0xFFFF9800),
                            ),
                            _buildFeatureItem(
                              icon: Icons.speed,
                              text: AppTexts.fastGeneration(context),
                              color: Color(0xFF4CAF50),
                            ),
                            _buildFeatureItem(
                              icon: Icons.download,
                              text: AppTexts.pdfExport(context),
                              color: Color(0xFF2196F3),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: 40),
              ],
            ),
          ),

          // Overlay de chargement
          _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}
