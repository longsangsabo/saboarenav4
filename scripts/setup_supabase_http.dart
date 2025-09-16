import 'dart:convert';
import 'dart:io';

/// Setup Supabase Storage bucket using HTTP API
Future<void> setupSupabaseStorageHTTP() async {
  final String supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  final String serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';
  
  final HttpClient client = HttpClient();
  
  try {
    print('🚀 Creating Supabase Storage bucket via REST API...');
    
    // Create bucket using REST API
    final createBucketRequest = await client.postUrl(Uri.parse('$supabaseUrl/storage/v1/bucket'));
    createBucketRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
    createBucketRequest.headers.set('Content-Type', 'application/json');
    createBucketRequest.headers.set('apikey', serviceRoleKey);
    
    final bucketData = {
      'id': 'profiles',
      'name': 'profiles',
      'public': true,
      'file_size_limit': 5242880,
      'allowed_mime_types': ['image/jpeg', 'image/png', 'image/webp', 'image/jpg']
    };
    
    createBucketRequest.write(jsonEncode(bucketData));
    final createBucketResponse = await createBucketRequest.close();
    final createBucketResponseBody = await createBucketResponse.transform(utf8.decoder).join();
    
    if (createBucketResponse.statusCode == 200 || createBucketResponse.statusCode == 409) {
      print('✅ Bucket created successfully or already exists');
      print('Response: $createBucketResponseBody');
    } else {
      print('❌ Failed to create bucket: ${createBucketResponse.statusCode}');
      print('Error: $createBucketResponseBody');
    }
    
    // Test bucket by listing buckets
    print('🔍 Testing bucket access...');
    final listBucketsRequest = await client.getUrl(Uri.parse('$supabaseUrl/storage/v1/bucket'));
    listBucketsRequest.headers.set('Authorization', 'Bearer $serviceRoleKey');
    listBucketsRequest.headers.set('apikey', serviceRoleKey);
    
    final listBucketsResponse = await listBucketsRequest.close();
    final listBucketsResponseBody = await listBucketsResponse.transform(utf8.decoder).join();
    
    if (listBucketsResponse.statusCode == 200) {
      print('✅ Successfully connected to Supabase Storage');
      final buckets = jsonDecode(listBucketsResponseBody) as List;
      final profilesBucket = buckets.where((bucket) => bucket['id'] == 'profiles').toList();
      
      if (profilesBucket.isNotEmpty) {
        print('✅ Profiles bucket found: ${profilesBucket.first}');
      } else {
        print('⚠️ Profiles bucket not found in list');
      }
      
      print('📋 All buckets: ${buckets.map((b) => b['id']).join(', ')}');
    } else {
      print('❌ Failed to list buckets: ${listBucketsResponse.statusCode}');
      print('Error: $listBucketsResponseBody');
    }
    
    print('🎉 Supabase Storage setup completed!');
    print('');
    print('📝 Next steps:');
    print('1. Test avatar upload in the app');
    print('2. Check if images persist after app restart');
    print('3. Verify images are saved to Supabase Storage dashboard');
    
  } catch (e) {
    print('❌ Error setting up Supabase Storage: $e');
  } finally {
    client.close();
  }
}

void main() async {
  await setupSupabaseStorageHTTP();
}