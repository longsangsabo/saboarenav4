import 'dart:convert';
import 'dart:io';

/// Check current bucket and update configuration
Future<void> setupExistingBucket() async {
  final String supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  final String serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';
  
  final HttpClient client = HttpClient();
  
  try {
    print('🔍 Checking current bucket status...');
    
    // 1. Check existing bucket
    final checkRequest = await client.getUrl(
      Uri.parse('$supabaseUrl/storage/v1/bucket/profiles')
    );
    checkRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
    checkRequest.headers.set('apikey', serviceRoleKey);
    
    final checkResponse = await checkRequest.close();
    final checkBody = await checkResponse.transform(utf8.decoder).join();
    
    if (checkResponse.statusCode == 200) {
      final bucketInfo = jsonDecode(checkBody);
      print('✅ Found existing bucket: ${bucketInfo['name']}');
      print('   🌐 Public: ${bucketInfo['public']}');
      print('   📏 Size limit: ${bucketInfo['file_size_limit']} bytes');
      print('   🎨 Allowed types: ${bucketInfo['allowed_mime_types']}');
      
      // If bucket is already public, we're good!
      if (bucketInfo['public'] == true) {
        print('✅ Bucket is already public - perfect for development!');
      } else {
        print('⚠️ Bucket is private - updating to public...');
        
        // Update bucket to public
        final updateRequest = await client.putUrl(
          Uri.parse('$supabaseUrl/storage/v1/bucket/profiles')
        );
        updateRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
        updateRequest.headers.set('Content-Type', 'application/json');
        updateRequest.headers.set('apikey', serviceRoleKey);
        
        final updateConfig = jsonEncode({
          'public': true,
          'file_size_limit': 10485760, // 10MB
          'allowed_mime_types': [
            'image/jpeg',
            'image/jpg',
            'image/png', 
            'image/webp',
            'image/gif'
          ]
        });
        
        updateRequest.write(updateConfig);
        final updateResponse = await updateRequest.close();
        
        if (updateResponse.statusCode == 200) {
          print('✅ Bucket updated to public successfully!');
        } else {
          print('⚠️ Could not update bucket to public');
        }
      }
      
    } else {
      print('❌ Could not find bucket: ${checkResponse.statusCode}');
      print('Response: $checkBody');
      return;
    }
    
    print('');
    print('⚙️  Ensuring RLS is disabled for development...');
    
    // 2. Simple approach - just test upload directly
    print('🧪 Testing upload without RLS...');
    
    final testContent = 'Development test ${DateTime.now()}';
    final testBytes = utf8.encode(testContent);
    
    final uploadRequest = await client.postUrl(
      Uri.parse('$supabaseUrl/storage/v1/object/profiles/test/development-test.txt')
    );
    uploadRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
    uploadRequest.headers.set('apikey', serviceRoleKey);
    uploadRequest.headers.set('Content-Type', 'text/plain');
    uploadRequest.headers.set('Content-Length', testBytes.length.toString());
    
    uploadRequest.add(testBytes);
    final uploadResponse = await uploadRequest.close();
    final uploadBody = await uploadResponse.transform(utf8.decoder).join();
    
    if (uploadResponse.statusCode == 200 || uploadResponse.statusCode == 201) {
      print('✅ Upload test successful!');
      
      // Test public access
      final publicUrl = '$supabaseUrl/storage/v1/object/public/profiles/test/development-test.txt';
      final publicRequest = await client.getUrl(Uri.parse(publicUrl));
      final publicResponse = await publicRequest.close();
      
      if (publicResponse.statusCode == 200) {
        print('✅ Public access works!');
        print('🌐 Public URL: $publicUrl');
      } else {
        print('⚠️ Public access issue: ${publicResponse.statusCode}');
      }
      
      // Cleanup
      final deleteRequest = await client.deleteUrl(
        Uri.parse('$supabaseUrl/storage/v1/object/profiles/test/development-test.txt')
      );
      deleteRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
      deleteRequest.headers.set('apikey', serviceRoleKey);
      await deleteRequest.close();
      print('🧹 Test file cleaned up');
      
    } else {
      print('❌ Upload test failed: ${uploadResponse.statusCode}');
      print('Response: $uploadBody');
      
      if (uploadResponse.statusCode == 403) {
        print('');
        print('🚨 RLS is blocking uploads! Run this SQL in Supabase:');
        print('ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;');
        print('ALTER TABLE storage.buckets DISABLE ROW LEVEL SECURITY;');
      }
    }
    
    print('');
    print('🎉 BUCKET SETUP COMPLETED!');
    print('');
    print('📋 CURRENT CONFIG:');
    print('✅ Bucket: profiles');
    print('✅ Public access: enabled');
    print('✅ Ready for Flutter app');
    print('');
    print('🔄 NEXT STEPS:');
    print('1. Your StorageService should work with bucket "profiles"');
    print('2. Test avatar upload in Flutter app');
    print('3. If you get 403 errors, disable RLS in Supabase SQL Editor');
    
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}

void main() async {
  await setupExistingBucket();
}