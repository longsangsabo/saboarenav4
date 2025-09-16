import 'dart:convert';
import 'dart:io';

/// Create fresh new bucket for development
Future<void> createFreshBucket() async {
  final String supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  final String serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjopyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';
  
  final HttpClient client = HttpClient();
  
  try {
    print('🆕 Creating fresh bucket for development...');
    
    // Create new bucket with simple name
    final createRequest = await client.postUrl(
      Uri.parse('$supabaseUrl/storage/v1/bucket')
    );
    createRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
    createRequest.headers.set('Content-Type', 'application/json');
    createRequest.headers.set('apikey', serviceRoleKey);
    
    final bucketConfig = jsonEncode({
      'id': 'uploads',
      'name': 'uploads',
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
    
    createRequest.write(bucketConfig);
    final createResponse = await createRequest.close();
    final createBody = await createResponse.transform(utf8.decoder).join();
    
    if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
      print('✅ Bucket "uploads" created successfully!');
      print('📁 Configuration:');
      print('   - ID: uploads');
      print('   - Public: true');
      print('   - Size limit: 10MB');
      print('   - Image formats: JPG, PNG, WebP, GIF');
    } else {
      print('❌ Failed to create bucket: ${createResponse.statusCode}');
      print('Response: $createBody');
      return;
    }
    
    print('');
    print('🧪 Testing upload functionality...');
    
    // Test with image-like content type
    final testContent = 'PNG test content';
    final testBytes = utf8.encode(testContent);
    
    final uploadRequest = await client.postUrl(
      Uri.parse('$supabaseUrl/storage/v1/object/uploads/test/sample.png')
    );
    uploadRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
    uploadRequest.headers.set('apikey', serviceRoleKey);
    uploadRequest.headers.set('Content-Type', 'image/png');
    uploadRequest.headers.set('Content-Length', testBytes.length.toString());
    
    uploadRequest.add(testBytes);
    final uploadResponse = await uploadRequest.close();
    final uploadBody = await uploadResponse.transform(utf8.decoder).join();
    
    if (uploadResponse.statusCode == 200 || uploadResponse.statusCode == 201) {
      print('✅ Upload test successful!');
      
      // Test public URL
      final publicUrl = '$supabaseUrl/storage/v1/object/public/uploads/test/sample.png';
      print('🌐 Public URL: $publicUrl');
      
      final publicRequest = await client.getUrl(Uri.parse(publicUrl));
      final publicResponse = await publicRequest.close();
      
      if (publicResponse.statusCode == 200) {
        print('✅ Public access works perfectly!');
      } else {
        print('⚠️ Public access status: ${publicResponse.statusCode}');
      }
      
      // Cleanup test file
      final deleteRequest = await client.deleteUrl(
        Uri.parse('$supabaseUrl/storage/v1/object/uploads/test/sample.png')
      );
      deleteRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
      deleteRequest.headers.set('apikey', serviceRoleKey);
      await deleteRequest.close();
      
    } else {
      print('❌ Upload failed: ${uploadResponse.statusCode}');
      print('Error: $uploadBody');
    }
    
    print('');
    print('🎉 SUCCESS! Bucket is ready for use!');
    print('');
    print('📋 WHAT YOU NEED TO UPDATE:');
    print('In your StorageService, change:');
    print('   FROM: .from("profiles")');
    print('   TO:   .from("uploads")');
    print('');
    print('🔄 NEXT STEPS:');
    print('1. Update StorageService to use "uploads" bucket');
    print('2. Test avatar upload in Flutter app');
    print('3. Images should persist after app restart');
    
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}

void main() async {
  await createFreshBucket();
}