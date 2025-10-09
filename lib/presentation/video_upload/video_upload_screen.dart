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
import 'dart:js' if (dart.library.html) 'dart:js' as js;
import '../../utils/ui_web_stub.dart' if (dart.library.html) 'dart:ui_web' as ui_web;

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
      // Silently fail for profile loading
    }
  }

  Future<void> _initializeVideoController(String videoPath) async {
    try {
      // Platform-specific video controller creation
      final VideoPlayerController controller;
      if (kIsWeb) {
        controller = VideoPlayerController.networkUrl(Uri.parse(videoPath));
      } else {
        controller = VideoPlayerController.file(File(videoPath));
      }
      
      _controller = controller;
      
      await _controller!.initialize();
      
      if (mounted) {
        _controller!.setVolume(1.0);
        _controller!.pause();
        setState(() {});
      }
    } catch (e) {
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

    try {
      final duration = _controller?.value.duration;
      if (duration == null) {
        throw Exception('Video duration not available');
      }
      
      if (kIsWeb) {
        if (mounted) {
          setState(() => _isGeneratingThumbnails = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thumbnail selection not available on web')),
          );
        }
      } else {
        await _generateMobileThumbnails(duration);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGeneratingThumbnails = false);
        
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
        }
      } catch (thumbnailError) {
        // Silently skip failed thumbnails
      }
    }

    if (mounted) {
      setState(() {
        _thumbnails = generatedThumbnails;
        _isGeneratingThumbnails = false;
        if (_thumbnails.isNotEmpty) {
          _selectedThumbnailIndex = 0;
        }
      });
    }
  }

  void _showFullScreenPreview() {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

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
  
  bool _isReplitSandbox = false;
  String _platformViewId = 'video-preview-${DateTime.now().millisecondsSinceEpoch}';
  bool _useFallbackView = false;
  
  String _textureKey = 'video_player_${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    
    if (kIsWeb) {
      try {
        final hostname = js.context['location']['hostname'].toString();
        _isReplitSandbox = hostname.contains('replit');
        if (_isReplitSandbox) {
          _registerPlatformView(widget.controller);
        }
      } catch (e) {
        // Silently fail hostname detection
      }
    }
    
    widget.controller.addListener(_updatePlaybackState);
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _waitForTextureAndStartPlayback());
  }
  
  void _registerPlatformView(VideoPlayerController controller) {
    if (!kIsWeb) return;
    
    try {
      ui_web.platformViewRegistry.registerViewFactory(
        _platformViewId,
        (int viewId) {
          final videoElement = html.VideoElement()
            ..src = controller.dataSource
            ..setAttribute('playsinline', 'true')
            ..setAttribute('autoplay', 'true')
            ..setAttribute('loop', 'true')
            ..setAttribute('muted', 'false')
            ..controls = false;
          
          videoElement.onLoadedMetadata.listen((_) {
            final vWidth = videoElement.videoWidth;
            final vHeight = videoElement.videoHeight;
            final isLandscapeVideo = vWidth > vHeight;
            
            if (isLandscapeVideo) {
              videoElement.style.position = 'fixed';
              videoElement.style.top = '50%';
              videoElement.style.left = '50%';
              videoElement.style.transform = 'translate(-50%, -50%) rotate(90deg)';
              videoElement.style.width = '100vh';
              videoElement.style.height = '100vw';
              videoElement.style.objectFit = 'cover';
              videoElement.style.pointerEvents = 'none';
            } else {
              videoElement.style.position = 'fixed';
              videoElement.style.top = '50%';
              videoElement.style.left = '50%';
              videoElement.style.transform = 'translate(-50%, -50%)';
              videoElement.style.width = '100vw';
              videoElement.style.height = '100vh';
              videoElement.style.objectFit = 'cover';
              videoElement.style.pointerEvents = 'none';
            }
          });
          
          videoElement.play();
          
          return videoElement;
        },
      );
      
      setState(() {
        _useFallbackView = true;
      });
      
      _scheduleRotationCheck();
    } catch (e) {
      // Silently fail platform view registration
    }
  }

  Future<void> _waitForTextureAndStartPlayback() async {
    if (!mounted || !widget.controller.value.isInitialized) {
      return;
    }

    setState(() {});
    
    if (kIsWeb) {
      _startDomVisibilityCheck();
    } else {
      await Future.delayed(const Duration(milliseconds: 250));
      if (mounted) _startPlayback();
    }
  }
  
  void _applyDomRotation() {
    if (!kIsWeb) return;
    
    try {
      final videoElements = html.document.querySelectorAll('video');
      
      for (var i = 0; i < videoElements.length; i++) {
        final dynamic videoElement = videoElements[i];
        
        if (videoElement.videoWidth == 0 || videoElement.videoHeight == 0) {
          continue;
        }
        
        final videoWidth = videoElement.videoWidth as num;
        final videoHeight = videoElement.videoHeight as num;
        final isLandscape = videoWidth > videoHeight;
        
        videoElement.style.removeProperty('position');
        videoElement.style.removeProperty('top');
        videoElement.style.removeProperty('left');
        videoElement.style.removeProperty('width');
        videoElement.style.removeProperty('height');
        videoElement.style.removeProperty('transform');
        
        if (isLandscape) {
          videoElement.style.position = 'fixed';
          videoElement.style.top = '50%';
          videoElement.style.left = '50%';
          videoElement.style.transform = 'translate(-50%, -50%) rotate(90deg)';
          videoElement.style.width = '100vh';
          videoElement.style.height = '100vw';
          videoElement.style.objectFit = 'cover';
          videoElement.style.pointerEvents = 'none';
        } else {
          videoElement.style.position = 'fixed';
          videoElement.style.top = '50%';
          videoElement.style.left = '50%';
          videoElement.style.transform = 'translate(-50%, -50())';
          videoElement.style.width = '100vw';
          videoElement.style.height = '100vh';
          videoElement.style.objectFit = 'cover';
          videoElement.style.pointerEvents = 'none';
        }
      }
    } catch (e) {
      // Silently fail DOM rotation
    }
  }
  
  void _startDomVisibilityCheck() {
    Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      try {
        final videoElements = html.document.getElementsByTagName('video');
        
        if (videoElements.length > 0) {
          timer.cancel();
          
          await Future.delayed(const Duration(milliseconds: 100));
          _applyDomRotation();
          
          _startPlayback();
        }
      } catch (e) {
        // Silently fail DOM check
      }
    });
  }
  
  Future<void> _startPlayback() async {
    if (!mounted) return;
    
    try {
      await widget.controller.play();
      await Future.delayed(const Duration(milliseconds: 32));
      await widget.controller.pause();
      await widget.controller.seekTo(Duration.zero);
    } catch (e) {
      // Silently fail frame decode
    }
    
    if (!mounted) return;
    
    widget.controller.setVolume(1.0);
    await widget.controller.play();
    widget.controller.setLooping(true);
    
    setState(() {
      _isPlaying = true;
    });
    
    if (kIsWeb) {
      _scheduleRotationCheck();
    }
  }
  
  void _scheduleRotationCheck() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _applyDomRotation();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _applyDomRotation();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _applyDomRotation();
    });
  }

  void _updatePlaybackState() {
    if (mounted) {
      setState(() {
        _isPlaying = widget.controller.value.isPlaying;
      });
    }
  }

  @override
  void dispose() {
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
    
    final isPortraitByDimensions = videoSize.height > videoSize.width;
    final isPortraitByRotation = (rotationDegrees == 90 || rotationDegrees == 270 || rotationDegrees == -90 || rotationDegrees == -270);
    final deviceIsPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final videoIsLandscape = videoSize.width > videoSize.height;
    
    final needsRotation = deviceIsPortrait && videoIsLandscape && rotationDegrees == 0;
    final isPortrait = isPortraitByDimensions || isPortraitByRotation || needsRotation;
    
    final double finalRotation = needsRotation ? (3.14159 / 2) : rotationCorrection;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        color: Colors.black,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Black background layer (bottom-most)
            Positioned.fill(
              child: Container(color: Colors.black),
            ),
            
            // VIDEO LAYER with conditional rendering (HtmlElementView fallback in sandbox)
            Positioned.fill(
              child: widget.controller.value.isInitialized
                  ? (_useFallbackView
                      ? // 3️⃣ HtmlElementView Fallback (Replit sandbox)
                        Container(
                          color: Colors.black,
                          child: HtmlElementView(
                            viewType: _platformViewId,
                          ),
                        )
                      : // Normal GPU-accelerated rendering (production)
                        RepaintBoundary(
                          key: ValueKey(_textureKey),
                          child: Container(
                            clipBehavior: Clip.none,
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
                        ))
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.orange),
                      ),
                    ),
            ),

            // PRODUCTION_VIDEO_PLAYER & SANDBOX_HTML_ELEMENT_VIEW: Close button (top-right)
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap: () {
                  widget.controller.pause();
                  Navigator.pop(context);
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0x99000000),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

            // PRODUCTION_VIDEO_PLAYER & SANDBOX_HTML_ELEMENT_VIEW: TikTok-style overlay chrome (bottom)
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
