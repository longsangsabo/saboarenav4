import 'dart:io';
import 'dart:convert';

/// Test script để kiểm tra Club Approval Flow end-to-end
/// Run: dart run scripts/test_club_approval_flow.dart

const String SUPABASE_URL = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
const String SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

void main() async {
  print('🧪 TESTING CLUB APPROVAL FLOW');
  print('=' * 50);

  try {
    await testFullApprovalFlow();
  } catch (e) {
    print('❌ Test failed: $e');
  }
}

Future<void> testFullApprovalFlow() async {
  // Step 1: Create test user and login
  print('\n1️⃣ Creating test user and login...');
  final userToken = await createTestUserAndLogin();
  if (userToken == null) {
    throw Exception('Failed to create user and login');
  }
  print('✅ User logged in successfully');

  // Step 2: Create club registration
  print('\n2️⃣ Creating club registration...');
  final clubId = await createClubRegistration(userToken);
  if (clubId == null) {
    throw Exception('Failed to create club');
  }
  print('✅ Club created with ID: $clubId');

  // Step 3: Verify club is in pending status
  print('\n3️⃣ Verifying club is in pending status...');
  final isPending = await verifyClubStatus(clubId, 'pending');
  if (!isPending) {
    throw Exception('Club is not in pending status');
  }
  print('✅ Club is in pending status');

  // Step 4: Admin approve club
  print('\n4️⃣ Admin approving club...');
  final adminToken = await getAdminToken();
  if (adminToken == null) {
    throw Exception('Failed to get admin token');
  }
  
  final approved = await adminApproveClub(adminToken, clubId);
  if (!approved) {
    throw Exception('Failed to approve club');
  }
  print('✅ Club approved by admin');

  // Step 5: Verify club is approved
  print('\n5️⃣ Verifying club is approved...');
  final isApproved = await verifyClubStatus(clubId, 'approved');
  if (!isApproved) {
    throw Exception('Club is not in approved status');
  }
  print('✅ Club is in approved status');

  // Step 6: Test rejection flow
  print('\n6️⃣ Testing rejection flow...');
  final clubId2 = await createClubRegistration(userToken);
  if (clubId2 == null) {
    throw Exception('Failed to create second club');
  }
  
  final rejected = await adminRejectClub(adminToken, clubId2, 'Test rejection reason');
  if (!rejected) {
    throw Exception('Failed to reject club');
  }
  print('✅ Club rejected by admin');

  // Step 7: Verify rejection
  print('\n7️⃣ Verifying club is rejected...');
  final isRejected = await verifyClubStatus(clubId2, 'rejected');
  if (!isRejected) {
    throw Exception('Club is not in rejected status');
  }
  print('✅ Club is in rejected status');

  print('\n🎉 ALL TESTS PASSED! Club approval flow is working correctly.');
}

Future<String?> createTestUserAndLogin() async {
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('$SUPABASE_URL/auth/v1/signup'));
    request.headers.set('apikey', SUPABASE_ANON_KEY);
    request.headers.set('Content-Type', 'application/json');

    final testEmail = 'test_user_${DateTime.now().millisecondsSinceEpoch}@test.com';
    final body = jsonEncode({
      'email': testEmail,
      'password': 'testpassword123',
      'data': {
        'display_name': 'Test User',
        'role': 'user'
      }
    });

    request.write(body);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data['access_token'];
    } else {
      print('Failed to create user: $responseBody');
      return null;
    }
  } catch (e) {
    print('Error creating user: $e');
    return null;
  }
}

Future<String?> createClubRegistration(String userToken) async {
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('$SUPABASE_URL/rest/v1/clubs'));
    request.headers.set('apikey', SUPABASE_ANON_KEY);
    request.headers.set('Authorization', 'Bearer $userToken');
    request.headers.set('Content-Type', 'application/json');

    final body = jsonEncode({
      'name': 'Test Club ${DateTime.now().millisecondsSinceEpoch}',
      'description': 'Test club description',
      'address': 'Test address',
      'phone': '0123456789',
      'email': 'test@club.com',
      'total_tables': 5,
      'price_per_hour': 50000,
      'approval_status': 'pending',
      'is_verified': false,
      'is_active': false,
    });

    request.write(body);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 201) {
      final data = jsonDecode(responseBody);
      return data[0]['id'];
    } else {
      print('Failed to create club: $responseBody');
      return null;
    }
  } catch (e) {
    print('Error creating club: $e');
    return null;
  }
}

Future<bool> verifyClubStatus(String clubId, String expectedStatus) async {
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('$SUPABASE_URL/rest/v1/clubs?id=eq.$clubId&select=approval_status'));
    request.headers.set('apikey', SUPABASE_ANON_KEY);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      if (data.length > 0) {
        return data[0]['approval_status'] == expectedStatus;
      }
    }
    return false;
  } catch (e) {
    print('Error verifying club status: $e');
    return false;
  }
}

Future<String?> getAdminToken() async {
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('$SUPABASE_URL/auth/v1/token?grant_type=password'));
    request.headers.set('apikey', SUPABASE_ANON_KEY);
    request.headers.set('Content-Type', 'application/json');

    final body = jsonEncode({
      'email': 'admin@saboarena.com',
      'password': 'admin123456',
    });

    request.write(body);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data['access_token'];
    } else {
      print('Failed to get admin token: $responseBody');
      return null;
    }
  } catch (e) {
    print('Error getting admin token: $e');
    return null;
  }
}

Future<bool> adminApproveClub(String adminToken, String clubId) async {
  try {
    final client = HttpClient();
    final request = await client.patchUrl(Uri.parse('$SUPABASE_URL/rest/v1/clubs?id=eq.$clubId'));
    request.headers.set('apikey', SUPABASE_ANON_KEY);
    request.headers.set('Authorization', 'Bearer $adminToken');
    request.headers.set('Content-Type', 'application/json');

    final body = jsonEncode({
      'approval_status': 'approved',
      'approved_at': DateTime.now().toIso8601String(),
      'rejection_reason': null,
      'updated_at': DateTime.now().toIso8601String(),
    });

    request.write(body);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    return response.statusCode == 204;
  } catch (e) {
    print('Error approving club: $e');
    return false;
  }
}

Future<bool> adminRejectClub(String adminToken, String clubId, String reason) async {
  try {
    final client = HttpClient();
    final request = await client.patchUrl(Uri.parse('$SUPABASE_URL/rest/v1/clubs?id=eq.$clubId'));
    request.headers.set('apikey', SUPABASE_ANON_KEY);
    request.headers.set('Authorization', 'Bearer $adminToken');
    request.headers.set('Content-Type', 'application/json');

    final body = jsonEncode({
      'approval_status': 'rejected',
      'rejection_reason': reason,
      'updated_at': DateTime.now().toIso8601String(),
    });

    request.write(body);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    return response.statusCode == 204;
  } catch (e) {
    print('Error rejecting club: $e');
    return false;
  }
}