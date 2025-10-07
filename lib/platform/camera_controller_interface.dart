// Interface for camera controller that works across all platforms
export 'camera_controller_mobile.dart'
    if (dart.library.html) 'camera_controller_web.dart';
