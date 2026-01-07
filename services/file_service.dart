import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:url_launcher/url_launcher.dart';

//Creation de pdf a partir d'un texte
class FileService {
  Future<List<int>> createPdfFile(String courseText) async {
    // 2. Création du PDF (Version multipage)
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();

    // Utilisation d'une police plus standard pour éviter les problèmes de caractères
    PdfTextElement textElement = PdfTextElement(
      text: courseText,
      font: PdfStandardFont(PdfFontFamily.helvetica, 12),
    );

    PdfLayoutFormat layoutFormat = PdfLayoutFormat(
      layoutType: PdfLayoutType.paginate,
      breakType: PdfLayoutBreakType.fitPage,
    );

    textElement.draw(
      page: page,
      bounds: Rect.fromLTWH(
        0,
        0,
        page.getClientSize().width,
        page.getClientSize().height - 20,
      ),
      format: layoutFormat,
    );

    final List<int> bytes = await document.save();
    document.dispose();
    return bytes;
  }

  //Choisir un fichier a uploader

  Future<dynamic> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      final pickedFile = result?.files.first;
      final tempDir = await getTemporaryDirectory();
      String cleanName = pickedFile!.name.replaceAll(RegExp(r'[^\w\.]'), '_');
      // 2. Créer le chemin de destination
      final String newPath = '${tempDir.path}/$cleanName';

      // 3. Utiliser .copy() pour dupliquer le fichier WhatsApp vers ton dossier
      final File copiedFile = await File(pickedFile.path!).copy(newPath);

      // 4. Retourner le fichier avec le nouveau chemin "autorisé"
      return PlatformFile(
        path: copiedFile.path,
        name: cleanName,
        size: pickedFile.size,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> handleViewFile(String? url, String fileName) async {
    final Uri uri = Uri.parse(url!);

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<(String, String)> constructPdfFile(
    String title,
    String explanation,
  ) async {
    PdfDocument document = PdfDocument();
    final page = document.pages.add();
    final double pageWidth = page.getClientSize().width;

    page.graphics.drawString(
      "AI Explanation: $title",
      PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold),
      bounds: Rect.fromLTWH(0, 0, pageWidth, 30),
    );

    PdfTextElement element = PdfTextElement(
      text: explanation,
      font: PdfStandardFont(PdfFontFamily.helvetica, 12),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
    );

    element.draw(page: page, bounds: Rect.fromLTWH(0, 50, pageWidth, 0))!;

    // 3. Sauvegarder
    List<int> bytes = await document.save();
    document.dispose();

    // 4. NETTOYAGE DU NOM ET CHEMIN (Important !)
    final directory = await getApplicationDocumentsDirectory();
    // On remplace les caractères spéciaux et espaces par des underscores
    final safeTitle = title
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(' ', '_');
    final fileName =
        "Explanation_${safeTitle}_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final path = "${directory.path}/$fileName";

    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return (fileName, path);
  }
}
