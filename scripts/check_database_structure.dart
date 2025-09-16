import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  // Supabase configuration with service role key
  final supabase = SupabaseClient(
    'https://mogjjvscxjwvhtpkrlqr.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo',
  );

  print('🔍 Checking existing database tables...');
  
  try {
    // Try to check some common tables
    final tables = [
      'users', 'profiles', 'user_profiles', 'clubs', 'tournaments', 
      'posts', 'achievements', 'matches', 'user_follows'
    ];
    
    print('\n📊 Database Tables Status:');
    print('=' * 50);
    
    for (final table in tables) {
      try {
        final response = await supabase.from(table).select('*').limit(1);
        print('✅ $table: EXISTS (${response.length} sample records)');
      } catch (e) {
        print('❌ $table: NOT EXISTS or NO ACCESS');
      }
    }
    
    print('\n🔍 Checking specific table structures...');
    
    // Check clubs table structure
    try {
      final clubs = await supabase.from('clubs').select('*').limit(1);
      if (clubs.isNotEmpty) {
        print('\n📋 Clubs table sample:');
        print('Columns: ${clubs.first.keys.join(', ')}');
      }
    } catch (e) {
      print('❌ Cannot access clubs table: $e');
    }
    
    // Check users table structure  
    try {
      final users = await supabase.from('users').select('*').limit(1);
      if (users.isNotEmpty) {
        print('\n👤 Users table sample:');
        print('Columns: ${users.first.keys.join(', ')}');
      }
    } catch (e) {
      print('❌ Cannot access users table: $e');
    }
    
    // Check profiles table structure
    try {
      final profiles = await supabase.from('profiles').select('*').limit(1);
      if (profiles.isNotEmpty) {
        print('\n👥 Profiles table sample:');
        print('Columns: ${profiles.first.keys.join(', ')}');
      }
    } catch (e) {
      print('❌ Cannot access profiles table: $e');
    }
    
  } catch (e) {
    print('❌ Error checking database: $e');
    exit(1);
  }
}