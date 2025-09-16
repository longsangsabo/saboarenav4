// Environment Configuration
// Handles different environments (dev, staging, prod)

class EnvironmentConfig {
  static const String environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
  
  // Supabase Configuration per environment
  static String get supabaseUrl {
    switch (environment) {
      case 'production':
        return const String.fromEnvironment('SUPABASE_URL', 
               defaultValue: 'https://your-production-project.supabase.co');
      case 'staging':
        return const String.fromEnvironment('SUPABASE_URL_STAGING', 
               defaultValue: 'https://your-staging-project.supabase.co');
      default:
        return const String.fromEnvironment('SUPABASE_URL_DEV', 
               defaultValue: 'https://demo-project.supabase.co');
    }
  }
  
  static String get supabaseAnonKey {
    switch (environment) {
      case 'production':
        return const String.fromEnvironment('SUPABASE_ANON_KEY', 
               defaultValue: 'your-production-anon-key');
      case 'staging':
        return const String.fromEnvironment('SUPABASE_ANON_KEY_STAGING', 
               defaultValue: 'your-staging-anon-key');
      default:
        return const String.fromEnvironment('SUPABASE_ANON_KEY_DEV', 
               defaultValue: 'demo-anon-key-for-development');
    }
  }
  
  // Service Role Key for development (NEVER use in production)
  static String get supabaseServiceKey {
    if (environment == 'development') {
      return const String.fromEnvironment('SUPABASE_SERVICE_KEY', 
             defaultValue: 'demo-service-key-for-dev-only');
    }
    throw Exception('Service key should never be used in production!');
  }
  
  // Feature flags per environment
  static bool get enableAnalytics => environment == 'production';
  static bool get enableDebugLogs => environment == 'development';
  static bool get enableMockData => environment == 'development';
  static bool get enableHotReload => environment == 'development';
  
  // API Configuration
  static String get apiBaseUrl {
    switch (environment) {
      case 'production':
        return 'https://api.sabo-arena.com';
      case 'staging':
        return 'https://api-staging.sabo-arena.com';
      default:
        return 'https://api-dev.sabo-arena.com';
    }
  }
  
  // App Configuration
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';
}