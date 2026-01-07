import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  final _model = GenerativeModel(
    model: "gemini-2.5-flash",
    apiKey: dotenv.env['GEMINI_API_KEY']!,
  );

  //Commencer la generation d'un cours

  Future<String> startCourseGeneration(
    String description,
    BuildContext context,
  ) async {
    // 1. Récupération de la langue active
    final locale = Localizations.localeOf(context).languageCode;
    final isFrench = locale == 'fr';

    // 2. Construction du prompt enrichi (Prompt Engineering)
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

    // Nettoyage de sécurité
    String courseText =
        response.text ??
        (isFrench ? "Erreur de génération" : "Generation Error");
    courseText = courseText.replaceAll(RegExp(r'[\*\#\_]'), '');

    return courseText;
  }

  Future<GenerateContentResponse> generateExplanation(
    String textToAnalyze,
    BuildContext context, // Ajout du context
  ) async {
    // 1. Détection de la langue
    final locale = Localizations.localeOf(context).languageCode;
    final isFrench = locale == 'fr';

    // 2. Prompt Engineering "Deep Dive"
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

    // 3. Appel à l'IA avec timeout
    final response = await _model
        .generateContent([Content.text(prompt)])
        .timeout(const Duration(seconds: 30));

    return response;
  }
}
