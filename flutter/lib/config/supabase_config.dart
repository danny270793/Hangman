import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Loads credentials from .env file
  // Make sure to create a .env file with SUPABASE_URL and SUPABASE_ANON_KEY
  static String get supabaseUrl =>
      dotenv.env['SUPABASE_URL'] ?? 'YOUR_SUPABASE_URL';
  
  static String get supabaseAnonKey =>
      dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_SUPABASE_ANON_KEY';
}

