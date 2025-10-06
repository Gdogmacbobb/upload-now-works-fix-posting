import 'dart:io';
import 'dart:async';

/// Internet connectivity check for mobile/desktop platforms
Future<bool> checkInternetConnection() async {
  try {
    // Try to look up a reliable host
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (e) {
    return false;
  }
}