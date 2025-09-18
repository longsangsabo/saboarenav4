import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'lib/services/qr_scan_service.dart';

/// Test script for QR scanning functionality
/// Run this to verify QR codes can be scanned and users found
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase (you'll need your actual keys)
  await Supabase.initialize(
    url: 'https://mogjjvscxjwvhtpkrlqr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ',
  );
  
  print('🔍 Testing QR Scan Service...\n');
  
  // Test different QR formats
  final testCases = [
    'SABO123456',           // User code format
    'demo-user-123',        // User ID format  
    'SABO000001',           // Another user code
    'test-user-001',        // Another user ID
    'https://saboarena.com/user/demo-user-123?user_code=SABO123456', // URL format
    'INVALID_CODE',         // Invalid code
    '',                     // Empty string
  ];
  
  for (final testQR in testCases) {
    print('🧪 Testing QR: "$testQR"');
    
    try {
      final result = await QRScanService.scanQRCode(testQR);
      
      if (result != null) {
        print('✅ SUCCESS: Found user "${result['fullName']}"');
        print('   ID: ${result['id']}');
        print('   Email: ${result['email']}');
        print('   User Code: ${result['userCode']}');
        print('   Skill Level: ${result['skillLevel']}');
        print('   ELO: ${result['eloRating']}');
      } else {
        print('❌ FAILED: No user found');
      }
    } catch (e) {
      print('💥 ERROR: $e');
    }
    
    print(''); // Empty line for readability
  }
  
  print('🎯 QR Scan Test Complete!');
  print('');
  print('📋 Summary:');
  print('- Make sure to run the database migration first:');
  print('  add_user_qr_system.sql');
  print('- Make sure to insert test data:');
  print('  qr_test_data.sql');
  print('- User codes should be in format: SABO123456');
  print('- Scanner supports: user_code, user_id, and URL formats');
}