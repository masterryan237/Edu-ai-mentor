import 'package:eduai_mentor/services/auth_service.dart';
import 'package:eduai_mentor/utilis/app_texts_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;
  final TextEditingController _resetEmailController = TextEditingController();

  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  // Variables pour masquer/afficher le texte
  bool _obscurePassword = true;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _confirmPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword(
    String email,
    BuildContext dialogContext,
    StateSetter setDialogState,
  ) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTexts.pleaseEnterEmail(context))),
      );
      return;
    }

    setDialogState(() => _isLoading = true);

    try {
      await AuthService().resetPassword(email);
      if (mounted) {
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTexts.resetLinkSent(context)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = AuthService().handleForgotPasswordError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      setDialogState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _emailError = null; // Reset propre
      _passwordError = null;
    });

    try {
      await AuthService().logInWithEmailAndPassword(_email, _password);

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home/', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        final results = AuthService().handleAuthError(e);
        _emailError = results.$1;
        _passwordError = results.$2;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppTexts.networkError(context, e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/AppLogo.png',
                          width: 120,
                          height: 120,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        AppTexts.welcomeBack(context),
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppTexts.signInToContinue(context),
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

                // Login Form Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email Field
                      Text(
                        AppTexts.email(context),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        identifier: "email_field",
                        child: TextField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: AppTexts.enterYourEmail(context),
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            errorText: _emailError,
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Colors.deepPurpleAccent,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Password Field
                      Text(
                        AppTexts.password(context),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        identifier: "password_field",
                        child: TextField(
                          controller: _password,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: AppTexts.enterYourPassword(context),
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            errorText: _passwordError,
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(
                                color: Colors.deepPurpleAccent,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.deepPurple,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.deepPurple,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => StatefulBuilder(
                                builder: (context, setDialogState) =>
                                    AlertDialog(
                                      title: Text(
                                        AppTexts.resetPassword(context),
                                        style: const TextStyle(
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            AppTexts.resetEmailInstruction(
                                              context,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          TextField(
                                            controller: _resetEmailController,
                                            decoration: InputDecoration(
                                              labelText: AppTexts.emailLabel(
                                                context,
                                              ),
                                              labelStyle: const TextStyle(
                                                color: Colors.deepPurple,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: const BorderSide(
                                                  color: Colors.deepPurple,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                borderSide: const BorderSide(
                                                  color:
                                                      Colors.deepPurpleAccent,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                            AppTexts.cancel(context),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        _isLoading
                                            ? const CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.deepPurple),
                                              )
                                            : ElevatedButton(
                                                onPressed: () =>
                                                    _handleForgotPassword(
                                                      _resetEmailController
                                                          .text,
                                                      context,
                                                      setDialogState,
                                                    ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.deepPurple,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                                child: Text(
                                                  AppTexts.sendLink(context),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                      ],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text(
                            AppTexts.forgotPassword(context),
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Login Button
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.deepPurple,
                                ),
                              ),
                            )
                          : Semantics(
                              identifier: "login_button",
                              child: ElevatedButton(
                                onPressed: _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 18,
                                  ),
                                  shadowColor: Colors.deepPurple.withOpacity(
                                    0.3,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppTexts.signIn(context),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(Icons.arrow_forward, size: 20),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Register Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppTexts.dontHaveAccount(context),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/register/', (route) => false),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppTexts.signUpNow(context),
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Divider
                const SizedBox(height: 20),

                // Social Login Icons (Placeholder for future integration)
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
