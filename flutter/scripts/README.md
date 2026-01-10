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

## Script: `seed_words.dart`

### What it does:
- **Complete sync** between local JSON files and Supabase database
- Downloads existing words, tags, and relationships from Supabase
- Inserts new words that only exist in JSON
- Updates tags for existing words when they change
- Deletes words from database that no longer exist in JSON
- Cleans up orphaned tags (tags not linked to any words)

### Usage:

```bash
# From the project root
dart scripts/seed_words.dart
```

### Requirements:
- `.env` file with `SUPABASE_URL` and `SUPABASE_SERVICE_KEY`
- Supabase database with words tables (see `WORDS_SCHEMA.md`)
- `supabase` package in `dev_dependencies`
- JSON files with flat structure: `{ "words": [{ "word": "...", "tags": [...] }] }`

### Example Output:

```bash
$ dart scripts/seed_words.dart

🔄 Words Database Sync
======================

📖 Syncing en words from assets/words_en.json...
  📊 Local: 500 words
  ⬇️  Downloading existing words from database...
  📊 Database: 480 words

  📈 Analysis:
     ➕ To insert: 25
     🔄 To update: 10
     ➖ To delete: 5

  ➕ Inserting new words...
     Progress: 25/25
     ✅ Inserted: 25 words
  🔄 Updating existing words...
     Progress: 10/10
     ✅ Updated: 10 words
  ➖ Deleting removed words...
     Progress: 5/5
     ✅ Deleted: 5 words
  🧹 Cleaning up orphaned tags...
     ✅ Cleaned up: 3 orphaned tags

  ✅ en sync complete: ➕25 ➖5 🔄10

📖 Syncing es words from assets/words_es.json...
  ...

✅ Sync complete!
```

### Sync Logic:

1. **Download Phase**: 
   - Fetches all words for the locale
   - Fetches all word-tag relationships
   - Builds in-memory map of database state

2. **Compare Phase**: 
   - Compares local JSON words with database words
   - Identifies words to insert (new)
   - Identifies words to update (tags changed)
   - Identifies words to delete (removed from JSON)

3. **Insert Phase**: 
   - Adds words that exist in JSON but not in database
   - Creates tags if they don't exist
   - Links words to tags via `word_tags` table
   - Difficulty value auto-calculated by database trigger

4. **Update Phase**: 
   - Updates tags for words that exist in both
   - Deletes all old tag associations
   - Inserts new tag associations from JSON
   - Only updates words where tags actually changed

5. **Delete Phase**: 
   - Removes words from database that no longer exist in JSON
   - Cascading delete removes word_tags automatically

6. **Cleanup Phase**:
   - Identifies orphaned tags (not linked to any words)
   - Removes orphaned tags for the locale

### When to Use:

- **Initial database setup**: Populate database from JSON files
- **After adding words**: New words in JSON → inserted to database
- **After removing words**: Deleted from JSON → deleted from database
- **After modifying tags**: Changed tags in JSON → updated in database
- **Regular maintenance**: Keep database perfectly in sync with JSON
- **After manual database changes**: Restore JSON as source of truth

### Notes:

- **Service role key** required for admin operations (INSERT, UPDATE, DELETE)
- **Cascading deletes** remove word_tags automatically when words are deleted
- **Progress indicators** shown every 50 words for large operations
- **UPPERCASE normalization** for all words to ensure consistent comparison
- **Tag comparison** uses set difference to detect changes
- **Orphaned tags** are automatically cleaned up after sync
- **Difficulty values** are automatically calculated by database trigger
- **Error handling** continues processing even if individual words fail
- **Atomic per-word** operations (not transactional across all words)

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

