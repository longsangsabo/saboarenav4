import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:supabase/supabase.dart';

void main() async {
  // Load environment variables
  final envFile = File('/workspaces/sabo_arena/env.json');
  final envContent = await envFile.readAsString();
  final env = jsonDecode(envContent);

  final supabaseUrl = env['SUPABASE_URL'] as String;
  final serviceKey = env['SUPABASE_SERVICE_KEY'] as String? ?? 
                     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.p6Cm7xuJOQlqpyyqPnmQSx4SVVl4RFKflHWE8xUYylY';

  final supabase = SupabaseClient(supabaseUrl, serviceKey);

  print('🔍 DEBUGGING OPPONENT TAB ISSUES');
  print('================================');

  try {
    // 1. Check if find_nearby_users function exists
    print('\n📍 1. KIỂM TRA FUNCTION find_nearby_users:');
    
    try {
      final functionCheck = await supabase.rpc('find_nearby_users', params: {
        'current_user_id': '00000000-0000-0000-0000-000000000000',
        'user_lat': 10.8231,
        'user_lon': 106.6297,
        'radius_km': 5.0,
      });
      print('   ✅ Function exists and works');
    } catch (e) {
      print('   ❌ Function issue: $e');
      
      // Check if function exists in database
      final functionExists = await supabase
          .from('pg_proc')
          .select('proname')
          .eq('proname', 'find_nearby_users')
          .limit(1);
      
      if (functionExists.isEmpty) {
        print('   ❌ Function find_nearby_users NOT FOUND in database');
      } else {
        print('   ⚠️  Function exists but has execution error');
      }
    }

    // 2. Check users table structure
    print('\n👥 2. KIỂM TRA CẤU TRÚC BẢNG USERS:');
    final userSample = await supabase
        .from('users')
        .select('id, display_name, latitude, longitude, skill_level')
        .limit(1)
        .maybeSingle();
    
    if (userSample != null) {
      print('   ✅ Users table accessible');
      print('   - Sample user: ${userSample['display_name']}');
      print('   - Has latitude: ${userSample['latitude'] != null}');
      print('   - Has longitude: ${userSample['longitude'] != null}');
      print('   - Skill level: ${userSample['skill_level']}');
    } else {
      print('   ❌ No users found or table issue');
    }

    // 3. Check users with location data
    print('\n🌍 3. USERS VỚI DỮ LIỆU LOCATION:');
    final usersWithLocation = await supabase
        .from('users')
        .select('id, display_name, latitude, longitude')
        .not('latitude', 'is', null)
        .not('longitude', 'is', null)
        .limit(5);
    
    print('   ✅ Found ${usersWithLocation.length} users with location data:');
    for (var user in usersWithLocation) {
      print('      - ${user['display_name']}: (${user['latitude']}, ${user['longitude']})');
    }

    // 4. Test location extensions
    print('\n🔧 4. KIỂM TRA EXTENSIONS:');
    try {
      final extensions = await supabase.rpc('pg_extension', params: {});
      print('   Extensions query executed');
    } catch (e) {
      // Try alternative way
      print('   Checking extensions differently...');
    }

    // 5. Manual distance calculation test
    print('\n📐 5. TEST MANUAL DISTANCE CALCULATION:');
    final testLat = 10.8231;  // Ho Chi Minh City
    final testLon = 106.6297;
    
    final nearbyTest = await supabase
        .from('users')
        .select('id, display_name, latitude, longitude')
        .not('latitude', 'is', null)
        .not('longitude', 'is', null)
        .limit(10);
    
    if (nearbyTest.isNotEmpty) {
      print('   ✅ Found ${nearbyTest.length} users to test distance with');
      
      // Simple distance calculation (for testing)
      for (var user in nearbyTest.take(3)) {
        final userLat = user['latitude'] as double?;
        final userLon = user['longitude'] as double?;
        
        if (userLat != null && userLon != null) {
          final distance = _calculateDistance(testLat, testLon, userLat, userLon);
          print('      - ${user['display_name']}: ${distance.toStringAsFixed(2)} km away');
        }
      }
    }

  } catch (error) {
    print('\n❌ CRITICAL ERROR: $error');
  }

  print('\n🏁 DEBUG COMPLETE');
}

double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  // Simple distance calculation using Haversine formula
  const double earthRadius = 6371; // Earth radius in kilometers
  
  double dLat = _toRadians(lat2 - lat1);
  double dLon = _toRadians(lon2 - lon1);
  
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  
  return earthRadius * c;
}

double _toRadians(double degrees) {
  return degrees * (pi / 180);
}