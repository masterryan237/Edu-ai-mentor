import 'dart:async';
import 'package:eduai_mentor/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({super.key});

  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  Timer? _emailVerificationTimer;
  bool _isSending = false; // Pour le chargement
  bool _hasSent = false; // Pour changer le texte à l'écran

  @override
  void initState() {
    super.initState();
    // Vérification automatique toutes les 8 secondes
    _emailVerificationTimer = Timer.periodic(const Duration(seconds: 8), (
      Timer t,
    ) {
      _checkEmailVerification();
    });
  }

  @override
  void dispose() {
    _emailVerificationTimer?.cancel();
    super.dispose();
  }

  void _checkEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    try {
      await user?.reload();
      if (user != null && user.emailVerified) {
        _emailVerificationTimer?.cancel();
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home/', (route) => false);
        }
      }
    } catch (e) {
      // Si le reload échoue (souvent problème de réseau), on ignore silencieusement
      // pour ne pas spammer d'erreurs pendant le timer.
      print("Network error during auto-check: $e");
    }
  }

  Future<void> _sendVerification() async {
    setState(() {
      _isSending = true;
    });

    try {
      if (AuthService().auth.currentUser != null) {
        await AuthService().sendAuthenticationEmail();
        setState(() {
          _hasSent = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Verification email sent successfully!"),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = AuthService().handleEmailVerificationError(e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not connect to server. Check your internet."),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? "your email";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Texte dynamique selon l'état de l'envoi
              Text(
                _hasSent
                    ? "Verify your identity"
                    : "Identity Verification Required",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),

              // Zone de message principale
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  _hasSent
                      ? "A verification link has been sent to:\n$userEmail\n\nPlease check your inbox (and spam folder). Once you click the link, you will be automatically redirected."
                      : "We need to make sure this email address is owned by you. Please click the button below to receive a verification link.",
                  style: const TextStyle(fontSize: 17, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40),
              const Text(
                '↓',
                style: TextStyle(
                  fontSize: 65,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 30),

              // Bouton avec gestion du chargement
              _isSending
                  ? const CircularProgressIndicator()
                  : OutlinedButton(
                      onPressed: _sendVerification,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Colors.blue, width: 2.0),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _hasSent
                            ? 'Resend Verification Email'
                            : 'Send the E-mail Verification',
                      ),
                    ),

              if (_hasSent) ...[
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => FirebaseAuth.instance.signOut().then((_) {
                    Navigator.of(context).pushReplacementNamed('/login/');
                  }),
                  child: const Text(
                    "Use another account",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
