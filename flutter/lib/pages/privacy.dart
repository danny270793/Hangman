import 'package:flutter/material.dart';
import 'package:hangman/l10n/app_localizations.dart';

class PrivacyPage extends StatelessWidget {
  static const String routeName = '/privacy';

  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyPolicy)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Information We Collect',
              'This app collects minimal information to provide the game experience:\n\n'
                  '• Email address and username for account creation\n'
                  '• Game statistics (scores, words solved, time played)\n'
                  '• User preferences (language, theme, difficulty settings)\n'
                  '• Profile photo (stored locally on your device)',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'How We Use Your Information',
              'We use the collected information to:\n\n'
                  '• Authenticate your account\n'
                  '• Store your game progress and statistics\n'
                  '• Personalize your game experience\n'
                  '• Display leaderboards with usernames\n'
                  '• Save your preferences across sessions',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Data Storage and Security',
              '• All user data is stored securely using Supabase\n'
                  '• Passwords are encrypted and never stored in plain text\n'
                  '• Profile photos are stored locally on your device\n'
                  '• Game records are associated with your account\n'
                  '• We implement industry-standard security measures',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Data Sharing',
              'We do not sell or share your personal information with third parties. '
                  'Game statistics (username, scores) are visible to other players on leaderboards.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Your Rights',
              'You have the right to:\n\n'
                  '• Access your personal data\n'
                  '• Update your account information\n'
                  '• Change your email and password\n'
                  '• Delete your account and associated data\n'
                  '• Export your game statistics',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Children\'s Privacy',
              'This app is suitable for all ages. We do not knowingly collect '
                  'personal information from children under 13 without parental consent.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Changes to This Policy',
              'We may update this privacy policy from time to time. '
                  'We will notify you of any changes by updating the "Last Updated" date.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Contact Us',
              'If you have questions about this privacy policy, please contact us through the app settings.',
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Last Updated: January 2026',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
