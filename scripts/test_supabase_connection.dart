import 'dart:io';
import 'package:supabase/supabase.dart';

Future<void> main() async {
  print('🔍 TESTING SUPABASE CONNECTION...\n');

  // Credentials từ user
  const supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';
  const serviceRoleKey = 'sb_secret_07Grp_TTwr21BjtBKc_gtw_5qx7UPFE';

  try {
    print('📡 Testing với ANON KEY...');
    
    // Test với anon key
    final supabaseAnon = SupabaseClient(supabaseUrl, anonKey);
    
    // Test basic connection
    final response1 = await supabaseAnon.from('users').select('count').count(CountOption.exact);
    print('✅ ANON KEY connection successful!');
    print('   Users table count: ${response1.count}');
    
  } catch (e) {
    print('❌ ANON KEY connection failed: $e');
  }

  try {
    print('\n🔐 Testing với SERVICE ROLE KEY...');
    
    // Test với service role key  
    final supabaseService = SupabaseClient(supabaseUrl, serviceRoleKey);
    
    // Test auth.users table (chỉ service role mới access được)
    final authUsers = await supabaseService.rpc('get_auth_users_count');
    print('✅ SERVICE ROLE KEY connection successful!');
    print('   Auth users count: $authUsers');
    
  } catch (e) {
    print('⚠️  SERVICE ROLE KEY test: $e');
  }

  try {
    print('\n📊 Testing tables structure...');
    
    final supabaseService = SupabaseClient(supabaseUrl, serviceRoleKey);
    
    // Check public.users table
    try {
      final publicUsers = await supabaseService.from('users').select('id').limit(1);
      print('✅ public.users table exists and accessible');
      print('   Sample data: ${publicUsers.isNotEmpty ? publicUsers[0] : 'No data'}');
    } catch (e) {
      print('❌ public.users table issue: $e');
    }

    // Check auth.users (via RPC function)
    try {
      final result = await supabaseService.rpc('get_auth_users_sample');
      print('✅ auth.users accessible via RPC');
      print('   Sample: $result');
    } catch (e) {
      print('⚠️  auth.users RPC test: $e');
    }

  } catch (e) {
    print('❌ Tables structure test failed: $e');
  }

  print('\n🔧 RECOMMENDED SQL COMMANDS TO RUN IN SUPABASE DASHBOARD:');
  print('''
-- 1. Tạo public.users table (nếu chưa có)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    username TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    bio TEXT,
    avatar_url TEXT,
    rank TEXT DEFAULT 'E',
    elo_rating INTEGER DEFAULT 1200,
    spa_points INTEGER DEFAULT 0,
    favorite_game TEXT DEFAULT '8-Ball',
    total_matches INTEGER DEFAULT 0,
    wins INTEGER DEFAULT 0,
    losses INTEGER DEFAULT 0,
    win_streak INTEGER DEFAULT 0,
    tournaments_played INTEGER DEFAULT 0,
    tournament_wins INTEGER DEFAULT 0,
    is_online BOOLEAN DEFAULT TRUE,
    last_seen TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- 3. Policies cho users table
CREATE POLICY "Users can view own profile" ON public.users 
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.users 
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users 
    FOR UPDATE USING (auth.uid() = id);

-- 4. Function để test auth.users (optional)
CREATE OR REPLACE FUNCTION get_auth_users_count()
RETURNS INTEGER AS \$\$
BEGIN
    RETURN (SELECT COUNT(*) FROM auth.users);
END;
\$\$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION get_auth_users_sample()
RETURNS TABLE(id UUID, email TEXT, created_at TIMESTAMPTZ) AS \$\$
BEGIN
    RETURN QUERY SELECT auth.users.id, auth.users.email, auth.users.created_at 
    FROM auth.users LIMIT 3;
END;
\$\$ LANGUAGE plpgsql SECURITY DEFINER;
''');

  print('\n🎯 NEXT STEPS:');
  print('1. Copy và run SQL commands ở trên trong Supabase Dashboard > SQL Editor');
  print('2. Test lại script này để verify');
  print('3. Sau đó test registration trong app');

  exit(0);
}