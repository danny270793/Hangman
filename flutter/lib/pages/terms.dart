import 'package:flutter/material.dart';
import 'package:hangman/l10n/app_localizations.dart';

class TermsPage extends StatelessWidget {
  static const String routeName = '/terms';

  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.termsOfService)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Acceptance of Terms',
              'By accessing and using this Hangman game app, you accept and agree to be bound by the terms and provision of this agreement. '
                  'If you do not agree to abide by these terms, please do not use this app.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'User Account',
              'To access certain features of the app, you must create an account by providing:\n\n'
                  '• A valid email address\n'
                  '• A unique username\n'
                  '• A secure password\n\n'
                  'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'User Conduct',
              'You agree to use the app only for lawful purposes. You must not:\n\n'
                  '• Use offensive or inappropriate usernames\n'
                  '• Attempt to manipulate game scores or statistics\n'
                  '• Interfere with other users\' experience\n'
                  '• Attempt to gain unauthorized access to the app or its systems\n'
                  '• Upload malicious code or content\n'
                  '• Violate any applicable laws or regulations',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Game Rules and Fair Play',
              'The game is intended for entertainment purposes. We expect all users to play fairly:\n\n'
                  '• Do not use automated tools or scripts\n'
                  '• Play the game as intended\n'
                  '• Respect the leaderboard and competition\n'
                  '• We reserve the right to remove records that appear to be fraudulent',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Intellectual Property',
              'All content, features, and functionality of this app, including but not limited to text, graphics, logos, and software, '
                  'are owned by the app developers and are protected by copyright, trademark, and other intellectual property laws.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'User-Generated Content',
              'You retain ownership of your game statistics and profile information. '
                  'By using the app, you grant us a license to display your username and game scores on leaderboards visible to other users.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Service Availability',
              'We strive to keep the app available 24/7, but we do not guarantee uninterrupted access. '
                  'We reserve the right to:\n\n'
                  '• Modify or discontinue features\n'
                  '• Perform maintenance and updates\n'
                  '• Suspend access for violations of these terms',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Account Termination',
              'We reserve the right to suspend or terminate your account if:\n\n'
                  '• You violate these terms of service\n'
                  '• You engage in fraudulent activity\n'
                  '• We receive valid legal requests\n\n'
                  'You may also delete your account at any time through the app settings.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Disclaimer of Warranties',
              'The app is provided "as is" and "as available" without warranties of any kind, either express or implied. '
                  'We do not warrant that the app will be error-free or that defects will be corrected.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Limitation of Liability',
              'To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, special, consequential, '
                  'or punitive damages resulting from your use of or inability to use the app.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Changes to Terms',
              'We reserve the right to modify these terms at any time. We will notify users of significant changes. '
                  'Continued use of the app after changes constitutes acceptance of the new terms.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Governing Law',
              'These terms shall be governed by and construed in accordance with applicable laws, '
                  'without regard to its conflict of law provisions.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'Contact Information',
              'If you have any questions about these Terms of Service, please contact us through the app settings.',
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
