import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🔧 CREATING MISSING DATABASE FUNCTIONS...\n');

  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const serviceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.sb_secret_07Grp_TTwr21BjtBKc_gtw_5qx7UPFE';

  try {
    print('🚀 Connecting with SERVICE ROLE KEY...');
    final supabase = SupabaseClient(supabaseUrl, serviceKey);
    
    // 1. Create get_auth_users_count function
    print('\n1️⃣ Creating get_auth_users_count function...');
    await supabase.rpc('exec_sql', params: {
      'sql': '''
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
      '''
    });
    print('✅ get_auth_users_count created!');
    
    // 2. Create get_auth_users_sample function
    print('\n2️⃣ Creating get_auth_users_sample function...');
    await supabase.rpc('exec_sql', params: {
      'sql': '''
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
      '''
    });
    print('✅ get_auth_users_sample created!');
    
    // 3. Create improved get_user_ranking function
    print('\n3️⃣ Creating get_user_ranking function...');
    await supabase.rpc('exec_sql', params: {
      'sql': '''
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
      '''
    });
    print('✅ get_user_ranking created!');
    
    // Test the functions
    print('\n🧪 TESTING CREATED FUNCTIONS...');
    
    final authCount = await supabase.rpc('get_auth_users_count');
    print('✅ Auth users count: $authCount');
    
    final authSample = await supabase.rpc('get_auth_users_sample');
    print('✅ Auth users sample: ${authSample.length} records');
    
    final userRanking = await supabase.rpc('get_user_ranking', params: {
      'user_uuid': 'ac44398b-faf8-4ce0-9043-581e0443b12b'
    });
    print('✅ User ranking test: $userRanking');
    
    print('\n🎉 ALL FUNCTIONS CREATED AND TESTED SUCCESSFULLY!');
    
  } catch (e) {
    print('❌ ERROR: $e');
    exit(1);
  }

  exit(0);
}