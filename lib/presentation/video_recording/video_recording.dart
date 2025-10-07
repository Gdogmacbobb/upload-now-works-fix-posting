import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ynfny/utils/responsive_scale.dart';

import '../../core/app_export.dart';
import './widgets/camera_controls_widget.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/location_verification_widget.dart';
import './widgets/recording_settings_widget.dart';

class VideoRecording extends StatefulWidget {
  const VideoRecording({super.key});

  @override
  State<VideoRecording> createState() => _VideoRecordingState();
}

class _VideoRecordingState extends State<VideoRecording>
    with TickerProviderStateMixin {
  // Camera related
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _showGrid = false;
  String _selectedQuality = 'High (1080p)';
  final List<String> _qualityOptions = [
    'High (1080p)',
    'Medium (720p)',
    'Low (480p)'
  ];
  Offset? _focusPoint;
  Timer? _focusTimer;

  // Recording related
  bool _isRecording = false;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  String _recordingTime = '00:00';
  static const int _maxRecordingSeconds = 60;

  // Location related
  bool _isLocationVerified = false;
  String _currentLocation = '';
  String? _selectedBorough;
  final List<String> _boroughs = [
    'Manhattan',
    'Brooklyn',
    'Queens',
    'The Bronx',
    'Staten Island'
  ];

  // UI related
  bool _showSettings = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initializeApp();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _focusTimer?.cancel();
    _cameraController?.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      await _requestPermissions();
      await _initializeCamera();
      await _getCurrentLocation();
    } catch (e) {
      debugPrint('Error initializing app: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) return;

    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.location,
    ];

    for (final permission in permissions) {
      final status = await permission.request();
      if (!status.isGranted) {
        debugPrint('Permission ${permission.toString()} not granted');
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        await _cameraController!.setFlashMode(FlashMode.off);
      }
    } catch (e) {
      debugPrint('Error applying camera settings: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (kIsWeb) {
        // Web geolocation simulation for NYC area
        setState(() {
          _currentLocation = 'New York, NY (Browser Location)';
          _isLocationVerified = true;
        });
        return;
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Mock NYC verification for demo
      final isInNYC = _isPositionInNYC(position.latitude, position.longitude);

      setState(() {
        _currentLocation = 'Lat: ${position.latitude.toStringAsFixed(4)}, '
            'Lng: ${position.longitude.toStringAsFixed(4)}';
        _isLocationVerified = isInNYC;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() {
        _currentLocation = 'Location unavailable';
        _isLocationVerified = false;
      });
    }
  }

  bool _isPositionInNYC(double lat, double lng) {
    // Simplified NYC bounds check
    return lat >= 40.4774 &&
        lat <= 40.9176 &&
        lng >= -74.2591 &&
        lng <= -73.7004;
  }

  void _startRecording() async {
    if (!_isCameraInitialized || _isRecording || !_canStartRecording()) return;

    try {
      await _cameraController!.startVideoRecording();

      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
        _recordingTime = '00:00';
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingSeconds++;
          final minutes = _recordingSeconds ~/ 60;
          final seconds = _recordingSeconds % 60;
          _recordingTime = '${minutes.toString().padLeft(2, '0')}:'
              '${seconds.toString().padLeft(2, '0')}';
        });

        if (_recordingSeconds >= _maxRecordingSeconds) {
          _stopRecording();
        }
      });

      if (!kIsWeb) {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  void _stopRecording() async {
    if (!_isRecording) return;

    try {
      final videoFile = await _cameraController!.stopVideoRecording();
      _recordingTimer?.cancel();

      setState(() => _isRecording = false);

      if (!kIsWeb) {
        HapticFeedback.mediumImpact();
      }

      // Navigate to video upload with the recorded file
      Navigator.pushNamed(
        context,
        '/video-upload',
        arguments: {
          'videoPath': videoFile.path,
          'duration': _recordingSeconds,
          'location': _currentLocation,
          'borough': _selectedBorough,
        },
      );
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  bool _canStartRecording() {
    return _isLocationVerified || _selectedBorough != null;
  }

  void _toggleFlash() async {
    if (kIsWeb || _cameraController == null) return;

    try {
      final newFlashMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _cameraController!.setFlashMode(newFlashMode);
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  void _flipCamera() async {
    if (_cameraController == null || _cameras.length < 2) return;

    try {
      final currentLensDirection = _cameraController!.description.lensDirection;
      final newCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection != currentLensDirection,
        orElse: () => _cameras.first,
      );

      await _cameraController!.dispose();

      _cameraController = CameraController(
        newCamera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error flipping camera: $e');
    }
  }

  void _handleTapToFocus(TapUpDetails details) async {
    if (_cameraController == null || !_isCameraInitialized) return;

    try {
      final offset = details.localPosition;
      setState(() => _focusPoint = offset);

      await _cameraController!.setFocusPoint(offset);
      await _cameraController!.setExposurePoint(offset);

      _focusTimer?.cancel();
      _focusTimer = Timer(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _focusPoint = null);
        }
      });
    } catch (e) {
      debugPrint('Error setting focus: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.primaryOrange,
              ),
              SizedBox(height: 2.h),
              Text(
                'Preparing Camera...',
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // Camera preview
          GestureDetector(
            onTapUp: _handleTapToFocus,
            child: CameraPreviewWidget(
              cameraController: _cameraController,
              showGrid: _showGrid,
              focusPoint: _focusPoint,
            ),
          ),

          // Location verification overlay
          if (!_isLocationVerified)
            Positioned(
              top: 15.h,
              left: 0,
              right: 0,
              child: LocationVerificationWidget(
                isVerified: _isLocationVerified,
                currentLocation: _currentLocation,
                selectedBorough: _selectedBorough,
                boroughs: _boroughs,
                onBoroughSelected: (borough) {
                  setState(() => _selectedBorough = borough);
                },
                onRetryLocation: _getCurrentLocation,
              ),
            ),

          // Camera controls
          CameraControlsWidget(
            onCapturePressed: _isRecording ? _stopRecording : _startRecording,
            onFlipCamera: _flipCamera,
            onFlashToggle: _toggleFlash,
            isRecording: _isRecording,
            isFlashOn: _isFlashOn,
            recordingTime: _recordingTime,
          ),

          // Settings button - moved to right side at same height as record button
          Positioned(
            bottom: 12.h,
            right: 4.w,
            child: GestureDetector(
              onTap: () => setState(() => _showSettings = !_showSettings),
              child: Container(
                width: 12.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppTheme.videoOverlay,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'settings',
                    color: AppTheme.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          // Flash button - positioned in the middle-left (where back button was)
          Positioned(
            top: 8.h,
            left: 20.w,
            child: GestureDetector(
              onTap: _toggleFlash,
              child: Container(
                width: 12.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppTheme.videoOverlay,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: _isFlashOn ? 'flash_on' : 'flash_off',
                    color: _isFlashOn
                        ? AppTheme.primaryOrange
                        : AppTheme.textPrimary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          // Back button - moved to top-left corner
          Positioned(
            top: 8.h,
            left: 4.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 12.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppTheme.videoOverlay,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: AppTheme.textPrimary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          // Recording disabled overlay
          if (!_canStartRecording())
            Positioned(
              bottom: 8.h,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.all(3.w),
                decoration: AppTheme.glassmorphismDecoration(
                  backgroundColor: AppTheme.accentRed.withOpacity(0.2),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'warning',
                      color: AppTheme.accentRed,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'NYC location verification required to start recording',
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Settings panel
          if (_showSettings)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: RecordingSettingsWidget(
                showGrid: _showGrid,
                onToggleGrid: () => setState(() => _showGrid = !_showGrid),
                selectedQuality: _selectedQuality,
                qualityOptions: _qualityOptions,
                onQualityChanged: (quality) =>
                    setState(() => _selectedQuality = quality),
                onClose: () => setState(() => _showSettings = false),
              ),
            ),
        ],
      ),
    );
  }
}
