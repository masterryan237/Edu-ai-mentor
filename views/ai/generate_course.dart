import 'package:eduai_mentor/services/ai_service.dart';
import 'package:eduai_mentor/services/db_service.dart';
import 'package:eduai_mentor/services/file_service.dart';
import 'package:eduai_mentor/utilis/app_texts_utils.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Pour le téléchargement

class GenerateCourse extends StatefulWidget {
  const GenerateCourse({super.key});

  @override
  State<GenerateCourse> createState() => _GenerateCourseState();
}

class _GenerateCourseState extends State<GenerateCourse> {
  final _aiService = AiService();
  final _fileService = FileService();
  String generatedContent = "";
  String? downloadUrl;
  bool isGenerating = false;
  late final TextEditingController _topicController;

  Future<void> startGeneration(String description) async {
    if (description.isEmpty) return;

    // Affichage du Loading (Inchangé)
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppTexts.generatingWait(context)),
        content: SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    try {
      // 1. Génération du contenu avec Gemini (PROMPT MODIFIÉ POUR ÉVITER LES SYMBOLES)
      String courseText = await _aiService.startCourseGeneration(
        description,
        context,
      );
      // 2. Création du PDF (Version multipage)
      List<int> bytes = await _fileService.createPdfFile(courseText);

      // 3. Upload vers Supabase Storage (Inchangé)
      String publicUrl = await DbService().saveGeneratedCourseToFirestore(
        description,
        bytes,
      );

      if (mounted) Navigator.pop(context);

      setState(() {
        generatedContent = courseText;
        downloadUrl = publicUrl;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppTexts.courseReady(context))));
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error : $e")));
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTexts.generateTitle(context))),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
          children: [
            TextField(
              controller: _topicController,
              decoration: InputDecoration(
                hintText: AppTexts.topicHint(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                ),
              ),
            ),

            // Bouton de téléchargement (s'affiche seulement si disponible)
            if (downloadUrl != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    final Uri url = Uri.parse(downloadUrl!);
                    await launchUrl(url);
                  },
                  icon: const Icon(Icons.download, color: Colors.green),
                  label: Text(
                    AppTexts.downloadPdf(context),
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton.icon(
                onPressed: () => startGeneration(_topicController.text),
                icon: const Icon(Icons.auto_awesome),
                label: Text(AppTexts.aiButton(context)),
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    generatedContent.isEmpty
                        ? AppTexts.placeholder(context)
                        : generatedContent,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
