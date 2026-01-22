import 'package:eduai_mentor/services/file_service.dart';
import 'package:eduai_mentor/utilis/app_texts_utils.dart';
import 'package:eduai_mentor/views/user_init_infos/avatar_store.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eduai_mentor/views/user_init_infos/avatar_picker.dart';

class ExplainingPage extends StatefulWidget {
  final String title;
  final String explanation;
  final String topic;

  const ExplainingPage({
    super.key,
    required this.title,
    required this.explanation,
    required this.topic,
  });

  @override
  State<ExplainingPage> createState() => _ExplainingPageState();
}

class _ExplainingPageState extends State<ExplainingPage> {
  final _fileService = FileService();
  final _auth = FirebaseAuth.instance;
  bool _isDownloading = false;
  bool _showFullText = false;

  Future<void> _downloadPDF(BuildContext context) async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      // 1. Créer le document PDF
      String fileName;
      String path;
      (fileName, path) = await _fileService.constructPdfFile(
        widget.title,
        widget.explanation,
      );

      // 2. OUVERTURE AUTOMATIQUE
      await OpenFilex.open(path);

      // 3. Notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppTexts.pdfSaved(context, fileName),
                      style: TextStyle(color: Color(0xFF333333)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => OpenFilex.open(path),
                    child: Text(
                      AppTexts.open(context),
                      style: TextStyle(
                        color: Color(0xFF7B61FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 10),
                Text(AppTexts.errorMessage(context, e.toString())),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Widget _buildContentPreview() {
    if (widget.explanation.length <= 500 || _showFullText) {
      return SelectableText(
        widget.explanation,
        style: TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF333333)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          '${widget.explanation.substring(0, 500)}...',
          style: TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF333333)),
        ),
        SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            setState(() {
              _showFullText = true;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFF7B61FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              AppTexts.showMore(context),
              style: TextStyle(
                color: Color(0xFF7B61FF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
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
              AppTexts.aiExplanation(context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              widget.title,
              style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
      body: Column(
        children: [
          // En-tête avec informations du sujet
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
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
                    color: Color(0xFF7B61FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFF7B61FF),
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
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
                        widget.topic,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte d'explication principale
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
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
                                color: Color(0xFF4CAF50).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF4CAF50),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              AppTexts.aiGeneratedExplanation(context),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        _buildContentPreview(),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Bouton de téléchargement
                  Container(
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
                        color: Color(0xFF2196F3).withOpacity(0.2),
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
                                color: Color(0xFF2196F3).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.save_alt,
                                color: Color(0xFF2196F3),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppTexts.saveExplanation(context),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  Text(
                                    AppTexts.downloadForOffline(context),
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
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isDownloading
                                ? null
                                : () => _downloadPDF(context),
                            icon: _isDownloading
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(Icons.download, size: 20),
                            label: Text(
                              _isDownloading
                                  ? AppTexts.creatingPdf(context)
                                  : AppTexts.downloadAsPdf(context),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),

                  // Informations supplémentaires
                  Container(
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
                                Icons.info_outline,
                                color: Color(0xFFFF9800),
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              AppTexts.aboutAiExplanation(context),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            _buildInfoItem(
                              icon: Icons.text_fields,
                              text: AppTexts.wordsCount(
                                context,
                                widget.explanation.split(' ').length,
                              ),
                            ),
                            SizedBox(width: 12),
                            _buildInfoItem(
                              icon: Icons.timelapse,
                              text: AppTexts.fileSize(
                                context,
                                (widget.explanation.length / 1000)
                                    .toStringAsFixed(1),
                              ),
                            ),
                            SizedBox(width: 12),
                            _buildInfoItem(
                              icon: Icons.format_quote,
                              text: AppTexts.aiGenerated(context),
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
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xFFF8F9FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Color(0xFF666666)),
            SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
          ],
        ),
      ),
    );
  }
}
