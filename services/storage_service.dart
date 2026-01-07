import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _bucket = 'edu-ai-files';
  final userid = FirebaseAuth.instance.currentUser!.uid;
  //enregistrer le document de cours uploadé sur le bucket créé dans Supabase
  Future<String?> uploadFileToStorage(String localPath, String fileName) async {
    final userid = FirebaseAuth.instance.currentUser?.uid;
    try {
      final file = File(localPath);
      final supabase = Supabase.instance.client;

      await supabase.storage
          .from(_bucket)
          .upload('uploads/$userid/$fileName', file);

      final String publicUrl = supabase.storage
          .from(_bucket)
          .getPublicUrl('uploads/$userid/$fileName');
      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteCourseFromSupabase(String docId, String fileID) async {
    final supabasePath = 'uploads/$userid/$fileID';
    await Supabase.instance.client.storage
        .from(_bucket)
        .remove([supabasePath])
        .timeout(const Duration(seconds: 10));
  }

  Future<(String, String)> saveGeneratedCourseToSupabase(
    String fileName,
    List<int> bytes,
  ) async {
    final fileName = "course_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final supabase = Supabase.instance.client;
    await supabase.storage
        .from(_bucket)
        .uploadBinary(
          fileName,
          Uint8List.fromList(bytes),
          fileOptions: const FileOptions(contentType: 'application/pdf'),
        );

    final String publicUrl = supabase.storage
        .from(_bucket)
        .getPublicUrl(fileName);
    return (fileName, publicUrl);
  }
}
