import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import '../../theme/app_theme.dart';

class VideoRecordingScreen extends StatefulWidget {
  const VideoRecordingScreen({Key? key}) : super(key: key);

  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen> {
  CameraController? _controller;
  bool _isRecording = false;
  bool _isMuted = false;
  bool _isInitialized = false;
  bool _isFlashOn = false;
  List<CameraDescription>? _cameras;
  int _selectedCamera = 0;
  
  // Timer for recording
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  
  // Zoom variables
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 5.0;
  
  // Zoom throttling with repeating timer (16ms for 60fps response)
  Timer? _zoomUpdateTimer;
  double? _pendingZoom;

  @override
  void initState() {
    super.initState();
    _lockOrientation();
    _initializeCamera();
  }

  Future<void> _lockOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('Camera initialization error: No cameras available');
        return;
      }
      debugPrint('Camera initialization: Found ${_cameras!.length} camera(s)');
      
      _controller = CameraController(
        _cameras![_selectedCamera],
        ResolutionPreset.high,
        enableAudio: !_isMuted,
      );
      await _controller!.initialize();
      debugPrint('Camera initialization: Controller initialized successfully');
      
      // Get actual zoom limits from camera, but reset to 1.0
      try {
        _minZoom = await _controller!.getMinZoomLevel();
        _maxZoom = await _controller!.getMaxZoomLevel();
        _currentZoom = 1.0;
        await _controller!.setZoomLevel(1.0);
      } catch (e) {
        debugPrint('Failed to get zoom limits: $e');
        // Fallback to safe defaults
        _minZoom = 1.0;
        _maxZoom = 1.0;
        _currentZoom = 1.0;
      }
      
      if (!mounted) return;
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera not available: $e'),
            backgroundColor: Colors.red.shade900,
          ),
        );
      }
    }
  }

  Future<void> _toggleRecord() async {
    if (!_isInitialized || _controller == null) return;
    
    if (!_isRecording) {
      try {
        await _controller!.startVideoRecording();
        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
        });
        
        // Start timer
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() => _recordingSeconds++);
          }
        });
      } catch (e) {
        debugPrint('Failed to start recording: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to start recording: $e'),
              backgroundColor: Colors.red.shade900,
            ),
          );
        }
      }
    } else {
      try {
        _recordingTimer?.cancel();
        final file = await _controller!.stopVideoRecording();
        setState(() {
          _isRecording = false;
          _recordingSeconds = 0;
        });
        if (!mounted) return;
        Navigator.pushNamed(context, '/video-upload', arguments: file.path);
      } catch (e) {
        debugPrint('Failed to stop recording: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to stop recording: $e'),
              backgroundColor: Colors.red.shade900,
            ),
          );
        }
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.isEmpty || !_isInitialized) return;
    if (_isRecording) return; // Don't switch while recording
    
    setState(() => _isInitialized = false);
    
    _selectedCamera = (_selectedCamera + 1) % _cameras!.length;
    await _controller?.dispose();
    
    _controller = CameraController(
      _cameras![_selectedCamera],
      ResolutionPreset.high,
      enableAudio: !_isMuted,
    );
    
    await _controller!.initialize();
    
    // Get zoom limits for new camera and reset zoom to 1.0
    try {
      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
      _currentZoom = 1.0;
      _baseZoom = 1.0;
      await _controller!.setZoomLevel(1.0);
    } catch (e) {
      debugPrint('Failed to get zoom limits after camera switch: $e');
      _minZoom = 1.0;
      _maxZoom = 1.0;
      _currentZoom = 1.0;
      _baseZoom = 1.0;
    }
    
    // Apply flash mode if it was on and supported on new camera
    if (_isFlashOn && _hasFlashSupport) {
      try {
        await _controller!.setFlashMode(FlashMode.torch);
      } catch (e) {
        debugPrint('Failed to reapply flash: $e');
        if (mounted) {
          setState(() => _isFlashOn = false);
        }
      }
    } else if (_isFlashOn && !_hasFlashSupport) {
      // Flash was on but new camera doesn't support it
      setState(() => _isFlashOn = false);
    }
    
    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  bool get _hasFlashSupport {
    // Check if camera has flash based on lens direction
    // Back cameras typically have flash, front cameras don't
    if (_cameras == null || _cameras!.isEmpty || _controller == null) {
      return false;
    }
    return _cameras![_selectedCamera].lensDirection == CameraLensDirection.back;
  }

  Future<void> _toggleFlash() async {
    if (!_isInitialized || _controller == null) return;
    
    // Check if flash is supported
    if (!_hasFlashSupport) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Flash not supported on this camera'),
            backgroundColor: Colors.orange.shade900,
          ),
        );
      }
      return;
    }
    
    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
        if (mounted) {
          setState(() => _isFlashOn = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Flash disabled'),
              backgroundColor: Colors.green.shade900,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
        if (mounted) {
          setState(() => _isFlashOn = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Flash enabled'),
              backgroundColor: Colors.green.shade900,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
      debugPrint('Flash toggled: $_isFlashOn');
    } catch (e) {
      debugPrint('Flash toggle failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Flash not available on this camera'),
            backgroundColor: Colors.orange.shade900,
          ),
        );
      }
    }
  }

  Future<void> _toggleMute() async {
    if (!_isInitialized || _controller == null) return;
    if (_isRecording) return; // Don't toggle while recording
    
    setState(() => _isInitialized = false);
    
    // Toggle mute state
    _isMuted = !_isMuted;
    
    // Rebuild controller with new audio setting
    await _controller?.dispose();
    
    _controller = CameraController(
      _cameras![_selectedCamera],
      ResolutionPreset.high,
      enableAudio: !_isMuted,
    );
    
    await _controller!.initialize();
    
    // Refresh zoom limits for new controller, reset to 1.0
    try {
      _minZoom = await _controller!.getMinZoomLevel();
      _maxZoom = await _controller!.getMaxZoomLevel();
      _currentZoom = 1.0;
      _baseZoom = 1.0;
      await _controller!.setZoomLevel(1.0);
    } catch (e) {
      debugPrint('Failed to get zoom limits after mute toggle: $e');
      _minZoom = 1.0;
      _maxZoom = 1.0;
      _currentZoom = 1.0;
      _baseZoom = 1.0;
    }
    
    // Reapply flash if it was on and supported
    if (_isFlashOn && _hasFlashSupport) {
      try {
        await _controller!.setFlashMode(FlashMode.torch);
      } catch (e) {
        debugPrint('Failed to reapply flash after mute toggle: $e');
        setState(() => _isFlashOn = false);
      }
    }
    
    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  void _startZoomUpdateTimer() {
    // Only start if not already running
    if (_zoomUpdateTimer != null && _zoomUpdateTimer!.isActive) return;
    
    // Repeating timer fires every 16ms for 60fps zoom response
    _zoomUpdateTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_pendingZoom != null && mounted) {
        final zoomToApply = _pendingZoom!;
        _pendingZoom = null; // Clear immediately to avoid re-applying
        
        // Use Future.microtask to offload from UI thread
        Future.microtask(() async {
          try {
            // Safety check: only apply zoom if not currently streaming
            if (_controller != null && 
                _controller!.value.isInitialized &&
                !_controller!.value.isStreamingImages) {
              await _controller!.setZoomLevel(zoomToApply);
              debugPrint('Zoom applied: $zoomToApply');
            }
          } catch (e) {
            debugPrint('Failed to set zoom: $e');
          }
        });
      }
    });
  }
  
  void _stopZoomUpdateTimer() {
    // Flush any pending zoom before stopping
    if (_pendingZoom != null && mounted && _controller != null) {
      final finalZoom = _pendingZoom!;
      _pendingZoom = null;
      
      // Apply final zoom immediately
      Future.microtask(() async {
        try {
          if (_controller != null && 
              _controller!.value.isInitialized &&
              !_controller!.value.isStreamingImages) {
            await _controller!.setZoomLevel(finalZoom);
            debugPrint('Final zoom applied: $finalZoom');
          }
        } catch (e) {
          debugPrint('Failed to set final zoom: $e');
        }
      });
    }
    
    _zoomUpdateTimer?.cancel();
    _zoomUpdateTimer = null;
    _pendingZoom = null;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen camera preview
          if (_isInitialized && _controller != null)
            _buildCameraPreview()
          else
            const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryOrange,
              ),
            ),

          // Top controls overlay (Stack with Positioned for guaranteed visibility)
          SafeArea(
            child: Stack(
              children: [
                // Back button - always visible for navigation
                Positioned(
                  top: 12,
                  left: 12,
                  child: _overlayIconButton(
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                
                // Camera controls - only when initialized
                if (_isInitialized && _controller != null) ...[
                  // Mute button
                  Positioned(
                    top: 12,
                    left: 72,
                    child: _overlayIconButton(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      onPressed: _toggleMute,
                    ),
                  ),
                  
                  // Flash button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _overlayIconButton(
                      icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                      onPressed: _toggleFlash,
                      isDisabled: !_hasFlashSupport,
                    ),
                  ),
                  
                  // Camera switch button
                  Positioned(
                    top: 12,
                    right: 72,
                    child: _overlayIconButton(
                      icon: Icons.cameraswitch,
                      onPressed: _switchCamera,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Recording timer
                if (_isRecording)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(_recordingSeconds),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 24),
                
                // Record button
                GestureDetector(
                  onTap: _isInitialized ? _toggleRecord : null,
                  child: Opacity(
                    opacity: _isInitialized ? 1.0 : 0.5,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryOrange,
                          width: 5,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: _isRecording ? 32 : 64,
                          height: _isRecording ? 32 : 64,
                          decoration: BoxDecoration(
                            color: _isRecording ? Colors.red : Colors.white,
                            borderRadius: _isRecording
                                ? BorderRadius.circular(8)
                                : BorderRadius.circular(32),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    // Get screen size
    final size = MediaQuery.of(context).size;
    
    // Calculate scale to fill screen while maintaining aspect ratio
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    
    if (scale < 1) scale = 1 / scale;

    return GestureDetector(
      onScaleStart: (details) {
        _baseZoom = _currentZoom;
        // Start repeating timer for smooth zoom updates
        _startZoomUpdateTimer();
      },
      onScaleUpdate: (details) {
        // Calculate new zoom level
        final newZoom = (_baseZoom * details.scale).clamp(_minZoom, _maxZoom);
        
        if (newZoom != _currentZoom && _controller != null && mounted) {
          setState(() {
            _currentZoom = newZoom;
          });
          
          // Queue zoom for next timer tick (every 16ms for 60fps response)
          _pendingZoom = newZoom;
        }
      },
      onScaleEnd: (details) {
        // Stop repeating timer when gesture ends
        _stopZoomUpdateTimer();
      },
      child: Center(
        child: Transform.scale(
          scale: scale,
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: RepaintBoundary(
              child: CameraPreview(_controller!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _overlayIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Opacity(
          opacity: isDisabled ? 0.4 : 1.0,
          child: Icon(
            icon,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _zoomUpdateTimer?.cancel();
    _controller?.dispose();
    // Reset orientation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }
}
