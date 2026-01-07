import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SearchAlgoliaService {
  final algolia_app_id = dotenv.env['ALGOLIA_APP_ID']!;
  final algolia_admin_key = dotenv.env['ALGOLIA_ADMIN_KEY']!;
  final userid = FirebaseAuth.instance.currentUser?.uid;

  //enregistrer un cours dans algolia pour permettre sa recherche plutard
  Future<void> indexToAlgolia(
    String title,
    String topic,
    String downloadURL,
    String docId,
  ) async {
    try {
      const String indexName = 'courses';
      final url = Uri.parse(
        'https://$algolia_app_id.algolia.net/1/indexes/$indexName/$docId',
      );

      await http
          .put(
            url,
            headers: {
              'X-Algolia-Application-Id': algolia_app_id,
              'X-Algolia-API-Key': algolia_admin_key,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'title': title,
              'topic': topic,
              'downloadURL': downloadURL,
              'userId': userid,
              'objectID': docId,
            }),
          )
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      print("Algolia Indexing failed: $e");
    }
  }

  Future<void> deleteCourseFromALgolia(String docId, String fileID) async {
    const String indexName = 'courses';
    final algoliaUrl = Uri.parse(
      'https://$algolia_app_id.algolia.net/1/indexes/$indexName/$fileID',
    );
    await http
        .delete(
          algoliaUrl,
          headers: {
            'X-Algolia-Application-Id': algolia_app_id,
            'X-Algolia-API-Key': algolia_admin_key,
          },
        )
        .timeout(const Duration(seconds: 10));
  }
}
