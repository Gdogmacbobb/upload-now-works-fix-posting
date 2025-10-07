import 'package:video_player/video_player.dart';

VideoPlayerController createVideoController(String path) {
  // Web: use network URL for blob/data URLs from camera
  return VideoPlayerController.networkUrl(Uri.parse(path));
}
