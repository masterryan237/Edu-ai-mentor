import 'package:flutter/material.dart';

class AppTexts {
  static bool _isFr(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'fr';

  //**HOME_PAGE **/

  static String deleteConfirmMsg(BuildContext context) => _isFr(context)
      ? "Voulez-vous supprimer ce cours définitivement?"
      : "Do you want to delete this course permanently?";

  static String confirmDeletion(BuildContext context) =>
      _isFr(context) ? "Confirmer la suppression" : "Confirm deletion ";

  static String cancel(BuildContext context) =>
      _isFr(context) ? "Annuler" : "Cancel ";
  static String delete(BuildContext context) =>
      _isFr(context) ? "Supprimerr" : "Delete";
  static String deleteSuccess(BuildContext context) => _isFr(context)
      ? "Cours supprimé avec succes"
      : "Course successfully deleted ";

  static String networkErrorDeletion(BuildContext context) => _isFr(context)
      ? "Erreur de suppression , verifiez votre connexion internet et Rééssayez"
      : "Deletion error, check your internet connection and try again.";

  static String modifyCourse(BuildContext context) =>
      _isFr(context) ? "Modifier le cours" : "Modify this course";

  static String courseTitleLabel(BuildContext context) =>
      _isFr(context) ? "Titre du cours" : "Course title";

  static String courseTopicLabel(BuildContext context) =>
      _isFr(context) ? "Sujet / Thème" : "Topic / Subject";

  static String save(BuildContext context) =>
      _isFr(context) ? "Enregistrer" : "Save";

  static String courseUpdated(BuildContext context) => _isFr(context)
      ? "Cours mis à jour avec succès"
      : "Course updated successfully";

  static String error(BuildContext context) =>
      _isFr(context) ? "Erreur" : "Error";
  static String quizGeneratedSuccess(BuildContext context) => _isFr(context)
      ? "Quiz généré avec succès !"
      : "Quiz generated successfully!";

  static String questionsCreated(BuildContext context, int count) =>
      _isFr(context) ? "$count questions créées" : "$count questions created";

  static String quizPreview(BuildContext context) =>
      _isFr(context) ? "Aperçu des questions :" : "Question preview:";

  static String otherQuestions(BuildContext context, int count) =>
      _isFr(context)
      ? "... et $count autres questions"
      : "... and $count more questions";

  static String quizSavedInfo(BuildContext context) => _isFr(context)
      ? "📝 Le quiz a été automatiquement sauvegardé dans votre collection de quizzes."
      : "📝 The quiz has been automatically saved to your quiz collection.";

  static String quizAccessInfo(BuildContext context) => _isFr(context)
      ? "Vous pouvez y accéder depuis l'onglet 'Quizz'."
      : "You can access it from the 'Quizz' tab.";

  static String close(BuildContext context) =>
      _isFr(context) ? "Fermer" : "Close";

  static String startQuiz(BuildContext context) =>
      _isFr(context) ? "Commencer le quiz" : "Start quiz";
  static String myCourses(BuildContext context) =>
      _isFr(context) ? "Mes cours" : "My Courses";

  static String myCoursesSubtitle(BuildContext context) =>
      _isFr(context) ? "Tous vos cours importés" : "All your uploaded courses";

  static String allCourses(BuildContext context, int count) =>
      _isFr(context) ? "Tous les cours ($count)" : "All Courses ($count)";
  static String loadingError(BuildContext context) =>
      _isFr(context) ? "Erreur de chargement" : "Loading error";

  static String noCourses(BuildContext context) =>
      _isFr(context) ? "Aucun cours pour l’instant" : "No courses yet";

  static String uploadFirstCourse(BuildContext context) => _isFr(context)
      ? "Importez votre premier cours pour commencer"
      : "Upload your first course to get started";
  static String view(BuildContext context) => _isFr(context) ? "Voir" : "View";

  static String explain(BuildContext context) =>
      _isFr(context) ? "Expliquer" : "Explain";

  static String quiz(BuildContext context) => _isFr(context) ? "Quiz" : "Quiz";

  static String edit(BuildContext context) =>
      _isFr(context) ? "Modifier" : "Edit";

  static String today(BuildContext context) =>
      _isFr(context) ? "Aujourd’hui" : "Today";

  static String yesterday(BuildContext context) =>
      _isFr(context) ? "Hier" : "Yesterday";

  static String daysAgo(BuildContext context, int days) =>
      _isFr(context) ? "Il y a $days jours" : "$days days ago";

  static String uploaded(BuildContext context) =>
      _isFr(context) ? "Importé :" : "Uploaded:";
  static String home(BuildContext context) =>
      _isFr(context) ? "Accueil" : "Home";

  static String quizz(BuildContext context) =>
      _isFr(context) ? "Quiz" : "Quizz";

  static String profile(BuildContext context) =>
      _isFr(context) ? "Profil" : "Profile";
  static String fileError(BuildContext context) => _isFr(context)
      ? "Erreur lors de l'ouverture du fichier"
      : "Error opening file";
  static String aiFailed(BuildContext context) =>
      _isFr(context) ? "L'explication IA a échoué" : "AI explanation failed";

  static String submitQuizz(BuildContext context) =>
      _isFr(context) ? "Soumettre les réponses" : "Submit Attempt";

  static String backHome(BuildContext context) =>
      _isFr(context) ? "Revenir a l'acceuil" : "Back Home";

  static String next(BuildContext context) =>
      _isFr(context) ? "Suivant" : "Next";

  static String previous(BuildContext context) =>
      _isFr(context) ? "Précédent" : "Previous";

  static String streakDay(BuildContext context, int streakReward) =>
      _isFr(context)
      ? "+$streakReward jour de streaks"
      : "+$streakReward streaks day";

  static String scoreQuiz(BuildContext context, int score) => _isFr(context)
      ? "Vous avez terminé votre quizz avec un score $score"
      : "Your attempt  score is $score";

  static String congratulations(BuildContext context) =>
      _isFr(context) ? "🎉Félicitations" : "🎉Congratulations";

  static String quizExplanations(BuildContext context) =>
      _isFr(context) ? "💡Explication" : "💡Explanation";

  static String submitAnyway(BuildContext context) => _isFr(context)
      ? "Vous n'avez pas répondu a toutes les questions du quizz "
            "Voulez-vous soumettre vos réponses comme ceci?"
      : "You haven't answered all the quiz questions."
            "Would you like to submit your answers like this?";

  static String continueBtn(BuildContext context) =>
      _isFr(context) ? "Continuer" : "Continuer";

  static String quizzIncomplete(BuildContext context) =>
      _isFr(context) ? "Quizz incomplet" : "Quizz incomplete";

  static String submit(BuildContext context) =>
      _isFr(context) ? "Soumettre" : "Submit";
  // Ajoutez ces nouvelles méthodes statiques dans votre classe AppTexts

  //**HOME_PAGE - TEXTES MANQUANTS **/

  static String confirmTitle(BuildContext context) =>
      _isFr(context) ? "Confirmer la suppression" : "Confirm deletion";

  static String confirmDeleteMsg(BuildContext context) => _isFr(context)
      ? "Voulez-vous vraiment supprimer ce cours ?"
      : "Are you sure you want to delete this course?";

  static String uploadTitle(BuildContext context) =>
      _isFr(context) ? "Importer un cours" : "Upload a course";

  static String courseNameLabel(BuildContext context) =>
      _isFr(context) ? "Nom du cours" : "Course name";

  static String topicLabel(BuildContext context) =>
      _isFr(context) ? "Sujet" : "Topic";

  static String selectDoc(BuildContext context) =>
      _isFr(context) ? "Sélectionner un document" : "Select document";

  static String uploadBtn(BuildContext context) =>
      _isFr(context) ? "Importer" : "Upload";

  static String uploadSuccess(BuildContext context) => _isFr(context)
      ? "Cours importé avec succès"
      : "Course uploaded successfully";

  static String searchHint(BuildContext context) =>
      _isFr(context) ? "Rechercher vos cours..." : "Search your courses...";

  static String noResults(BuildContext context, String query) => _isFr(context)
      ? "Aucun résultat pour '$query'"
      : "No results for '$query'";

  static String tryDifferentKeywords(BuildContext context) => _isFr(context)
      ? "Essayez avec d'autres mots-clés"
      : "Try different keywords";

  static String yourProgress(BuildContext context) =>
      _isFr(context) ? "Votre progression" : "Your Progress";

  static String subjectsCount(BuildContext context, int count) =>
      _isFr(context) ? "$count Matières" : "$count Subjects";

  static String recentCourses(BuildContext context) =>
      _isFr(context) ? "Cours récents" : "Recent Courses";

  static String seeAll(BuildContext context) =>
      _isFr(context) ? "Voir tout" : "See All";

  static String learningStatistics(BuildContext context) =>
      _isFr(context) ? "Statistiques d'apprentissage" : "Learning Statistics";

  static String coursesLabel(BuildContext context) =>
      _isFr(context) ? "Cours" : "Courses";

  static String subjectsLabel(BuildContext context) =>
      _isFr(context) ? "Matières" : "Subjects";

  static String dayStreak(BuildContext context) =>
      _isFr(context) ? "Série de jours" : "Day Streak";

  static String professorOwl(BuildContext context) =>
      _isFr(context) ? "Professeur Hibou" : "Professor Owl";

  static String generateNotes(BuildContext context) =>
      _isFr(context) ? "Générer des notes" : "Generate Notes";

  static String startLearningJourney(BuildContext context) => _isFr(context)
      ? "Commencez votre parcours d'apprentissage"
      : "Start Your Learning Journey";

  static String uploadFirstCourseHint(BuildContext context) => _isFr(context)
      ? "Importez votre premier cours ou document pour commencer à apprendre avec votre mentor IA"
      : "Upload your first course or document to begin learning with your AI mentor";

  static String addFirstCourse(BuildContext context) =>
      _isFr(context) ? "Ajouter votre premier cours" : "Add Your First Course";

  // Textes dynamiques basés sur le nombre de cours
  static String mentorMessageNoCourses(BuildContext context) => _isFr(context)
      ? "Bienvenue ! Commencez votre parcours d'apprentissage en ajoutant votre premier cours."
      : "Welcome! Start your learning journey by adding your first course.";

  static String mentorMessageNoStudy(BuildContext context, int totalCourses) =>
      _isFr(context)
      ? "Il est temps de continuer à apprendre ! Vous avez $totalCourses cours en attente."
      : "Time to continue learning! You have $totalCourses courses waiting.";

  static String mentorMessageStreak(BuildContext context, int streakDays) =>
      _isFr(context)
      ? "Super progression ! Vous avez une série de $streakDays jours. Continuez comme ça !"
      : "Great progress! You're on a $streakDays-day streak. Keep going!";

  // Textes de bienvenue dynamiques
  static String helloUser(BuildContext context, String userName) =>
      _isFr(context) ? "Bonjour, $userName !" : "Hello, $userName!";

  static String letsLearn(BuildContext context) => _isFr(context)
      ? "Apprenons quelque chose de nouveau"
      : "Let's learn something new";

  // Textes pour le placeholder du nom d'utilisateur
  static String student(BuildContext context) =>
      _isFr(context) ? "Étudiant" : "Student";
  // Ajoutez ces nouvelles méthodes statiques dans votre classe AppTexts

  //**PROFILE_PAGE - TEXTES MANQUANTS **/

  static String manageAccount(BuildContext context) => _isFr(context)
      ? "Gérez votre compte et paramètres"
      : "Manage your account & settings";

  static String profileID(BuildContext context, String id) => _isFr(context)
      ? "ID: ${id.substring(0, 8)}..."
      : "ID: ${id.substring(0, 8)}...";

  static String learningStats(BuildContext context) => _isFr(context)
      ? "Vos statistiques d'apprentissage"
      : "Your Learning Stats";

  static String uploadedCourses(BuildContext context) =>
      _isFr(context) ? "Cours importés" : "Uploaded Courses";

  static String aiCourses(BuildContext context) =>
      _isFr(context) ? "Cours IA" : "AI Courses";

  static String activeAccount(BuildContext context) =>
      _isFr(context) ? "Compte actif" : "Active Account";

  static String connectedWith(BuildContext context, String email) =>
      _isFr(context) ? "Connecté avec $email" : "Connected with $email";

  static String accountSettings(BuildContext context) =>
      _isFr(context) ? "Paramètres du compte" : "Account Settings";

  static String changePassword(BuildContext context) =>
      _isFr(context) ? "Changer le mot de passe" : "Change Password";

  static String secureAccount(BuildContext context) =>
      _isFr(context) ? "Sécurisez votre compte" : "Secure your account";

  static String language(BuildContext context) =>
      _isFr(context) ? "Langue" : "Language";

  static String appLanguage(BuildContext context) =>
      _isFr(context) ? "Langue de l'application" : "App language";

  static String french(BuildContext context) =>
      _isFr(context) ? "Français" : "French";

  static String english(BuildContext context) =>
      _isFr(context) ? "Anglais" : "English";

  static String helpSupport(BuildContext context) =>
      _isFr(context) ? "Aide & Support" : "Help & Support";

  static String getHelp(BuildContext context) => _isFr(context)
      ? "Obtenir de l'aide avec l'application"
      : "Get help with the app";

  static String aboutApp(BuildContext context, String version) =>
      _isFr(context) ? "À propos d'EduAI Mentor" : "About EduAI Mentor";

  static String version(BuildContext context, String version) =>
      _isFr(context) ? "Version $version" : "Version $version";

  static String signOut(BuildContext context) =>
      _isFr(context) ? "Déconnexion" : "Sign Out";

  static String signOutDescription(BuildContext context) => _isFr(context)
      ? "Déconnectez-vous de votre compte"
      : "Sign out of your account";

  static String resetEmailSent(BuildContext context) =>
      _isFr(context) ? "Email de réinitialisation envoyé" : "Reset email sent";

  static String noEmail(BuildContext context) =>
      _isFr(context) ? "Pas d'email" : "No email";

  static String userFallback(BuildContext context) =>
      _isFr(context) ? "Utilisateur" : "User";

  static String refresh(BuildContext context) =>
      _isFr(context) ? "Actualiser" : "Refresh";

  static String frenchFlag(BuildContext context) => "🇫🇷";

  static String englishFlag(BuildContext context) => "🇬🇧";
  //**LEVEL_PLACEMENT_SCREEN - TEXTES MANQUANTS **/

  static String levelAssessment(BuildContext context) =>
      _isFr(context) ? "Évaluation du niveau" : "Level Assessment";

  static String questionNumber(BuildContext context, int current, int total) =>
      _isFr(context) ? "Question $current/$total" : "Question $current/$total";

  static String assessmentComplete(BuildContext context) =>
      _isFr(context) ? "Évaluation terminée !" : "Assessment Complete!";

  static String yourLevel(BuildContext context) =>
      _isFr(context) ? "Votre niveau :" : "Your Level: ";

  // Niveaux
  static String beginner(BuildContext context) =>
      _isFr(context) ? "Débutant" : "Beginner";

  static String beginnerDescription(BuildContext context) => _isFr(context)
      ? "Votre mentor se concentrera sur les bases essentielles et des explications simples."
      : "Your mentor will focus on core basics and simple explanations.";

  static String intermediate(BuildContext context) =>
      _isFr(context) ? "Intermédiaire" : "Intermediate";

  static String intermediateDescription(BuildContext context) => _isFr(context)
      ? "Préparez-vous pour des leçons structurées et des applications pratiques."
      : "Get ready for structured lessons and practical applications.";

  static String advanced(BuildContext context) =>
      _isFr(context) ? "Avancé" : "Advanced";

  static String advancedDescription(BuildContext context) => _isFr(context)
      ? "Des défis intensifs et la maîtrise technique vous attendent !"
      : "Intensive challenges and technical mastery await you!";

  static String startMyJourney(BuildContext context) =>
      _isFr(context) ? "Commencer mon parcours" : "Start My Journey";

  static String errorSavingProfile(BuildContext context, String error) =>
      _isFr(context)
      ? "Erreur lors de l'enregistrement du profil : $error"
      : "Error saving profile: $error";

  // Questions
  static String question1(BuildContext context) => _isFr(context)
      ? "À quel point votre vision professionnelle est-elle claire ?"
      : "How clear is your professional vision?";

  static String option1A(BuildContext context) => _isFr(context)
      ? "J'ai une idée vague de ce que je veux faire."
      : "I have a vague idea of what I want to do.";

  static String option1B(BuildContext context) => _isFr(context)
      ? "Je connais le domaine, mais pas le poste spécifique."
      : "I know the field, but not the specific job.";

  static String option1C(BuildContext context) => _isFr(context)
      ? "J'ai un poste cible et un parcours professionnel clairs."
      : "I have a clear target job and career path.";

  static String question2(BuildContext context) => _isFr(context)
      ? "Avez-vous déjà pratiqué des compétences liées à votre objectif ?"
      : "Have you ever practiced skills related to your goal?";

  static String option2A(BuildContext context) => _isFr(context)
      ? "Non, je commence juste à explorer."
      : "No, I am just starting to explore.";

  static String option2B(BuildContext context) => _isFr(context)
      ? "J'ai fait quelques tutoriels ou projets de base."
      : "I have done some basic tutorials or projects.";

  static String option2C(BuildContext context) => _isFr(context)
      ? "Je travaille régulièrement sur des projets concrets."
      : "I regularly work on concrete projects.";

  static String question3(BuildContext context) => _isFr(context)
      ? "Comment préférez-vous apprendre des concepts complexes ?"
      : "How do you prefer to learn complex concepts?";

  static String option3A(BuildContext context) => _isFr(context)
      ? "Avec beaucoup d'exemples simples et d'histoires."
      : "With lots of simple examples and stories.";

  static String option3B(BuildContext context) => _isFr(context)
      ? "Avec des résumés structurés et des diagrammes."
      : "With structured summaries and diagrams.";

  static String option3C(BuildContext context) => _isFr(context)
      ? "Avec des détails techniques approfondis et des défis."
      : "With deep technical details and challenges.";
  //**GOAL_SETTING_SCREEN - TEXTES MANQUANTS **/

  static String yourAmbition(BuildContext context) =>
      _isFr(context) ? "Votre ambition" : "Your Ambition";

  static String primaryFocus(BuildContext context) => _isFr(context)
      ? "Quel est votre objectif principal ?"
      : "What is your primary focus?";

  static String goalAdaptation(BuildContext context) => _isFr(context)
      ? "Nous adapterons les conseils de votre mentor à cet objectif."
      : "We will adapt your mentor's advice to this goal.";

  static String validateMyGoal(BuildContext context) =>
      _isFr(context) ? "Valider mon objectif" : "Validate My Goal";

  // Options d'objectifs
  static String goalExamTitle(BuildContext context) =>
      _isFr(context) ? "Réussir mes examens à venir" : "Ace my upcoming exams";

  static String goalExamDesc(BuildContext context) => _isFr(context)
      ? "Concentrez-vous sur la révision intensive et les annales."
      : "Focus on intensive revision and past papers.";

  static String goalMasteryTitle(BuildContext context) => _isFr(context)
      ? "Maîtriser mon domaine professionnel"
      : "Master my professional field";

  static String goalMasteryDesc(BuildContext context) => _isFr(context)
      ? "Plongez en profondeur dans les concepts pour une expertise à long terme."
      : "Deep dive into concepts for long-term expertise.";

  static String goalProductivityTitle(BuildContext context) => _isFr(context)
      ? "Améliorer mes habitudes d'étude"
      : "Improve my study habits";

  static String goalProductivityDesc(BuildContext context) => _isFr(context)
      ? "Apprenez à organiser votre temps et à rester constant."
      : "Learn how to organize time and stay consistent.";

  static String goalCareerTitle(BuildContext context) => _isFr(context)
      ? "Préparer mon emploi de rêve"
      : "Prepare for my dream job";

  static String goalCareerDesc(BuildContext context) => _isFr(context)
      ? "Concentrez-vous sur les compétences pratiques requises par les entreprises."
      : "Focus on practical skills required by companies.";

  static String goalOtherTitle(BuildContext context) =>
      _isFr(context) ? "Autre / Projet personnel" : "Other / Personal project";

  static String goalOtherDesc(BuildContext context) => _isFr(context)
      ? "Parcours personnalisé pour des besoins d'apprentissage uniques."
      : "Customized path for unique learning needs.";

  //**AVATAR_PICKER_SCREEN - TEXTES MANQUANTS **/

  static String chooseMentor(BuildContext context) => _isFr(context)
      ? "Choisissez votre mentor d'apprentissage"
      : "Choose your Learning Mentor";

  static String mentorGuidance(BuildContext context) => _isFr(context)
      ? "Ce compagnon vous guidera tout au long de votre parcours !"
      : "This buddy will guide you through your journey!";

  // Noms des avatars
  static String professorOwlName(BuildContext context) =>
      _isFr(context) ? "Professeur Hibou" : "Professor Owl";

  static String eduBotName(BuildContext context) =>
      _isFr(context) ? "EduBot" : "EduBot";

  static String smartFoxName(BuildContext context) =>
      _isFr(context) ? "Renard Intelligent" : "Smart Fox";
  //**REGISTER_VIEW - TEXTES MANQUANTS **/

  static String createAccount(BuildContext context) =>
      _isFr(context) ? "Créer un compte" : "Create Account";

  static String joinToday(BuildContext context) => _isFr(context)
      ? "Rejoignez EduAI Mentor aujourd'hui"
      : "Join EduAI Mentor today";

  static String emailAddress(BuildContext context) =>
      _isFr(context) ? "Adresse email" : "Email Address";

  static String emailHint(BuildContext context) =>
      _isFr(context) ? "votre.email@exemple.com" : "your.email@example.com";

  static String password(BuildContext context) =>
      _isFr(context) ? "Mot de passe" : "Password";

  static String confirmPassword(BuildContext context) =>
      _isFr(context) ? "Confirmer le mot de passe" : "Confirm Password";

  static String passwordHint(BuildContext context) =>
      _isFr(context) ? "••••••••" : "••••••••";

  static String atLeastCharacters(BuildContext context) =>
      _isFr(context) ? "Au moins 6 caractères" : "At least 6 characters";

  static String createAccountBtn(BuildContext context) =>
      _isFr(context) ? "Créer un compte" : "Create Account";

  static String alreadyHaveAccount(BuildContext context) => _isFr(context)
      ? "Vous avez déjà un compte ? "
      : "Already have an account? ";

  static String signIn(BuildContext context) =>
      _isFr(context) ? "Se connecter" : "Sign In";

  static String termsAgreement(BuildContext context) => _isFr(context)
      ? "En créant un compte, vous acceptez nos Conditions d'utilisation et notre Politique de confidentialité"
      : "By creating an account, you agree to our Terms of Service and Privacy Policy";

  // Messages d'erreur de validation
  static String enterEmail(BuildContext context) => _isFr(context)
      ? "Entrez votre adresse email"
      : "Enter your email address";

  static String enterPassword(BuildContext context) => _isFr(context)
      ? "Entrez un mot de passe sécurisé"
      : "Enter a secure password";

  static String passwordTooShort(BuildContext context) => _isFr(context)
      ? "Le mot de passe doit avoir au moins 6 caractères"
      : "The password should have at least 6 characters";

  static String passwordsDontMatch(BuildContext context) => _isFr(context)
      ? "Les mots de passe ne correspondent pas"
      : "passwords don't matching";

  static String unknownError(BuildContext context, String error) =>
      _isFr(context) ? "Erreur inconnue : $error" : "Unknown Error : $error";
  //**LOGIN_VIEW - TEXTES MANQUANTS **/

  static String welcomeBack(BuildContext context) =>
      _isFr(context) ? "Bon retour" : "Welcome Back";

  static String signInToContinue(BuildContext context) => _isFr(context)
      ? "Connectez-vous pour continuer votre parcours"
      : "Sign in to continue your journey";

  static String email(BuildContext context) =>
      _isFr(context) ? "Email" : "Email";

  static String enterYourEmail(BuildContext context) =>
      _isFr(context) ? "Entrez votre email" : "Enter your email";

  static String enterYourPassword(BuildContext context) =>
      _isFr(context) ? "Entrez votre mot de passe" : "Enter your password";

  static String forgotPassword(BuildContext context) =>
      _isFr(context) ? "Mot de passe oublié ?" : "Forgot password?";

  static String resetPassword(BuildContext context) =>
      _isFr(context) ? "Réinitialiser le mot de passe" : "Reset Password";

  static String resetEmailInstruction(BuildContext context) => _isFr(context)
      ? "Entrez votre email pour recevoir un lien de réinitialisation :"
      : "Enter your email to receive a reset link:";

  static String emailLabel(BuildContext context) =>
      _isFr(context) ? "Email" : "Email";

  static String sendLink(BuildContext context) =>
      _isFr(context) ? "Envoyer le lien" : "Send Link";

  static String dontHaveAccount(BuildContext context) => _isFr(context)
      ? "Vous n'avez pas de compte ? "
      : "Don't have an account? ";

  static String signUpNow(BuildContext context) =>
      _isFr(context) ? "Inscrivez-vous " : "Sign Up Now";

  static String pleaseEnterEmail(BuildContext context) => _isFr(context)
      ? "Veuillez d'abord entrer votre email"
      : "Please enter your email first";

  static String resetLinkSent(BuildContext context) => _isFr(context)
      ? "Lien de réinitialisation envoyé ! Vérifiez votre boîte de réception."
      : "Reset link sent! Check your email inbox.";

  static String networkError(BuildContext context, String error) =>
      _isFr(context) ? "Erreur réseau : $error" : "Network Error : $error";
  //**EMAIL_VERIFICATION_VIEW - TEXTES MANQUANTS **/

  static String verifyYourIdentity(BuildContext context) =>
      _isFr(context) ? "Vérifiez votre identité" : "Verify Your Identity";

  static String emailVerificationRequired(BuildContext context) =>
      _isFr(context)
      ? "Vérification d'email requise"
      : "Email Verification Required";

  static String checkYourInbox(BuildContext context) => _isFr(context)
      ? "Vérifiez votre boîte de réception pour continuer"
      : "Check your inbox to continue";

  static String verificationEmailSentTo(BuildContext context) => _isFr(context)
      ? "Email de vérification envoyé à :"
      : "Verification email sent to:";

  static String sentStatus(BuildContext context) =>
      _isFr(context) ? "Envoyé ✓" : "Sent ✓";

  static String pendingStatus(BuildContext context) =>
      _isFr(context) ? "En attente" : "Pending";

  static String importantInstructions(BuildContext context) =>
      _isFr(context) ? "Instructions importantes" : "Important Instructions";

  static String instruction1(BuildContext context) => _isFr(context)
      ? "Vérifiez votre boîte de réception (et le dossier spam)"
      : "Check your email inbox (and spam folder)";

  static String instruction2(BuildContext context) => _isFr(context)
      ? "Cliquez sur le lien de vérification dans l'email"
      : "Click the verification link in the email";

  static String instruction3(BuildContext context) => _isFr(context)
      ? "Vous serez redirigé automatiquement"
      : "You'll be redirected automatically";

  static String autoCheckEnabled(BuildContext context) => _isFr(context)
      ? "Vérification automatique activée"
      : "Auto-check enabled";

  static String autoCheckDescription(BuildContext context) => _isFr(context)
      ? "Vérification du statut toutes les 8 secondes"
      : "Checking verification status every 8 seconds";

  static String resending(BuildContext context) =>
      _isFr(context) ? "Renvoyement..." : "Resending...";

  static String sending(BuildContext context) =>
      _isFr(context) ? "Envoi..." : "Sending...";

  static String resendVerificationEmail(BuildContext context) =>
      _isFr(context) ? "Verifier a nouveau" : "Resend Verification Email";

  static String sendVerificationEmail(BuildContext context) =>
      _isFr(context) ? "Verifier par email" : "Send Verification Email";

  static String useAnotherAccount(BuildContext context) =>
      _isFr(context) ? "Utiliser un autre compte" : "Use Another Account";

  static String emailNotReceived(BuildContext context) => _isFr(context)
      ? "Vous n'avez pas reçu l'email ? Vérifiez votre dossier spam ou essayez de le renvoyer."
      : "Didn't receive the email? Check your spam folder or try resending.";

  static String verificationEmailSentSuccess(BuildContext context) =>
      _isFr(context)
      ? "Email de vérification envoyé avec succès !"
      : "Verification email sent successfully!";

  static String checkInternetConnection(BuildContext context) => _isFr(context)
      ? "Impossible de se connecter au serveur. Vérifiez votre connexion internet."
      : "Could not connect to server. Check your internet.";

  static String networkErrorDuringCheck(BuildContext context) => _isFr(context)
      ? "Erreur réseau lors de la vérification"
      : "Network error during auto-check";
  //**QUIZZ_TAB - TEXTES MANQUANTS **/

  static String aiQuizz(BuildContext context) =>
      _isFr(context) ? "Quiz IA" : "AI Quizz";

  static String testYourKnowledge(BuildContext context) =>
      _isFr(context) ? "Testez vos connaissances" : "Test your knowledge";

  static String browseByTopic(BuildContext context) =>
      _isFr(context) ? "Parcourir par thème" : "Browse by Topic";

  static String allTopics(BuildContext context) =>
      _isFr(context) ? "Tous les sujets" : "All Topics";

  static String yourQuizzes(BuildContext context) =>
      _isFr(context) ? "Vos quiz" : "Your Quizzes";

  static String quizzesCount(BuildContext context, int count) =>
      _isFr(context) ? "$count quiz" : "$count quizzes";

  static String totalQuizzes(BuildContext context) =>
      _isFr(context) ? "Quiz totaux" : "Total Quizzes";

  static String completed(BuildContext context) =>
      _isFr(context) ? "Terminés" : "Completed";

  static String topics(BuildContext context) =>
      _isFr(context) ? "Thèmes" : "Topics";

  static String noQuizzesYet(BuildContext context) =>
      _isFr(context) ? "Aucun quiz pour l'instant" : "No Quizzes Yet";

  static String createFirstQuiz(BuildContext context) => _isFr(context)
      ? "Créez votre premier quiz pour tester vos connaissances"
      : "Create your first quiz to test your knowledge";

  static String createNewQuiz(BuildContext context) =>
      _isFr(context) ? "Créer un nouveau quiz" : "Create New Quiz";

  static String newQuiz(BuildContext context) =>
      _isFr(context) ? "Nouveau quiz" : "New Quiz";

  // Textes des cartes de quiz
  static String testYourKnowledgeIn(BuildContext context, String title) =>
      _isFr(context)
      ? "Testez vos connaissances en $title"
      : "Test your knowledge in $title";

  static String questions(BuildContext context) =>
      _isFr(context) ? "Questions" : "Questions";

  static String minutes(BuildContext context) =>
      _isFr(context) ? "Minutes" : "Minutes";

  static String streak(BuildContext context) =>
      _isFr(context) ? "Série" : "Streak";

  static String startQuizInstruction(BuildContext context) => _isFr(context)
      ? "Commencez ce quiz pour tester vos connaissances"
      : "Start this quiz to test your knowledge";

  static String completedQuizScore(BuildContext context, int score) =>
      _isFr(context)
      ? "Terminé - Score : $score%"
      : "Completed - Score: $score%";

  static String noQuestionsAvailable(BuildContext context) =>
      _isFr(context) ? "Aucune question disponible" : "No questions available";

  // Dialogues de création de quiz
  static String createNewQuizTitle(BuildContext context) =>
      _isFr(context) ? "Créer un nouveau quiz" : "Create New Quiz";

  static String fromDescription(BuildContext context) =>
      _isFr(context) ? "À partir d'une description" : "From Description";

  static String generateFromDescription(BuildContext context) => _isFr(context)
      ? "Générer un quiz à partir d'une description textuelle"
      : "Generate quiz from text description";

  static String fromUploadedCourse(BuildContext context) =>
      _isFr(context) ? "À partir d'un cours importé" : "From Uploaded Course";

  static String generateFromCourse(BuildContext context) => _isFr(context)
      ? "Générer un quiz à partir de vos cours existants"
      : "Generate quiz from your existing courses";

  static String createQuizFromDescription(BuildContext context) =>
      _isFr(context)
      ? "Créer un quiz à partir d'une description"
      : "Create Quiz from Description";

  static String quizTitleHint(BuildContext context) => _isFr(context)
      ? "ex. Quiz sur les bases de Python"
      : "e.g., Python Basics Quiz";

  static String topicHint(BuildContext context) => _isFr(context)
      ? "ex. Programmation, Mathématiques"
      : "e.g., Programming, Mathematics";

  static String descriptionHint(BuildContext context) => _isFr(context)
      ? "Décrivez de quoi devrait traiter le quiz..."
      : "Describe what the quiz should be about...";

  static String enterDescription(BuildContext context) => _isFr(context)
      ? "Veuillez entrer une description"
      : "Please enter a description";

  static String generatingQuiz(BuildContext context) =>
      _isFr(context) ? "Génération du quiz..." : "Generating Quiz...";

  static String aiIsCreatingQuiz(BuildContext context) => _isFr(context)
      ? "L'IA crée votre quiz..."
      : "AI is creating your quiz...";

  static String thisMayTakeFewMoments(BuildContext context) => _isFr(context)
      ? "Cela peut prendre quelques instants"
      : "This may take a few moments";

  static String analyzingContent(BuildContext context) => _isFr(context)
      ? "Analyse du contenu et création des questions"
      : "Analyzing course content and creating questions";

  static String mayTake2030Seconds(BuildContext context) => _isFr(context)
      ? "Cela peut prendre 20-30 secondes"
      : "This may take 20-30 seconds";

  static String generationMethod(BuildContext context) =>
      _isFr(context) ? "Méthode de génération :" : "Generation Method:";

  static String willExtractFromPdf(BuildContext context) => _isFr(context)
      ? "✓ Extraira le texte du PDF et générera le quiz"
      : "✓ Will extract text from PDF and generate quiz";

  static String willUseCourseContent(BuildContext context) => _isFr(context)
      ? "✓ Utilisera le contenu du cours pour générer le quiz"
      : "✓ Will use course content to generate quiz";

  static String selectCourse(BuildContext context) =>
      _isFr(context) ? "Sélectionner un cours" : "Select a Course";

  static String noCoursesFound(BuildContext context) => _isFr(context)
      ? "Aucun cours trouvé. Veuillez d'abord importer un cours."
      : "No courses found. Please upload a course first.";

  static String pdfAvailable(BuildContext context) =>
      _isFr(context) ? "Document PDF disponible" : "PDF document available";

  static String textContentAvailable(BuildContext context) =>
      _isFr(context) ? "Contenu textuel disponible" : "Text content available";

  static String createQuizFromCourse(BuildContext context) => _isFr(context)
      ? "Créer un quiz à partir d'un cours"
      : "Create Quiz from Course";

  static String errorLoadingCourses(BuildContext context) => _isFr(context)
      ? "Erreur lors du chargement des cours"
      : "Error loading courses";

  static String quizCreatedSuccessfully(BuildContext context) =>
      _isFr(context) ? "Quiz créé avec succès !" : "Quiz created successfully!";

  static String errorCreatingQuiz(BuildContext context, String error) =>
      _isFr(context)
      ? "Erreur lors de la création du quiz : $error"
      : "Error creating quiz: $error";

  static String errorGeneratingQuiz(BuildContext context, String error) =>
      _isFr(context)
      ? "Erreur lors de la génération du quiz : $error"
      : "Error generating quiz: $error";
  //**QUIZZ_TAB - SUITE DES TEXTES MANQUANTS **/

  static String untitledQuiz(BuildContext context) =>
      _isFr(context) ? "Quiz sans titre" : "Untitled Quiz";

  static String general(BuildContext context) =>
      _isFr(context) ? "Général" : "General";

  // Messages de difficulté
  static String easy(BuildContext context) =>
      _isFr(context) ? "Facile" : "Easy";

  static String medium(BuildContext context) =>
      _isFr(context) ? "Moyen" : "Medium";

  static String hard(BuildContext context) =>
      _isFr(context) ? "Difficile" : "Hard";
  //**EXPLAINING_PAGE - TEXTES MANQUANTS **/

  static String aiExplanation(BuildContext context) =>
      _isFr(context) ? "Explication IA" : "AI Explanation";

  static String aiGeneratedExplanation(BuildContext context) => _isFr(context)
      ? "Explication générée par IA"
      : "AI-Generated Explanation";

  static String showMore(BuildContext context) =>
      _isFr(context) ? "Voir plus" : "Show More";

  static String saveExplanation(BuildContext context) => _isFr(context)
      ? "Sauvegarder cette explication"
      : "Save this Explanation";

  static String downloadForOffline(BuildContext context) => _isFr(context)
      ? "Télécharger en PDF pour un accès hors ligne"
      : "Download as PDF for offline access";

  static String creatingPdf(BuildContext context) =>
      _isFr(context) ? "Création du PDF..." : "Creating PDF...";

  static String downloadAsPdf(BuildContext context) =>
      _isFr(context) ? "Télécharger en PDF" : "Download as PDF";

  static String aboutAiExplanation(BuildContext context) => _isFr(context)
      ? "À propos de cette explication IA"
      : "About this AI Explanation";

  static String pdfSaved(BuildContext context, String fileName) =>
      _isFr(context) ? "PDF sauvegardé: $fileName" : "PDF saved: $fileName";

  static String open(BuildContext context) =>
      _isFr(context) ? "OUVRIR" : "OPEN";

  static String wordsCount(BuildContext context, int count) =>
      _isFr(context) ? "$count mots" : "$count words";

  static String fileSize(BuildContext context, String size) =>
      _isFr(context) ? "$size Ko" : "${size}KB";

  static String aiGenerated(BuildContext context) =>
      _isFr(context) ? "Généré par IA" : "AI Generated";

  static String errorMessage(BuildContext context, String error) =>
      _isFr(context) ? "Erreur: $error" : "Error: $error";
  static String titleLabel(BuildContext context) =>
      _isFr(context) ? "Titre" : "Title";
  static String description(BuildContext context) =>
      _isFr(context) ? "Description" : "Description";
  static String difficulty(BuildContext context) =>
      _isFr(context) ? "Difficulté" : "Difficulty";
  //**GENERATE_COURSE - TEXTES MANQUANTS **/

  static String pleaseEnterDescription(BuildContext context) => _isFr(context)
      ? "Veuillez entrer une description de sujet"
      : "Please enter a topic description";

  static String failedToGenerateCourse(BuildContext context) => _isFr(context)
      ? "Échec de la génération du cours"
      : "Failed to generate course";

  static String aiGenerating(BuildContext context) =>
      _isFr(context) ? "IA Génération en cours..." : "AI Generating...";

  static String aiGeneratingCourse(BuildContext context) =>
      _isFr(context) ? "Génération de cours IA" : "AI Generating Course";

  static String createWithAiAssistant(BuildContext context) =>
      _isFr(context) ? "Créer avec l'assistant IA" : "Create with AI Assistant";

  static String describeWhatYouWantToLearn(BuildContext context) =>
      _isFr(context)
      ? "Décrivez ce que vous voulez apprendre"
      : "Describe what you want to learn";

  static String describeCourseExample(BuildContext context) => _isFr(context)
      ? "Exemple : 'Introduction au Machine Learning avec les bases de Python, les algorithmes et les applications réelles'"
      : "Example: 'Introduction to Machine Learning with Python basics, algorithms, and real-world applications'";

  static String beSpecificForBetterResults(BuildContext context) =>
      _isFr(context)
      ? "Soyez précis pour de meilleurs résultats"
      : "Be specific for better results";

  static String generateCourseWithAi(BuildContext context) =>
      _isFr(context) ? "Générer un cours avec l'IA" : "Generate Course with AI";

  static String courseReady(BuildContext context) =>
      _isFr(context) ? "Cours prêt !" : "Course Ready!";

  static String aiCourseReadyForDownload(BuildContext context) => _isFr(context)
      ? "Votre cours généré par IA est disponible au téléchargement"
      : "Your AI-generated course is available for download";

  static String downloadPdf(BuildContext context) =>
      _isFr(context) ? "Télécharger PDF" : "Download PDF";

  static String generatedContentPreview(BuildContext context) =>
      _isFr(context) ? "Aperçu du contenu généré" : "Generated Content Preview";

  static String scrollToPreviewFullContent(BuildContext context) =>
      _isFr(context)
      ? "Faites défiler pour prévisualiser le contenu complet"
      : "Scroll to preview the full content";

  static String aiCourseGenerator(BuildContext context) =>
      _isFr(context) ? "Générateur de cours IA" : "AI Course Generator";

  static String describeAndAiWillCreate(BuildContext context) => _isFr(context)
      ? "Décrivez ce que vous voulez apprendre et notre IA créera un cours complet pour vous."
      : "Describe what you want to learn and our AI will create a comprehensive course for you.";

  static String smartAi(BuildContext context) =>
      _isFr(context) ? "IA Intelligente" : "Smart AI";

  static String fastGeneration(BuildContext context) =>
      _isFr(context) ? "Génération rapide" : "Fast Generation";

  static String pdfExport(BuildContext context) =>
      _isFr(context) ? "Export PDF" : "PDF Export";

  static String courseGeneratedSuccess(BuildContext context) => _isFr(context)
      ? "Cours généré avec succès !"
      : "Course generated successfully!";
}
