import 'package:eduai_mentor/services/auth_service.dart';
import 'package:eduai_mentor/utilis/app_texts_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirmPassword;

  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  // Variables pour gérer la visibilité des mots de passe
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
    super.dispose();
  }

  bool _validateFields() {
    setState(() {
      _emailError = _email.text.isEmpty ? AppTexts.enterEmail(context) : null;

      if (_password.text.isEmpty) {
        _passwordError = AppTexts.enterPassword(context);
      } else if (_password.text.length < 6) {
        _passwordError = AppTexts.passwordTooShort(context);
      } else if (_password.text != _confirmPassword.text) {
        _passwordError = AppTexts.passwordsDontMatch(context);
      } else {
        _passwordError = null;
      }
    });
    return _emailError == null && _passwordError == null;
  }

  Future<void> _handleRegister() async {
    if (!_validateFields()) return;

    setState(() {
      _isLoading = true;
      _emailError = null; // Reset propre
      _passwordError = null;
    });

    try {
      await AuthService().registerWithEmailAndPassword(_email, _password);

      if (mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/emailVerification/', (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        final results = AuthService().handleAuthError(e);
        _emailError = results.$1;
        _passwordError = results.$2;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppTexts.unknownError(context, e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo et titre
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B61FF).withOpacity(0.1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7B61FF).withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            "assets/images/AppLogo.png",
                            color: const Color(0xFF7B61FF),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppTexts.createAccount(context),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppTexts.joinToday(context),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Formulaire d'inscription
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Champ Email
                      Semantics(
                        identifier: "email_field",
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTexts.emailAddress(context),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF333333),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _emailError != null
                                      ? Colors.red
                                      : const Color(0xFFE0E0E0),
                                  width: 1.5,
                                ),
                              ),
                              child: TextField(
                                controller: _email,
                                autocorrect: false,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF333333),
                                ),
                                decoration: InputDecoration(
                                  hintText: AppTexts.emailHint(context),
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF999999),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: Color(0xFF7B61FF),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            if (_emailError != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                _emailError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Champ Password
                      Semantics(
                        identifier: "password_field",
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTexts.password(context),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF333333),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _passwordError != null
                                      ? Colors.red
                                      : const Color(0xFFE0E0E0),
                                  width: 1.5,
                                ),
                              ),
                              child: TextField(
                                controller: _password,
                                obscureText: _obscurePassword,
                                enableSuggestions: false,
                                autocorrect: false,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF333333),
                                ),
                                decoration: InputDecoration(
                                  hintText: AppTexts.passwordHint(context),
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF999999),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Color(0xFF7B61FF),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Color(0xFF999999),
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      );
                                    },
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Champ Confirm Password
                      Semantics(
                        identifier: "confirm_password_field",
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTexts.confirmPassword(context),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF333333),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _passwordError != null
                                      ? Colors.red
                                      : const Color(0xFFE0E0E0),
                                  width: 1.5,
                                ),
                              ),
                              child: TextField(
                                controller: _confirmPassword,
                                obscureText: _obscureConfirmPassword,
                                enableSuggestions: false,
                                autocorrect: false,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF333333),
                                ),
                                decoration: InputDecoration(
                                  hintText: AppTexts.passwordHint(context),
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF999999),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_reset,
                                    color: Color(0xFF7B61FF),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Color(0xFF999999),
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(
                                        () => _obscureConfirmPassword =
                                            !_obscureConfirmPassword,
                                      );
                                    },
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            if (_passwordError != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                _passwordError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Indications pour le mot de passe
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Color(0xFF666666),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            AppTexts.atLeastCharacters(context),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Bouton Register
                      SizedBox(
                        width: double.infinity,
                        child: _isLoading
                            ? Center(
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  padding: const EdgeInsets.all(8),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Semantics(
                                identifier: "register_button",
                                child: ElevatedButton(
                                  onPressed: _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7B61FF),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 24,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 0,
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        AppTexts.createAccountBtn(context),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Lien vers Login
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login/', (route) => false),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: RichText(
                        text: TextSpan(
                          text: AppTexts.alreadyHaveAccount(context),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF666666),
                          ),
                          children: [
                            TextSpan(
                              text: AppTexts.signIn(context),
                              style: const TextStyle(
                                color: Color(0xFF7B61FF),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Conditions d'utilisation
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      AppTexts.termsAgreement(context),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
