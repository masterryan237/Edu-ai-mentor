import 'package:flutter/material.dart';

class AppTexts {
  static bool _isFr(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'fr';

  //**HOME_PAGE **/
  static String home(BuildContext context) =>
      _isFr(context) ? "Accueil" : "Home";
  static String myCourses(BuildContext context) =>
      _isFr(context) ? "Mes cours" : "My courses";
  static String profile(BuildContext context) =>
      _isFr(context) ? "Profil" : "Profile";
  static String searchHint(BuildContext context) =>
      _isFr(context) ? "Rechercher un cours" : "Search course";

  // Actions Home
  static String uploadNewCourse(BuildContext context) =>
      _isFr(context) ? "Ajouter un cours" : "Upload a new course";
  static String generateNotes(BuildContext context) =>
      _isFr(context) ? "Générer cours" : "Generate Notes";
  static String recentCourses(BuildContext context) =>
      _isFr(context) ? "Cours récents..." : "Recent courses...";
  static String viewAllCourses(BuildContext context) =>
      _isFr(context) ? "Voir tous les cours" : "View all Courses";
  static String view(BuildContext context) => _isFr(context) ? "Voir" : "View";

  // Dialogue Upload
  static String uploadTitle(BuildContext context) => _isFr(context)
      ? "Uploader un document de cours"
      : "Upload a course document";
  static String courseNameLabel(BuildContext context) =>
      _isFr(context) ? "Nom du cours" : "Course name";
  static String topicLabel(BuildContext context) =>
      _isFr(context) ? "Sujet" : "Topic";
  static String selectDoc(BuildContext context) =>
      _isFr(context) ? "Choisir un document" : "Select a document";
  static String uploadBtn(BuildContext context) =>
      _isFr(context) ? "Uploader" : "Upload";
  static String cancel(BuildContext context) =>
      _isFr(context) ? "Annuler" : "Cancel";

  // Dialogue Suppression
  static String confirmTitle(BuildContext context) =>
      _isFr(context) ? "Confirmation" : "Confirmation";
  static String confirmDeleteMsg(BuildContext context) => _isFr(context)
      ? "Voulez-vous vraiment supprimer ce cours définitivement ?"
      : "Are you sure you want to delete this course permanently?";
  static String delete(BuildContext context) =>
      _isFr(context) ? "Supprimer" : "Delete";

  // États et Erreurs
  static String noResults(BuildContext context, String query) => _isFr(context)
      ? "Aucun résultat pour '$query'"
      : "No Results Matching '$query'";
  static String deleteSuccess(BuildContext context) => _isFr(context)
      ? "Cours supprimé avec succès"
      : "Course deleted with success";
  static String uploadSuccess(BuildContext context) => _isFr(context)
      ? "Cours uploader avec succès"
      : "Course uploaded successfully";
  static String networkError(BuildContext context) => _isFr(context)
      ? "Erreur réseau : suppression impossible"
      : "Network error: Could not complete deletion";
  static String noCourseYet(BuildContext context) => _isFr(context)
      ? "Aucun cours envoyé pour le moment."
      : "No course uploaded yet.";
  static String aiFailed(BuildContext context) => _isFr(context)
      ? "Échec de l'IA. Vérifiez votre connexion."
      : "AI generation failed. Please check internet connection.";
  static String searchError(BuildContext context) => _isFr(context)
      ? "Service de recherche temporairement indisponible"
      : "Search service temporarily unavailable";
  static String fileError(BuildContext context) =>
      _isFr(context) ? "Impossible d'ouvrir le fichier" : "Could not open file";

  // Profile Page
  static String profileTitle(BuildContext context) =>
      _isFr(context) ? "Profil Utilisateur" : "User Profile";
  static String connectedWith(BuildContext context, String email) =>
      _isFr(context) ? "Connecté avec $email" : "Connected with $email";
  static String statsTitle(BuildContext context) =>
      _isFr(context) ? "Statistiques" : "Stats";
  static String uploads(BuildContext context) =>
      _isFr(context) ? "Documents" : "Uploads";
  static String aiCourses(BuildContext context) =>
      _isFr(context) ? "Cours IA" : "AI Courses";
  static String settings(BuildContext context) =>
      _isFr(context) ? "Paramètres" : "Settings";
  static String changePassword(BuildContext context) =>
      _isFr(context) ? "Modifier le mot de passe" : "Change password";
  static String resetEmailSent(BuildContext context) => _isFr(context)
      ? "E-mail de réinitialisation envoyé !"
      : "Reset email sent!";
  static String signOut(BuildContext context) =>
      _isFr(context) ? "Déconnexion" : "Sign out";
  static String language(BuildContext context) =>
      _isFr(context) ? "Langue" : "Language";

  // My Courses Tab
  static String myCoursesTitle(BuildContext context) =>
      _isFr(context) ? "Mes Cours" : "My Courses";
  static String confirmDeletion(BuildContext context) =>
      _isFr(context) ? "Confirmation" : "Confirmation";
  static String deleteConfirmMsg(BuildContext context) => _isFr(context)
      ? "Voulez-vous vraiment supprimer ce cours définitivement ?"
      : "Are you sure you want to delete this course permanently?";
  static String noCourse(BuildContext context) => _isFr(context)
      ? "Aucun cours téléchargé pour le moment."
      : "No course uploaded yet.";
  static String aiGenFailed(BuildContext context) => _isFr(context)
      ? "Échec de l'IA. Vérifiez votre connexion."
      : "AI generation failed. Please check internet connection.";

  // Email Verification View
  static String emailVerifyTitle(BuildContext context) =>
      _isFr(context) ? "Vérification de l'e-mail" : "Email Verification";
  static String verifyIdentity(BuildContext context) =>
      _isFr(context) ? "Vérifiez votre identité" : "Verify your identity";
  static String identityRequired(BuildContext context) => _isFr(context)
      ? "Vérification d'identité requise"
      : "Identity Verification Required";
  static String verificationSentMsg(BuildContext context, String email) =>
      _isFr(context)
      ? "Un lien de vérification a été envoyé à :\n$email\n\nVeuillez vérifier votre boîte de réception (et vos spams). Une fois que vous aurez cliqué sur le lien, vous serez automatiquement redirigé."
      : "A verification link has been sent to:\n$email\n\nPlease check your inbox (and spam folder). Once you click the link, you will be automatically redirected.";
  static String verificationNeededMsg(BuildContext context) => _isFr(context)
      ? "Nous devons nous assurer que cette adresse e-mail vous appartient. Veuillez cliquer sur le bouton ci-dessous pour recevoir un lien de vérification."
      : "We need to make sure this email address is owned by you. Please click the button below to receive a verification link.";
  static String resendEmail(BuildContext context) => _isFr(context)
      ? "Renvoyer l'e-mail de vérification"
      : "Resend Verification Email";
  static String sendEmail(BuildContext context) => _isFr(context)
      ? "Envoyer l'e-mail de vérification"
      : "Send the E-mail Verification";
  static String anotherAccount(BuildContext context) =>
      _isFr(context) ? "Utiliser un autre compte" : "Use another account";
  static String verifySuccess(BuildContext context) => _isFr(context)
      ? "E-mail de vérification envoyé avec succès !"
      : "Verification email sent successfully!";
  static String connectionError(BuildContext context) => _isFr(context)
      ? "Connexion au serveur impossible. Vérifiez votre internet."
      : "Could not connect to server. Check your internet.";

  // Login View
  static String login(BuildContext context) =>
      _isFr(context) ? "Connexion" : "Login";
  static String emailLabel(BuildContext context) =>
      _isFr(context) ? "Adresse E-mail" : "Email Address";
  static String emailHint(BuildContext context) =>
      _isFr(context) ? "Entrez votre e-mail" : "Enter your Email";
  static String passwordLabel(BuildContext context) =>
      _isFr(context) ? "Mot de passe" : "Password";
  static String confirmPasswordLabel(BuildContext context) =>
      _isFr(context) ? "Confirmer le mot de passe" : "Confirm Password";
  static String forgotPassword(BuildContext context) => _isFr(context)
      ? "Mot de passe oublié ? Réinitialiser"
      : "Forgot password? Try to reset";
  static String notRegistered(BuildContext context) => _isFr(context)
      ? "Pas encore inscrit ? S'inscrire"
      : "Not registered? Register Now";

  // Validation & Dialogs
  static String enterEmail(BuildContext context) => _isFr(context)
      ? "Entrez votre adresse e-mail"
      : "Enter your email address";
  static String enterSecurePass(BuildContext context) => _isFr(context)
      ? "Entrez un mot de passe sécurisé"
      : "Enter a secure password";
  static String passNotMatching(BuildContext context) => _isFr(context)
      ? "Les mots de passe ne correspondent pas"
      : "Passwords not matching";
  static String resetTitle(BuildContext context) =>
      _isFr(context) ? "Réinitialiser le mot de passe" : "Reset Password";
  static String resetInstruction(BuildContext context) => _isFr(context)
      ? "Entrez votre e-mail pour recevoir un lien :"
      : "Enter your email to receive a reset link:";
  static String sendLink(BuildContext context) =>
      _isFr(context) ? "Envoyer le lien" : "Send Link";
  static String resetLinkSent(BuildContext context) => _isFr(context)
      ? "Lien envoyé ! Vérifiez vos e-mails."
      : "Reset link sent! Check your email inbox.";

  // Register View
  static String registering(BuildContext context) =>
      _isFr(context) ? "Inscription" : "Registering";
  static String emailHintFull(BuildContext context) => _isFr(context)
      ? "Entrez votre adresse e-mail"
      : "Enter your Email address";
  static String passRequirement(BuildContext context) => _isFr(context)
      ? "Le mot de passe doit contenir au moins 6 caractères"
      : "The password should have at least 6 characters";
  static String alreadyAccount(BuildContext context) => _isFr(context)
      ? "Déjà un compte ? Se connecter !"
      : "Already have an account? Log In !";
  static String unknownError(BuildContext context) =>
      _isFr(context) ? "Erreur inconnue" : "Unknown Error";
  // Generate Course View
  static String generateTitle(BuildContext context) =>
      _isFr(context) ? "Générer un cours" : "Generate a course";
  static String generatingWait(BuildContext context) =>
      _isFr(context) ? "Génération du cours..." : "Generating course...";
  static String topicHint(BuildContext context) => _isFr(context)
      ? "Décrivez le sujet du cours"
      : "Describe the topic of the course";
  static String downloadPdf(BuildContext context) =>
      _isFr(context) ? "Télécharger le PDF" : "Download PDF";
  static String aiButton(BuildContext context) =>
      _isFr(context) ? "Générer avec l'IA" : "AI Generating Course";
  static String placeholder(BuildContext context) => _isFr(context)
      ? "Le contenu du cours s'affichera ici..."
      : "The course content will be displayed here...";
  static String courseReady(BuildContext context) => _isFr(context)
      ? "Votre cours est prêt ! Téléchargez-le et ajoutez-le à votre bibliothèque."
      : "Your course is ready! Download it and upload it to your library to save it permanently.";

  // Explaining Page
  static String explanationTitle(BuildContext context, String topic) =>
      _isFr(context) ? "Explication : $topic" : "Explanation : $topic";
  static String downloadAsPdf(BuildContext context) =>
      _isFr(context) ? "Télécharger en PDF" : "Download as PDF";
  static String pdfSaved(BuildContext context, String name) =>
      _isFr(context) ? "PDF enregistré sous $name" : "PDF saved as $name";
  static String open(BuildContext context) =>
      _isFr(context) ? "Ouvrir" : "Open";
}
