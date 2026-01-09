# Utility Scripts

This directory contains utility scripts for the Hangman Flutter project.

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

---

## Script: `group_words.dart`

### What it does:
- Reads words from `assets/words_en.json` and `assets/words_es.json`
- Calculates difficulty for each word using Supabase's `calculate_word_difficulty` function
- Groups words by difficulty: easy (0-33), medium (34-66), hard (67-100)
- Saves the reorganized structure back to the JSON files

### Usage:

```bash
# From the project root
dart scripts/group_words.dart
```

### Requirements:
- `.env` file with `SUPABASE_URL` and `SUPABASE_SERVICE_KEY`
- Supabase database with `calculate_word_difficulty` function
- `supabase` package in `dev_dependencies`
- Words migration must be applied (see `DIFFICULTY_CALCULATION.md`)

### Example Output:

```bash
$ dart scripts/group_words.dart

🎯 Words Difficulty Grouping Script
====================================

✅ Connected to Supabase

📂 Processing: assets/words_en.json
─────────────────────────────────
📊 Found 500 words
🔢 Calculating difficulties...
   Progress: 50/500 words
   Progress: 100/500 words
   Progress: 150/500 words
   ...
   Progress: 500/500 words

📈 Difficulty Distribution:
   Easy (0-33):     167 words
   Medium (34-66):  166 words
   Hard (67-100):   167 words
💾 Saved updated file: assets/words_en.json

📂 Processing: assets/words_es.json
─────────────────────────────────
📊 Found 501 words
🔢 Calculating difficulties...
   Progress: 50/501 words
   ...
   Progress: 501/501 words

📈 Difficulty Distribution:
   Easy (0-33):     170 words
   Medium (34-66):  165 words
   Hard (67-100):   166 words
💾 Saved updated file: assets/words_es.json

✅ All files processed successfully!
```

### How Difficulty is Calculated:

The script uses Supabase's `calculate_word_difficulty` function which considers:

1. **Unique Letter Ratio (40%)**: Fewer repeated letters = harder
2. **Letter Rarity (35%)**: Uncommon letters = harder (language-specific)
3. **Word Length (25%)**: Longer words = harder

**Formula:**
```
difficulty = (unique_ratio × 0.40) + (letter_rarity × 0.35) + (length × 0.25)
```

**Examples:**
- `CAT` (English): 0.23 → **Easy**
- `PIANO` (English): 0.45 → **Medium**
- `DEVELOPER` (English): 0.58 → **Medium**
- `SAXOPHONE` (English): 0.72 → **Hard**

### When to Use:

- After adding new words to JSON files
- When changing the difficulty calculation algorithm
- To rebalance difficulty categories
- To ensure consistent difficulty across languages

### Notes:

- The script maintains the JSON structure with `easy`, `medium`, and `hard` categories
- Each category contains a `words` array with word objects
- Original tags are preserved during reorganization
- The script handles errors gracefully and defaults problematic words to medium difficulty
- See `DIFFICULTY_CALCULATION.md` for detailed documentation on the algorithm

