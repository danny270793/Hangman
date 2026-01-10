# Hangman

## Commands

### Get supabase changes

```bash
supabase db pull
```

### Upload supabase changes

```bash
supabase db push
```

### Format code

```bash
dart format .
```

### Check for "code smells"

```bash
flutter analyze
```

### Generate new platform icons

```bash
dart run flutter_launcher_icons
```

### Generate strings classes

```bash
flutter gen-l10n
```

### Sync words database

To sync words between local JSON files and Supabase database:

```bash
dart scripts/seed_words.dart
```

**What it does:**
1. Downloads existing words from Supabase for each locale
2. Compares with local JSON files (`assets/words_en.json`, `assets/words_es.json`)
3. **Inserts** words that are in JSON but not in database
4. **Updates** tags for words that exist in both
5. **Deletes** words that are in database but not in JSON

**Note**: Requires `SUPABASE_SERVICE_KEY` in your `.env` file (available in your Supabase project settings).

### Update word difficulties

After seeding or adding new words, recalculate difficulties using the Supabase SQL Editor:

```sql
SELECT update_all_word_difficulties();
```

Or update specific locale:

```sql
SELECT update_word_difficulties_by_locale('en');
```

**Note**: Difficulty is automatically calculated when inserting/updating words via trigger, but you can manually recalculate all words with this function. See `DIFFICULTY_CALCULATION.md` for details.

### Reorganize JSON words by difficulty

To reorganize local JSON files by computed difficulty:

```bash
dart scripts/group_words.dart
```

This script:
- Reads `assets/words_en.json` and `assets/words_es.json`
- Calculates difficulty using Supabase `calculate_word_difficulty` function
- Groups words into easy (0-33), medium (34-66), and hard (67-100)
- Saves the reorganized files back

**Note**: Requires `SUPABASE_SERVICE_KEY` in your `.env` file.
