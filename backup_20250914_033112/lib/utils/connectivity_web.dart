import 'dart:async';

/// Internet connectivity check for web platform
Future<bool> checkInternetConnection() async {
  try {
    // For web platform, we'll assume connectivity if we can run this check
    // A more robust check would require a CORS-enabled endpoint
    // For now, we'll be more lenient and assume connectivity exists
    // unless there's a clear network error during Supabase initialization
    return true;
  } catch (e) {
    return false;
  }
}