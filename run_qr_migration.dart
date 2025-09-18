import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

// Simple SQL execution script for QR migration
void main() async {
  print('🎯 SABO ARENA - Running QR Database Migration');
  print('===============================================');
  
  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://mogjjvscxjwvhtpkrlqr.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ',
    );
    
    final supabase = Supabase.instance.client;
    
    print('\n📊 Step 1: Check current schema...');
    
    // Check if columns already exist
    try {
      await supabase.from('user_profiles').select('user_code').limit(1);
      print('✅ user_code column already exists');
    } catch (e) {
      if (e.toString().contains('column') && e.toString().contains('does not exist')) {
        print('⚠️  user_code column does not exist - need to add it');
      } else {
        print('❌ Error checking user_code: $e');
      }
    }
    
    print('\n📈 Step 2: Get current user statistics...');
    
    final users = await supabase
        .from('user_profiles')
        .select('id, full_name');
    
    print('👥 Total users in database: ${users.length}');
    
    if (users.isNotEmpty) {
      print('\n🔍 Sample users:');
      for (int i = 0; i < (users.length > 3 ? 3 : users.length); i++) {
        print('   - ${users[i]['full_name']} (ID: ${users[i]['id']})');
      }
    }
    
    print('\n💡 Migration Status:');
    print('   📄 SQL file created: add_user_qr_system.sql');
    print('   📄 Services created: UserCodeService, RegistrationQRService');
    print('   📄 Widgets created: UserQRCodeWidget');
    
    print('\n🚀 Next Steps:');
    print('   1. Execute SQL migration in Supabase Dashboard:');
    print('      - Go to SQL Editor in Supabase Dashboard');
    print('      - Copy content from add_user_qr_system.sql');
    print('      - Run the SQL commands');
    
    print('\n   2. Test QR system after migration:');
    print('      - User codes will be auto-generated');
    print('      - QR data will be stored in database');
    print('      - Existing users will get QR codes');
    
    print('\n✅ Migration preparation complete!');
    
  } catch (e) {
    print('❌ Error: $e');
  }
  
  exit(0);
}