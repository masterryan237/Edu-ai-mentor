import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class AuthService {
  final auth = FirebaseAuth.instance;

  //fonction de verifcation que l'utilisateur entre bien le meme mot de passe deux fois

  //fonction de creation de nouveau compte
  Future<void> registerWithEmailAndPassword(
    TextEditingController email,
    TextEditingController password,
  ) async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      // C'EST CETTE LIGNE QUI DIT À LA PAGE DE LOGIN QU'IL Y A UNE ERREUR
      rethrow;
    }
  }

  //Fonction de connexion de l'utilisateur
  Future<void> logInWithEmailAndPassword(
    TextEditingController email,
    TextEditingController password,
  ) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      rethrow; // Renvoie l'erreur vers ton _handleLogin dans LoginView
    }
  }

  //fonction de changment de mot de passe
  Future<void> resetPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> sendAuthenticationEmail() async {
    await auth.currentUser?.sendEmailVerification().timeout(
      const Duration(seconds: 10),
    );
  }

  //Gerer les erreurs pour les connexions et les créations de compte
  (String?, String?) handleAuthError(FirebaseAuthException e) {
    String? passwordError;
    String? emailError;
    if (e.code == 'weak-password') {
      passwordError = "The password is very weak";
    } else if (e.code == 'email-already-in-use') {
      emailError = "This email is already using by another account";
    } else if (e.code == 'invalid-email') {
      emailError = "invalid email";
    } else if (e.code == 'invalid-credential') {
      passwordError =
          "Wrong password please try with another password or unknown error ";
    } else {
      emailError = "Error : ${e.message}";
    }
    return (emailError, passwordError);
  }

  //Gerer les erreurs lié a l'envoi de l'email ve verification
  String handleEmailVerificationError(FirebaseAuthException e) {
    String message = "An error occurred. Please try again.";
    if (e.code == 'too-many-requests') {
      message = "Too many requests. Please check your inbox or wait a moment.";
    } else if (e.code == 'network-request-failed') {
      message = "Poor internet connection. Please check your network.";
    }
    return message;
  }

  //Gerer les erreurs liés a l'envoi des messages de reset de mots de passe
  String handleForgotPasswordError(FirebaseAuthException e) {
    String errorMessage = "An error occurred";
    if (e.code == 'user-not-found') {
      errorMessage = "No user found with this email";
    }
    if (e.code == 'invalid-email') errorMessage = "Invalid email format";
    return errorMessage;
  }

  Future<void> logOut() async {
    await auth.signOut();
  }
}
