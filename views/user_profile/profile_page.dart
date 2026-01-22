import 'package:eduai_mentor/services/auth_service.dart';
import 'package:eduai_mentor/utilis/app_texts_utils.dart';
import 'package:eduai_mentor/utilis/build_stats_card_utils.dart';
import 'package:eduai_mentor/utilis/lang_utils.dart';
import 'package:eduai_mentor/utilis/stats_utils.dart';
import 'package:eduai_mentor/views/ai/quizz_page.dart';
import 'package:eduai_mentor/views/user_document_view/MyCourses.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eduai_mentor/views/home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  // Fonction pour extraire le username de l'email
  String get username =>
      user?.email?.split('@')[0] ?? AppTexts.userFallback(context);

  // Initiales pour l'avatar
  String get initials {
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      final names = user!.displayName!.split(' ');
      if (names.length > 1) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      }
      return user!.displayName![0].toUpperCase();
    }
    if (user?.email != null) {
      return user!.email![0].toUpperCase();
    }
    return AppTexts.userFallback(context)[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final totalUploads = getCount("users/${user?.uid}/courses");
    final totalAiCourses = getCount("users/${user?.uid}/generated_courses");

    return Scaffold(
      backgroundColor: Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              // Navigation vers l'écran de sélection d'avatar si nécessaire
            },
            child: CircleAvatar(
              backgroundColor: Color(0xFF7B61FF).withOpacity(0.1),
              child: user?.photoURL != null
                  ? CircleAvatar(backgroundImage: NetworkImage(user!.photoURL!))
                  : Text(
                      initials,
                      style: TextStyle(
                        color: Color(0xFF7B61FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTexts.profile(context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              AppTexts.manageAccount(context),
              style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: Icon(Icons.refresh, color: Color(0xFF7B61FF)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Identité - Carte améliorée
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7B61FF), Color(0xFF9378FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF7B61FF).withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: Center(
                        child: user?.photoURL != null
                            ? CircleAvatar(
                                radius: 35,
                                backgroundImage: NetworkImage(user!.photoURL!),
                              )
                            : Text(
                                initials,
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            user?.email ?? AppTexts.noEmail(context),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.fingerprint,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  user?.uid != null
                                      ? AppTexts.profileID(context, user!.uid)
                                      : "ID: ...",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Section Statistiques - MODIFIÉ POUR ÉVITER L'OVERFLOW
              Text(
                AppTexts.learningStats(context),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 16),

              // Utilisation de ConstrainedBox pour fixer la hauteur
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: 130, maxHeight: 150),
                child: Row(
                  children: [
                    Expanded(
                      child: buildStatCard(
                        AppTexts.uploadedCourses(context),
                        totalUploads,
                        Icons.upload_file,
                        Color(0xFFFF9800),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: buildStatCard(
                        AppTexts.aiCourses(context),
                        totalAiCourses,
                        Icons.auto_awesome,
                        Color(0xFF9C27B0),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.verified,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTexts.activeAccount(context),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            AppTexts.connectedWith(context, user?.email ?? ""),
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Section Paramètres
              Text(
                AppTexts.accountSettings(context),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              SizedBox(height: 12),

              _buildSettingItem(
                icon: Icons.lock_reset,
                title: AppTexts.changePassword(context),
                subtitle: AppTexts.secureAccount(context),
                color: Color(0xFF2196F3),
                onTap: () {
                  if (user?.email != null) {
                    AuthService().resetPassword(user!.email!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppTexts.resetEmailSent(context)),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),

              _buildSettingItem(
                icon: Icons.language,
                title: AppTexts.language(context),
                subtitle: AppTexts.appLanguage(context),
                color: Color(0xFF7B61FF),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF7B61FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButton<String>(
                    value: context.watch<LocaleProvider>().locale?.languageCode,
                    underline: SizedBox(),
                    icon: Icon(Icons.arrow_drop_down, color: Color(0xFF7B61FF)),
                    style: TextStyle(fontSize: 14, color: Color(0xFF333333)),
                    items: [
                      DropdownMenuItem(
                        value: 'fr',
                        child: Text(
                          "${AppTexts.frenchFlag(context)} ${AppTexts.french(context)}",
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(
                          "${AppTexts.englishFlag(context)} ${AppTexts.english(context)}",
                        ),
                      ),
                    ],
                    onChanged: (String? code) {
                      if (code != null) {
                        context.read<LocaleProvider>().setLocale(Locale(code));
                      }
                    },
                  ),
                ),
              ),

              _buildSettingItem(
                icon: Icons.help_outline,
                title: AppTexts.helpSupport(context),
                subtitle: AppTexts.getHelp(context),
                color: Color(0xFFFF9800),
                onTap: () {
                  // TODO: Naviguer vers l'aide
                },
              ),

              _buildSettingItem(
                icon: Icons.info_outline,
                title: AppTexts.aboutApp(context, "1.0.2"),
                subtitle: AppTexts.version(context, "1.0.2"),
                color: Color(0xFF9C27B0),
                onTap: () {
                  // TODO: Naviguer vers À propos
                },
              ),

              SizedBox(height: 20),
              Divider(height: 1),
              SizedBox(height: 20),

              // Bouton Déconnexion
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Semantics(
                  identifier: "sign-out",
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.logout, color: Colors.red, size: 22),
                    ),
                    title: Text(
                      AppTexts.signOut(context),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    subtitle: Text(
                      AppTexts.signOutDescription(context),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.withOpacity(0.7),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.red,
                    ),
                    onTap: () async {
                      await AuthService().logOut();
                      if (mounted) {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/login/', (route) => false);
                      }
                    },
                  ),
                ),
              ),

              SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Profile est toujours à l'index 3
        onTap: (index) {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
            );
          } else if (index == 1) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MyCoursesTab()),
              (route) => false,
            );
          } else if (index == 2) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => QuizzTab()),
              (route) => false,
            );
          } else if (index == 3) {
            // Déjà sur Profile
          }
        },
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF7B61FF),
        unselectedItemColor: Color(0xFF999999),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppTexts.home(context),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: AppTexts.myCourses(context),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: AppTexts.quizz(context),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppTexts.profile(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
        ),
        trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
