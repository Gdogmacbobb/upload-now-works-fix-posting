import 'dart:async';

// Platform-specific imports
import 'connectivity_stub.dart'
    if (dart.library.io) 'connectivity_io.dart'
    if (dart.library.html) 'connectivity_web.dart';

/// Platform-agnostic connectivity checker
class ConnectivityChecker {
  static Future<bool> hasInternetConnection() async {
    try {
      return await checkInternetConnection();
    } catch (e) {
      return false;
    }
  }
}