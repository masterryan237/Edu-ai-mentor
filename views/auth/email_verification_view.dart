import 'dart:async';
import 'package:eduai_mentor/services/auth_service.dart';
import 'package:eduai_mentor/utilis/app_texts_utils.dart';
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
          ).pushNamedAndRemoveUntil('/avatarPicker/', (route) => false);
        }
      }
    } catch (e) {
      // Si le reload échoue (souvent problème de réseau), on ignore silencieusement
      // pour ne pas spammer d'erreurs pendant le timer.
      print("${AppTexts.networkErrorDuringCheck(context)}: $e");
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
            SnackBar(
              content: Text(AppTexts.verificationEmailSentSuccess(context)),
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
          SnackBar(content: Text(AppTexts.checkInternetConnection(context))),
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
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Logo et icône de vérification
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.verified_outlined,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        _hasSent
                            ? AppTexts.verifyYourIdentity(context)
                            : AppTexts.emailVerificationRequired(context),
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppTexts.checkYourInbox(context),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Card contenant les informations
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.15),
                        blurRadius: 25,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email display avec badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.deepPurple.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              color: Colors.deepPurple,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppTexts.verificationEmailSentTo(context),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userEmail,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _hasSent
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _hasSent
                                    ? AppTexts.sentStatus(context)
                                    : AppTexts.pendingStatus(context),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _hasSent
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Instructions
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.1),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.blueAccent,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    AppTexts.importantInstructions(context),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _buildInstructionStep(
                              1,
                              AppTexts.instruction1(context),
                            ),
                            const SizedBox(height: 12),
                            _buildInstructionStep(
                              2,
                              AppTexts.instruction2(context),
                            ),
                            const SizedBox(height: 12),
                            _buildInstructionStep(
                              3,
                              AppTexts.instruction3(context),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Auto-check indicator
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.deepPurple.withOpacity(0.08),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.autorenew_rounded,
                                color: Colors.deepPurple,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppTexts.autoCheckEnabled(context),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppTexts.autoCheckDescription(context),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 35),

                      // Send/Resend Button
                      _isSending
                          ? Center(
                              child: Column(
                                children: [
                                  const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.deepPurple,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    _hasSent
                                        ? AppTexts.resending(context)
                                        : AppTexts.sending(context),
                                    style: const TextStyle(
                                      color: Colors.deepPurple,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ElevatedButton(
                              onPressed: _sendVerification,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shadowColor: Colors.deepPurple.withOpacity(0.3),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _hasSent
                                        ? Icons.refresh_rounded
                                        : Icons.send_rounded,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _hasSent
                                        ? AppTexts.resendVerificationEmail(
                                            context,
                                          )
                                        : AppTexts.sendVerificationEmail(
                                            context,
                                          ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Use another account option
                if (_hasSent)
                  Center(
                    child: TextButton(
                      onPressed: () => FirebaseAuth.instance.signOut().then((
                        _,
                      ) {
                        Navigator.of(context).pushReplacementNamed('/login/');
                      }),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.swap_horiz_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppTexts.useAnotherAccount(context),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                // Footer note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    AppTexts.emailNotReceived(context),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(int step, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
