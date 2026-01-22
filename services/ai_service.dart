// lib/services/ai_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduai_mentor/implementations/I_implementations/i_ai_implementations.dart';
import 'package:eduai_mentor/interfaces/Iai_service.dart';

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/quizz_model.dart';

class AiService implements IaiService {
  IaiServiceImplementation? _implementation;

  AiService({IaiServiceImplementation? implementation}) {
    _implementation = implementation;
  }

  @override
  void setImplementation(IaiServiceImplementation implementation) {
    _implementation = implementation;
  }

  void _checkImplementation() {
    if (_implementation == null) {
      throw Exception("No implementation set for AiService");
    }
  }

  @override
  Future<String> startCourseGeneration(
    String description,
    BuildContext context,
  ) async {
    _checkImplementation();
    return await _implementation!.startCourseGeneration(description, context);
  }

  @override
  Future<GenerateContentResponse> generateExplanation(
    String textToAnalyze,
    BuildContext context,
  ) async {
    _checkImplementation();
    return await _implementation!.generateExplanation(textToAnalyze, context);
  }

  @override
  Future<List<QuizQuestion>> generateQuizz(
    String description,
    BuildContext context,
  ) async {
    _checkImplementation();
    return await _implementation!.generateQuizz(description, context);
  }

  @override
  Future<Map<String, dynamic>> generateQuizFromContent(
    String textToAnalyze,
    BuildContext context, {
    String? courseTitle,
    String? courseTopic,
    String? courseId,
  }) async {
    _checkImplementation();
    return await _implementation!.generateQuizFromContent(
      textToAnalyze,
      context,
      courseTitle: courseTitle,
      courseTopic: courseTopic,
      courseId: courseId,
    );
  }

  @override
  Future<Map<String, dynamic>> generateQuizFromPdfUrl(
    String pdfUrl,
    BuildContext context, {
    required String courseTitle,
    required String courseTopic,
    required String courseId,
  }) async {
    _checkImplementation();
    return await _implementation!.generateQuizFromPdfUrl(
      pdfUrl,
      context,
      courseTitle: courseTitle,
      courseTopic: courseTopic,
      courseId: courseId,
    );
  }

  @override
  Future<String> extractTextFromPdf(String pdfUrl) async {
    _checkImplementation();
    return await _implementation!.extractTextFromPdf(pdfUrl);
  }

  @override
  Stream<QuerySnapshot> getUserQuizzes() {
    _checkImplementation();
    return _implementation!.getUserQuizzes();
  }

  @override
  Future<DocumentSnapshot> getQuizById(String quizId) async {
    _checkImplementation();
    return await _implementation!.getQuizById(quizId);
  }

  @override
  Future<void> updateQuizStats(
    String quizId,
    double score,
    int duration,
  ) async {
    _checkImplementation();
    return await _implementation!.updateQuizStats(quizId, score, duration);
  }
}
