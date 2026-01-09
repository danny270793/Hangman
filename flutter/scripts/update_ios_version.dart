#!/usr/bin/env dart

import 'dart:io';

// ANSI color codes
const String green = '\x1B[32m';
const String blue = '\x1B[34m';
const String red = '\x1B[31m';
const String reset = '\x1B[0m';

void main(List<String> args) async {
  print('${blue}📱 iOS Version Updater$reset');
  print('${blue}=======================$reset\n');

  // Get the project root directory (one level up from scripts)
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final projectRoot = scriptDir.parent;
  final pubspecFile = File('${projectRoot.path}/pubspec.yaml');

  // Check if pubspec.yaml exists
  if (!await pubspecFile.exists()) {
    print('${red}❌ Error: pubspec.yaml not found at ${pubspecFile.path}$reset');
    exit(1);
  }

  // Read current version from pubspec.yaml
  final pubspecContent = await pubspecFile.readAsString();
  final versionLine = pubspecContent
      .split('\n')
      .firstWhere((line) => line.startsWith('version:'), orElse: () => '');

  if (versionLine.isEmpty) {
    print('${red}❌ Error: Could not read version from pubspec.yaml$reset');
    exit(1);
  }

  final currentVersion = versionLine.replaceFirst('version:', '').trim();

  // Split version into version name and build number
  // Format: 1.0.0+1 -> version_name=1.0.0, build_number=1
  final parts = currentVersion.split('+');
  if (parts.length != 2) {
    print('${red}❌ Error: Invalid version format in pubspec.yaml$reset');
    exit(1);
  }

  final versionName = parts[0];
  final buildNumber = int.parse(parts[1]);

  print('Current version: $green$versionName$reset');
  print('Current build number: $green$buildNumber$reset\n');

  // Split version name into major.minor.patch
  final versionParts = versionName.split('.');
  if (versionParts.length != 3) {
    print('${red}❌ Error: Invalid version name format$reset');
    exit(1);
  }

  final major = int.parse(versionParts[0]);
  final minor = int.parse(versionParts[1]);
  final patch = int.parse(versionParts[2]);

  // Increment patch version
  final newPatch = patch + 1;
  final newVersionName = '$major.$minor.$newPatch';

  // Increment build number
  final newBuildNumber = buildNumber + 1;

  // Create new version string
  final newVersion = '$newVersionName+$newBuildNumber';

  print('${blue}📈 Updating version...$reset');
  print('New version: $green$newVersionName$reset');
  print('New build number: $green$newBuildNumber$reset\n');

  // Update pubspec.yaml
  final updatedContent = pubspecContent.replaceFirst(
    'version: $currentVersion',
    'version: $newVersion',
  );

  await pubspecFile.writeAsString(updatedContent);

  print('${green}✅ pubspec.yaml updated successfully!$reset\n');

  // Show the change
  print('${blue}Changes:$reset');
  print('  ${red}- version: $currentVersion$reset');
  print('  ${green}+ version: $newVersion$reset\n');

  // Ask if user wants to update iOS Info.plist files
  print(
      "${blue}Do you want to run 'flutter build ios --config-only' to update iOS Info.plist? (y/n)$reset");
  final response = stdin.readLineSync()?.toLowerCase();

  if (response == 'y' || response == 'yes') {
    print('\n${blue}🔄 Running flutter build ios --config-only...$reset');

    final result = await Process.run(
      'flutter',
      ['build', 'ios', '--config-only'],
      workingDirectory: projectRoot.path,
    );

    if (result.exitCode == 0) {
      print('${green}✅ iOS configuration updated!$reset\n');
    } else {
      print(
          '${red}❌ Error running flutter build: ${result.stderr}$reset\n');
    }
  } else {
    print(
        "\n${blue}ℹ️  Skipped iOS build. Run 'flutter build ios --config-only' manually to update Info.plist$reset\n");
  }

  print('${green}🎉 Version update complete!$reset');
  print('${blue}Summary:$reset');
  print('  Version Name: $green$versionName → $newVersionName$reset');
  print('  Build Number: $green$buildNumber → $newBuildNumber$reset');
  print('\n${blue}💡 Don\'t forget to commit these changes!$reset');
}

