import 'package:eduai_mentor/firebase_options.dart';
import 'package:eduai_mentor/views/auth/email_verification_view.dart';
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
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;

        Widget nextScreen;

        if (user == null) {
          // Cas 1 : Personne n'est connecté
          nextScreen = const LoginView();
        } else {
          // On force un reload pour être sûr d'avoir le dernier état de verification
          await user.reload();
          final refreshedUser = FirebaseAuth.instance.currentUser;

          if (refreshedUser != null && refreshedUser.emailVerified) {
            // Cas 2 : Connecté ET vérifié
            nextScreen = HomePage();
          } else {
            // Cas 3 : Connecté MAIS email non vérifié
            // Remplacez par le nom de votre vue de vérification d'email
            nextScreen = const EmailVerificationView();
          }
        }

        // 3. Navigation
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => nextScreen),
          );
        }
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 142, 120, 250),
              Color.fromARGB(255, 160, 140, 255),
              Colors.white,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo Container
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(30),
                    child: Image.asset(
                      'assets/images/AppLogo.png',
                      fit: BoxFit.contain,
                      color: Colors.white,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.school_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // App Name
                  const Text(
                    'EduAI Mentor',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Tagline
                  const Text(
                    'Your Intelligent Learning Companion',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Loading Card
                  Container(
                    constraints: const BoxConstraints(maxWidth: 280),
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Loading Animation - CORRECTION ICI
                        Container(
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.deepPurple.withOpacity(0.3),
                                  ),
                                  strokeWidth: 3,
                                ),
                              ),
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.deepPurple,
                                      ),
                                  strokeWidth: 4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Loading Text
                        const Text(
                          'Initializing Application',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Services Loading
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildServiceStatus('Firebase', true),
                            const SizedBox(height: 8),
                            _buildServiceStatus('Supabase', true),
                            const SizedBox(height: 8),
                            _buildServiceStatus('Environment', true),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // Status Message
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Please wait while we configure your experience...",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Copyright/Version
                  const Text(
                    '© 2024 EduAI Mentor v1.0.2',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceStatus(String service, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isLoading ? Colors.orange : Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              service,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.deepPurple.withOpacity(0.7),
                ),
              ),
            )
          else
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 16,
            ),
        ],
      ),
    );
  }
}
