import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/di/injection.dart';
import '../core/locale/app_locale_controller.dart';
import '../core/security/app_biometric_unlock_controller.dart';
import '../core/theme/app_theme_controller.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/auth/domain/usecases/update_email_usecase.dart';
import '../features/auth/domain/usecases/update_password_usecase.dart';
import '../features/auth/domain/usecases/update_username_usecase.dart';
import '../features/auth/presentation/cubit/settings_cubit.dart';
import '../features/auth/presentation/cubit/settings_state.dart';
import '../widgets/bottom_sheet_pinned_title.dart';

const _playStoreUrl =
    'https://play.google.com/store/apps/details?id=io.github.danny270793.hangman';

const _profileImageKey = 'profile_image_path';

final _emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

const int _kMinPasswordLength = 6;
const int _kMinUsernameLength = 3;

String _languageOptionLabel(AppLocalizations l10n, AppLanguagePreference p) =>
    switch (p) {
      AppLanguagePreference.system => l10n.settingsLanguageSystem,
      AppLanguagePreference.en => l10n.settingsLanguageEnglish,
      AppLanguagePreference.es => l10n.settingsLanguageSpanish,
    };

String _themeOptionLabel(AppLocalizations l10n, AppThemePreference p) =>
    switch (p) {
      AppThemePreference.system => l10n.settingsThemeSystem,
      AppThemePreference.light => l10n.settingsThemeLight,
      AppThemePreference.dark => l10n.settingsThemeDark,
    };

/// Bottom sheet with one check-marked row per option.
Future<void> _showOptionPickerSheet<T>(
  BuildContext context, {
  required String title,
  required List<T> options,
  required T selected,
  required String Function(T) label,
  required Future<void> Function(T) onSelected,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: false,
    isScrollControlled: true,
    builder: (sheetContext) => BottomSheetPinnedTitleScrollView(
      padding: EdgeInsets.zero,
      title: title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final option in options)
            ListTile(
              title: Text(label(option)),
              trailing: selected == option
                  ? Icon(
                      Icons.check,
                      color: Theme.of(sheetContext).colorScheme.primary,
                    )
                  : null,
              onTap: () async {
                await onSelected(option);
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
            ),
        ],
      ),
    ),
  );
}

Future<void> _setBiometricUnlockEnabled(
  BuildContext context,
  AppLocalizations l10n,
  AppBiometricUnlockController ctrl,
  bool enabled,
) async {
  if (!enabled) {
    await ctrl.setEnabled(false);
    return;
  }
  await ctrl.refreshAuthenticatorAvailability();
  if (!ctrl.authenticatorAvailable) {
    if (context.mounted) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(l10n.settingsBiometricUnavailable)),
      );
    }
    return;
  }
  final ok = await ctrl.localAuth
      .authenticate(
        localizedReason: l10n.settingsBiometricAuthReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      )
      .catchError((Object _) => false, test: (e) => e is LocalAuthException);
  if (!context.mounted) {
    return;
  }
  if (ok) {
    await ctrl.setEnabled(true);
  }
}

/// Opens a profile bottom sheet; shows [AppLocalizations.updateSuccess] and
/// calls [onChanged] when the sheet pops with `true`.
Future<void> _showProfileSheet(
  BuildContext context,
  AppLocalizations l10n, {
  required String title,
  required Widget Function(BuildContext hostContext) body,
  VoidCallback? onChanged,
}) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: false,
    isScrollControlled: true,
    builder: (_) =>
        BottomSheetPinnedTitleScrollView(title: title, child: body(context)),
  );
  if (ok == true && context.mounted) {
    onChanged?.call();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.updateSuccess)));
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ImagePicker _picker = ImagePicker();
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        getIt<AppBiometricUnlockController>()
            .refreshAuthenticatorAvailability(),
      );
    });
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString(_profileImageKey);
    if (imagePath != null && await File(imagePath).exists()) {
      if (!mounted) return;
      setState(() => _profileImagePath = imagePath);
    }
  }

  Future<void> _pickImage(ImageSource source, AppLocalizations l10n) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image == null) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileImageKey, image.path);
      if (!mounted) return;
      setState(() => _profileImagePath = image.path);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.updateSuccess)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.settingsPickImageFailed)));
    }
  }

  Future<void> _showImageSourceSheet(AppLocalizations l10n) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: false,
      isScrollControlled: true,
      builder: (sheetContext) => BottomSheetPinnedTitleScrollView(
        padding: EdgeInsets.zero,
        title: l10n.selectPhotoSource,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.camera),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.gallery),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) await _pickImage(source, l10n);
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<SettingsCubit>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = getIt<GetCurrentUserUsecase>()();

    return BlocProvider(
      create: (_) => getIt<SettingsCubit>(),
      child: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is SettingsSignedOut) {
            context.go('/login');
          }
        },
        child: Scaffold(
          appBar: AppBar(title: Text(l10n.settings)),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
              children: [
                _SectionHeader(l10n.settingsProfileSection),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: _profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : null,
                    child: _profileImagePath == null
                        ? Icon(
                            Icons.person_outline_rounded,
                            color: theme.colorScheme.onPrimaryContainer,
                          )
                        : null,
                  ),
                  title: Text(l10n.changeProfilePhoto),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showImageSourceSheet(l10n),
                ),
                _NavigationTile(
                  icon: Icons.email_outlined,
                  title: l10n.changeEmail,
                  subtitle: user?.email ?? l10n.currentEmail,
                  onTap: () => _showProfileSheet(
                    context,
                    l10n,
                    title: l10n.changeEmail,
                    body: (host) => _ChangeEmailSheetBody(
                      hostContext: host,
                      currentEmail: user?.email ?? '',
                      l10n: l10n,
                    ),
                    onChanged: () => setState(() {}),
                  ),
                ),
                _NavigationTile(
                  icon: Icons.lock_outline_rounded,
                  title: l10n.changePassword,
                  subtitle: l10n.settingsChangePasswordSubtitle,
                  onTap: () => _showProfileSheet(
                    context,
                    l10n,
                    title: l10n.changePassword,
                    body: (host) =>
                        _ChangePasswordSheetBody(hostContext: host, l10n: l10n),
                  ),
                ),
                _NavigationTile(
                  icon: Icons.person_outline_rounded,
                  title: l10n.changeUsername,
                  subtitle: user?.username ?? l10n.currentUsername,
                  onTap: () => _showProfileSheet(
                    context,
                    l10n,
                    title: l10n.changeUsername,
                    body: (host) => _ChangeUsernameSheetBody(
                      hostContext: host,
                      currentUsername: user?.username ?? '',
                      l10n: l10n,
                    ),
                    onChanged: () => setState(() {}),
                  ),
                ),
                const _SectionDivider(),
                _SectionHeader(l10n.settingsSecuritySection),
                ListenableBuilder(
                  listenable: getIt<AppBiometricUnlockController>(),
                  builder: (context, _) {
                    final bio = getIt<AppBiometricUnlockController>();
                    return SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      secondary: Icon(
                        Icons.fingerprint_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      title: Text(l10n.settingsBiometricUnlockTitle),
                      subtitle: Text(
                        bio.authenticatorAvailable
                            ? l10n.settingsBiometricUnlockSubtitle
                            : l10n.settingsBiometricUnavailable,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      value: bio.enabled,
                      onChanged: bio.authenticatorAvailable
                          ? (v) => _setBiometricUnlockEnabled(
                              context,
                              l10n,
                              bio,
                              v,
                            )
                          : null,
                    );
                  },
                ),
                const _SectionDivider(),
                _SectionHeader(l10n.settingsAppearance),
                ListenableBuilder(
                  listenable: getIt<AppLocaleController>(),
                  builder: (context, _) {
                    final ctrl = getIt<AppLocaleController>();
                    return _NavigationTile(
                      icon: Icons.language_outlined,
                      title: l10n.settingsLanguage,
                      subtitle: _languageOptionLabel(l10n, ctrl.preference),
                      onTap: () => _showOptionPickerSheet(
                        context,
                        title: l10n.settingsLanguage,
                        options: AppLanguagePreference.values,
                        selected: ctrl.preference,
                        label: (p) => _languageOptionLabel(l10n, p),
                        onSelected: ctrl.setPreference,
                      ),
                    );
                  },
                ),
                ListenableBuilder(
                  listenable: getIt<AppThemeController>(),
                  builder: (context, _) {
                    final ctrl = getIt<AppThemeController>();
                    return _NavigationTile(
                      icon: Icons.palette_outlined,
                      title: l10n.settingsTheme,
                      subtitle: _themeOptionLabel(l10n, ctrl.preference),
                      onTap: () => _showOptionPickerSheet(
                        context,
                        title: l10n.settingsTheme,
                        options: AppThemePreference.values,
                        selected: ctrl.preference,
                        label: (p) => _themeOptionLabel(l10n, p),
                        onSelected: ctrl.setPreference,
                      ),
                    );
                  },
                ),
                const _SectionDivider(),
                _SectionHeader(l10n.settingsAboutSection),
                _NavigationTile(
                  icon: Icons.info_outline_rounded,
                  title: l10n.settingsAboutApp,
                  onTap: () => context.push('/settings/about'),
                ),
                _NavigationTile(
                  icon: Icons.star_outline_rounded,
                  title: l10n.settingsRateApp,
                  trailingIcon: Icons.open_in_new_rounded,
                  onTap: () => launchUrl(
                    Uri.parse(_playStoreUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                _NavigationTile(
                  icon: Icons.privacy_tip_outlined,
                  title: l10n.settingsPrivacyPolicy,
                  onTap: () => context.push('/settings/privacy'),
                ),
                _NavigationTile(
                  icon: Icons.description_outlined,
                  title: l10n.settingsTermsOfUse,
                  onTap: () => context.push('/settings/terms'),
                ),
                const _SectionDivider(),
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    final signOutStyle = FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: state is SettingsLoading
                            ? FilledButton(
                                style: signOutStyle,
                                onPressed: null,
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: theme.colorScheme.onError,
                                  ),
                                ),
                              )
                            : FilledButton.icon(
                                style: signOutStyle,
                                onPressed: () => _confirmSignOut(context, l10n),
                                icon: const Icon(Icons.logout_rounded),
                                label: Text(l10n.signOut),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 16),
    child: Divider(height: 1),
  );
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.trailingIcon = Icons.chevron_right,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final IconData trailingIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(title),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Icon(trailingIcon),
      onTap: onTap,
    );
  }
}

/// Shared submit plumbing for the profile sheets: loading flag, error snack
/// on the host scaffold, and popping with `true` on success.
mixin _SheetSubmitMixin<T extends StatefulWidget> on State<T> {
  bool loading = false;

  BuildContext get hostContext;
  AppLocalizations get l10n;

  void snack(String message) {
    ScaffoldMessenger.of(hostContext)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> runSubmit(Future<void> Function() action) async {
    setState(() => loading = true);
    try {
      await action();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on InvalidCurrentPasswordException {
      if (mounted) setState(() => loading = false);
      snack(l10n.settingsCurrentPasswordIncorrect);
    } on AuthException catch (e) {
      if (mounted) setState(() => loading = false);
      snack(e.message);
    } catch (_) {
      if (mounted) setState(() => loading = false);
      snack(l10n.unexpectedError);
    }
  }

  Widget submitButton(String label, VoidCallback onSubmit) => FilledButton(
    onPressed: loading ? null : onSubmit,
    child: loading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label),
  );
}

class _ChangeEmailSheetBody extends StatefulWidget {
  const _ChangeEmailSheetBody({
    required this.hostContext,
    required this.currentEmail,
    required this.l10n,
  });

  final BuildContext hostContext;
  final String currentEmail;
  final AppLocalizations l10n;

  @override
  State<_ChangeEmailSheetBody> createState() => _ChangeEmailSheetBodyState();
}

class _ChangeEmailSheetBodyState extends State<_ChangeEmailSheetBody>
    with _SheetSubmitMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  BuildContext get hostContext => widget.hostContext;

  @override
  AppLocalizations get l10n => widget.l10n;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final next = _controller.text.trim();
    await runSubmit(() => getIt<UpdateEmailUsecase>()(newEmail: next));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _controller,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofocus: true,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: l10n.newEmail,
              hintText: l10n.enterNewEmail,
            ),
            enabled: !loading,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return l10n.pleaseEnterEmail;
              final t = v.trim();
              if (!_emailPattern.hasMatch(t)) return l10n.invalidEmail;
              if (t == widget.currentEmail.trim()) {
                return l10n.emailMustBeDifferent;
              }
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          submitButton(l10n.update, _submit),
        ],
      ),
    );
  }
}

class _ChangePasswordSheetBody extends StatefulWidget {
  const _ChangePasswordSheetBody({
    required this.hostContext,
    required this.l10n,
  });

  final BuildContext hostContext;
  final AppLocalizations l10n;

  @override
  State<_ChangePasswordSheetBody> createState() =>
      _ChangePasswordSheetBodyState();
}

class _ChangePasswordSheetBodyState extends State<_ChangePasswordSheetBody>
    with _SheetSubmitMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  BuildContext get hostContext => widget.hostContext;

  @override
  AppLocalizations get l10n => widget.l10n;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await runSubmit(
      () => getIt<UpdatePasswordUsecase>()(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    bool autofocus = false,
    bool last = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      autofocus: autofocus,
      textInputAction: last ? TextInputAction.done : TextInputAction.next,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
      enabled: !loading,
      validator: validator,
      onFieldSubmitted: last ? (_) => _submit() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _passwordField(
            controller: _currentController,
            label: l10n.currentPassword,
            hint: l10n.enterCurrentPassword,
            obscure: _obscureCurrent,
            autofocus: true,
            onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.pleaseEnterPassword;
              return null;
            },
          ),
          const SizedBox(height: 12),
          _passwordField(
            controller: _newController,
            label: l10n.newPassword,
            hint: l10n.enterNewPassword,
            obscure: _obscureNew,
            onToggle: () => setState(() => _obscureNew = !_obscureNew),
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.pleaseEnterPassword;
              if (v.length < _kMinPasswordLength) {
                return l10n.passwordMinLength;
              }
              if (v == _currentController.text) {
                return l10n.newPasswordMustBeDifferent;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _passwordField(
            controller: _confirmController,
            label: l10n.confirmPassword,
            hint: l10n.enterConfirmPassword,
            obscure: _obscureConfirm,
            last: true,
            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.pleaseEnterPassword;
              if (v != _newController.text) return l10n.passwordsDoNotMatch;
              return null;
            },
          ),
          const SizedBox(height: 20),
          submitButton(l10n.update, _submit),
        ],
      ),
    );
  }
}

class _ChangeUsernameSheetBody extends StatefulWidget {
  const _ChangeUsernameSheetBody({
    required this.hostContext,
    required this.currentUsername,
    required this.l10n,
  });

  final BuildContext hostContext;
  final String currentUsername;
  final AppLocalizations l10n;

  @override
  State<_ChangeUsernameSheetBody> createState() =>
      _ChangeUsernameSheetBodyState();
}

class _ChangeUsernameSheetBodyState extends State<_ChangeUsernameSheetBody>
    with _SheetSubmitMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  BuildContext get hostContext => widget.hostContext;

  @override
  AppLocalizations get l10n => widget.l10n;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentUsername);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final next = _controller.text.trim();
    await runSubmit(() => getIt<UpdateUsernameUsecase>()(newUsername: next));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _controller,
            textInputAction: TextInputAction.done,
            autofocus: true,
            autofillHints: const [AutofillHints.username],
            decoration: InputDecoration(
              labelText: l10n.newUsername,
              hintText: l10n.enterNewUsername,
            ),
            enabled: !loading,
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.pleaseEnterUsername;
              if (v.length < _kMinUsernameLength) {
                return l10n.usernameMinLength;
              }
              if (v == widget.currentUsername) {
                return l10n.usernameMustBeDifferent;
              }
              return null;
            },
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 20),
          submitButton(l10n.update, _submit),
        ],
      ),
    );
  }
}
