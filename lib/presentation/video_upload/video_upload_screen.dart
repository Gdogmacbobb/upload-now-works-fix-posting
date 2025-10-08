import 'dart:io' show File;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../theme/app_theme.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/profile_service.dart';
import '../../utils/web_dom_stub.dart' if (dart.library.html) 'dart:html' as html;

class VideoUploadScreen extends StatefulWidget {
  const VideoUploadScreen({Key? key}) : super(key: key);

  @override
  State<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  bool _isPlaying = false;
  String? _caption;
  String _performanceType = 'Music';
  String _location = 'Washington Square Park';
  String _privacy = 'Public';
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
      _initializeVideoPlayerFuture = _initializeVideoController(videoPath);
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

  Future<void> _initializeVideoController(String videoPath) async {
    try {
      debugPrint('[VIDEO_INIT] Starting initialization for: $videoPath');
      
      // Platform-specific video controller creation
      final VideoPlayerController controller;
      if (kIsWeb) {
        // Web: Use network-based controller (video path is a blob URL on web)
        controller = VideoPlayerController.networkUrl(Uri.parse(videoPath));
        debugPrint('[VIDEO_INIT] Created web network controller');
      } else {
        // Mobile: Use file-based controller
        controller = VideoPlayerController.file(File(videoPath));
        debugPrint('[VIDEO_INIT] Created mobile file controller');
      }
      
      // Assign controller before awaiting initialization
      _controller = controller;
      
      await _controller!.initialize();
      debugPrint('[VIDEO_INIT] Controller initialized successfully');
      debugPrint('[VIDEO_INIT] Video size: ${_controller!.value.size}');
      debugPrint('[VIDEO_INIT] Video aspect ratio: ${_controller!.value.aspectRatio}');
      debugPrint('[VIDEO_INIT] Video duration: ${_controller!.value.duration}');
      debugPrint('[VIDEO_INIT] Rotation correction: ${_controller!.value.rotationCorrection}');
      
      // Set volume and pause - user must tap Preview to start playback
      if (mounted) {
        _controller!.setVolume(1.0);
        _controller!.pause();
        debugPrint('[VIDEO_INIT] Volume set to 1.0, video paused (awaiting user tap)');
        
        // Force UI update to ensure texture is ready
        setState(() {});
      }
    } catch (e) {
      debugPrint('[VIDEO_INIT] Controller initialization failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load video: $e')),
        );
      }
      rethrow;
    }
  }

  Future<void> _generateThumbnails() async {
    if (_videoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No video loaded')),
      );
      return;
    }

    setState(() => _isGeneratingThumbnails = true);
    debugPrint('[THUMBNAIL] Starting thumbnail generation...');

    try {
      final duration = _controller?.value.duration;
      if (duration == null) {
        throw Exception('Video duration not available');
      }

      debugPrint('[THUMBNAIL] Video duration: $duration');
      
      // Platform-specific thumbnail generation
      if (kIsWeb) {
        // Web: Thumbnail generation not supported (no path_provider support)
        debugPrint('[THUMBNAIL] Web platform - thumbnail generation not available');
        if (mounted) {
          setState(() => _isGeneratingThumbnails = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thumbnail selection not available on web')),
          );
        }
      } else {
        // Mobile: Use video_thumbnail package
        await _generateMobileThumbnails(duration);
      }
    } catch (e) {
      debugPrint('[THUMBNAIL] Thumbnail generation failed: $e');
      if (mounted) {
        setState(() => _isGeneratingThumbnails = false);
        
        // Handle MissingPluginException specifically
        if (e.toString().contains('MissingPluginException')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thumbnail feature not available on this platform')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Thumbnail generation failed: $e')),
          );
        }
      }
    }
  }

  Future<void> _generateMobileThumbnails(Duration duration) async {
    final List<String> generatedThumbnails = [];
    final int thumbnailCount = 8;
    
    debugPrint('[THUMBNAIL] Generating $thumbnailCount thumbnails for mobile...');
    
    final tempDir = await getTemporaryDirectory();
    
    for (int i = 0; i < thumbnailCount; i++) {
      final timeMs = (duration.inMilliseconds / (thumbnailCount + 1) * (i + 1)).round();
      
      try {
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
          debugPrint('[THUMBNAIL] ✓ Generated thumbnail $i at $timeMs ms: $thumbnail');
        } else {
          debugPrint('[THUMBNAIL] ✗ Null result for thumbnail $i at $timeMs ms');
        }
      } catch (thumbnailError) {
        debugPrint('[THUMBNAIL] ✗ Error generating thumbnail $i: $thumbnailError');
      }
    }

    if (mounted) {
      setState(() {
        _thumbnails = generatedThumbnails;
        _isGeneratingThumbnails = false;
        if (_thumbnails.isNotEmpty) {
          _selectedThumbnailIndex = 0;
          debugPrint('[THUMBNAIL] Successfully generated ${_thumbnails.length} thumbnails');
        } else {
          debugPrint('[THUMBNAIL] No thumbnails generated');
        }
      });
    }
  }

  void _showFullScreenPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      debugPrint('[PREVIEW] Cannot show preview - controller not initialized');
      return;
    }

    debugPrint('[PREVIEW] Opening full-screen preview');
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
            // Video preview with FutureBuilder (tappable for full-screen)
            FutureBuilder<void>(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && 
                    snapshot.hasError) {
                  return Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Video failed to load',
                        style: TextStyle(color: Colors.red.shade400),
                      ),
                    ),
                  );
                } else if (snapshot.connectionState == ConnectionState.done &&
                           _controller != null &&
                           _controller!.value.isInitialized) {
                  return GestureDetector(
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
                  );
                } else {
                  // Loading state
                  return Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            // Select Thumbnail button (visible after video loads)
            if (_controller != null && _controller!.value.isInitialized)
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
  bool _frameDecoded = false;
  bool _soundActive = false;
  bool _paintConfirmed = false;
  
  // DOM visibility retry logic
  int _retryCount = 0;
  bool _domAttached = false;
  Timer? _retryTimer;
  String _textureKey = 'video_player_${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    
    // Add listener to track playback state
    widget.controller.addListener(_updatePlaybackState);
    
    // Wait for texture to be ready before starting playback
    WidgetsBinding.instance.addPostFrameCallback((_) => _waitForTextureAndStartPlayback());
  }

  Future<void> _waitForTextureAndStartPlayback() async {
    if (!mounted || !widget.controller.value.isInitialized) {
      debugPrint('[PREVIEW] Controller not initialized, aborting');
      return;
    }

    debugPrint('[PREVIEW] Starting DOM visibility check (Retry #$_retryCount)');
    
    // Force rebuild to add VideoPlayer widget to tree
    setState(() {});
    
    if (kIsWeb) {
      // Web: Check if HTML <video> element is in DOM before playing
      _startDomVisibilityCheck();
    } else {
      // Mobile: Use standard texture attachment delay
      await Future.delayed(const Duration(milliseconds: 250));
      if (mounted) _startPlayback();
    }
  }
  
  void _forceVideoVisibility() {
    if (!kIsWeb) return;
    
    debugPrint('[PREVIEW] 🎨 Attempting CSS visibility enforcement...');
    
    try {
      final videoElements = html.document.getElementsByTagName('video');
      debugPrint('[PREVIEW] Found ${videoElements.length} video elements to modify');
      
      for (var i = 0; i < videoElements.length; i++) {
        final video = videoElements[i];
        // Access style property directly without type casting
        final dynamic videoElement = video;
        videoElement.style.visibility = 'visible';
        videoElement.style.opacity = '1';
        videoElement.style.display = 'block';
        debugPrint('[PREVIEW] Set visibility on video #$i');
      }
      debugPrint('[PREVIEW] 🎨 Forced CSS visibility on ${videoElements.length} video element(s)');
    } catch (e, stackTrace) {
      debugPrint('[PREVIEW] CSS visibility enforcement failed: $e');
      debugPrint('[PREVIEW] Stack trace: $stackTrace');
    }
  }
  
  void _startDomVisibilityCheck() {
    _retryTimer?.cancel();
    
    _retryTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      _retryCount++;
      
      // Check if <video> element exists in DOM
      try {
        final videoElements = html.document.getElementsByTagName('video');
        
        if (videoElements.length > 0) {
          debugPrint('[PREVIEW] ✅ DOM Check: Found ${videoElements.length} <video> element(s) on retry #$_retryCount');
          setState(() => _domAttached = true);
          timer.cancel();
          
          // Force CSS visibility on all video elements
          _forceVideoVisibility();
          
          _startPlayback();
        } else {
          debugPrint('[PREVIEW] ⏳ DOM Check: No <video> elements yet (retry #$_retryCount)');
        }
      } catch (e) {
        debugPrint('[PREVIEW] DOM Check failed: $e');
      }
      
      // Timeout after 3 seconds (15 attempts at 200ms)
      if (_retryCount >= 15) {
        debugPrint('[PREVIEW] ⚠️ DOM Check timeout after $_retryCount attempts - forcing playback');
        timer.cancel();
        setState(() => _domAttached = false);
        
        // Last resort: dispose and reinit with fresh texture key
        setState(() {
          _textureKey = 'video_player_${DateTime.now().millisecondsSinceEpoch}';
        });
        
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) _startPlayback();
      }
    });
  }
  
  Future<void> _startPlayback() async {
    if (!mounted) return;
    
    debugPrint('[PREVIEW] Starting playback (DOM: ${_domAttached ? "✅" : "❌"}, Retry: #$_retryCount)');
    
    try {
      // Trigger first frame decode
      await widget.controller.play();
      await Future.delayed(const Duration(milliseconds: 32));
      await widget.controller.pause();
      await widget.controller.seekTo(Duration.zero);
      debugPrint('[PREVIEW] First frame decoded');
    } catch (e) {
      debugPrint('[PREVIEW] Frame decode failed: $e');
    }
    
    if (!mounted) return;
    
    // Start actual playback
    widget.controller.setVolume(1.0);
    await widget.controller.play();
    widget.controller.setLooping(true);
    
    setState(() {
      _isPlaying = true;
      _frameDecoded = true;
      _soundActive = widget.controller.value.volume > 0;
    });
    
    debugPrint('[PREVIEW] ✅ Playback active - isPlaying: ${widget.controller.value.isPlaying}');
    
    // Web: Force paint refresh after CSS visibility enforcement
    if (kIsWeb && _domAttached) {
      _forcePaintRefresh();
    }
  }
  
  Future<void> _forcePaintRefresh() async {
    if (!mounted) return;
    
    debugPrint('[PREVIEW] 🖌️ Forcing paint refresh...');
    
    // Wait for browser to apply CSS changes
    await Future.delayed(const Duration(milliseconds: 150));
    
    if (!mounted) return;
    
    // Trigger repaint via pause/play cycle in postFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      try {
        await widget.controller.pause();
        await Future.delayed(const Duration(milliseconds: 16));
        await widget.controller.play();
        
        // Check if video has actual dimensions (paint confirmed)
        _checkPaintDimensions();
        
        debugPrint('[PREVIEW] 🖌️ Paint refresh complete');
      } catch (e) {
        debugPrint('[PREVIEW] Paint refresh failed: $e');
      }
    });
  }
  
  void _checkPaintDimensions() {
    if (!kIsWeb || !mounted) return;
    
    try {
      final video = html.document.querySelector('video') as html.VideoElement?;
      if (video != null && video.videoWidth > 0 && video.videoHeight > 0) {
        setState(() => _paintConfirmed = true);
        debugPrint('[PREVIEW] ✅ PAINT confirmed - dimensions: ${video.videoWidth}x${video.videoHeight}');
      } else {
        debugPrint('[PREVIEW] ⚠️ Video element has zero dimensions');
      }
    } catch (e) {
      debugPrint('[PREVIEW] Paint dimension check failed: $e');
    }
  }

  void _updatePlaybackState() {
    if (mounted) {
      setState(() {
        _isPlaying = widget.controller.value.isPlaying;
        _soundActive = widget.controller.value.volume > 0 && widget.controller.value.isPlaying;
        if (widget.controller.value.isPlaying && widget.controller.value.position > Duration.zero) {
          _frameDecoded = true;
        }
      });
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    widget.controller.removeListener(_updatePlaybackState);
    widget.controller.pause();
    widget.controller.setLooping(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoSize = widget.controller.value.size;
    final rotationCorrection = widget.controller.value.rotationCorrection.toDouble();
    final int rotationDegrees = (rotationCorrection * 180 / 3.14159).round();
    
    // Check portrait: dimensions OR rotation metadata OR device orientation (for web landscape videos)
    final isPortraitByDimensions = videoSize.height > videoSize.width;
    final isPortraitByRotation = (rotationDegrees == 90 || rotationDegrees == 270 || rotationDegrees == -90 || rotationDegrees == -270);
    final deviceIsPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final videoIsLandscape = videoSize.width > videoSize.height;
    
    // Web records landscape even in portrait mode - detect and rotate
    final needsRotation = deviceIsPortrait && videoIsLandscape && rotationDegrees == 0;
    final isPortrait = isPortraitByDimensions || isPortraitByRotation || needsRotation;
    
    // Calculate final rotation angle (use 90° for web portrait videos)
    final double finalRotation = needsRotation ? (3.14159 / 2) : rotationCorrection;
    final int finalRotationDegrees = (finalRotation * 180 / 3.14159).round();
    
    final screenSize = MediaQuery.of(context).size;
    final isInitialized = widget.controller.value.isInitialized;
    
    // Texture debugging
    debugPrint('[PREVIEW] Video size: $videoSize, isPortrait: $isPortrait');
    debugPrint('[PREVIEW] Controller hashCode: ${widget.controller.hashCode} (for ValueKey)');
    debugPrint('[PREVIEW] Device orientation: ${deviceIsPortrait ? "portrait" : "landscape"}');
    debugPrint('[PREVIEW] Needs rotation: $needsRotation (device portrait + video landscape)');
    debugPrint('[PREVIEW] Final rotation: $finalRotationDegrees° (metadata: $rotationDegrees°)');
    debugPrint('[PREVIEW] Portrait by: dimensions=$isPortraitByDimensions, rotation=$isPortraitByRotation, device=$needsRotation');
    debugPrint('[PREVIEW] Screen size: ${screenSize.width}x${screenSize.height}');
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            // Black background layer (bottom-most)
            Positioned.fill(
              child: Container(color: Colors.black),
            ),
            
            // VIDEO LAYER with dynamic texture refresh
            Positioned.fill(
              child: widget.controller.value.isInitialized
                  ? RepaintBoundary(
                      key: ValueKey(_textureKey),
                      child: Container(
                        color: Colors.black,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: isPortrait 
                                ? (videoSize.height / videoSize.width) 
                                : widget.controller.value.aspectRatio,
                            child: isPortrait
                                ? Transform.rotate(
                                    angle: finalRotation,
                                    child: AspectRatio(
                                      aspectRatio: widget.controller.value.aspectRatio,
                                      child: VideoPlayer(widget.controller),
                                    ),
                                  )
                                : VideoPlayer(widget.controller),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.orange),
                      ),
                    ),
            ),

            // DEBUG OVERLAY - Visual verification
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '🐛 DEBUG',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Initialized: ${isInitialized ? '✅' : '❌'}',
                      style: TextStyle(
                        color: isInitialized ? Colors.green : Colors.red,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (kIsWeb) ...[
                      Text(
                        'Retry: #$_retryCount',
                        style: TextStyle(
                          color: _retryCount > 0 ? Colors.yellow : Colors.white,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        'DOM: ${_domAttached ? '✅' : '❌'}',
                        style: TextStyle(
                          color: _domAttached ? Colors.green : Colors.red,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                    Text(
                      'Video: ${videoSize.width.toInt()}x${videoSize.height.toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Screen: ${screenSize.width.toInt()}x${screenSize.height.toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Device: ${deviceIsPortrait ? 'portrait' : 'landscape'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Rotation: ${finalRotationDegrees}° ${needsRotation ? '(web fix)' : ''}',
                      style: TextStyle(
                        color: finalRotationDegrees != 0 ? Colors.yellow : Colors.white,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Portrait: ${isPortrait ? '✅' : '❌'} ${needsRotation ? '(device)' : isPortraitByRotation ? '(rot)' : '(dim)'}',
                      style: TextStyle(
                        color: isPortrait ? Colors.green : Colors.amber,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'BoxFit: ${isPortrait ? 'cover' : 'aspectRatio'}',
                      style: const TextStyle(
                        color: Colors.cyan,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Aspect: ${widget.controller.value.aspectRatio.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Volume: ${widget.controller.value.volume.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: widget.controller.value.volume > 0 ? Colors.green : Colors.red,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // PLAYBACK STATUS OVERLAY - Visual proof
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (_frameDecoded && _soundActive && (!kIsWeb || _paintConfirmed)) ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Frame: ${_frameDecoded ? '✅' : '❌'}',
                      style: TextStyle(
                        color: _frameDecoded ? Colors.green : Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Sound: ${_soundActive ? '✅' : '❌'}',
                      style: TextStyle(
                        color: _soundActive ? Colors.green : Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (kIsWeb)
                      Text(
                        'Paint: ${_paintConfirmed ? '✅' : '❌'}',
                        style: TextStyle(
                          color: _paintConfirmed ? Colors.green : Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    Text(
                      'Pos: ${widget.controller.value.position.inMilliseconds}ms',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Close button (top-right, moved from left)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
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
