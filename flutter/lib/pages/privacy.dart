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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(context, l10n.infoWeCollect, l10n.infoWeCollectContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.howWeUseInfo, l10n.howWeUseInfoContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.dataStorageSecurity, l10n.dataStorageSecurityContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.dataSharing, l10n.dataSharingContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.yourRights, l10n.yourRightsContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.childrensPrivacy, l10n.childrensPrivacyContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.changesToPolicy, l10n.changesToPolicyContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.contactUs, l10n.contactUsContent),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  l10n.lastUpdated('January 2026'),
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
