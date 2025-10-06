import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/role_service.dart';
import '../../widgets/role_gate_widget.dart';

class VideoRecording extends StatefulWidget {
  const VideoRecording({Key? key}) : super(key: key);

  @override
  State<VideoRecording> createState() => _VideoRecordingState();
}

class _VideoRecordingState extends State<VideoRecording> {
  @override
  Widget build(BuildContext context) {
    // Whole-page defense-in-depth: prevent direct route access
    return RoleGate.performerOnly(
      fallback: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          title: const Text('Access Restricted'),
          backgroundColor: AppTheme.backgroundDark,
          foregroundColor: AppTheme.textPrimary,
        ),
        body: UpgradePromptWidget(
          title: 'Become a Street Performer',
          description: 'Video recording is exclusive to Street Performers. Upgrade your account to unlock this feature!',
          onUpgrade: () {
            Navigator.pop(context);
            // Navigate to account upgrade or contact support
          },
        ),
      ),
      child: RoleGate.requiresFeature(
        feature: PerformerFeature.recordVideo,
        fallback: Scaffold(
          backgroundColor: AppTheme.backgroundDark,
          appBar: AppBar(
            title: const Text('Feature Coming Soon'),
            backgroundColor: AppTheme.backgroundDark,
            foregroundColor: AppTheme.textPrimary,
          ),
          body: const Center(
            child: Text(
              'Camera recording feature will be available soon!',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          title: const Text('Video Recording'),
          backgroundColor: AppTheme.backgroundDark,
          foregroundColor: AppTheme.textPrimary,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam,
                size: 64,
                color: AppTheme.primaryOrange,
              ),
              SizedBox(height: 16),
              Text(
                'Video Recording Coming Soon',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Camera functionality will be available in a future update.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
  }
}