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
              'createdAt': DateTime.now().millisecondsSinceEpoch,
            }),
          )
          .timeout(const Duration(seconds: 20));
      print('Course indexed to Algolia: $docId');
    } catch (e) {
      print("Algolia Indexing failed: $e");
    }
  }

  Future<void> deleteCourseFromALgolia(String docId, String fileID) async {
    const String indexName = 'courses';
    final algoliaUrl = Uri.parse(
      'https://$algolia_app_id.algolia.net/1/indexes/$indexName/$fileID',
    );
    try {
      await http
          .delete(
            algoliaUrl,
            headers: {
              'X-Algolia-Application-Id': algolia_app_id,
              'X-Algolia-API-Key': algolia_admin_key,
            },
          )
          .timeout(const Duration(seconds: 30));
      print('Course deleted from Algolia: $fileID');
    } catch (e) {
      print("Algolia deletion failed: $e");
      rethrow;
    }
  }

  // NOUVELLE FONCTION : Mettre à jour un cours dans Algolia
  Future<void> updateCourseInAlgolia(
    String docId,
    Map<String, dynamic> updates,
  ) async {
    try {
      const String indexName = 'courses';
      final url = Uri.parse(
        'https://$algolia_app_id.algolia.net/1/indexes/$indexName/$docId',
      );

      // Récupérer d'abord l'objet existant pour conserver les autres champs
      final getUrl = Uri.parse(
        'https://$algolia_app_id.algolia.net/1/indexes/$indexName/$docId',
      );

      final getResponse = await http
          .get(
            getUrl,
            headers: {
              'X-Algolia-Application-Id': algolia_app_id,
              'X-Algolia-API-Key': algolia_admin_key,
            },
          )
          .timeout(const Duration(seconds: 15));

      Map<String, dynamic> existingData = {};
      if (getResponse.statusCode == 200) {
        existingData = jsonDecode(getResponse.body);
      }

      // Fusionner les données existantes avec les mises à jour
      final mergedData = {
        ...existingData,
        ...updates,
        'objectID': docId,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
        'userId': userid, // Conserver l'userId
      };

      // Supprimer les champs null ou vides pour éviter les erreurs
      mergedData.removeWhere((key, value) => value == null || value == '');

      await http
          .put(
            url,
            headers: {
              'X-Algolia-Application-Id': algolia_app_id,
              'X-Algolia-API-Key': algolia_admin_key,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(mergedData),
          )
          .timeout(const Duration(seconds: 20));

      print('Course updated in Algolia: $docId');
    } catch (e) {
      print("Algolia update failed: $e");
      rethrow;
    }
  }

  // Fonction utilitaire optionnelle : Rechercher un cours par son ID
  Future<Map<String, dynamic>?> getCourseFromAlgolia(String docId) async {
    try {
      const String indexName = 'courses';
      final url = Uri.parse(
        'https://$algolia_app_id.algolia.net/1/indexes/$indexName/$docId',
      );

      final response = await http
          .get(
            url,
            headers: {
              'X-Algolia-Application-Id': algolia_app_id,
              'X-Algolia-API-Key': algolia_admin_key,
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        print('Course not found in Algolia: $docId');
        return null;
      } else {
        throw Exception('Failed to get course: ${response.statusCode}');
      }
    } catch (e) {
      print("Algolia get failed: $e");
      return null;
    }
  }
}
