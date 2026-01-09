import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hangman/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;

class AboutPage extends StatefulWidget {
  static const String routeName = '/about';

  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  PackageInfo? _packageInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _packageInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getPlatformName() {
    if (kIsWeb) {
      return 'Web';
    } else {
      try {
        if (Platform.isAndroid) return 'Android';
        if (Platform.isIOS) return 'iOS';
        if (Platform.isMacOS) return 'macOS';
        if (Platform.isWindows) return 'Windows';
        if (Platform.isLinux) return 'Linux';
        if (Platform.isFuchsia) return 'Fuchsia';
      } catch (e) {
        // Platform detection failed
      }
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    // App Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Image.asset(
                          'assets/icons/icon.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // App Name
                    Text(
                      _packageInfo?.appName ?? l10n.hangmanGame,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      l10n.challengeYourVocabulary,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Version Information Card
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              context,
                              Icons.info_outline,
                              l10n.appVersion,
                              _packageInfo?.version ?? '1.0.0',
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              context,
                              Icons.tag,
                              l10n.buildNumber,
                              _packageInfo?.buildNumber ?? '1',
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              context,
                              Icons.devices,
                              l10n.platform,
                              _getPlatformName(),
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              context,
                              Icons.apps,
                              l10n.packageName,
                              _packageInfo?.packageName ??
                                  'com.example.hangman',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Description
                    Text(
                      l10n.appDescription(l10n.hangmanGame),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Features
                    _buildFeaturesList(context),

                    const SizedBox(height: 32),

                    // Tech Stack
                    _buildTechStack(context),

                    const SizedBox(height: 32),

                    // Credits
                    Text(
                      l10n.madeWithLove,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Copyright
                    Text(
                      l10n.copyright,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      l10n.allRightsReserved,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final features = [
      {
        'icon': Icons.translate,
        'text': l10n.featureMultilingual,
      },
      {'icon': Icons.emoji_events, 'text': l10n.featureLeaderboards},
      {'icon': Icons.tune, 'text': l10n.featureDifficulty},
      {'icon': Icons.timer, 'text': l10n.featureTimed},
      {'icon': Icons.dark_mode, 'text': l10n.featureDarkMode},
      {'icon': Icons.person, 'text': l10n.featureProfiles},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.features,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            ...features.map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      size: 20,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature['text'] as String,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechStack(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final techStack = [
      {'text': l10n.techFlutter, 'initial': 'F'},
      {'text': l10n.techSupabase, 'initial': 'S'},
      {'text': l10n.techProvider, 'initial': 'P'},
      {'text': l10n.techGoRouter, 'initial': 'G'},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.build_circle_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.builtWith,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: techStack
                  .map(
                    (tech) => Chip(
                      avatar: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          tech['initial'] as String,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      label: Text(tech['text'] as String),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
