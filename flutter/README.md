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

### Seed words database

To populate the Supabase database with words from JSON files:

```bash
dart scripts/seed_words.dart
```

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
