import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Setup Supabase Storage bucket using service role key
Future<void> setupSupabaseStorage() async {
  try {
    // Initialize Supabase with service role key for admin operations
    final supabase = SupabaseClient(
      'https://mogjjvscxjwvhtpkrlqr.supabase.co',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NzkxOTU4MCwiZXhwIjoyMDczNDk1NTgwfQ.T2ntQv-z2EL4mkGb9b3QyXM3dT8pAOFSPKvqWPd7Xoo',
    );
    
    print('🚀 Setting up Supabase Storage with admin privileges...');
    
    // Check if profiles bucket exists
    try {
      final buckets = await supabase.storage.listBuckets();
      final profilesBucket = buckets.firstWhere(
        (bucket) => bucket.id == 'profiles',
        orElse: () => throw Exception('Bucket not found'),
      );
      print('✅ Profiles bucket already exists: ${profilesBucket.id}');
    } catch (e) {
      print('📦 Creating profiles bucket...');
      
      // Create profiles bucket
      await supabase.storage.createBucket(
        'profiles',
        BucketOptions(
          public: true,
          fileSizeLimit: '5242880', // 5MB
          allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp', 'image/jpg'],
        ),
      );
      print('✅ Profiles bucket created successfully');
    }
    
    // Test upload to verify bucket works
    print('🔍 Testing bucket upload...');
    final testData = Uint8List.fromList('test upload'.codeUnits);
    final testPath = 'test/test_${DateTime.now().millisecondsSinceEpoch}.txt';
    
    await supabase.storage
        .from('profiles')
        .uploadBinary(testPath, testData);
    
    print('✅ Test upload successful');
    
    // Get public URL to verify
    final publicUrl = supabase.storage
        .from('profiles')
        .getPublicUrl(testPath);
    
    print('✅ Public URL generated: $publicUrl');
    
    // Clean up test file
    await supabase.storage
        .from('profiles')
        .remove([testPath]);
    
    print('✅ Test file cleaned up');
    print('🎉 Supabase Storage setup completed successfully!');
    
    // Show bucket info
    final buckets = await supabase.storage.listBuckets();
    final profilesBucket = buckets.firstWhere((b) => b.id == 'profiles');
    print('📋 Bucket info:');
    print('   ID: ${profilesBucket.id}');
    print('   Name: ${profilesBucket.name}');
    print('   Public: ${profilesBucket.public}');
    print('   Created: ${profilesBucket.createdAt}');
    
  } catch (e) {
    print('❌ Error setting up Supabase Storage: $e');
    print('🔧 Troubleshooting:');
    print('1. Check service role key is correct');
    print('2. Verify Supabase URL is correct');
    print('3. Ensure service role has storage admin permissions');
  }
}

void main() async {
  await setupSupabaseStorage();
  exit(0);
}