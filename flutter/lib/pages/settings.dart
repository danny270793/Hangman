import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:hangman/pages/privacy.dart';
import 'package:hangman/pages/terms.dart';
import 'package:hangman/pages/about.dart';
import 'package:hangman/services/auth_service.dart';
import 'package:hangman/services/locale_service.dart';
import 'package:hangman/services/theme_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = '/settings';

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String _profileImageKey = 'profile_image_path';
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString(_profileImageKey);
    if (imagePath != null && await File(imagePath).exists()) {
      setState(() {
        _profileImagePath = imagePath;
      });
    }
  }

  Future<void> _saveProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileImageKey, path);
    setState(() {
      _profileImagePath = path;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        await _saveProfileImage(image.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.updateSuccess),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
      }
    }
  }

  void _showImageSourceDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.selectPhotoSource),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(l10n.camera),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l10n.gallery),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeService = context.watch<LocaleService>();
    final themeService = context.watch<ThemeService>();
    final authService = context.watch<AuthService>();

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
                GestureDetector(
                  onTap: () => _showImageSourceDialog(l10n),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        backgroundImage: _profileImagePath != null
                            ? FileImage(File(_profileImagePath!))
                            : null,
                        child: _profileImagePath == null
                            ? const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Profile Section
          _buildSectionHeader(context, l10n.profile),
          _buildSettingsTile(
            context,
            icon: Icons.email_outlined,
            title: l10n.changeEmail,
            subtitle: authService.userEmail ?? l10n.currentEmail,
            onTap: () {
              _showChangeEmailDialog(context, l10n);
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.lock_outlined,
            title: l10n.changePassword,
            onTap: () {
              _showChangePasswordDialog(context, l10n);
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.person_outlined,
            title: l10n.changeUsername,
            subtitle: authService.userName ?? l10n.currentUsername,
            onTap: () {
              _showChangeUsernameDialog(context, l10n);
            },
          ),

          const Divider(height: 32),

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

          // About Section
          _buildSectionHeader(context, l10n.about),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: l10n.appVersion,
            subtitle: '1.0.0',
            onTap: () {
              context.push(AboutPage.routeName);
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyPolicy,
            onTap: () {
              context.push(PrivacyPage.routeName);
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.description_outlined,
            title: l10n.termsOfService,
            onTap: () {
              context.push(TermsPage.routeName);
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

  void _showChangeEmailDialog(BuildContext context, AppLocalizations l10n) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final authService = context.read<AuthService>();

    // Pre-fill with current email
    emailController.text = authService.userEmail ?? '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.changeEmail),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: l10n.newEmail,
                        hintText: l10n.enterNewEmail,
                        prefixIcon: const Icon(Icons.email),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseEnterEmail;
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return l10n.invalidEmail;
                        }
                        if (value == authService.userEmail) {
                          return l10n.emailMustBeDifferent;
                        }
                        return null;
                      },
                    ),
                    if (isLoading) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setDialogState(() {
                              isLoading = true;
                            });

                            final error = await authService.updateEmail(
                              emailController.text.trim(),
                            );

                            if (dialogContext.mounted) {
                              setDialogState(() {
                                isLoading = false;
                              });

                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                Navigator.of(dialogContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.updateSuccess),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(l10n.update),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context, AppLocalizations l10n) {
    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final authService = context.read<AuthService>();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.changePassword),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: currentPasswordController,
                        decoration: InputDecoration(
                          labelText: l10n.currentPassword,
                          hintText: l10n.enterCurrentPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseEnterPassword;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: newPasswordController,
                        decoration: InputDecoration(
                          labelText: l10n.newPassword,
                          hintText: l10n.enterNewPassword,
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseEnterPassword;
                          }
                          if (value.length < 6) {
                            return l10n.passwordMinLength;
                          }
                          if (value == currentPasswordController.text) {
                            return l10n.newPasswordMustBeDifferent;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: l10n.confirmPassword,
                          hintText: l10n.enterConfirmPassword,
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                        enabled: !isLoading,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseEnterPassword;
                          }
                          if (value != newPasswordController.text) {
                            return l10n.passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),
                      if (isLoading) ...[
                        const SizedBox(height: 16),
                        const LinearProgressIndicator(),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setDialogState(() {
                              isLoading = true;
                            });

                            final error = await authService.updatePassword(
                              currentPassword: currentPasswordController.text,
                              newPassword: newPasswordController.text,
                            );

                            if (dialogContext.mounted) {
                              setDialogState(() {
                                isLoading = false;
                              });

                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                Navigator.of(dialogContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.updateSuccess),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(l10n.update),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangeUsernameDialog(BuildContext context, AppLocalizations l10n) {
    final formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController();
    final authService = context.read<AuthService>();

    // Pre-fill with current username
    usernameController.text = authService.userName ?? '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.changeUsername),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: l10n.newUsername,
                        hintText: l10n.enterNewUsername,
                        prefixIcon: const Icon(Icons.person),
                        border: const OutlineInputBorder(),
                      ),
                      enabled: !isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseEnterUsername;
                        }
                        if (value.length < 3) {
                          return l10n.usernameMinLength;
                        }
                        if (value == authService.userName) {
                          return l10n.usernameMustBeDifferent;
                        }
                        return null;
                      },
                    ),
                    if (isLoading) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            setDialogState(() {
                              isLoading = true;
                            });

                            final error = await authService.updateUsername(
                              usernameController.text.trim(),
                            );

                            if (dialogContext.mounted) {
                              setDialogState(() {
                                isLoading = false;
                              });

                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } else {
                                Navigator.of(dialogContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.updateSuccess),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(l10n.update),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
