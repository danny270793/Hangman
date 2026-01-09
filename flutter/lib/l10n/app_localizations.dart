import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Hangman'**
  String get appTitle;

  /// No description provided for @splashTitle.
  ///
  /// In en, this message translates to:
  /// **'HANGMAN'**
  String get splashTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Guess the Word'**
  String get splashSubtitle;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue playing'**
  String get signInToContinue;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get enterUsername;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get pleaseEnterUsername;

  /// No description provided for @usernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameMinLength;

  /// No description provided for @usernameMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'Username must be different'**
  String get usernameMustBeDifferent;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccess;

  /// No description provided for @checkEmailToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Please check your email to confirm your account before logging in.'**
  String get checkEmailToConfirm;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @createOne.
  ///
  /// In en, this message translates to:
  /// **'Create one'**
  String get createOne;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @enterConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your new password'**
  String get enterConfirmPassword;

  /// No description provided for @readyToTest.
  ///
  /// In en, this message translates to:
  /// **'Ready to test your vocabulary?'**
  String get readyToTest;

  /// No description provided for @hangmanGame.
  ///
  /// In en, this message translates to:
  /// **'Hangman Game'**
  String get hangmanGame;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @guessesLeft.
  ///
  /// In en, this message translates to:
  /// **'Lives'**
  String get guessesLeft;

  /// No description provided for @lettersUsed.
  ///
  /// In en, this message translates to:
  /// **'Letters'**
  String get lettersUsed;

  /// No description provided for @youWon.
  ///
  /// In en, this message translates to:
  /// **'🎉 You Won!'**
  String get youWon;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'😢 Game Over!'**
  String get gameOver;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Profile Photo'**
  String get changeProfilePhoto;

  /// No description provided for @selectPhotoSource.
  ///
  /// In en, this message translates to:
  /// **'Select Photo Source'**
  String get selectPhotoSource;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changeUsername.
  ///
  /// In en, this message translates to:
  /// **'Change Username'**
  String get changeUsername;

  /// No description provided for @currentEmail.
  ///
  /// In en, this message translates to:
  /// **'Current Email'**
  String get currentEmail;

  /// No description provided for @currentUsername.
  ///
  /// In en, this message translates to:
  /// **'Current Username'**
  String get currentUsername;

  /// No description provided for @newEmail.
  ///
  /// In en, this message translates to:
  /// **'New Email'**
  String get newEmail;

  /// No description provided for @enterNewEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your new email'**
  String get enterNewEmail;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get enterCurrentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password'**
  String get enterNewPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @newUsername.
  ///
  /// In en, this message translates to:
  /// **'New Username'**
  String get newUsername;

  /// No description provided for @enterNewUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter your new username'**
  String get enterNewUsername;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @newPasswordMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from current password'**
  String get newPasswordMustBeDifferent;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get invalidEmail;

  /// No description provided for @emailMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'Email must be different'**
  String get emailMustBeDifferent;

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully!'**
  String get updateSuccess;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get soundEffects;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @gameSettings.
  ///
  /// In en, this message translates to:
  /// **'Game Settings'**
  String get gameSettings;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @timedMode.
  ///
  /// In en, this message translates to:
  /// **'Timed Mode'**
  String get timedMode;

  /// No description provided for @playWithTimer.
  ///
  /// In en, this message translates to:
  /// **'Play with a timer'**
  String get playWithTimer;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoon;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @selectDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Select Difficulty'**
  String get selectDifficulty;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @wordsSolved.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get wordsSolved;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get totalTime;

  /// No description provided for @nextWord.
  ///
  /// In en, this message translates to:
  /// **'Next Word'**
  String get nextWord;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get points;

  /// No description provided for @letsPlay.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Play!'**
  String get letsPlay;

  /// No description provided for @seeRecords.
  ///
  /// In en, this message translates to:
  /// **'See Records'**
  String get seeRecords;

  /// No description provided for @gameRecords.
  ///
  /// In en, this message translates to:
  /// **'Game Records'**
  String get gameRecords;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @player.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// No description provided for @noRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No records yet. Be the first to play!'**
  String get noRecordsYet;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @gameConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Game Configuration'**
  String get gameConfiguration;

  /// No description provided for @exitGame.
  ///
  /// In en, this message translates to:
  /// **'Exit Game?'**
  String get exitGame;

  /// No description provided for @exitGameConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit? Your current progress will be lost.'**
  String get exitGameConfirmation;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @infoWeCollect.
  ///
  /// In en, this message translates to:
  /// **'Information We Collect'**
  String get infoWeCollect;

  /// No description provided for @infoWeCollectContent.
  ///
  /// In en, this message translates to:
  /// **'This app collects minimal information to provide the game experience:\n\n• Email address and username for account creation\n• Game statistics (scores, words solved, time played)\n• User preferences (language, theme, difficulty settings)\n• Profile photo (stored locally on your device)'**
  String get infoWeCollectContent;

  /// No description provided for @howWeUseInfo.
  ///
  /// In en, this message translates to:
  /// **'How We Use Your Information'**
  String get howWeUseInfo;

  /// No description provided for @howWeUseInfoContent.
  ///
  /// In en, this message translates to:
  /// **'We use the collected information to:\n\n• Authenticate your account\n• Store your game progress and statistics\n• Personalize your game experience\n• Display leaderboards with usernames\n• Save your preferences across sessions'**
  String get howWeUseInfoContent;

  /// No description provided for @dataStorageSecurity.
  ///
  /// In en, this message translates to:
  /// **'Data Storage and Security'**
  String get dataStorageSecurity;

  /// No description provided for @dataStorageSecurityContent.
  ///
  /// In en, this message translates to:
  /// **'• All user data is stored securely using Supabase\n• Passwords are encrypted and never stored in plain text\n• Profile photos are stored locally on your device\n• Game records are associated with your account\n• We implement industry-standard security measures'**
  String get dataStorageSecurityContent;

  /// No description provided for @dataSharing.
  ///
  /// In en, this message translates to:
  /// **'Data Sharing'**
  String get dataSharing;

  /// No description provided for @dataSharingContent.
  ///
  /// In en, this message translates to:
  /// **'We do not sell or share your personal information with third parties. Game statistics (username, scores) are visible to other players on leaderboards.'**
  String get dataSharingContent;

  /// No description provided for @yourRights.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get yourRights;

  /// No description provided for @yourRightsContent.
  ///
  /// In en, this message translates to:
  /// **'You have the right to:\n\n• Access your personal data\n• Update your account information\n• Change your email and password\n• Delete your account and associated data\n• Export your game statistics'**
  String get yourRightsContent;

  /// No description provided for @childrensPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Children\'s Privacy'**
  String get childrensPrivacy;

  /// No description provided for @childrensPrivacyContent.
  ///
  /// In en, this message translates to:
  /// **'This app is suitable for all ages. We do not knowingly collect personal information from children under 13 without parental consent.'**
  String get childrensPrivacyContent;

  /// No description provided for @changesToPolicy.
  ///
  /// In en, this message translates to:
  /// **'Changes to This Policy'**
  String get changesToPolicy;

  /// No description provided for @changesToPolicyContent.
  ///
  /// In en, this message translates to:
  /// **'We may update this privacy policy from time to time. We will notify you of any changes by updating the \"Last Updated\" date.'**
  String get changesToPolicyContent;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @contactUsContent.
  ///
  /// In en, this message translates to:
  /// **'If you have questions about this privacy policy, please contact us through the app settings.'**
  String get contactUsContent;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated: {date}'**
  String lastUpdated(String date);

  /// No description provided for @acceptanceOfTerms.
  ///
  /// In en, this message translates to:
  /// **'Acceptance of Terms'**
  String get acceptanceOfTerms;

  /// No description provided for @acceptanceOfTermsContent.
  ///
  /// In en, this message translates to:
  /// **'By accessing and using this Hangman game app, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by these terms, please do not use this app.'**
  String get acceptanceOfTermsContent;

  /// No description provided for @userAccount.
  ///
  /// In en, this message translates to:
  /// **'User Account'**
  String get userAccount;

  /// No description provided for @userAccountContent.
  ///
  /// In en, this message translates to:
  /// **'To access certain features of the app, you must create an account by providing:\n\n• A valid email address\n• A unique username\n• A secure password\n\nYou are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.'**
  String get userAccountContent;

  /// No description provided for @userConduct.
  ///
  /// In en, this message translates to:
  /// **'User Conduct'**
  String get userConduct;

  /// No description provided for @userConductContent.
  ///
  /// In en, this message translates to:
  /// **'You agree to use the app only for lawful purposes. You must not:\n\n• Use offensive or inappropriate usernames\n• Attempt to manipulate game scores or statistics\n• Interfere with other users\' experience\n• Attempt to gain unauthorized access to the app or its systems\n• Upload malicious code or content\n• Violate any applicable laws or regulations'**
  String get userConductContent;

  /// No description provided for @gameRulesFairPlay.
  ///
  /// In en, this message translates to:
  /// **'Game Rules and Fair Play'**
  String get gameRulesFairPlay;

  /// No description provided for @gameRulesFairPlayContent.
  ///
  /// In en, this message translates to:
  /// **'The game is intended for entertainment purposes. We expect all users to play fairly:\n\n• Do not use automated tools or scripts\n• Play the game as intended\n• Respect the leaderboard and competition\n• We reserve the right to remove records that appear to be fraudulent'**
  String get gameRulesFairPlayContent;

  /// No description provided for @intellectualProperty.
  ///
  /// In en, this message translates to:
  /// **'Intellectual Property'**
  String get intellectualProperty;

  /// No description provided for @intellectualPropertyContent.
  ///
  /// In en, this message translates to:
  /// **'All content, features, and functionality of this app, including but not limited to text, graphics, logos, and software, are owned by the app developers and are protected by copyright, trademark, and other intellectual property laws.'**
  String get intellectualPropertyContent;

  /// No description provided for @userGeneratedContent.
  ///
  /// In en, this message translates to:
  /// **'User-Generated Content'**
  String get userGeneratedContent;

  /// No description provided for @userGeneratedContentContent.
  ///
  /// In en, this message translates to:
  /// **'You retain ownership of your game statistics and profile information. By using the app, you grant us a license to display your username and game scores on leaderboards visible to other users.'**
  String get userGeneratedContentContent;

  /// No description provided for @serviceAvailability.
  ///
  /// In en, this message translates to:
  /// **'Service Availability'**
  String get serviceAvailability;

  /// No description provided for @serviceAvailabilityContent.
  ///
  /// In en, this message translates to:
  /// **'We strive to keep the app available 24/7, but we do not guarantee uninterrupted access. We reserve the right to:\n\n• Modify or discontinue features\n• Perform maintenance and updates\n• Suspend access for violations of these terms'**
  String get serviceAvailabilityContent;

  /// No description provided for @accountTermination.
  ///
  /// In en, this message translates to:
  /// **'Account Termination'**
  String get accountTermination;

  /// No description provided for @accountTerminationContent.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to suspend or terminate your account if:\n\n• You violate these terms of service\n• You engage in fraudulent activity\n• We receive valid legal requests\n\nYou may also delete your account at any time through the app settings.'**
  String get accountTerminationContent;

  /// No description provided for @disclaimerWarranties.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer of Warranties'**
  String get disclaimerWarranties;

  /// No description provided for @disclaimerWarrantiesContent.
  ///
  /// In en, this message translates to:
  /// **'The app is provided \"as is\" and \"as available\" without warranties of any kind, either express or implied. We do not warrant that the app will be error-free or that defects will be corrected.'**
  String get disclaimerWarrantiesContent;

  /// No description provided for @limitationLiability.
  ///
  /// In en, this message translates to:
  /// **'Limitation of Liability'**
  String get limitationLiability;

  /// No description provided for @limitationLiabilityContent.
  ///
  /// In en, this message translates to:
  /// **'To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of or inability to use the app.'**
  String get limitationLiabilityContent;

  /// No description provided for @changesToTerms.
  ///
  /// In en, this message translates to:
  /// **'Changes to Terms'**
  String get changesToTerms;

  /// No description provided for @changesToTermsContent.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to modify these terms at any time. We will notify users of significant changes. Continued use of the app after changes constitutes acceptance of the new terms.'**
  String get changesToTermsContent;

  /// No description provided for @governingLaw.
  ///
  /// In en, this message translates to:
  /// **'Governing Law'**
  String get governingLaw;

  /// No description provided for @governingLawContent.
  ///
  /// In en, this message translates to:
  /// **'These terms shall be governed by and construed in accordance with applicable laws, without regard to its conflict of law provisions.'**
  String get governingLawContent;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @contactInformationContent.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about these Terms of Service, please contact us through the app settings.'**
  String get contactInformationContent;

  /// No description provided for @challengeYourVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Challenge your vocabulary!'**
  String get challengeYourVocabulary;

  /// No description provided for @versionInfo.
  ///
  /// In en, this message translates to:
  /// **'Version Information'**
  String get versionInfo;

  /// No description provided for @buildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get buildNumber;

  /// No description provided for @platform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// No description provided for @packageName.
  ///
  /// In en, this message translates to:
  /// **'Package Name'**
  String get packageName;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'{appName} is a fun and engaging word guessing game that helps you expand your vocabulary while having fun. Test your skills across different difficulty levels and compete with players worldwide!'**
  String appDescription(String appName);

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @featureMultilingual.
  ///
  /// In en, this message translates to:
  /// **'Multilingual support (English & Spanish)'**
  String get featureMultilingual;

  /// No description provided for @featureLeaderboards.
  ///
  /// In en, this message translates to:
  /// **'Global leaderboards'**
  String get featureLeaderboards;

  /// No description provided for @featureDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Customizable difficulty levels'**
  String get featureDifficulty;

  /// No description provided for @featureTimed.
  ///
  /// In en, this message translates to:
  /// **'Optional timed challenges'**
  String get featureTimed;

  /// No description provided for @featureDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode support'**
  String get featureDarkMode;

  /// No description provided for @featureProfiles.
  ///
  /// In en, this message translates to:
  /// **'User profiles and statistics'**
  String get featureProfiles;

  /// No description provided for @builtWith.
  ///
  /// In en, this message translates to:
  /// **'Built With'**
  String get builtWith;

  /// No description provided for @techFlutter.
  ///
  /// In en, this message translates to:
  /// **'Flutter: UI Framework'**
  String get techFlutter;

  /// No description provided for @techSupabase.
  ///
  /// In en, this message translates to:
  /// **'Supabase: Backend & Auth'**
  String get techSupabase;

  /// No description provided for @techProvider.
  ///
  /// In en, this message translates to:
  /// **'Provider: State Management'**
  String get techProvider;

  /// No description provided for @techGoRouter.
  ///
  /// In en, this message translates to:
  /// **'GoRouter: Navigation'**
  String get techGoRouter;

  /// No description provided for @madeWithLove.
  ///
  /// In en, this message translates to:
  /// **'Made with ❤️ using Flutter'**
  String get madeWithLove;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Hangman Game'**
  String get copyright;

  /// No description provided for @allRightsReserved.
  ///
  /// In en, this message translates to:
  /// **'All rights reserved'**
  String get allRightsReserved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
