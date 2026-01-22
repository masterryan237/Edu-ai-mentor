class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex; // 0 à 3
  final String explanation; // L'IA doit la générer dès le début
  int? userSelectedIndex; // Pour stocker la réponse de l'étudiant

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  // Factory pour transformer le JSON de l'IA en objet Dart
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: json['question'],
      options: List<String>.from(json['options']),
      correctIndex: json['correct_index'],
      explanation: json['explanation'],
    );
  }
}
