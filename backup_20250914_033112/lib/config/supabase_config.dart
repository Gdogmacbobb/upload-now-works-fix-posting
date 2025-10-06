/// HARDENED SUPABASE CONFIGURATION
/// 
/// This file contains environment-safe constants that NEVER reset during rebuild.
/// These values are injected into Supabase client initialization only once.
/// 
/// IMPORTANT: This file is locked from edits to prevent URL overwrites.

class SupabaseConfig {
  // Production Supabase credentials - DO NOT MODIFY
  static const String supabaseUrl = "https://oemeugiejcjfbpmsftot.supabase.co";
  static const String supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9lbWV1Z2llamNqZmJwbXNmdG90Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc2MDg2MTAsImV4cCI6MjA3MzE4NDYxMH0.dw8T-7WVm05O9wftaTDnh1j9mUs6aSJxS_fFIHxnDR4";
  
  // Configuration validation
  static bool get isValid {
    bool valid = supabaseUrl.isNotEmpty && 
           supabaseAnonKey.isNotEmpty &&
           supabaseUrl.startsWith('https://') &&
           supabaseUrl.contains('.supabase.co');
    // STABILITY TEST: Added debug validation during hardening
    if (!valid) {
      print('STABILITY TEST: Config validation failed during hardening check');
    }
    return valid;
  }
  
  // Safe error messages (no URL exposure)
  static const String connectionErrorMessage = "Unable to connect to server. Please check your connection.";
  static const String configErrorMessage = "Configuration error. Please contact support.";
}