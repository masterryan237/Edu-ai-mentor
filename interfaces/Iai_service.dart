// lib/interfaces/iai_service.dart
import 'package:eduai_mentor/implementations/I_implementations/i_ai_implementations.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/quizz_model.dart';

abstract class IaiService {
  // Génération de cours
  Future<String> startCourseGeneration(
    String description,
    BuildContext context,
  );

  // Génération d'explications
  Future<GenerateContentResponse> generateExplanation(
    String textToAnalyze,
    BuildContext context,
  );

  // Génération de quiz simple
  Future<List<QuizQuestion>> generateQuizz(
    String description,
    BuildContext context,
  );

  // Génération de quiz depuis contenu
  Future<Map<String, dynamic>> generateQuizFromContent(
    String textToAnalyze,
    BuildContext context, {
    String? courseTitle,
    String? courseTopic,
    String? courseId,
  });

  // Génération de quiz depuis PDF
  Future<Map<String, dynamic>> generateQuizFromPdfUrl(
    String pdfUrl,
    BuildContext context, {
    required String courseTitle,
    required String courseTopic,
    required String courseId,
  });

  // Extraction de texte PDF
  Future<String> extractTextFromPdf(String pdfUrl);

  // Gestion des quizzes
  Stream<QuerySnapshot> getUserQuizzes();
  Future<DocumentSnapshot> getQuizById(String quizId);
  Future<void> updateQuizStats(String quizId, double score, int duration);

  // Bridge-specific method
  void setImplementation(IaiServiceImplementation implementation);
}
