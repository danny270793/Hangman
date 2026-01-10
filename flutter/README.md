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
