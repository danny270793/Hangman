/// Supabase credentials injected at build time with
/// `--dart-define-from-file=.env.json` (see `.env.example.json`).
abstract class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );
}
