import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hangman/pages/splash.dart';
import 'package:hangman/pages/login.dart';
import 'package:hangman/pages/home.dart';
import 'package:hangman/services/auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final protectedPages = const [
    HomePage.routeName,
  ];
  final publicPages = const [
    SplashPage.routeName,
    LoginPage.routeName,
  ];
  final authService = AuthService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        refreshListenable: authService,
        redirect: (context, state) {
          final isLoggedIn = authService.isAuthenticated;
          final location = state.matchedLocation;

          final isPublicPage = publicPages.contains(location);
          final isProtectedPage = protectedPages.contains(location);

          if (!isLoggedIn && isProtectedPage) {
            return LoginPage.routeName;
          }

          if (isLoggedIn && isPublicPage) {
            return HomePage.routeName;
          }

          return null;
        },
        routes: [
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
