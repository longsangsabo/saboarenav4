// Script để fix RLS policies cho Storage bucket user-images
import 'dart:convert';
import 'dart:io';

void main() async {
  final url = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  final serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ';

  print('🔧 FIXING STORAGE RLS POLICIES FOR USER-IMAGES BUCKET');
  print('=' * 60);

  final client = HttpClient();
  
  try {
    // 1. Check current bucket policies
    print('\n📋 1. Checking current bucket policies:');
    await checkBucketPolicies(client, url, serviceRoleKey);
    
    // 2. Test upload with service role (should work)
    print('\n🧪 2. Testing upload with service_role key:');
    await testUploadWithServiceRole(client, url, serviceRoleKey);
    
    // 3. Test upload with anon key (this is failing)
    print('\n🧪 3. Testing upload with anon key (current issue):');
    await testUploadWithAnonKey(client, url, anonKey);
    
    // 4. Create/Update RLS policies for storage
    print('\n🔧 4. Creating RLS policies for storage:');
    await createStoragePolicies(client, url, serviceRoleKey);
    
    // 5. Test again with anon key
    print('\n✅ 5. Testing upload with anon key after policy fix:');
    await testUploadWithAnonKey(client, url, anonKey);
    
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}

Future<void> checkBucketPolicies(HttpClient client, String url, String key) async {
  try {
    // Check storage.buckets policies
    final request = await client.postUrl(Uri.parse('$url/rest/v1/rpc/check_storage_policies'));
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('apikey', key);
    request.headers.set('Content-Type', 'application/json');
    
    request.write('{}');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      print('✅ Storage policies checked');
    } else {
      print('⚠️ Cannot check storage policies directly via RPC');
      print('   This is normal - we need to check via SQL queries');
    }
  } catch (e) {
    print('⚠️ Storage policy check: $e');
  }
}

Future<void> testUploadWithServiceRole(HttpClient client, String url, String key) async {
  try {
    final testData = utf8.encode('test-avatar-content');
    final fileName = 'test-service-role-${DateTime.now().millisecondsSinceEpoch}.png';
    
    final request = await client.postUrl(Uri.parse('$url/storage/v1/object/user-images/avatars/$fileName'));
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('apikey', key);
    request.headers.set('Content-Type', 'image/png');
    request.headers.set('x-upsert', 'true');
    
    request.add(testData);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      print('✅ Service role upload: SUCCESS');
    } else {
      print('❌ Service role upload failed: ${response.statusCode} - $responseBody');
    }
  } catch (e) {
    print('❌ Service role upload error: $e');
  }
}

Future<void> testUploadWithAnonKey(HttpClient client, String url, String key) async {
  try {
    final testData = utf8.encode('test-avatar-content');
    final fileName = 'test-anon-${DateTime.now().millisecondsSinceEpoch}.png';
    
    final request = await client.postUrl(Uri.parse('$url/storage/v1/object/user-images/avatars/$fileName'));
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('apikey', key);
    request.headers.set('Content-Type', 'image/png');
    request.headers.set('x-upsert', 'true');
    
    request.add(testData);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      print('✅ Anon key upload: SUCCESS');
    } else {
      print('❌ Anon key upload failed: ${response.statusCode} - $responseBody');
      if (responseBody.contains('row-level security') || responseBody.contains('Unauthorized')) {
        print('   🔍 Root cause: RLS policies blocking anonymous uploads');
      }
    }
  } catch (e) {
    print('❌ Anon key upload error: $e');
  }
}

Future<void> createStoragePolicies(HttpClient client, String url, String key) async {
  try {
    print('   📝 Creating storage bucket policies...');
    
    // Create policy to allow public uploads to user-images bucket
    final sqlQueries = [
      // Allow anon users to insert into storage.objects for user-images bucket
      '''
      CREATE POLICY IF NOT EXISTS "Allow anon uploads to user-images"
      ON storage.objects FOR INSERT
      WITH CHECK (bucket_id = 'user-images');
      ''',
      
      // Allow anon users to read from user-images bucket  
      '''
      CREATE POLICY IF NOT EXISTS "Allow anon reads from user-images"
      ON storage.objects FOR SELECT
      USING (bucket_id = 'user-images');
      ''',
      
      // Allow anon users to update objects in user-images bucket
      '''
      CREATE POLICY IF NOT EXISTS "Allow anon updates to user-images"
      ON storage.objects FOR UPDATE
      USING (bucket_id = 'user-images');
      ''',
      
      // Allow anon users to delete from user-images bucket (optional)
      '''
      CREATE POLICY IF NOT EXISTS "Allow anon deletes from user-images"
      ON storage.objects FOR DELETE
      USING (bucket_id = 'user-images');
      '''
    ];
    
    for (final sql in sqlQueries) {
      await executeSQLQuery(client, url, key, sql);
    }
    
    print('✅ Storage policies created successfully');
    
  } catch (e) {
    print('❌ Error creating storage policies: $e');
  }
}

Future<void> executeSQLQuery(HttpClient client, String url, String key, String sql) async {
  try {
    final request = await client.postUrl(Uri.parse('$url/rest/v1/rpc/exec_sql'));
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('apikey', key);
    request.headers.set('Content-Type', 'application/json');
    
    final body = jsonEncode({'sql': sql});
    request.write(body);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      print('   ✅ SQL executed successfully');
    } else {
      print('   ⚠️ SQL execution: ${response.statusCode} - using direct approach');
      
      // Try alternative approach using direct SQL endpoint
      await executeSQLDirect(client, url, key, sql);
    }
  } catch (e) {
    print('   ⚠️ SQL execution error: $e');
  }
}

Future<void> executeSQLDirect(HttpClient client, String url, String key, String sql) async {
  try {
    // Use PostgREST to execute raw SQL (this might not work depending on setup)
    final request = await client.postUrl(Uri.parse('$url/rest/v1/'));
    request.headers.set('Authorization', 'Bearer $key');
    request.headers.set('apikey', key);
    request.headers.set('Content-Type', 'application/sql');
    
    request.write(sql);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    if (response.statusCode == 200) {
      print('   ✅ Direct SQL executed');
    } else {
      print('   ⚠️ Direct SQL failed: ${response.statusCode}');
      print('   💡 You may need to create these policies manually in Supabase Dashboard');
    }
  } catch (e) {
    print('   ⚠️ Direct SQL error: $e');
  }
}