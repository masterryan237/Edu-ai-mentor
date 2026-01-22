import 'package:eduai_mentor/providers/ai_provider.dart';
import 'package:eduai_mentor/utilis/lang_utils.dart';
import 'package:eduai_mentor/utilis/theme_app.dart';
import 'package:eduai_mentor/views/ai/quizz_page.dart';
import 'package:eduai_mentor/views/auth/email_verification_view.dart';
import 'package:eduai_mentor/views/auth/login_view.dart';
import 'package:eduai_mentor/views/auth/register_view.dart';
import 'package:eduai_mentor/views/home_page.dart';
import 'package:eduai_mentor/views/initialize_app/splash_screen.dart';
import 'package:eduai_mentor/views/user_document_view/MyCourses.dart';
import 'package:eduai_mentor/views/user_document_view/quizz_detail.dart';
import 'package:eduai_mentor/views/user_init_infos/avatar_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>(
          create: (context) => LocaleProvider(),
        ),
        ChangeNotifierProxyProvider<LocaleProvider, AiServiceProvider>(
          create: (context) => AiServiceProvider(),
          update: (context, localeProvider, aiServiceProvider) {
            if (aiServiceProvider == null) {
              return AiServiceProvider();
            }
            // Mettez à jour AiServiceProvider si nécessaire
            // Par exemple, changer la langue
            return aiServiceProvider;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return MaterialApp(
      title: 'Flutter Demo',
      locale: localeProvider.locale,
      theme: educationTheme(),
      supportedLocales: const [Locale('en', ''), Locale('fr', '')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;

        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return const Locale('en', ''); // Anglais par défaut
      },
      home: const SplashScreen(),
      routes: {
        '/login/': (context) => LoginView(),
        '/register/': (context) => RegisterView(),
        '/emailVerification/': (context) => EmailVerificationView(),
        '/home/': (context) => HomePage(),
        '/Mycourse/': (context) => MyCoursesTab(),
        '/QuizzTab/': (context) => QuizzTab(),
        '/avatarPicker/': (context) => AvatarPickerScreen(),
        '/quizDetailPage/': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return QuizDetailPage(
            quizId: args['quizId'],
            quizData: args['quizData'],
          );
        },
      },
    );
  }
}
