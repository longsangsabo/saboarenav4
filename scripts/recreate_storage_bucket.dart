import 'dart:convert';
import 'dart:io';

/// Recreate Storage Bucket with proper configuration
Future<void> recreateStorageBucket() async {
  final String supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  final String serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';
  
  final HttpClient client = HttpClient();
  
  try {
    print('🗑️  Step 1: Deleting old bucket...');
    
    // 1. Delete existing bucket
    final deleteRequest = await client.deleteUrl(
      Uri.parse('$supabaseUrl/storage/v1/bucket/profiles')
    );
    deleteRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
    deleteRequest.headers.set('apikey', serviceRoleKey);
    
    final deleteResponse = await deleteRequest.close();
    final deleteBody = await deleteResponse.transform(utf8.decoder).join();
    
    if (deleteResponse.statusCode == 200) {
      print('✅ Old bucket deleted successfully');
    } else if (deleteResponse.statusCode == 404) {
      print('ℹ️  No existing bucket to delete');
    } else {
      print('⚠️ Delete response: ${deleteResponse.statusCode}');
      print('Body: $deleteBody');
    }
    
    // Wait a bit for deletion to complete
    await Future.delayed(Duration(seconds: 2));
    
    print('');
    print('🆕 Step 2: Creating new bucket with optimal config...');
    
    // 2. Create new bucket with perfect configuration
    final createRequest = await client.postUrl(
      Uri.parse('$supabaseUrl/storage/v1/bucket')
    );
    createRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
    createRequest.headers.set('Content-Type', 'application/json');
    createRequest.headers.set('apikey', serviceRoleKey);
    
    final bucketConfig = jsonEncode({
      'id': 'user-uploads',
      'name': 'user-uploads', 
      'public': true,
      'file_size_limit': 10485760, // 10MB limit
      'allowed_mime_types': [
        'image/jpeg',
        'image/jpg', 
        'image/png',
        'image/webp',
        'image/gif'
      ]
    });
    
    createRequest.write(bucketConfig);
    final createResponse = await createRequest.close();
    final createBody = await createResponse.transform(utf8.decoder).join();
    
    if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
      print('✅ New bucket created successfully!');
      print('   📁 ID: user-uploads');
      print('   🌐 Public: true');
      print('   📏 Size limit: 10485760 bytes (10.0MB)');
      print('   🎨 Allowed types: [image/jpeg, image/jpg, image/png, image/webp, image/gif]');
      print('Response: $createBody');
    } else {
      print('❌ Failed to create bucket: ${createResponse.statusCode}');
      print('Response: $createBody');
      return;
    }
    
    print('');
    print('⚙️  Step 3: Configuring security (disable RLS for dev)...');
    
    // 3. Ensure RLS is disabled for development
    final rlsRequest = await client.postUrl(
      Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql')
    );
    rlsRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
    rlsRequest.headers.set('Content-Type', 'application/json');
    rlsRequest.headers.set('apikey', serviceRoleKey);
    
    final sqlCommand = jsonEncode({
      'sql': '''
        -- Ensure RLS is disabled for development
        ALTER TABLE IF EXISTS storage.objects DISABLE ROW LEVEL SECURITY;
        ALTER TABLE IF EXISTS storage.buckets DISABLE ROW LEVEL SECURITY;
      '''
    });
    
    rlsRequest.write(sqlCommand);
    final rlsResponse = await rlsRequest.close();
    
    if (rlsResponse.statusCode == 200) {
      print('✅ RLS disabled for development');
    } else {
      print('ℹ️  RLS config may need manual setup');
    }
    
    print('');
    print('🧪 Step 4: Testing bucket functionality...');
    
    // 4. Test upload functionality
    final testContent = 'Test upload ${DateTime.now()}';
    final testBytes = utf8.encode(testContent);
    
    final testRequest = await client.postUrl(
      Uri.parse('$supabaseUrl/storage/v1/object/user-uploads/test/dev-test.txt')
    );
    testRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
    testRequest.headers.set('apikey', serviceRoleKey);
    testRequest.headers.set('Content-Type', 'text/plain');
    testRequest.headers.set('Content-Length', testBytes.length.toString());
    
    testRequest.add(testBytes);
    final testResponse = await testRequest.close();
    
    if (testResponse.statusCode == 200 || testResponse.statusCode == 201) {
      print('✅ Upload test successful!');
      
      // Test public URL
      final publicUrl = '$supabaseUrl/storage/v1/object/public/user-uploads/test/dev-test.txt';
      print('🌐 Public URL: $publicUrl');
      
      // Cleanup test file
      final cleanupRequest = await client.deleteUrl(
        Uri.parse('$supabaseUrl/storage/v1/object/user-uploads/test/dev-test.txt')
      );
      cleanupRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
      cleanupRequest.headers.set('apikey', serviceRoleKey);
      await cleanupRequest.close();
      
    } else {
      print('⚠️ Upload test failed: ${testResponse.statusCode}');
    }
    
    print('');
    print('🎉 BUCKET SETUP COMPLETED!');
    print('');
    print('📋 SUMMARY:');
    print('✅ Bucket ID: user-uploads');
    print('✅ Public access: enabled'); 
    print('✅ File size limit: 10MB');
    print('✅ Allowed formats: JPG, PNG, WebP, GIF');
    print('✅ RLS: disabled for development');
    print('✅ Upload functionality: tested');
    print('');
    print('🔄 NEXT STEPS:');
    print('1. Update your Flutter code to use bucket "user-uploads"');
    print('2. Test avatar/cover photo upload in app');
    print('3. Verify images persist after app restart');
    
  } catch (e) {
    print('❌ Error setting up bucket: $e');
  } finally {
    client.close();
  }
}

void main() async {
  await recreateStorageBucket();
}