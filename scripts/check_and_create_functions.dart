import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🔧 CREATING DATABASE FUNCTIONS VIA DIRECT SQL...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

  try {
    print('🚀 Connecting with ANON KEY...');
    final supabase = SupabaseClient(supabaseUrl, anonKey);
    
    // Test if functions already exist
    print('\n🔍 Checking existing functions...');
    
    try {
      final result = await supabase.rpc('get_user_ranking', params: {
        'user_uuid': 'ac44398b-faf8-4ce0-9043-581e0443b12b'
      });
      print('✅ get_user_ranking already exists: $result');
    } catch (e) {
      print('❌ get_user_ranking does not exist');
    }
    
    try {
      final count = await supabase.rpc('get_auth_users_count');
      print('✅ get_auth_users_count already exists: $count');
    } catch (e) {
      print('❌ get_auth_users_count does not exist');
    }
    
    try {
      final sample = await supabase.rpc('get_auth_users_sample');
      print('✅ get_auth_users_sample already exists: ${sample.length} records');
    } catch (e) {
      print('❌ get_auth_users_sample does not exist');
    }
    
    print('\n📋 MANUAL STEPS REQUIRED:');
    print('Since functions don\'t exist, you need to manually run this SQL in Supabase Dashboard:');
    print('\n🔗 Go to: https://supabase.com/dashboard/project/mogjjvscxjwvhtpkrlqr/sql');
    print('\n📄 Copy and run this SQL:');
    
    print('''
-- 1. Function to count auth users
CREATE OR REPLACE FUNCTION public.get_auth_users_count()
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS \$\$
BEGIN
    RETURN (SELECT COUNT(*) FROM auth.users);
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END;
\$\$;

-- 2. Function to get sample auth users
CREATE OR REPLACE FUNCTION public.get_auth_users_sample()
RETURNS TABLE(id UUID, email TEXT, created_at TIMESTAMPTZ) 
LANGUAGE plpgsql
SECURITY DEFINER
AS \$\$
BEGIN
    RETURN QUERY 
    SELECT au.id, au.email, au.created_at 
    FROM auth.users au 
    ORDER BY au.created_at DESC
    LIMIT 3;
EXCEPTION
    WHEN OTHERS THEN
        RETURN;
END;
\$\$;

-- 3. Function to get user ranking
CREATE OR REPLACE FUNCTION public.get_user_ranking(user_uuid UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS \$\$
DECLARE
    user_rank INTEGER;
BEGIN
    SELECT COUNT(*) + 1 INTO user_rank
    FROM public.users
    WHERE ranking_points > (
        SELECT COALESCE(ranking_points, 0)
        FROM public.users 
        WHERE id = user_uuid
    ) AND is_active = true;
    
    RETURN COALESCE(user_rank, 0);
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END;
\$\$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION public.get_auth_users_count() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_auth_users_sample() TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_user_ranking(UUID) TO authenticated;
''');
    
    print('\n✅ After running the SQL, test again with: dart scripts/final_connection_test.dart');
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}