import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../platform/camera_controller_interface.dart';
import '../../theme/app_theme.dart';

class VideoRecordingScreen extends StatefulWidget {
  const VideoRecordingScreen({Key? key}) : super(key: key);

  @override
  State<VideoRecordingScreen> createState() => _VideoRecordingScreenState();
}

class _VideoRecordingScreenState extends State<VideoRecordingScreen> {
  PlatformCameraController? _controller;
  bool _isRecording = false;
  bool _isMuted = false;
  bool _isInitialized = false;
  
  StreamSubscription<CameraState>? _stateSubscription;
  
  // Timer for recording
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  
  // Zoom variables
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 5.0;
  bool _isFlashOn = false;
  bool _hasFlashSupport = false;
  String _lensDirection = 'back';
  
  // Zoom throttling with repeating timer (16ms for 60fps response)
  Timer? _zoomUpdateTimer;
  double? _pendingZoom;

  @override
  void initState() {
    super.initState();
    debugPrint('🎬 [UI_RENDER] VideoRecordingScreen initState - starting orientation lock and camera init');
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
      _controller = PlatformCameraController();
      
      // Listen to state stream for updates
      _stateSubscription = _controller!.stateStream.listen((state) {
        if (mounted) {
          debugPrint('🔄 [CAMERA_STATE] State update: lens=${state.lensDirection}, flash=${state.torchSupported}, zoom=${state.zoomLevel.toStringAsFixed(2)}x');
          setState(() {
            _currentZoom = state.zoomLevel;
            _minZoom = state.minZoom;
            _maxZoom = state.maxZoom;
            _baseZoom = state.zoomLevel;
            _isFlashOn = state.torchEnabled;
            _hasFlashSupport = state.torchSupported;
            _lensDirection = state.lensDirection;
          });
          debugPrint('✅ [FLASH_STATE] Flash support: $_hasFlashSupport, Flash on: $_isFlashOn');
        }
      });
      
      await _controller!.initialize(
        cameraIndex: 0,
        targetFps: 60,
        quality: 'max',
      );
      
      // Get initial state
      final state = _controller!.value;
      if (!mounted) return;
      
      setState(() {
        _isInitialized = true;
        _currentZoom = state.zoomLevel;
        _minZoom = state.minZoom;
        _maxZoom = state.maxZoom;
        _baseZoom = state.zoomLevel;
        _isFlashOn = state.torchEnabled;
        _hasFlashSupport = state.torchSupported;
        _lensDirection = state.lensDirection;
      });
      
      debugPrint('✅ [UI_RENDER] Camera initialized - overlay should be attached');
      debugPrint('📊 [FLASH_STATE] Initial flash support: $_hasFlashSupport on ${_lensDirection} camera');
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
        await _controller!.startRecording();
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
        final filePath = await _controller!.stopRecording();
        setState(() {
          _isRecording = false;
          _recordingSeconds = 0;
        });
        if (!mounted) return;
        Navigator.pushNamed(context, '/video-upload', arguments: filePath);
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
    if (!_isInitialized || _controller == null) return;
    if (_isRecording) return; // Don't switch while recording
    
    try {
      final startTime = DateTime.now();
      debugPrint('🔄 [CAMERA_SWITCH] Starting camera switch from $_lensDirection...');
      
      await _controller!.switchCamera();
      
      final latency = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('✅ [CAMERA_SWITCH] Switch completed in ${latency}ms');
      
      // State will be updated via stateStream listener
    } catch (e) {
      debugPrint('❌ [CAMERA_SWITCH] Failed to switch camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to switch camera: $e'),
            backgroundColor: Colors.red.shade900,
          ),
        );
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (!_isInitialized || _controller == null) return;
    
    debugPrint('💡 [FLASH_TOGGLE] Attempting flash toggle...');
    debugPrint('   Current state: support=$_hasFlashSupport, on=$_isFlashOn, lens=$_lensDirection');
    
    // Check if flash is supported
    if (!_hasFlashSupport) {
      debugPrint('⚠️ [FLASH_TOGGLE] Flash not supported - showing error');
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
      final newFlashState = !_isFlashOn;
      debugPrint('🔦 [FLASH_TOGGLE] Calling setTorch($newFlashState)...');
      
      await _controller!.setTorch(newFlashState);
      
      debugPrint('✅ [FLASH_TOGGLE] Torch command sent successfully');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newFlashState ? 'Flash enabled' : 'Flash disabled'),
            backgroundColor: Colors.green.shade900,
            duration: const Duration(seconds: 1),
          ),
        );
      }
      // State will be updated via stateStream listener
    } catch (e) {
      debugPrint('❌ [FLASH_TOGGLE] Flash toggle failed: $e');
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
    
    // Toggle mute state
    setState(() {
      _isMuted = !_isMuted;
    });
    
    debugPrint('Mute toggled: ${_isMuted ? "ON" : "OFF"}');
  }

  void _startZoomUpdateTimer() {
    // Only start if not already running
    if (_zoomUpdateTimer != null && _zoomUpdateTimer!.isActive) return;
    
    // Repeating timer fires every 16ms for 60fps zoom response
    _zoomUpdateTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_pendingZoom != null && mounted && _controller != null) {
        final zoomToApply = _pendingZoom!;
        _pendingZoom = null; // Clear immediately to avoid re-applying
        
        // Use Future.microtask to offload from UI thread
        Future.microtask(() async {
          try {
            await _controller!.setZoom(zoomToApply);
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
          await _controller!.setZoom(finalZoom);
          debugPrint('Final zoom applied: $finalZoom');
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
    debugPrint('🎨 [UI_RENDER] Building UI - initialized=$_isInitialized, flash=$_hasFlashSupport');
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen camera preview
          if (_isInitialized && _controller != null && _controller!.textureId != null)
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
                
                // Mute button - always visible, disabled when not ready
                Positioned(
                  top: 12,
                  left: 72,
                  child: _overlayIconButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    onPressed: _toggleMute,
                    isDisabled: !_isInitialized,
                  ),
                ),
                
                // Flash button - always visible
                Positioned(
                  top: 12,
                  right: 12,
                  child: _overlayIconButton(
                    icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    onPressed: _toggleFlash,
                    isDisabled: !_isInitialized || !_hasFlashSupport,
                  ),
                ),
                
                // Camera switch button - always visible, disabled when not ready
                Positioned(
                  top: 12,
                  right: 72,
                  child: _overlayIconButton(
                    icon: Icons.cameraswitch,
                    onPressed: _switchCamera,
                    isDisabled: !_isInitialized,
                  ),
                ),
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
    
    // Use Texture widget for preview
    return GestureDetector(
      onScaleStart: (details) {
        _baseZoom = _currentZoom;
        debugPrint('🔍 [ZOOM_EVENTS] Zoom gesture started at ${_currentZoom.toStringAsFixed(2)}x');
        // Start repeating timer for smooth zoom updates
        _startZoomUpdateTimer();
      },
      onScaleUpdate: (details) {
        // Calculate new zoom level
        final newZoom = (_baseZoom * details.scale).clamp(_minZoom, _maxZoom);
        
        if (newZoom != _currentZoom && _controller != null && mounted) {
          final updateStart = DateTime.now();
          setState(() {
            _currentZoom = newZoom;
          });
          
          // Queue zoom for next timer tick (every 16ms for 60fps response)
          _pendingZoom = newZoom;
          
          final latency = DateTime.now().difference(updateStart).inMilliseconds;
          if (latency > 5) {
            debugPrint('⏱️ [ZOOM_EVENTS] UI update latency: ${latency}ms for ${newZoom.toStringAsFixed(2)}x');
          }
        }
      },
      onScaleEnd: (details) {
        debugPrint('✅ [ZOOM_EVENTS] Zoom gesture ended at ${_currentZoom.toStringAsFixed(2)}x');
        // Stop repeating timer when gesture ends
        _stopZoomUpdateTimer();
      },
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Texture(textureId: _controller!.textureId!),
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
    _stateSubscription?.cancel();
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
