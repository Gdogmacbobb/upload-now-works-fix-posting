export 'video_controller_stub.dart'
  if (dart.library.io) 'video_controller_mobile.dart'
  if (dart.library.html) 'video_controller_web.dart';
