import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../theme/app_theme.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/profile_service.dart';

class VideoUploadScreen extends StatefulWidget {
  const VideoUploadScreen({Key? key}) : super(key: key);

  @override
  State<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  String? _caption;
  String _performanceType = 'Music';
  String _location = 'Washington Square Park';
  String _privacy = 'Public';
  bool _isInitialized = false;
  String? _videoPath;
  String _userHandle = '@user';
  
  // Thumbnail selection
  List<String> _thumbnails = [];
  int _selectedThumbnailIndex = -1;
  bool _isGeneratingThumbnails = false;
  
  final ProfileService _profileService = ProfileService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final videoPath = ModalRoute.of(context)!.settings.arguments as String?;
    if (videoPath != null && _videoPath == null) {
      _videoPath = videoPath;
      _initializeVideoController(videoPath);
      _loadUserProfile();
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        debugPrint('No authenticated user found');
        return;
      }

      final profile = await _profileService.getUserProfile(user.id);
      if (profile != null && profile['username'] != null) {
        if (mounted) {
          setState(() {
            _userHandle = '@${profile['username']}';
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to load user profile: $e');
    }
  }

  void _initializeVideoController(String videoPath) {
    try {
      // Platform-specific video controller initialization
      if (kIsWeb) {
        // Web: Use network-based controller (video path is a blob URL on web)
        _controller = VideoPlayerController.networkUrl(Uri.parse(videoPath));
      } else {
        // Mobile: Use file-based controller
        _controller = VideoPlayerController.file(File(videoPath));
      }
      
      _controller!.initialize().then((_) {
        if (mounted) {
          setState(() => _isInitialized = true);
        }
      }).catchError((error) {
        debugPrint('Video player initialization failed: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load video')),
          );
        }
      });
    } catch (e) {
      debugPrint('Video controller creation failed: $e');
    }
  }

  Future<void> _generateThumbnails() async {
    if (_videoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video loaded')),
      );
      return;
    }

    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thumbnail generation not available on web')),
      );
      return;
    }

    setState(() => _isGeneratingThumbnails = true);

    try {
      final duration = _controller?.value.duration;
      if (duration == null) {
        throw Exception('Video duration not available');
      }

      final tempDir = await getTemporaryDirectory();
      final List<String> generatedThumbnails = [];
      final int thumbnailCount = 8;
      
      for (int i = 0; i < thumbnailCount; i++) {
        final timeMs = (duration.inMilliseconds / (thumbnailCount + 1) * (i + 1)).round();
        
        final thumbnail = await VideoThumbnail.thumbnailFile(
          video: _videoPath!,
          thumbnailPath: tempDir.path,
          imageFormat: ImageFormat.PNG,
          maxWidth: 200,
          timeMs: timeMs,
          quality: 75,
        );
        
        if (thumbnail != null) {
          generatedThumbnails.add(thumbnail);
          debugPrint('Generated thumbnail $i at $timeMs ms: $thumbnail');
        } else {
          debugPrint('Failed to generate thumbnail $i at $timeMs ms');
        }
      }

      setState(() {
        _thumbnails = generatedThumbnails;
        _isGeneratingThumbnails = false;
        if (_thumbnails.isNotEmpty) {
          _selectedThumbnailIndex = 0;
          debugPrint('Generated ${_thumbnails.length} thumbnails, selected index 0');
        } else {
          debugPrint('No thumbnails were generated');
        }
      });
    } catch (e) {
      debugPrint('Thumbnail generation failed: $e');
      setState(() => _isGeneratingThumbnails = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate thumbnails: $e')),
        );
      }
    }
  }

  void _showFullScreenPreview() {
    if (_controller == null || !_isInitialized) return;

    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) => _FullScreenVideoPreview(
        controller: _controller!,
        caption: _caption ?? '',
        performanceType: _performanceType,
        location: _location,
        userHandle: _userHandle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Post", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video preview (tappable for full-screen)
            if (_isInitialized && _controller != null)
              GestureDetector(
                onTap: _showFullScreenPreview,
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: Stack(
                    children: [
                      // Show selected thumbnail or video frame
                      if (_selectedThumbnailIndex >= 0 && 
                          _selectedThumbnailIndex < _thumbnails.length &&
                          !kIsWeb)
                        Image.file(
                          File(_thumbnails[_selectedThumbnailIndex]),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      else
                        VideoPlayer(_controller!),
                      
                      // Play icon overlay
                      Center(
                        child: Icon(
                          Icons.play_circle,
                          color: Colors.white.withOpacity(0.8),
                          size: 64,
                        ),
                      ),
                      
                      // Refresh icon
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Icon(Icons.refresh, color: Colors.white),
                      ),
                      
                      // Duration badge
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _formatDuration(_controller!.value.duration),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Video preview unavailable',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Select Thumbnail button (visible on all platforms, shows feedback on web)
            if (_isInitialized)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryOrange,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isGeneratingThumbnails
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.image, color: Colors.white),
                label: Text(
                  _isGeneratingThumbnails ? 'Generating...' : 'Select Thumbnail',
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: _isGeneratingThumbnails ? null : _generateThumbnails,
              ),

            // Thumbnail selection list (mobile only)
            if (_thumbnails.isNotEmpty && !kIsWeb) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _thumbnails.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedThumbnailIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedThumbnailIndex = index);
                      },
                      child: Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryOrange : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            File(_thumbnails[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Caption
            Text("Caption", style: _labelStyle()),
            const SizedBox(height: 8),
            TextField(
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Share your performance story... #StreetArt #NYC",
                hintStyle: const TextStyle(color: Colors.white54),
                fillColor: AppTheme.inputBackground,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => _caption = value),
            ),

            const SizedBox(height: 24),
            Text("Performance Type", style: _labelStyle()),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: ["Music", "Dance", "Visual Arts", "Comedy"].map((type) {
                final selected = _performanceType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: selected,
                  selectedColor: AppTheme.primaryOrange,
                  onSelected: (_) => setState(() => _performanceType = type),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            Text("Location", style: _labelStyle()),
            const SizedBox(height: 8),
            _locationCard(),

            const SizedBox(height: 24),
            Text("Privacy Settings", style: _labelStyle()),
            const SizedBox(height: 8),
            _privacyOptions(),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.upload, color: Colors.white),
              label: const Text("Drop Content", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Uploading video...")),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  TextStyle _labelStyle() => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  Widget _locationCard() => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.inputBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.greenAccent),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Manhattan, NYC",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(_location, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ),
      );

  Widget _privacyOptions() => Column(
        children: [
          _privacyCard("Public", "Anyone can see your performance", true),
          const SizedBox(height: 8),
          _privacyCard("Followers Only", "Only your followers can see this video", false),
        ],
      );

  Widget _privacyCard(String title, String desc, bool selected) => GestureDetector(
        onTap: () => setState(() => _privacy = title),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _privacy == title ? AppTheme.primaryOrange : Colors.grey.shade700,
              width: 2,
            ),
            color: _privacy == title ? AppTheme.primaryOrange.withOpacity(0.1) : Colors.black26,
          ),
          child: Row(
            children: [
              Icon(
                _privacy == title ? Icons.check_circle : Icons.radio_button_unchecked,
                color: _privacy == title ? AppTheme.primaryOrange : Colors.white54,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

// Full-screen video preview modal
class _FullScreenVideoPreview extends StatefulWidget {
  final VideoPlayerController controller;
  final String caption;
  final String performanceType;
  final String location;
  final String userHandle;

  const _FullScreenVideoPreview({
    required this.controller,
    required this.caption,
    required this.performanceType,
    required this.location,
    required this.userHandle,
  });

  @override
  State<_FullScreenVideoPreview> createState() => _FullScreenVideoPreviewState();
}

class _FullScreenVideoPreviewState extends State<_FullScreenVideoPreview> {
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Auto-play when modal opens
    widget.controller.play();
    _isPlaying = true;
    widget.controller.setLooping(true);
  }

  @override
  void dispose() {
    // Pause when modal closes
    widget.controller.pause();
    widget.controller.setLooping(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoAspectRatio = widget.controller.value.aspectRatio;
    final isPortrait = videoAspectRatio < 1.0;
    
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            // Full-screen video with portrait orientation support
            Center(
              child: isPortrait
                  ? SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: widget.controller.value.size.width,
                          height: widget.controller.value.size.height,
                          child: VideoPlayer(widget.controller),
                        ),
                      ),
                    )
                  : AspectRatio(
                      aspectRatio: videoAspectRatio,
                      child: VideoPlayer(widget.controller),
                    ),
            ),

            // Close button (top-left)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            // Bottom overlay (like discovery feed)
            Positioned(
              bottom: 40,
              left: 16,
              right: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile image and handle
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryOrange,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.userHandle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Performance type
                  Text(
                    '🎵 ${widget.performanceType}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(0, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Caption
                  if (widget.caption.isNotEmpty)
                    Text(
                      widget.caption,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            offset: Offset(0, 1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.location,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          shadows: [
                            Shadow(
                              color: Colors.black,
                              offset: Offset(0, 1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
