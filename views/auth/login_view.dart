import 'package:eduai_mentor/services/auth_service.dart';
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
    _resetEmailController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    setState(() {
      _emailError = _email.text.isEmpty ? "Enter your email address" : null;
      if (_password.text.isEmpty) {
        _passwordError = "Enter a secure password";
      } else if (_password.text != _confirmPassword.text) {
        _passwordError = "passwords not matching";
      } else {
        _passwordError = null;
      }
    });
    return _emailError == null && _passwordError == null;
  }

  Future<void> _handleForgotPassword(
    String email,
    BuildContext dialogContext,
    StateSetter setDialogState,
  ) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email first")),
      );
      return;
    }

    setDialogState(() => _isLoading = true);

    try {
      await AuthService().resetPassword(email);
      if (mounted) {
        Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Reset link sent! Check your email inbox."),
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
    if (!_validateFields()) return;

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Network Error : $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
                'LogIn',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              Semantics(
                identifier: "email_field",
                child: TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your Email',
                    errorText: _emailError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- CHAMP PASSWORD AVEC OEIL ---
              Semantics(
                identifier: "password_field",
                child: TextField(
                  controller: _password,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter password',
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
              const SizedBox(height: 20),

              // --- CHAMP CONFIRM PASSWORD AVEC OEIL ---
              Semantics(
                identifier: "confirm_password_field",
                child: TextField(
                  controller: _confirmPassword,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Confirm password',
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

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => StatefulBuilder(
                        builder: (context, setDialogState) => AlertDialog(
                          title: const Text("Reset Password"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Enter your email to receive a reset link:",
                              ),
                              const SizedBox(height: 15),
                              TextField(
                                controller: _resetEmailController,
                                decoration: InputDecoration(
                                  labelText: "Email",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            _isLoading
                                ? const CircularProgressIndicator()
                                : ElevatedButton(
                                    onPressed: () => _handleForgotPassword(
                                      _resetEmailController.text,
                                      context,
                                      setDialogState,
                                    ),
                                    child: const Text("Send Link"),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Forgot password? Try to reset',
                    style: TextStyle(color: Colors.blue, fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Semantics(
                        identifier: "login_button",
                        child: OutlinedButton(
                          onPressed: _handleLogin,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blue),
                          ),
                          child: const Text(
                            'Log in',
                            style: TextStyle(color: Colors.blue, fontSize: 18),
                          ),
                        ),
                      ),
                    ),

              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/register/', (route) => false),
                child: const Text(
                  'Not registered? Register Now',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
