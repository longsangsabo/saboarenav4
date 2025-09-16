import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Setup Supabase Storage bucket for profile images
Future<void> setupStorageBucket() async {
  try {
    final supabase = Supabase.instance.client;
    
    print('🚀 Setting up Supabase Storage bucket...');
    
    // Check if profiles bucket exists
    final buckets = await supabase.storage.listBuckets();
    final profilesBucketExists = buckets.any((bucket) => bucket.id == 'profiles');
    
    if (!profilesBucketExists) {
      print('❌ Profiles bucket does not exist');
      print('ℹ️ Please create the bucket manually in Supabase Dashboard:');
      print('1. Go to Supabase Dashboard > Storage');
      print('2. Create new bucket named "profiles"');
      print('3. Set it as public bucket');
      print('4. Run the SQL commands in supabase_storage_setup.sql');
      return;
    }
    
    print('✅ Profiles bucket exists');
    
    // Test upload a small file to verify permissions
    final testBytes = Uint8List.fromList('test'.codeUnits);
    final testPath = 'test_${DateTime.now().millisecondsSinceEpoch}.txt';
    
    await supabase.storage
        .from('profiles')
        .uploadBinary(testPath, testBytes);
    
    print('✅ Upload test successful');
    
    // Clean up test file
    await supabase.storage
        .from('profiles')
        .remove([testPath]);
    
    print('✅ Storage setup complete');
    
  } catch (e) {
    print('❌ Storage setup error: $e');
    print('ℹ️ Make sure to:');
    print('1. Create "profiles" bucket in Supabase Dashboard');
    print('2. Set bucket as public');
    print('3. Run the SQL policies from supabase_storage_setup.sql');
  }
}

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  
  await setupStorageBucket();
}