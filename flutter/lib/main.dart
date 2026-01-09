import 'package:flutter/material.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hangman/pages/splash.dart';
import 'package:hangman/pages/login.dart';
import 'package:hangman/pages/register.dart';
import 'package:hangman/pages/home.dart';
import 'package:hangman/pages/game.dart';
import 'package:hangman/pages/settings.dart';
import 'package:hangman/pages/records.dart';
import 'package:hangman/pages/privacy.dart';
import 'package:hangman/pages/terms.dart';
import 'package:hangman/pages/about.dart';
import 'package:hangman/services/auth_service.dart';
import 'package:hangman/services/locale_service.dart';
import 'package:hangman/services/theme_service.dart';
import 'package:hangman/services/difficulty_service.dart';
import 'package:hangman/services/timed_mode_service.dart';
import 'package:hangman/config/supabase_config.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Initialize services and load saved preferences
  final localeService = LocaleService();
  await localeService.loadLocale();

  final themeService = ThemeService();
  await themeService.loadTheme();

  final difficultyService = DifficultyService();
  await difficultyService.loadDifficulty();

  final timedModeService = TimedModeService();
  await timedModeService.loadTimedMode();

  final authService = AuthService();
  await authService.loadAuth();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider<LocaleService>.value(value: localeService),
        ChangeNotifierProvider<ThemeService>.value(value: themeService),
        ChangeNotifierProvider<DifficultyService>.value(
          value: difficultyService,
        ),
        ChangeNotifierProvider<TimedModeService>.value(value: timedModeService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
    final protectedPages = const [
      HomePage.routeName,
      GamePage.routeName,
      SettingsPage.routeName,
      RecordsPage.routeName,
      PrivacyPage.routeName,
      TermsPage.routeName,
      AboutPage.routeName,
    ];
  final publicPages = const [
    SplashPage.routeName,
    LoginPage.routeName,
    RegisterPage.routeName,
  ];

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final localeService = context.watch<LocaleService>();
    final themeService = context.watch<ThemeService>();

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
            path: RegisterPage.routeName,
            builder: (context, state) => const RegisterPage(),
          ),
          GoRoute(
            path: HomePage.routeName,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: GamePage.routeName,
            builder: (context, state) => const GamePage(),
          ),
          GoRoute(
            path: SettingsPage.routeName,
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: RecordsPage.routeName,
            builder: (context, state) => const RecordsPage(),
          ),
          GoRoute(
            path: PrivacyPage.routeName,
            builder: (context, state) => const PrivacyPage(),
          ),
          GoRoute(
            path: TermsPage.routeName,
            builder: (context, state) => const TermsPage(),
          ),
          GoRoute(
            path: AboutPage.routeName,
            builder: (context, state) => const AboutPage(),
          ),
        ],
      ),
      title: 'Flutter Demo',
      locale: localeService.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: themeService.materialThemeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
    );
  }
}
