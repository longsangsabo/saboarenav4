// Test upload với service_role key để xác nhận vấn đề RLS
import 'dart:convert';
import 'dart:io';

void main() async {
  final url = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  final serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';

  print('🔍 Testing with SERVICE_ROLE key (bypasses RLS)');
  print('================================================');

  final client = HttpClient();
  
  // 1. Test bucket access với service_role
  print('\n1. Testing bucket access with service_role:');
  try {
    final request = await client.getUrl(Uri.parse('$url/storage/v1/bucket'));
    request.headers.set('Authorization', 'Bearer $serviceRoleKey');
    request.headers.set('apikey', serviceRoleKey);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final buckets = jsonDecode(responseBody) as List;
      print('✅ Buckets accessible with service_role:');
      for (final bucket in buckets) {
        print('   - ${bucket['name']} (public: ${bucket['public']})');
      }
      
      // Check user-images bucket
      final userImagesBucket = buckets.firstWhere(
        (bucket) => bucket['name'] == 'user-images',
        orElse: () => null,
      );
      
      if (userImagesBucket != null) {
        print('✅ user-images bucket found with service_role!');
      }
    } else {
      print('❌ Failed with service_role: ${response.statusCode}');
      print('   Response: $responseBody');
    }
  } catch (e) {
    print('❌ Error with service_role: $e');
  }

  // 2. Test file upload với service_role
  print('\n2. Testing file upload with service_role:');
  try {
    final testContent = 'service-role-test-${DateTime.now().millisecondsSinceEpoch}';
    final fileName = 'test-service-role-${DateTime.now().millisecondsSinceEpoch}.txt';
    
    final request = await client.postUrl(Uri.parse('$url/storage/v1/object/user-images/$fileName'));
    request.headers.set('Authorization', 'Bearer $serviceRoleKey');
    request.headers.set('apikey', serviceRoleKey);
    request.headers.set('Content-Type', 'text/plain');
    request.write(testContent);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ File upload SUCCESSFUL with service_role!');
      print('   This confirms RLS is the issue with anon key');
    } else {
      print('❌ File upload failed even with service_role: ${response.statusCode}');
      print('   Response: $responseBody');
    }
  } catch (e) {
    print('❌ Error uploading with service_role: $e');
  }

  client.close();
  
  print('\n🎯 CONCLUSION:');
  print('If service_role upload works but anon fails:');
  print('- RLS policies are blocking anon users');
  print('- Need to either:');
  print('  A) Disable RLS on users table temporarily');
  print('  B) Create proper RLS policies for authenticated users');
  print('  C) Use service_role for Storage operations (NOT recommended for production)');
}