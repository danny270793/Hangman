import 'package:flutter/material.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:hangman/services/auth_service.dart';
import 'package:hangman/services/locale_service.dart';
import 'package:hangman/services/theme_service.dart';
import 'package:hangman/services/difficulty_service.dart';
import 'package:hangman/services/timed_mode_service.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  static const String routeName = '/settings';

  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeService = context.watch<LocaleService>();
    final themeService = context.watch<ThemeService>();
    final difficultyService = context.watch<DifficultyService>();
    final timedModeService = context.watch<TimedModeService>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.05),
                ],
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Player',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // General Settings Section
          _buildSectionHeader(context, l10n.general),
          _buildSettingsTile(
            context,
            icon: Icons.language,
            title: l10n.language,
            subtitle: _getLanguageName(localeService.locale.languageCode, l10n),
            onTap: () {
              _showLanguagePicker(context, l10n, localeService);
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.brightness_6,
            title: l10n.theme,
            subtitle: _getThemeName(themeService.themeMode, l10n),
            onTap: () {
              _showThemePicker(context, l10n, themeService);
            },
          ),

          const Divider(height: 32),

          // Game Settings Section
          _buildSectionHeader(context, l10n.gameSettings),
          _buildSettingsTile(
            context,
            icon: Icons.speed,
            title: l10n.difficulty,
            subtitle: _getDifficultyName(difficultyService.difficulty, l10n),
            onTap: () {
              _showDifficultyPicker(context, l10n, difficultyService);
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.timer,
            title: l10n.timedMode,
            subtitle: l10n.playWithTimer,
            trailing: Switch(
              value: timedModeService.isEnabled,
              onChanged: (value) {
                timedModeService.setTimedMode(value);
              },
            ),
          ),

          const Divider(height: 32),

          // About Section
          _buildSectionHeader(context, l10n.about),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: l10n.appVersion,
            subtitle: '1.0.0',
            onTap: () {},
          ),
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyPolicy,
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.description_outlined,
            title: l10n.termsOfService,
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.comingSoon)));
            },
          ),

          const Divider(height: 32),

          // Logout Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                _showLogoutDialog(context, l10n);
              },
              icon: const Icon(Icons.logout),
              label: Text(l10n.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: trailing == null ? onTap : null,
    );
  }

  void _showLogoutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.logout),
          content: Text(l10n.logoutConfirmation),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthService>().logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );
  }

  String _getLanguageName(String languageCode, AppLocalizations l10n) {
    switch (languageCode) {
      case 'en':
        return l10n.languageEnglish;
      case 'es':
        return l10n.languageSpanish;
      default:
        return l10n.languageEnglish;
    }
  }

  void _showLanguagePicker(
    BuildContext context,
    AppLocalizations l10n,
    LocaleService localeService,
  ) {
    final supportedLocales = AppLocalizations.supportedLocales;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.selectLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: supportedLocales.map((locale) {
              final isSelected =
                  locale.languageCode == localeService.locale.languageCode;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(_getLanguageName(locale.languageCode, l10n)),
                selected: isSelected,
                onTap: () {
                  localeService.setLocale(locale);
                  Navigator.of(dialogContext).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  String _getThemeName(AppThemeMode themeMode, AppLocalizations l10n) {
    switch (themeMode) {
      case AppThemeMode.system:
        return l10n.themeSystem;
      case AppThemeMode.light:
        return l10n.themeLight;
      case AppThemeMode.dark:
        return l10n.themeDark;
    }
  }

  void _showThemePicker(
    BuildContext context,
    AppLocalizations l10n,
    ThemeService themeService,
  ) {
    final themeOptions = AppThemeMode.values;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.selectTheme),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: themeOptions.map((mode) {
              final isSelected = mode == themeService.themeMode;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(_getThemeName(mode, l10n)),
                selected: isSelected,
                onTap: () {
                  themeService.setTheme(mode);
                  Navigator.of(dialogContext).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  String _getDifficultyName(GameDifficulty difficulty, AppLocalizations l10n) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return l10n.easy;
      case GameDifficulty.medium:
        return l10n.medium;
      case GameDifficulty.hard:
        return l10n.hard;
    }
  }

  void _showDifficultyPicker(
    BuildContext context,
    AppLocalizations l10n,
    DifficultyService difficultyService,
  ) {
    final difficultyOptions = GameDifficulty.values;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.selectDifficulty),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: difficultyOptions.map((difficulty) {
              final isSelected = difficulty == difficultyService.difficulty;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(_getDifficultyName(difficulty, l10n)),
                selected: isSelected,
                onTap: () {
                  difficultyService.setDifficulty(difficulty);
                  Navigator.of(dialogContext).pop();
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }
}
