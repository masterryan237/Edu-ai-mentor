import 'package:eduai_mentor/services/auth_service.dart';
import 'package:eduai_mentor/utilis/app_texts_utils.dart';
import 'package:eduai_mentor/utilis/build_stats_card_utils.dart';
import 'package:eduai_mentor/utilis/lang_utils.dart';
import 'package:eduai_mentor/utilis/stats_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  // Fonction pour extraire le username de l'email (ex: "john.doe" de john.doe@mail.com)
  String get username => user?.email?.split('@')[0] ?? "Utilisateur";

  // Fonction pour compter les documents dans une collection spécifique

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTexts.profileTitle(context)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Section Identité
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 15),
              Text(
                "USER ID: ${user?.uid.substring(0, 8)}...", // ID raccourci pour le style
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 5),
              Text(
                username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                AppTexts.connectedWith(context, user!.email!),
                style: const TextStyle(color: Colors.blueGrey),
              ),

              const SizedBox(height: 30),
              const Divider(),

              // Section Stats
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppTexts.statsTitle(context),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  buildStatCard(
                    AppTexts.uploads(context),
                    getCount(
                      "users/${user?.uid}/courses",
                    ), // Ton chemin d'upload manuel
                    Icons.upload_file,
                    Colors.orange,
                  ),
                  const SizedBox(width: 15),
                  buildStatCard(
                    AppTexts.aiCourses(context),
                    getCount(
                      "users/${user?.uid}/generated_courses",
                    ), // Ton chemin de génération IA
                    Icons.auto_awesome,
                    Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 30),
              const Divider(),

              // Section Settings
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppTexts.settings(context),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),

              ListTile(
                leading: const Icon(Icons.lock_reset, color: Colors.blue),
                title: Text(AppTexts.changePassword(context)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Logique pour envoyer un mail de reset
                  if (user?.email != null) {
                    AuthService().resetPassword(user!.email!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppTexts.resetEmailSent(context))),
                    );
                  }
                },
              ),

              Semantics(
                identifier: "sign-out",
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    AppTexts.signOut(context),
                    style: TextStyle(color: Colors.red),
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
              ListTile(
                title: Text(AppTexts.language(context)),
                trailing: DropdownButton<String>(
                  value: context.watch<LocaleProvider>().locale?.languageCode,
                  items: const [
                    DropdownMenuItem(value: 'fr', child: Text("Français")),
                    DropdownMenuItem(value: 'en', child: Text("English")),
                  ],
                  onChanged: (String? code) {
                    if (code != null) {
                      context.read<LocaleProvider>().setLocale(Locale(code));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour créer une carte de statistique
}
