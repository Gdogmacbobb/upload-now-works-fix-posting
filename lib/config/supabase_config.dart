class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://oemeugiejcjfbpmsftot.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9lbWV1Z2llamNqZmJwbXNmdG90Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUwODMzMDksImV4cCI6MjA1MDY1OTMwOX0.Y5uo_rWEMsyXk7F-qCNh8qXs6RBjrxLaC0VZNBHZCJs',
  );
}
