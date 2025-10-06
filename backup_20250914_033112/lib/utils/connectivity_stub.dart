import 'dart:async';

/// Stub implementation for unsupported platforms
Future<bool> checkInternetConnection() async {
  throw UnsupportedError('Internet connectivity check not supported on this platform');
}