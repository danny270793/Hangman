import 'package:flutter/material.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hangman/pages/splash.dart';
import 'package:hangman/pages/login.dart';
import 'package:hangman/pages/home.dart';
import 'package:hangman/pages/settings.dart';
import 'package:hangman/services/auth_service.dart';
import 'package:hangman/services/locale_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize LocaleService and load saved locale
  final localeService = LocaleService();
  await localeService.loadLocale();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        ChangeNotifierProvider<LocaleService>.value(
          value: localeService,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final protectedPages = const [HomePage.routeName, SettingsPage.routeName];
  final publicPages = const [SplashPage.routeName, LoginPage.routeName];

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final localeService = context.watch<LocaleService>();

    return MaterialApp.router(
      routerConfig: GoRouter(
        refreshListenable: authService,
        initialLocation: SplashPage.routeName,
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
          GoRoute(
            path: SplashPage.routeName,
            builder: (context, state) => const SplashPage(),
          ),
          GoRoute(
            path: LoginPage.routeName,
            builder: (context, state) => const LoginPage(),
          ),
          GoRoute(
            path: HomePage.routeName,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: SettingsPage.routeName,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
      title: 'Flutter Demo',
      locale: localeService.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
    );
  }
}
