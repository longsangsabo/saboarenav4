import 'dart:convert';
import 'dart:io';

/// Disable RLS for development (temporary fix)
Future<void> disableRLSForDev() async {
  final String supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  final String serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';
  
  final HttpClient client = HttpClient();
  
  try {
    print('🔧 Disabling RLS for development...');
    
    // Disable RLS on storage.objects
    final request1 = await client.postUrl(Uri.parse('$supabaseUrl/rest/v1/rpc/sql'));
    request1.headers.set('Authorization', 'Bearer $serviceRoleKey');
    request1.headers.set('Content-Type', 'application/json');
    request1.headers.set('apikey', serviceRoleKey);
    
    final sql1 = jsonEncode({
      'query': 'ALTER TABLE storage.objects DISABLE ROW LEVEL SECURITY;'
    });
    request1.write(sql1);
    
    final response1 = await request1.close();
    final body1 = await response1.transform(utf8.decoder).join();
    
    if (response1.statusCode == 200) {
      print('✅ RLS disabled on storage.objects');
    } else {
      print('⚠️ Could not disable RLS on objects: ${response1.statusCode}');
      print('Response: $body1');
    }
    
    // Disable RLS on storage.buckets  
    final request2 = await client.postUrl(Uri.parse('$supabaseUrl/rest/v1/rpc/sql'));
    request2.headers.set('Authorization', 'Bearer $serviceRoleKey');
    request2.headers.set('Content-Type', 'application/json');
    request2.headers.set('apikey', serviceRoleKey);
    
    final sql2 = jsonEncode({
      'query': 'ALTER TABLE storage.buckets DISABLE ROW LEVEL SECURITY;'
    });
    request2.write(sql2);
    
    final response2 = await request2.close();
    final body2 = await response2.transform(utf8.decoder).join();
    
    if (response2.statusCode == 200) {
      print('✅ RLS disabled on storage.buckets');
    } else {
      print('⚠️ Could not disable RLS on buckets: ${response2.statusCode}');
      print('Response: $body2');
    }
    
    print('');
    print('🎉 RLS disabled for development!');
    print('💡 Now your app can upload images without policies');
    print('');
    print('🚨 REMEMBER: Enable RLS again in production!');
    
  } catch (e) {
    print('❌ Error disabling RLS: $e');
  } finally {
    client.close();
  }
}

void main() async {
  await disableRLSForDev();
}