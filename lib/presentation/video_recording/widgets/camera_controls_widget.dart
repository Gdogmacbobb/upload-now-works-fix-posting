import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class CameraControlsWidget extends StatelessWidget {
  final VoidCallback? onCapturePressed;
  final VoidCallback? onFlipCamera;
  final VoidCallback? onFlashToggle;
  final bool isRecording;
  final bool isFlashOn;
  final String recordingTime;

  const CameraControlsWidget({
    super.key,
    this.onCapturePressed,
    this.onFlipCamera,
    this.onFlashToggle,
    required this.isRecording,
    required this.isFlashOn,
    required this.recordingTime,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Back button (top-left, where flash button was)
        Positioned(
          top: 64.0,
          left: 16.0,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 48.0,
              height: 48.0,
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

        // Timer display (above record button)
        Positioned(
          bottom: 192.0,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: isRecording ? AppTheme.accentRed : AppTheme.videoOverlay,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isRecording) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.textPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.0),
                  ],
                  Text(
                    recordingTime,
                    style: AppTheme.videoOverlayStyle(),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Flip camera (top-right)
        Positioned(
          top: 64.0,
          right: 16.0,
          child: GestureDetector(
            onTap: onFlipCamera,
            child: Container(
              width: 48.0,
              height: 48.0,
              decoration: BoxDecoration(
                color: AppTheme.videoOverlay,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'flip_camera_ios',
                  color: AppTheme.textPrimary,
                  size: 24,
                ),
              ),
            ),
          ),
        ),

        // Capture button (bottom-center)
        Positioned(
          bottom: 96.0,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: onCapturePressed,
              child: Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isRecording ? AppTheme.accentRed : AppTheme.primaryOrange,
                  border: Border.all(
                    color: AppTheme.textPrimary,
                    width: 4,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: isRecording ? 32.0 : 64.0,
                    height: isRecording ? 32.0 : 64.0,
                    decoration: BoxDecoration(
                      color: AppTheme.textPrimary,
                      borderRadius: BorderRadius.circular(isRecording ? 4 : 50),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
