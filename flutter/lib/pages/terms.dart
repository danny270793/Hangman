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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(context, l10n.acceptanceOfTerms, l10n.acceptanceOfTermsContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.userAccount, l10n.userAccountContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.userConduct, l10n.userConductContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.gameRulesFairPlay, l10n.gameRulesFairPlayContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.intellectualProperty, l10n.intellectualPropertyContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.userGeneratedContent, l10n.userGeneratedContentContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.serviceAvailability, l10n.serviceAvailabilityContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.accountTermination, l10n.accountTerminationContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.disclaimerWarranties, l10n.disclaimerWarrantiesContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.limitationLiability, l10n.limitationLiabilityContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.changesToTerms, l10n.changesToTermsContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.governingLaw, l10n.governingLawContent),
              const SizedBox(height: 24),
              _buildSection(context, l10n.contactInformation, l10n.contactInformationContent),
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
