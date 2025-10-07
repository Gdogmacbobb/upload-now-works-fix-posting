import 'package:flutter/material.dart';
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
  List<CameraDescription>? _cameras;
  int _selectedCamera = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('No cameras available');
        return;
      }
      _controller = CameraController(_cameras![_selectedCamera], ResolutionPreset.high);
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera not available: $e')),
        );
      }
    }
  }

  Future<void> _toggleRecord() async {
    if (!_isInitialized || _controller == null) return;
    
    if (!_isRecording) {
      await _controller!.startVideoRecording();
      setState(() => _isRecording = true);
    } else {
      final file = await _controller!.stopVideoRecording();
      setState(() => _isRecording = false);
      if (!mounted) return;
      Navigator.pushNamed(context, '/video-upload', arguments: file.path);
    }
  }

  void _switchCamera() async {
    if (_cameras == null || _cameras!.isEmpty) return;
    
    _selectedCamera = (_selectedCamera + 1) % _cameras!.length;
    await _controller?.dispose();
    _controller = CameraController(_cameras![_selectedCamera], ResolutionPreset.high);
    await _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          if (_isInitialized)
            CameraPreview(_controller!)
          else
            const Center(child: CircularProgressIndicator(color: Colors.orange)),

          // Top controls
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _iconBtn(Icons.arrow_back, () => Navigator.pop(context)),
                Row(
                  children: [
                    _iconBtn(_isMuted ? Icons.mic_off : Icons.mic, () {
                      setState(() => _isMuted = !_isMuted);
                    }),
                    const SizedBox(width: 12),
                    _iconBtn(Icons.cameraswitch, _switchCamera),
                  ],
                )
              ],
            ),
          ),

          // Record button
          Positioned(
            bottom: 80,
            child: Column(
              children: [
                if (_isRecording)
                  Text(
                    "00:00",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      backgroundColor: Colors.black54,
                    ),
                  ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _isInitialized ? _toggleRecord : null,
                  child: Opacity(
                    opacity: _isInitialized ? 1.0 : 0.5,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryOrange, width: 4),
                        color: _isRecording ? Colors.red : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Settings button
          Positioned(
            bottom: 80,
            right: 24,
            child: _iconBtn(Icons.settings, () {}),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
