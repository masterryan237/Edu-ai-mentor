import 'package:eduai_mentor/firebase_options.dart';
import 'package:eduai_mentor/views/auth/login_view.dart';
import 'package:eduai_mentor/views/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Fonction d'initialisation robuste
  Future<void> _initializeAndNavigate() async {
    try {
      // AJOUT : Chargement de la configuration
      await dotenv.load(fileName: ".env");

      // 1. Initialisation Firebase (Logique inchangée)
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(const Duration(seconds: 10));

      // AJOUT : Initialisation Supabase avec timeout
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      ).timeout(const Duration(seconds: 10));

      // 2. Configuration optionnelle
      FirebaseAuth.instance.setLanguageCode('en');

      // 3. Navigation
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                user == null ? const LoginView() : const HomePage(),
          ),
        );
      }
    } catch (e) {
      // En cas d'erreur (Firebase, Supabase ou .env)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Network issues. Try to reconnecting..."),
            duration: Duration(seconds: 5),
            backgroundColor: Colors.orange,
          ),
        );
      }

      // On attend 3 secondes et on recommence la tentative
      await Future.delayed(const Duration(seconds: 3));
      return _initializeAndNavigate();
    }
  }

  @override
  void initState() {
    super.initState();
    // On lance l'initialisation dès le chargement du widget
    _initializeAndNavigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/AppLogo.png',
              width: 350,
              height: 350,
              fit: BoxFit.cover,
              // Gestion d'erreur au cas où l'image asset manque
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.school, size: 100),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              "Configuration Verification...",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
