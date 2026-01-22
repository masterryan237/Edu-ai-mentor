// lib/services/ai_service_implementation.dart
import 'dart:convert';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduai_mentor/implementations/I_implementations/i_ai_implementations.dart';
import 'package:eduai_mentor/models/quizz_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';

class AiServiceImplementation implements IaiServiceImplementation {
  late GenerativeModel _model;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AiServiceImplementation() {
    _initializeModel();
  }

  void _initializeModel() {
    _model = GenerativeModel(
      model: "gemini-2.5-flash",
      apiKey: dotenv.env['GEMINI_API_KEY']!,
    );
  }

  @override
  Future<String> startCourseGeneration(
    String description,
    BuildContext context,
  ) async {
    final locale = Localizations.localeOf(context).languageCode;
    final isFrench = locale == 'fr';

    final prompt =
        """
    ${isFrench ? "Tu es un assistant d'enseignement senior expert en pédagogie." : "You are a senior teaching assistant expert in pedagogy."}
    
    ${isFrench ? "Crée un cours complet, approfondi et structuré sur : $description." : "Create a complete, in-depth, and structured course on: $description."}

    ${isFrench ? "DIRECTIVES DE STRUCTURE :" : "STRUCTURAL GUIDELINES :"}
    1. INTRODUCTION : ${isFrench ? "Contexte et importance du sujet." : "Context and importance of the subject."}
    2. OBJECTIFS : ${isFrench ? "Ce que l'étudiant saura faire après le cours." : "What the student will be able to do after the course."}
    3. MODULES DÉTAILLÉS : ${isFrench ? "Développe chaque concept avec précision." : "Develop each concept with precision."}
    4. EXEMPLES CONCRETS : ${isFrench ? "Illustre avec des cas réels." : "Illustrate with real-world cases."}
    5. RÉSUMÉ ET CONCLUSION.

    ${isFrench ? "RÈGLES DE FORMATAGE (CRUCIAL) :" : "FORMATTING RULES (CRUCIAL) :"}
    - ${isFrench ? "NE JAMAIS UTILISER de symboles Markdown (pas d'astérisques **, pas de dièses #, pas de tirets -)." : "NEVER USE Markdown symbols (no asterisks **, no hash symbols #, no hyphens -)."}
    - ${isFrench ? "Écris les titres en MAJUSCULES." : "Write headings in ALL CAPITALS."}
    - ${isFrench ? "Utilise uniquement des chiffres (1., 2.) pour les listes." : "Use only numbers (1., 2.) for lists."}
    - ${isFrench ? "Sépare chaque section par deux sauts de ligne." : "Separate each section with two line breaks."}
    - ${isFrench ? "RÉPONDRE EXCLUSIVEMENT EN FRANÇAIS." : "RESPOND EXCLUSIVELY IN ENGLISH."}
  """;

    final response = await _model.generateContent([Content.text(prompt)]);

    String courseText =
        response.text ??
        (isFrench ? "Erreur de génération" : "Generation Error");
    courseText = courseText.replaceAll(RegExp(r'[\*\#\_]'), '');

    return courseText;
  }

  @override
  Future<GenerateContentResponse> generateExplanation(
    String textToAnalyze,
    BuildContext context,
  ) async {
    final locale = Localizations.localeOf(context).languageCode;
    final isFrench = locale == 'fr';

    final prompt =
        """
${isFrench ? "Tu es un tuteur pédagogique expert. Voici le contenu d'une leçon ou d'un exercice :" : "You are an expert teaching tutor. Here is the content of a lesson or an exercise:"}

$textToAnalyze

${isFrench ? "TES MISSIONS :" : "YOUR MISSIONS:"}
1. ${isFrench ? "ANALYSE : Identifie et explique les concepts clés de manière approfondie mais simple." : "ANALYSIS: Identify and explain key concepts in depth but simply."}
2. ${isFrench ? "EXAMEN : S'il s'agit d'un examen ou d'un test, résous-le dans son intégralité avec des explications pour chaque réponse." : "EXAM: If this is an exam or test, solve it in its entirety with explanations for each answer."}
3. ${isFrench ? "PÉDAGOGIE : Utilise des analogies si nécessaire pour faciliter la compréhension." : "PEDAGOGY: Use analogies if necessary to facilitate understanding."}

${isFrench ? "DIRECTIVES DE FORMATAGE (STRICTES) :" : "FORMATTING GUIDELINES (STRICT):"}
- ${isFrench ? "NE JAMAIS UTILISER de symboles Markdown (pas d'astérisques **, pas de dièses #, pas de tirets -)." : "NEVER USE Markdown symbols (no asterisks **, no hash symbols #, no hyphens -)."}
- ${isFrench ? "ÉCRIS LES TITRES DE SECTION EN MAJUSCULES." : "WRITE SECTION HEADINGS IN CAPITAL LETTERS."}
- ${isFrench ? "Utilise des chiffres (1., 2., 3.) pour les listes." : "Use numbers (1., 2., 3.) for lists."}
- ${isFrench ? "Ajoute deux sauts de ligne entre chaque paragraphe pour la clarté." : "Add double line breaks between paragraphs for clarity."}
- ${isFrench ? "RÉPONDS EXCLUSIVEMENT EN FRANÇAIS." : "RESPOND EXCLUSIVELY IN ENGLISH."}
""";

    final response = await _model
        .generateContent([Content.text(prompt)])
        .timeout(const Duration(seconds: 30));

    return response;
  }

  @override
  Future<List<QuizQuestion>> generateQuizz(
    String description,
    BuildContext context,
  ) async {
    String language = Localizations.localeOf(context).languageCode == 'fr'
        ? 'French'
        : 'English';

    final prompt =
        """
  Generate a quiz with exactly 10 multiple-choice questions (MCQs) based on this description: $description.
  Language: $language.
  For each question, provide 4 options and the index of the correct answer (0-3).
  Also provide a very short explanation (1-2 lines max) for the answer.
  Return ONLY a JSON array with this structure:
  [
    {
      "question": "text",
      "options": ["opt0", "opt1", "opt2", "opt3"],
      "correct_index": 0,
      "explanation": "short explanation"
    }
  ]
  """;

    final response = await _model.generateContent([Content.text(prompt)]);
    final String? jsonString = response.text;

    if (jsonString != null) {
      String cleanJson = jsonString
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      List<dynamic> data = jsonDecode(cleanJson);
      return data.map((q) => QuizQuestion.fromJson(q)).toList();
    }
    throw Exception("Failed to generate quiz");
  }

  @override
  Future<Map<String, dynamic>> generateQuizFromContent(
    String textToAnalyze,
    BuildContext context, {
    String? courseTitle,
    String? courseTopic,
    String? courseId,
  }) async {
    try {
      final locale = Localizations.localeOf(context).languageCode;
      final isFrench = locale == 'fr';

      final prompt =
          """
${isFrench ? "Tu es un expert en création de quiz pédagogiques." : "You are an expert in creating educational quizzes."}

${isFrench ? "CONTENU DU COURS :" : "COURSE CONTENT:"}
$textToAnalyze

${isFrench ? "INSTRUCTIONS POUR LE QUIZ :" : "QUIZ INSTRUCTIONS:"}
1. ${isFrench ? "Crée un quiz de 10 questions à choix multiples" : "Create a 10-question multiple choice quiz"}
2. ${isFrench ? "Questions basées sur les concepts clés du contenu" : "Questions based on key concepts from the content"}
3. ${isFrench ? "Chaque question doit avoir 4 options (A, B, C, D)" : "Each question must have 4 options (A, B, C, D)"}
4. ${isFrench ? "Indique la réponse correcte (0 pour A, 1 pour B, 2 pour C, 3 pour D)" : "Indicate the correct answer (0 for A, 1 for B, 2 for C, 3 for D)"}
5. ${isFrench ? "Ajoute une explication courte pour chaque réponse" : "Add a short explanation for each answer"}
6. ${isFrench ? "Varie la difficulté (facile, moyen, difficile)" : "Vary the difficulty (easy, medium, hard)"}
7. ${isFrench ? "Format de sortie : JSON valide uniquement" : "Output format: Valid JSON only"}

${isFrench ? "FORMAT JSON REQUIS :" : "REQUIRED JSON FORMAT:"}
{
  "quizTitle": "${isFrench ? "Quiz sur : " : "Quiz on: "}$courseTitle",
  "description": "${isFrench ? "Quiz généré à partir du cours" : "Quiz generated from the course"}: $courseTitle",
  "topic": "$courseTopic",
  "courseId": "$courseId",
  "difficulty": "mixed",
  "questions": [
    {
      "question": "${isFrench ? "Texte de la question" : "Question text"}",
      "options": ["${isFrench ? "Option A" : "Option A"}", "${isFrench ? "Option B" : "Option B"}", "${isFrench ? "Option C" : "Option C"}", "${isFrench ? "Option D" : "Option D"}"],
      "correctAnswer": 0,
      "explanation": "${isFrench ? "Explication courte" : "Short explanation"}",
      "difficulty": "${isFrench ? "facile" : "easy"}"
    }
  ],
  "createdAt": "${DateTime.now().toIso8601String()}",
  "estimatedDuration": 15
}

${isFrench ? "IMPORTANT : Retourne UNIQUEMENT le JSON, sans texte supplémentaire." : "IMPORTANT: Return ONLY the JSON, no additional text."}
${isFrench ? "Réponds en français." : "Respond in English."}
""";

      final response = await _model
          .generateContent([Content.text(prompt)])
          .timeout(const Duration(seconds: 45));

      if (response.text == null) {
        throw Exception(
          isFrench ? "Échec de génération du quiz" : "Quiz generation failed",
        );
      }

      String rawResponse = response.text!;
      String jsonString = _extractJsonFromResponse(rawResponse);

      Map<String, dynamic> quizData = jsonDecode(jsonString);
      String quizId = await _saveQuizToFirestore(quizData);
      quizData['id'] = quizId;

      return {
        'success': true,
        'quizId': quizId,
        'quizData': quizData,
        'questionsCount': (quizData['questions'] as List).length,
        'message': isFrench
            ? "Quiz généré et sauvegardé avec succès !"
            : "Quiz generated and saved successfully!",
      };
    } catch (e) {
      print("Error generating quiz: $e");
      final locale = Localizations.localeOf(context).languageCode;
      final isFrench = locale == 'fr';

      return {
        'success': false,
        'error': e.toString(),
        'message': isFrench
            ? "Erreur lors de la génération du quiz: $e"
            : "Error generating quiz: $e",
      };
    }
  }

  @override
  Future<Map<String, dynamic>> generateQuizFromPdfUrl(
    String pdfUrl,
    BuildContext context, {
    required String courseTitle,
    required String courseTopic,
    required String courseId,
  }) async {
    try {
      final extractedText = await extractTextFromPdf(pdfUrl);

      return await generateQuizFromContent(
        extractedText,
        context,
        courseTitle: courseTitle,
        courseTopic: courseTopic,
        courseId: courseId,
      );
    } catch (e) {
      print("Error generating quiz from PDF URL: $e");
      final locale = Localizations.localeOf(context).languageCode;
      final isFrench = locale == 'fr';

      return {
        'success': false,
        'error': e.toString(),
        'message': isFrench
            ? "Erreur lors de l'extraction du PDF: $e"
            : "Error extracting PDF: $e",
      };
    }
  }

  @override
  Future<String> extractTextFromPdf(String pdfUrl) async {
    try {
      final response = await http
          .get(Uri.parse(pdfUrl))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch PDF: ${response.statusCode}');
      }

      final PdfDocument document = PdfDocument(inputBytes: response.bodyBytes);

      String extractedText = '';
      int pageCount = document.pages.count;
      int limit = pageCount > 10 ? 10 : pageCount;

      for (int i = 0; i < limit; i++) {
        final pageText = PdfTextExtractor(
          document,
        ).extractText(startPageIndex: i, endPageIndex: i);
        extractedText += '$pageText\n\n';
      }

      document.dispose();

      if (extractedText.length > 10000) {
        extractedText = extractedText.substring(0, 10000);
      }

      return extractedText;
    } catch (e) {
      print("Error extracting PDF text: $e");
      return "Contenu PDF non disponible. Quiz généré sur le titre et le sujet uniquement.";
    }
  }

  @override
  Stream<QuerySnapshot> getUserQuizzes() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('quizzes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Future<DocumentSnapshot> getQuizById(String quizId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

    return await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('quizzes')
        .doc(quizId)
        .get();
  }

  @override
  Future<void> updateQuizStats(
    String quizId,
    double score,
    int duration,
  ) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final quizRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('quizzes')
        .doc(quizId);

    final transaction = _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(quizRef);
      if (!snapshot.exists) return;

      final currentData = snapshot.data() as Map<String, dynamic>;
      final currentAttempts = currentData['attempts'] ?? 0;
      final currentAvgScore = currentData['averageScore'] ?? 0.0;

      final newAttempts = currentAttempts + 1;
      final newAvgScore =
          ((currentAvgScore * currentAttempts) + score) / newAttempts;

      transaction.update(quizRef, {
        'attempts': newAttempts,
        'averageScore': newAvgScore,
        'updatedAt': FieldValue.serverTimestamp(),
        'lastAttempt': FieldValue.serverTimestamp(),
      });
    });

    return transaction;
  }

  // Méthodes privées
  String _extractJsonFromResponse(String text) {
    int startIndex = text.indexOf('{');
    int endIndex = text.lastIndexOf('}');

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return text.substring(startIndex, endIndex + 1);
    }

    String cleaned = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    try {
      jsonDecode(cleaned);
      return cleaned;
    } catch (e) {
      return _createDefaultQuizJson();
    }
  }

  String _createDefaultQuizJson() {
    final defaultQuiz = {
      "quizTitle": "Quiz généré automatiquement",
      "description": "Quiz généré à partir du contenu du cours",
      "topic": "Général",
      "courseId": "",
      "difficulty": "medium",
      "questions": [
        {
          "question": "Qu'avez-vous retenu du contenu étudié ?",
          "options": ["Beaucoup", "Assez", "Peu", "Rien"],
          "correctAnswer": 0,
          "explanation": "C'est une question d'évaluation subjective.",
          "difficulty": "easy",
        },
      ],
      "createdAt": DateTime.now().toIso8601String(),
      "estimatedDuration": 5,
    };

    return jsonEncode(defaultQuiz);
  }

  Future<String> _saveQuizToFirestore(Map<String, dynamic> quizData) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception("User not authenticated");

      Map<String, dynamic> firestoreData = {
        'title': quizData['quizTitle'] ?? 'Quiz sans titre',
        'description': quizData['description'] ?? 'Quiz généré automatiquement',
        'topic': quizData['topic'] ?? 'Général',
        'courseId': quizData['courseId'] ?? '',
        'difficulty': quizData['difficulty'] ?? 'medium',
        'questions': quizData['questions'] ?? [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'status': 'active',
        'totalQuestions': (quizData['questions'] as List).length,
        'estimatedDuration': quizData['estimatedDuration'] ?? 10,
        'attempts': 0,
        'averageScore': 0.0,
      };

      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('quizzes')
          .add(firestoreData);

      print("Quiz sauvegardé avec ID: ${docRef.id}");
      return docRef.id;
    } catch (e) {
      print("Error saving quiz to Firestore: $e");
      rethrow;
    }
  }
}
