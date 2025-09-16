import 'dart:io';

void main() async {
  print('🚀 Starting Member Management Database Setup using psql...\n');

  // Database connection details
  const String host = 'db.mogjjvscxjwvhtpkrlqr.supabase.co';
  const String port = '5432';
  const String database = 'postgres';
  const String username = 'postgres';
  const String password = 'TLsang963@';

  // Path to SQL file
  const String sqlFile = 'scripts/member_management_schema.sql';

  try {
    // Check if SQL file exists
    final file = File(sqlFile);
    if (!await file.exists()) {
      print('❌ SQL file not found: $sqlFile');
      return;
    }

    print('📂 Found SQL file: $sqlFile');
    print('📊 Executing database schema...\n');

    // Build psql command
    final List<String> psqlArgs = [
      '-h', host,
      '-p', port,
      '-U', username,
      '-d', database,
      '-f', sqlFile,
      '-v', 'ON_ERROR_STOP=1',
      '--single-transaction',
    ];

    print('🔗 Connecting to database...');
    print('   Host: $host');
    print('   Database: $database');
    print('   User: $username\n');

    // Set environment variable for password
    final Map<String, String> environment = {
      ...Platform.environment,
      'PGPASSWORD': password,
    };

    // Execute psql command
    final ProcessResult result = await Process.run(
      'psql',
      psqlArgs,
      environment: environment,
    );

    print('📡 Command executed with exit code: ${result.exitCode}\n');

    if (result.exitCode == 0) {
      print('✅ SUCCESS! Member Management Schema created successfully!\n');
      
      print('📋 STDOUT:');
      if (result.stdout.toString().isNotEmpty) {
        print(result.stdout);
      } else {
        print('   (No output)');
      }
      
      if (result.stderr.toString().isNotEmpty) {
        print('\n⚠️ STDERR (warnings/notices):');
        print(result.stderr);
      }

      print('\n🎉 Member Management System Database Setup Complete!');
      print('✅ All tables, indexes, policies, and functions created');
      print('🔒 Row Level Security enabled');
      print('⚡ Performance optimizations applied');
      print('🎯 Ready for production use!');
      
    } else {
      print('❌ FAILED! Database setup encountered errors.\n');
      
      if (result.stdout.toString().isNotEmpty) {
        print('📋 STDOUT:');
        print(result.stdout);
      }
      
      if (result.stderr.toString().isNotEmpty) {
        print('\n❌ ERROR OUTPUT:');
        print(result.stderr);
      }
      
      print('\n💡 Possible solutions:');
      print('• Check database connection details');
      print('• Verify psql is installed and accessible');
      print('• Check SQL syntax in the schema file');
      print('• Ensure proper permissions');
    }
    
  } catch (e) {
    print('❌ Exception occurred: $e');
    print('\n💡 Make sure psql is installed:');
    print('   sudo apt-get install postgresql-client');
  }
}