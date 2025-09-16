// Supabase Configuration
// Using service role key for development speed

class SupabaseConfig {
  // Demo Supabase instance for development
  static const String url = 'https://demo-supabase-url.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.demo-anon-key';
  
  // Storage bucket names
  static const String avatarsBucket = 'avatars';
  static const String tournamentImagesBucket = 'tournament-images';
  static const String postImagesBucket = 'post-images';
  
  // Database table names
  static const String usersTable = 'users';
  static const String clubsTable = 'clubs';
  static const String tournamentsTable = 'tournaments';
  static const String matchesTable = 'matches';
  static const String postsTable = 'posts';
  static const String commentsTable = 'comments';
  
  // Real-time channels
  static const String matchesChannel = 'matches-updates';
  static const String tournamentsChannel = 'tournaments-updates';
  static const String postsChannel = 'posts-updates';
}