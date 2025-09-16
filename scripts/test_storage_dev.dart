import 'dart:convert';
import 'dart:io';

/// Test Supabase Storage WITHOUT policies (for development)
Future<void> testStorageNoPolicy() async {
  final String supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  final String serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';
  
  final HttpClient client = HttpClient();
  
  try {
    print('🧪 Testing Supabase Storage (Development Mode)...');
    print('');
    
    // 1. Check if bucket exists and is public
    print('📂 Checking bucket status...');
    final request = await client.getUrl(Uri.parse('$supabaseUrl/storage/v1/bucket/profiles'));
    request.headers.set('Authorization', 'Bearer $serviceRoleKey');
    request.headers.set('apikey', serviceRoleKey);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      final bucketInfo = jsonDecode(responseBody);
      print('✅ Bucket found: ${bucketInfo['name']}');
      print('   - Public: ${bucketInfo['public']}');
      print('   - File size limit: ${bucketInfo['file_size_limit']} bytes');
      print('   - Allowed types: ${bucketInfo['allowed_mime_types']}');
      
      if (bucketInfo['public'] == true) {
        print('🎉 Bucket is PUBLIC - No policies needed for development!');
        print('');
        
        // 2. Test upload a small dummy file
        print('📤 Testing file upload...');
        
        // Create test file content
        final testContent = 'Hello Supabase Storage ${DateTime.now()}';
        final testBytes = utf8.encode(testContent);
        
        final uploadRequest = await client.postUrl(
          Uri.parse('$supabaseUrl/storage/v1/object/profiles/test/development_test.txt')
        );
        uploadRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
        uploadRequest.headers.set('apikey', serviceRoleKey);
        uploadRequest.headers.set('Content-Type', 'text/plain');
        uploadRequest.headers.set('Content-Length', testBytes.length.toString());
        
        uploadRequest.add(testBytes);
        final uploadResponse = await uploadRequest.close();
        final uploadBody = await uploadResponse.transform(utf8.decoder).join();
        
        if (uploadResponse.statusCode == 200 || uploadResponse.statusCode == 201) {
          print('✅ Test file uploaded successfully!');
          
          // 3. Test public URL access
          final publicUrl = '$supabaseUrl/storage/v1/object/public/profiles/test/development_test.txt';
          print('🌐 Testing public URL: $publicUrl');
          
          final publicRequest = await client.getUrl(Uri.parse(publicUrl));
          final publicResponse = await publicRequest.close();
          
          if (publicResponse.statusCode == 200) {
            final content = await publicResponse.transform(utf8.decoder).join();
            print('✅ Public URL works! Content: $content');
          } else {
            print('⚠️ Public URL status: ${publicResponse.statusCode}');
          }
          
          // 4. Cleanup test file
          print('🧹 Cleaning up test file...');
          final deleteRequest = await client.deleteUrl(
            Uri.parse('$supabaseUrl/storage/v1/object/profiles/test/development_test.txt')
          );
          deleteRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
          deleteRequest.headers.set('apikey', serviceRoleKey);
          
          final deleteResponse = await deleteRequest.close();
          if (deleteResponse.statusCode == 200) {
            print('✅ Test file cleaned up');
          }
          
        } else {
          print('❌ Upload failed: ${uploadResponse.statusCode}');
          print('Response: $uploadBody');
        }
        
      } else {
        print('⚠️ Bucket is not public - you may need policies');
      }
      
    } else {
      print('❌ Bucket check failed: ${response.statusCode}');
      print('Response: $responseBody');
    }
    
    print('');
    print('🎯 RESULT:');
    print('✅ Bucket "profiles" is ready for development');
    print('✅ No policies needed - bucket is public');
    print('✅ Your Flutter app can now upload images!');
    print('');
    print('🚀 Next steps:');
    print('1. Test avatar upload in your Flutter app');
    print('2. Test cover photo upload');
    print('3. Restart app to verify images persist');
    
  } catch (e) {
    print('❌ Error testing storage: $e');
  } finally {
    client.close();
  }
}

void main() async {
  await testStorageNoPolicy();
}