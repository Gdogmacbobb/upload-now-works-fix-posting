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
    
    // Apply flash mode if it was on
    if (_isFlashOn) {
      try {
        await _controller!.setFlashMode(FlashMode.torch);
      } catch (e) {
        debugPrint('Failed to reapply flash: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Flash not available on this camera'),
              backgroundColor: Colors.orange.shade900,
            ),
          );
          setState(() => _isFlashOn = false);
        }
      }
    }
    
    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  Future<void> _toggleFlash() async {
    if (!_isInitialized || _controller == null) return;
    
    // Check if flash is supported
    if (_cameras != null && _cameras!.isNotEmpty) {
      final hasFlash = _cameras![_selectedCamera].lensDirection == CameraLensDirection.back;
      if (!hasFlash && !_isFlashOn) {
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
    }
    
    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
      }
      setState(() => _isFlashOn = !_isFlashOn);
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
    
    // Reapply flash if it was on
    if (_isFlashOn) {
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

          // Top controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Top row with all controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left side: Back and Mute
                      Row(
                        children: [
                          _iconButton(
                            icon: Icons.arrow_back,
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 12),
                          _iconButton(
                            icon: _isMuted ? Icons.mic_off : Icons.mic,
                            onPressed: _toggleMute,
                          ),
                        ],
                      ),
                      
                      // Right side: Flash and Switch Camera
                      Row(
                        children: [
                          _iconButton(
                            icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                            onPressed: _toggleFlash,
                          ),
                          const SizedBox(width: 12),
                          _iconButton(
                            icon: Icons.cameraswitch,
                            onPressed: _switchCamera,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
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
      },
      onScaleUpdate: (details) {
        // Calculate new zoom level
        final newZoom = (_baseZoom * details.scale).clamp(_minZoom, _maxZoom);
        
        if (newZoom != _currentZoom && _controller != null && mounted) {
          // Fire-and-forget to prevent blocking UI thread
          _controller!.setZoomLevel(newZoom).catchError((e) {
            debugPrint('Failed to set zoom: $e');
          });
          
          setState(() {
            _currentZoom = newZoom;
          });
        }
      },
      child: Center(
        child: Transform.scale(
          scale: scale,
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: CameraPreview(_controller!),
          ),
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
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
