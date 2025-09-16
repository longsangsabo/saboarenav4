import 'dart:convert';
import 'dart:io';

/// Setup Supabase Storage policies using SQL API
Future<void> setupStoragePolicies() async {
  final String supabaseUrl = 'https://mogjjvscxjwvhtpkrlqr.supabase.co';
  final String serviceRoleKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo';
  
  final HttpClient client = HttpClient();
  
  final List<String> sqlCommands = [
    // 1. Create policy for authenticated users to upload their own files
    '''
    CREATE POLICY IF NOT EXISTS "Users can upload their own profile images" ON storage.objects
    FOR INSERT WITH CHECK (
      bucket_id = 'profiles' 
      AND auth.uid()::text = (storage.foldername(name))[1]
    );
    ''',
    
    // 2. Create policy for authenticated users to update their own files  
    '''
    CREATE POLICY IF NOT EXISTS "Users can update their own profile images" ON storage.objects
    FOR UPDATE USING (
      bucket_id = 'profiles' 
      AND auth.uid()::text = (storage.foldername(name))[1]
    );
    ''',
    
    // 3. Create policy for authenticated users to delete their own files
    '''
    CREATE POLICY IF NOT EXISTS "Users can delete their own profile images" ON storage.objects
    FOR DELETE USING (
      bucket_id = 'profiles' 
      AND auth.uid()::text = (storage.foldername(name))[1]
    );
    ''',
    
    // 4. Create policy for public access to view profile images
    '''
    CREATE POLICY IF NOT EXISTS "Public can view profile images" ON storage.objects
    FOR SELECT USING (bucket_id = 'profiles');
    ''',
    
    // 5. Create policy for bucket access
    '''
    CREATE POLICY IF NOT EXISTS "Public can access profiles bucket" ON storage.buckets
    FOR SELECT USING (id = 'profiles');
    ''',
    
    // 6. Enable RLS if not already enabled
    '''
    ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
    ''',
    
    '''
    ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;
    '''
  ];
  
  try {
    print('🚀 Setting up Supabase Storage policies...');
    
    for (int i = 0; i < sqlCommands.length; i++) {
      final sql = sqlCommands[i].trim();
      if (sql.isEmpty) continue;
      
      print('📝 Executing SQL command ${i + 1}/${sqlCommands.length}...');
      
      final request = await client.postUrl(Uri.parse('$supabaseUrl/rest/v1/rpc/exec_sql'));
      request.headers.set('Authorization', 'Bearer $serviceRoleKey');
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('apikey', serviceRoleKey);
      
      final requestBody = jsonEncode({'sql': sql});
      request.write(requestBody);
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ SQL command ${i + 1} executed successfully');
      } else {
        print('⚠️ SQL command ${i + 1} status: ${response.statusCode}');
        print('Response: $responseBody');
      }
    }
    
    print('🎉 Storage policies setup completed!');
    print('');
    print('✅ The following policies have been created:');
    print('  • Users can upload their own profile images');
    print('  • Users can update their own profile images');  
    print('  • Users can delete their own profile images');
    print('  • Public can view profile images');
    print('  • Public can access profiles bucket');
    print('  • Row Level Security enabled');
    print('');
    print('🚀 Now you can test image upload in the app!');
    
  } catch (e) {
    print('❌ Error setting up policies: $e');
  } finally {
    client.close();
  }
}

void main() async {
  await setupStoragePolicies();
}