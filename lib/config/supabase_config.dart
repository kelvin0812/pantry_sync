/// Supabase project configuration.
///
/// To set up:
/// 1. Create a project at https://supabase.com
/// 2. Go to Settings > API
/// 3. Copy your Project URL and anon/public key
/// 4. Replace the values below
///
/// IMPORTANT: Never commit real keys to git!
/// Use environment variables or .env in production.
class SupabaseConfig {
  /// Your Supabase project URL
  static const String url = 'https://qixngbxvkwfopvryvpkk.supabase.co';

  /// Your Supabase anon/public key
  static const String anonKey =
      'sb_publishable_lrGm0fEJH7l29x3HByrzow_MhGMa8dNkey';

  /// Whether to use mock data (set to true to skip Supabase connection)
  static bool get useMockData => false;
}
