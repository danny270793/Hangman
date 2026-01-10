# iOS Version Update Script

This directory contains scripts to automate version updates for the iOS app using semantic versioning.

## Script: `update_ios_version.dart` (Recommended)

### What it does:
- Reads the current version from `pubspec.yaml`
- Automatically increments the **patch version** (1.0.x → 1.0.x+1)
- Increments the **build number** (+1, +2, +3, etc.)
- Updates `pubspec.yaml` with the new version
- Optionally runs `flutter build ios --config-only` to update iOS `Info.plist`

### Usage:

```bash
# From the project root
dart scripts/update_ios_version.dart

# Or make it executable and run directly
./scripts/update_ios_version.dart

# Or from anywhere
dart /path/to/flutter/scripts/update_ios_version.dart
```

### Legacy Bash Version:

A bash version (`update_ios_version.sh`) is also available for compatibility:

```bash
./scripts/update_ios_version.sh
```

### Example:

```bash
$ dart scripts/update_ios_version.dart

📱 iOS Version Updater
=======================

Current version: 1.0.0
Current build number: 1

📈 Updating version...
New version: 1.0.1
New build number: 2

✅ pubspec.yaml updated successfully!

Changes:
  - version: 1.0.0+1
  + version: 1.0.1+2

Do you want to run 'flutter build ios --config-only' to update iOS Info.plist? (y/n)
```

### Semantic Versioning Format:

The script follows semantic versioning with the format: `MAJOR.MINOR.PATCH+BUILD`

- **MAJOR**: Breaking changes (manual update)
- **MINOR**: New features (manual update)
- **PATCH**: Bug fixes and minor updates (auto-incremented by script)
- **BUILD**: Build number (auto-incremented by script)

### Manual Version Updates:

If you need to update MAJOR or MINOR versions manually:

1. Edit `pubspec.yaml` directly:
   ```yaml
   version: 2.0.0+1  # For major version
   version: 1.1.0+1  # For minor version
   ```

2. Run `flutter build ios --config-only` to update iOS files

### Files Modified:

- `pubspec.yaml` - Flutter version configuration
- `ios/Runner/Info.plist` - iOS version info (via flutter build command)

### Notes:

- The script creates a backup before modifying files
- Always commit version changes to git
- The build number should always increment, never reset
- iOS uses both `CFBundleShortVersionString` (version name) and `CFBundleVersion` (build number)

