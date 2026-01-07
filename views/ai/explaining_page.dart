import 'package:eduai_mentor/services/file_service.dart';
import 'package:eduai_mentor/utilis/app_texts_utils.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

class ExplainingPage extends StatelessWidget {
  final String title;
  final String explanation;
  final String topic;

  ExplainingPage({
    super.key,
    required this.title,
    required this.explanation,
    required this.topic,
  });
  final _fileService = FileService();
  Future<void> _downloadPDF(BuildContext context) async {
    // 1. Afficher le loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.blue)),
    );

    try {
      // 2. Créer le document PDF
      String fileName;
      String path;
      (fileName, path) = await _fileService.constructPdfFile(
        title,
        explanation,
      );

      // 5. Fermer le loader (Vérification context.mounted)
      if (context.mounted) Navigator.pop(context);

      // 6. OUVERTURE AUTOMATIQUE
      await OpenFilex.open(path);

      // 7. Notification
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTexts.pdfSaved(context, fileName)),
            action: SnackBarAction(
              label: AppTexts.open(context),
              onPressed: () => OpenFilex.open(path),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Fermer le loader en cas d'erreur
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTexts.explanationTitle(context, title))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => _downloadPDF(context),
              icon: const Icon(Icons.download),
              label: Text(AppTexts.downloadAsPdf(context)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
            SelectableText(
              // Permet à l'utilisateur de copier le texte
              explanation,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
