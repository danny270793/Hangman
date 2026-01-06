import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hangman/pages/splash.dart';
import 'package:hangman/pages/login.dart';
import 'package:hangman/pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(routes: [
        GoRoute(path: SplashPage.routeName, builder: (context, state) => const SplashPage()),
        GoRoute(path: LoginPage.routeName, builder: (context, state) => const LoginPage()),
        GoRoute(path: HomePage.routeName, builder: (context, state) => const HomePage()),
      ]),
      title: 'Flutter Demo',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
    );
  }
}
