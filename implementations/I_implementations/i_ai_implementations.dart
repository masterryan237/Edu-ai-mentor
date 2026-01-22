// lib/interfaces/iai_service_implementation.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduai_mentor/models/quizz_model.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

abstract class IaiServiceImplementation {
  Future<String> startCourseGeneration(
    String description,
    BuildContext context,
  );

  Future<GenerateContentResponse> generateExplanation(
    String textToAnalyze,
    BuildContext context,
  );

  Future<List<QuizQuestion>> generateQuizz(
    String description,
    BuildContext context,
  );

  Future<Map<String, dynamic>> generateQuizFromContent(
    String textToAnalyze,
    BuildContext context, {
    String? courseTitle,
    String? courseTopic,
    String? courseId,
  });

  Future<Map<String, dynamic>> generateQuizFromPdfUrl(
    String pdfUrl,
    BuildContext context, {
    required String courseTitle,
    required String courseTopic,
    required String courseId,
  });

  Future<String> extractTextFromPdf(String pdfUrl);

  Stream<QuerySnapshot> getUserQuizzes();
  Future<DocumentSnapshot> getQuizById(String quizId);
  Future<void> updateQuizStats(String quizId, double score, int duration);
}
