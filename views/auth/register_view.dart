import 'package:eduai_mentor/services/auth_service.dart';
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
      _emailError = _email.text.isEmpty ? "Enter your email address" : null;

      if (_password.text.isEmpty) {
        _passwordError = "Enter a secure password";
      } else if (_password.text.length < 6) {
        _passwordError = "The password should have at least 6 characters";
      } else if (_password.text != _confirmPassword.text) {
        _passwordError = "passwords don't matching";
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Unknown Error : $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registering'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/images/AppLogo.png', width: 150, height: 150),
              const Text(
                'Registering',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // Champ Email
              Semantics(
                identifier: "email_field",
                child: TextField(
                  controller: _email,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your Email address',
                    errorText: _emailError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // --- CHAMP PASSWORD AVEC OEIL ---
              Semantics(
                identifier: "password_field",
                child: TextField(
                  controller: _password,
                  obscureText: _obscurePassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter a secure password',
                    errorText: _passwordError,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // --- CHAMP CONFIRM PASSWORD AVEC OEIL ---
              Semantics(
                identifier: "confirm_password_field",
                child: TextField(
                  controller: _confirmPassword,
                  obscureText: _obscureConfirmPassword,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Confirm your password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Bouton Register / Loading
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Semantics(
                        identifier: "register_button",
                        child: OutlinedButton(
                          onPressed: _handleRegister,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.blue,
                              width: 1.0,
                            ),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(color: Colors.blue, fontSize: 18),
                          ),
                        ),
                      ),
                    ),

              const SizedBox(height: 10),

              TextButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login/', (route) => false),
                child: const Text(
                  'Already have an account? Log In !',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
