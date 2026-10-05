# Hangman

## Run

```bash
cp .env.example.json .env.json   # then fill in SUPABASE_URL / SUPABASE_ANON_KEY
flutter run --dart-define-from-file=.env.json
```

`.env` (see `.env.example`) is still used by the maintenance scripts in `scripts/`
(it also needs `SUPABASE_SERVICE_KEY`); the app itself reads its Supabase
credentials from `--dart-define-from-file`.

## Database

This repo has the app only. The `hangman_*` schema lives in [danny270793/supabase](https://github.com/danny270793/supabase), the source of truth for migrations. Hangman shares that Supabase project with the other apps. To change the database you need both repos:

```sh
git clone git@github.com:danny270793/Hangman.git
git clone git@github.com:danny270793/supabase.git
```

Create, test, and push migrations from the `supabase` repo. This repo ignores any `supabase/` folder, and `.env.json` holds the project credentials, so never commit it.

## Commands

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
SELECT hangman_update_all_word_difficulties();
```

Or update specific locale:

```sql
SELECT hangman_update_word_difficulties_by_locale('en');
```

**Note**: Difficulty is automatically calculated when inserting/updating words via trigger, but you can manually recalculate all words with this function. See [difficulty calculation](https://github.com/danny270793/supabase/blob/main/docs/hangman/difficulty-calculation.md) for details.

### Reorganize JSON words by difficulty

To reorganize local JSON files by computed difficulty:

```bash
dart scripts/group_words.dart
```

This script:
- Reads `assets/words_en.json` and `assets/words_es.json`
- Calculates difficulty using Supabase `hangman_calculate_word_difficulty` function
- Groups words into easy (0-33), medium (34-66), and hard (67-100)
- Saves the reorganized files back

**Note**: Requires `SUPABASE_SERVICE_KEY` in your `.env` file.
