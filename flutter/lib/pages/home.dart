import 'package:flutter/material.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:hangman/pages/settings.dart';
import 'package:hangman/pages/game.dart';
import 'package:hangman/services/difficulty_service.dart';
import 'package:hangman/services/timed_mode_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  static const String routeName = '/';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final difficultyService = context.watch<DifficultyService>();
    final timedModeService = context.watch<TimedModeService>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: OrientationBuilder(
                    builder: (context, orientation) {
                      final isLandscape = orientation == Orientation.landscape;
                      
                      if (isLandscape) {
                        return _buildLandscapeLayout(context, l10n, difficultyService, timedModeService);
                      } else {
                        return _buildPortraitLayout(context, l10n, difficultyService, timedModeService);
                      }
                    },
                  ),
                ),
              ),
              
              // Settings button in top-right corner
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  iconSize: 28,
                  onPressed: () {
                    context.push(SettingsPage.routeName);
                  },
                  tooltip: l10n.settings,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(
    BuildContext context,
    AppLocalizations l10n,
    DifficultyService difficultyService,
    TimedModeService timedModeService,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo/Title Section
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.games_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.hangmanGame,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 48),

        // Game Configuration Card
        _buildConfigurationCard(context, l10n, difficultyService, timedModeService),
        const SizedBox(height: 48),

        // Let's Play Button
        _buildPlayButton(context, l10n),
      ],
    );
  }

  Widget _buildLandscapeLayout(
    BuildContext context,
    AppLocalizations l10n,
    DifficultyService difficultyService,
    TimedModeService timedModeService,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left side - Logo and Title
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.games_outlined,
                  size: 60,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.hangmanGame,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        
        // Right side - Configuration and Play Button
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildConfigurationCard(context, l10n, difficultyService, timedModeService),
              const SizedBox(height: 24),
              _buildPlayButton(context, l10n),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfigurationCard(
    BuildContext context,
    AppLocalizations l10n,
    DifficultyService difficultyService,
    TimedModeService timedModeService,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.gameConfiguration,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 24),

            // Difficulty Setting
            _buildSettingsTile(
              context,
              icon: Icons.speed,
              title: l10n.difficulty,
              subtitle: _getDifficultyLabel(l10n, difficultyService.difficulty),
              onTap: () {
                _showDifficultyPicker(context, l10n, difficultyService);
              },
            ),
            const Divider(height: 24),

            // Timed Mode Setting
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
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context, AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
          onPressed: () {
          context.push(GamePage.routeName);
          },
        icon: const Icon(Icons.play_arrow, size: 32),
        label: Text(
          l10n.letsPlay,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
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
      contentPadding: EdgeInsets.zero,
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

  String _getDifficultyLabel(AppLocalizations l10n, GameDifficulty difficulty) {
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
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.selectDifficulty),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: GameDifficulty.values.map((difficulty) {
              return RadioListTile<GameDifficulty>(
                title: Text(_getDifficultyLabel(l10n, difficulty)),
                value: difficulty,
                groupValue: difficultyService.difficulty,
                onChanged: (GameDifficulty? value) {
                  if (value != null) {
                    difficultyService.setDifficulty(value);
                    Navigator.of(dialogContext).pop();
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
