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
  /// Example: 'https://xyzcompany.supabase.co'
  static const String url = 'YOUR_SUPABASE_URL';

  /// Your Supabase anon/public key
  /// This is safe to use in client apps (Row Level Security protects data)
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// Whether to use mock data (set to false when Supabase is configured)
  static bool get useMockData =>
      url == 'YOUR_SUPABASE_URL' || anonKey == 'YOUR_SUPABASE_ANON_KEY';
}
