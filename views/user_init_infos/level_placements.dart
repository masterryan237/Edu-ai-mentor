import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eduai_mentor/views/home_page.dart';
import 'package:eduai_mentor/utilis/app_texts_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LevelPlacementScreen extends StatefulWidget {
  const LevelPlacementScreen({super.key});

  @override
  _LevelPlacementScreenState createState() => _LevelPlacementScreenState();
}

class _LevelPlacementScreenState extends State<LevelPlacementScreen> {
  int currentQuestionIndex = 0;
  int totalScore = 0;

  // Liste des questions basées sur la maturité professionnelle
  final List<Map<String, dynamic>> questions = [
    {
      'question': (context) => AppTexts.question1(context),
      'options': [
        {'text': (context) => AppTexts.option1A(context), 'points': 1},
        {'text': (context) => AppTexts.option1B(context), 'points': 2},
        {'text': (context) => AppTexts.option1C(context), 'points': 3},
      ],
    },
    {
      'question': (context) => AppTexts.question2(context),
      'options': [
        {'text': (context) => AppTexts.option2A(context), 'points': 1},
        {'text': (context) => AppTexts.option2B(context), 'points': 2},
        {'text': (context) => AppTexts.option2C(context), 'points': 3},
      ],
    },
    {
      'question': (context) => AppTexts.question3(context),
      'options': [
        {'text': (context) => AppTexts.option3A(context), 'points': 1},
        {'text': (context) => AppTexts.option3B(context), 'points': 2},
        {'text': (context) => AppTexts.option3C(context), 'points': 3},
      ],
    },
  ];

  void _nextQuestion(int points) {
    setState(() {
      totalScore += points;
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        _showResult();
      }
    });
  }

  void _showResult() {
    String level;
    String description;

    if (totalScore <= 4) {
      level = AppTexts.beginner(context);
      description = AppTexts.beginnerDescription(context);
    } else if (totalScore <= 7) {
      level = AppTexts.intermediate(context);
      description = AppTexts.intermediateDescription(context);
    } else {
      level = AppTexts.advanced(context);
      description = AppTexts.advancedDescription(context);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppTexts.assessmentComplete(context),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppTexts.yourLevel(context), style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text(
              level,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7B61FF),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B61FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                // 1. AFFICHER UN CHARGEMENT (Simule la configuration de l'IA)
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );

                try {
                  // 2. SAUVEGARDE DANS FIREBASE (Firestore)
                  // On récupère l'ID de l'utilisateur actuel
                  String uid = FirebaseAuth.instance.currentUser!.uid;
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('userinfo')
                      .add({
                        'level': level,
                        'score': totalScore,
                        'setupComplete': true,
                      });

                  // Note: J'ai commenté Firebase pour que ton code compile si tu n'as pas encore fini l'install
                  // Mais c'est ici que tu mets tes `await`.

                  await Future.delayed(
                    const Duration(seconds: 2),
                  ); // Simulation délai IA

                  // 3. REDIRECTION VERS LE HOME
                  // pushAndRemoveUntil vide la pile pour que l'utilisateur ne revienne pas en arrière sur le test
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (route) => false,
                  );
                } catch (e) {
                  Navigator.pop(context); // Ferme le loader en cas d'erreur
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppTexts.errorSavingProfile(context, e.toString()),
                      ),
                    ),
                  );
                }
              },
              child: Text(
                AppTexts.startMyJourney(context),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = (currentQuestionIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppTexts.levelAssessment(context),
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de progression
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B61FF)),
            ),
            SizedBox(height: 40),
            Text(
              AppTexts.questionNumber(
                context,
                currentQuestionIndex + 1,
                questions.length,
              ),
              style: TextStyle(
                color: Color(0xFF7B61FF),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              questions[currentQuestionIndex]['question'](context),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            // Options du QCM
            Expanded(
              child: ListView.builder(
                itemCount: questions[currentQuestionIndex]['options'].length,
                itemBuilder: (context, index) {
                  var option =
                      questions[currentQuestionIndex]['options'][index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        backgroundColor: Colors.white,
                        elevation: 2,
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.grey[100]!),
                        ),
                      ),
                      onPressed: () => _nextQuestion(option['points']),
                      child: Text(
                        option['text'](context),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
