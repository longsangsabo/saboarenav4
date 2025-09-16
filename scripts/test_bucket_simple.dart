// Script kiểm tra Supabase Storage bucket
import 'dart:convert';
import 'dart:io';

void main() async {
  final url = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

  print('🔍 Debug Supabase Storage Issues');
  print('================================');

  // 1. Check bucket tồn tại
  print('\n1. Checking user-images bucket exists:');
  final client = HttpClient();
  
  try {
    final request = await client.getUrl(Uri.parse('$url/storage/v1/bucket'));
    request.headers.set('Authorization', 'Bearer $anonKey');
    request.headers.set('apikey', anonKey);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final buckets = jsonDecode(responseBody) as List;
      final userImagesBucket = buckets.firstWhere(
        (bucket) => bucket['name'] == 'user-images',
        orElse: () => null,
      );
      
      if (userImagesBucket != null) {
        print('✅ user-images bucket found');
        print('   Public: ${userImagesBucket['public']}');
        print('   Created: ${userImagesBucket['created_at']}');
      } else {
        print('❌ user-images bucket NOT found');
        print('   Available buckets:');
        for (final bucket in buckets) {
          print('   - ${bucket['name']} (public: ${bucket['public']})');
        }
      }
    } else {
      print('❌ Failed to fetch buckets: ${response.statusCode}');
      print('   Response: $responseBody');
    }
  } catch (e) {
    print('❌ Error checking buckets: $e');
  }

  // 2. Kiểm tra bucket permissions
  print('\n2. Checking bucket permissions:');
  try {
    final request = await client.getUrl(Uri.parse('$url/storage/v1/bucket/user-images'));
    request.headers.set('Authorization', 'Bearer $anonKey');
    request.headers.set('apikey', anonKey);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final bucketInfo = jsonDecode(responseBody);
      print('✅ Bucket accessible');
      print('   Public: ${bucketInfo['public']}');
      print('   File size limit: ${bucketInfo['file_size_limit']}');
    } else {
      print('❌ Cannot access bucket: ${response.statusCode}');
      print('   Response: $responseBody');
    }
  } catch (e) {
    print('❌ Error accessing bucket: $e');
  }

  // 3. Test upload một file nhỏ
  print('\n3. Testing file upload:');
  try {
    final testContent = 'test-content-${DateTime.now().millisecondsSinceEpoch}';
    final fileName = 'test-${DateTime.now().millisecondsSinceEpoch}.txt';
    
    final request = await client.postUrl(Uri.parse('$url/storage/v1/object/user-images/$fileName'));
    request.headers.set('Authorization', 'Bearer $anonKey');
    request.headers.set('apikey', anonKey);
    request.headers.set('Content-Type', 'text/plain');
    request.write(testContent);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ File upload successful');
      print('   Response: $responseBody');
    } else {
      print('❌ File upload failed: ${response.statusCode}');
      print('   Response: $responseBody');
      
      if (responseBody.contains('row-level security')) {
        print('   >>> This is the RLS policy issue!');
      }
    }
  } catch (e) {
    print('❌ Error uploading file: $e');
  }

  client.close();
  
  print('\n🔍 Debug complete!');
  print('\nConclusions:');
  print('- If bucket not found: Need to create user-images bucket');
  print('- If RLS error: Need to fix bucket policies');
  print('- If unauthorized: Need to check authentication');
}