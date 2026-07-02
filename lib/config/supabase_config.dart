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
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpeG5nYnh2a3dmb3B2cnl2cGtrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwMDA5NDUsImV4cCI6MjA5ODU3Njk0NX0.WmmM2dxL1_BdeiL3nIvbO8TZUtvQ88sg2YNBvKLdJKM';

  /// Whether to use mock data (set to true to skip Supabase connection)
  static bool get useMockData => false;
}
