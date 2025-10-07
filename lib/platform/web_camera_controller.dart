import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'platform_camera_controller.dart';

class WebCameraController {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;
  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _isRecording = false;
  
  final StreamController<CameraState> _stateController = StreamController<CameraState>.broadcast();
  
  CameraState _currentState = CameraState(
    isInitialized: false,
    cameraIndex: 0,
    cameraCount: 0,
    zoomLevel: 1.0,
    minZoom: 1.0,
    maxZoom: 1.0,
    torchEnabled: false,
    torchSupported: false,
    lensDirection: 'back',
    resolution: Size.zero,
    fps: 30,
  );
  
  int? get textureId => null;
  bool get isInitialized => _isInitialized;
  CameraState get value => _currentState;
  Stream<CameraState> get stateStream => _stateController.stream;
  CameraController? get cameraController => _cameraController;
  
  Future<void> initialize({
    int cameraIndex = 0,
    int targetFps = 60,
    String quality = 'max',
  }) async {
    if (_isDisposed) throw Exception('Controller is disposed');
    if (_isInitialized) return;
    
    try {
      debugPrint('═══════════════════════════════════════');
      debugPrint('[ENV_MODE] Dev bridge active - using Flutter camera plugin for Replit/web');
      debugPrint('[CAMERA_SOURCE] WebCameraPlugin active');
      debugPrint('Target FPS: $targetFps (web may limit to 30fps)');
      debugPrint('Quality: $quality');
      
      _cameras = await availableCameras();
      
      if (_cameras.isEmpty) {
        throw Exception('No cameras available');
      }
      
      _currentCameraIndex = cameraIndex.clamp(0, _cameras.length - 1);
      final camera = _cameras[_currentCameraIndex];
      
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: kIsWeb ? ImageFormatGroup.jpeg : ImageFormatGroup.yuv420,
      );
      
      await _cameraController!.initialize();
      
      final minZoom = await _cameraController!.getMinZoomLevel();
      final maxZoom = await _cameraController!.getMaxZoomLevel();
      
      _currentState = CameraState(
        isInitialized: true,
        cameraIndex: _currentCameraIndex,
        cameraCount: _cameras.length,
        zoomLevel: minZoom,
        minZoom: minZoom,
        maxZoom: maxZoom,
        torchEnabled: false,
        torchSupported: camera.lensDirection == CameraLensDirection.back && !kIsWeb,
        lensDirection: camera.lensDirection == CameraLensDirection.back ? 'back' : 'front',
        resolution: Size(
          _cameraController!.value.previewSize?.width ?? 1280,
          _cameraController!.value.previewSize?.height ?? 720,
        ),
        fps: 30,
      );
      
      _isInitialized = true;
      _stateController.add(_currentState);
      
      debugPrint('Camera initialized successfully');
      debugPrint('Camera Count: ${_cameras.length}');
      debugPrint('Lens Direction: ${_currentState.lensDirection}');
      debugPrint('Zoom Range: ${_currentState.minZoom.toStringAsFixed(2)}x - ${_currentState.maxZoom.toStringAsFixed(2)}x');
      debugPrint('Resolution: ${_currentState.resolution.width.toInt()}x${_currentState.resolution.height.toInt()}');
      debugPrint('Torch Support: ${_currentState.torchSupported} (disabled on web)');
      debugPrint('═══════════════════════════════════════');
      
    } catch (e) {
      debugPrint('Failed to initialize camera: $e');
      rethrow;
    }
  }
  
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _isInitialized = false;
    
    await _cameraController?.dispose();
    await _stateController.close();
    
    debugPrint('WebCameraController disposed');
  }
  
  Future<void> switchCamera() async {
    if (!_isInitialized || _isDisposed || _cameras.length < 2) return;
    
    try {
      debugPrint('[CAMERA_SWITCH] Switching camera...');
      
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
      final camera = _cameras[_currentCameraIndex];
      
      await _cameraController?.dispose();
      
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: kIsWeb ? ImageFormatGroup.jpeg : ImageFormatGroup.yuv420,
      );
      
      await _cameraController!.initialize();
      
      final minZoom = await _cameraController!.getMinZoomLevel();
      final maxZoom = await _cameraController!.getMaxZoomLevel();
      
      _currentState = CameraState(
        isInitialized: true,
        cameraIndex: _currentCameraIndex,
        cameraCount: _cameras.length,
        zoomLevel: minZoom,
        minZoom: minZoom,
        maxZoom: maxZoom,
        torchEnabled: false,
        torchSupported: camera.lensDirection == CameraLensDirection.back && !kIsWeb,
        lensDirection: camera.lensDirection == CameraLensDirection.back ? 'back' : 'front',
        resolution: Size(
          _cameraController!.value.previewSize?.width ?? 1280,
          _cameraController!.value.previewSize?.height ?? 720,
        ),
        fps: 30,
      );
      
      _stateController.add(_currentState);
      
      debugPrint('[CAMERA_SWITCH] Switched to: ${_currentState.lensDirection}');
      
    } catch (e) {
      debugPrint('Failed to switch camera: $e');
      rethrow;
    }
  }
  
  Future<void> setTorch(bool enabled) async {
    if (!_isInitialized || _isDisposed) return;
    if (!_currentState.torchSupported || kIsWeb) {
      debugPrint('Torch not supported on web/this camera');
      return;
    }
    
    try {
      await _cameraController?.setFlashMode(enabled ? FlashMode.torch : FlashMode.off);
      _currentState = _currentState.copyWith(torchEnabled: enabled);
      _stateController.add(_currentState);
      
      debugPrint('Torch ${enabled ? "enabled" : "disabled"}');
    } catch (e) {
      debugPrint('Failed to set torch: $e');
    }
  }
  
  Future<void> setZoom(double level) async {
    if (!_isInitialized || _isDisposed) return;
    
    final clampedZoom = level.clamp(_currentState.minZoom, _currentState.maxZoom);
    
    try {
      await _cameraController?.setZoomLevel(clampedZoom);
      _currentState = _currentState.copyWith(zoomLevel: clampedZoom);
      _stateController.add(_currentState);
    } catch (e) {
      debugPrint('Failed to set zoom: $e');
    }
  }
  
  Future<void> tapToFocus(double x, double y) async {
    if (!_isInitialized || _isDisposed) return;
    
    try {
      await _cameraController?.setFocusPoint(Offset(x, y));
      debugPrint('Focus set to ($x, $y)');
    } catch (e) {
      debugPrint('Failed to set focus: $e');
    }
  }
  
  Future<void> lockExposure(bool lock) async {
    if (!_isInitialized || _isDisposed) return;
    
    try {
      if (lock) {
        await _cameraController?.setExposureMode(ExposureMode.locked);
      } else {
        await _cameraController?.setExposureMode(ExposureMode.auto);
      }
      debugPrint('Exposure ${lock ? "locked" : "unlocked"}');
    } catch (e) {
      debugPrint('Failed to lock exposure: $e');
    }
  }
  
  Future<void> startRecording() async {
    if (!_isInitialized || _isDisposed || _isRecording) return;
    
    try {
      await _cameraController?.startVideoRecording();
      _isRecording = true;
      debugPrint('Recording started (web mode)');
    } catch (e) {
      debugPrint('Failed to start recording: $e');
      rethrow;
    }
  }
  
  Future<String> stopRecording() async {
    if (!_isInitialized || _isDisposed || !_isRecording) {
      throw Exception('Not recording');
    }
    
    try {
      final file = await _cameraController?.stopVideoRecording();
      _isRecording = false;
      
      if (file == null) throw Exception('No file returned');
      
      debugPrint('Recording stopped (web mode). File: ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('Failed to stop recording: $e');
      rethrow;
    }
  }
}
