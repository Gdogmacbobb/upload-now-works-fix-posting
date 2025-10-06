import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
<<<<<<< HEAD
import 'package:ynfny/utils/responsive_scale.dart';
=======
import 'package:sizer/sizer.dart';
>>>>>>> b1f9c438f65d3f7093efb1d909f7b1e8e83c8cb5

import '../../core/app_export.dart';
import './widgets/caption_input_widget.dart';
import './widgets/location_display_widget.dart';
import './widgets/performance_type_selector_widget.dart';
import './widgets/privacy_settings_widget.dart';
import './widgets/share_button_widget.dart';
import './widgets/upload_progress_widget.dart';
import './widgets/video_thumbnail_widget.dart';

class VideoUpload extends StatefulWidget {
  const VideoUpload({super.key});

  @override
  State<VideoUpload> createState() => _VideoUploadState();
}

class _VideoUploadState extends State<VideoUpload> {
  final TextEditingController _captionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mock data for video upload - with safety checks
  final List<Map<String, dynamic>> mockVideoData = [
    {
      "videoPath": "/storage/videos/street_performance_001.mp4",
      "duration": "0:45",
      "thumbnail":
          "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "fileSize": "24.5 MB",
      "resolution": "1080x1920"
    }
  ];

  final List<Map<String, dynamic>> mockLocationSpots = [
    {"name": "Washington Square Park", "borough": "Manhattan"},
    {"name": "Brooklyn Bridge Park", "borough": "Brooklyn"},
    {"name": "Central Park - Bethesda Fountain", "borough": "Manhattan"},
    {"name": "Times Square", "borough": "Manhattan"},
    {"name": "Coney Island Boardwalk", "borough": "Brooklyn"},
    {"name": "High Line Park", "borough": "Manhattan"},
    {"name": "Union Square", "borough": "Manhattan"},
    {"name": "Prospect Park", "borough": "Brooklyn"}
  ];

  String _selectedPerformanceType = 'Music';
  String _currentLocation = 'Manhattan, NYC';
  String? _specificSpot;
  bool _isPublic = true;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadStatus = 'Preparing video...';
  String? _estimatedTime;

  // Add timer tracking for proper cleanup
  Timer? _uploadTimer;

  @override
  void initState() {
    super.initState();
    _initializeSpot();
  }

  void _initializeSpot() {
    try {
      if (mockLocationSpots.isNotEmpty) {
        _specificSpot = mockLocationSpots.first['name'] as String?;
      }
    } catch (e) {
      debugPrint('Error initializing spot: $e');
      _specificSpot = 'Manhattan, NYC';
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _scrollController.dispose();
    _uploadTimer?.cancel();
    super.dispose();
  }

  void _handleRetakeVideo() {
    try {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/video-recording');
      }
    } catch (e) {
      debugPrint('Error navigating to video recording: $e');
      _showErrorToast('Unable to retake video. Please try again.');
    }
  }

  void _handleCaptionChanged(String value) {
    if (mounted) {
      setState(() {});
    }
  }

  void _handlePerformanceTypeSelected(String type) {
    if (mounted) {
      setState(() {
        _selectedPerformanceType = type;
      });
    }
  }

  void _handleLocationTap() {
    try {
      _showLocationBottomSheet();
    } catch (e) {
      debugPrint('Error showing location sheet: $e');
      _showErrorToast('Unable to show location options.');
    }
  }

  void _handlePrivacyChanged(bool isPublic) {
    if (mounted) {
      setState(() {
        _isPublic = isPublic;
      });
    }
  }

  void _handleShareVideo() {
    try {
      if (_captionController.text.trim().isEmpty) {
        _showErrorToast("Please add a caption to your video");
        return;
      }

      if (!mounted) return;

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
        _uploadStatus = 'Compressing video...';
        _estimatedTime = '2 minutes';
      });

      _simulateUploadProgress();
    } catch (e) {
      debugPrint('Error starting upload: $e');
      _showErrorToast('Unable to start upload. Please try again.');
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  void _simulateUploadProgress() {
    _uploadTimer?.cancel();
    _uploadTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted || !_isUploading) return;

      try {
        setState(() {
          _uploadProgress += 0.1;

          if (_uploadProgress <= 0.3) {
            _uploadStatus = 'Compressing video...';
            _estimatedTime = '2 minutes';
          } else if (_uploadProgress <= 0.7) {
            _uploadStatus = 'Uploading to server...';
            _estimatedTime = '1 minute';
          } else if (_uploadProgress <= 0.9) {
            _uploadStatus = 'Processing video...';
            _estimatedTime = '30 seconds';
          } else {
            _uploadStatus = 'Finalizing upload...';
            _estimatedTime = '10 seconds';
          }
        });

        if (_uploadProgress < 1.0) {
          _simulateUploadProgress();
        } else {
          _completeUpload();
        }
      } catch (e) {
        debugPrint('Error during upload progress: $e');
        _cancelUpload();
      }
    });
  }

  void _completeUpload() {
    try {
      _uploadTimer?.cancel();

      if (!mounted) return;

      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      _showSuccessToast("Video uploaded successfully! 🎉");

      // Navigate to discovery feed after successful upload
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          try {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/discovery-feed',
              (route) => false,
            );
          } catch (e) {
            debugPrint('Error navigating after upload: $e');
          }
        }
      });
    } catch (e) {
      debugPrint('Error completing upload: $e');
      _showErrorToast('Upload completed but navigation failed.');
    }
  }

  void _cancelUpload() {
    try {
      _uploadTimer?.cancel();

      if (!mounted) return;

      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      _showInfoToast("Upload cancelled");
    } catch (e) {
      debugPrint('Error cancelling upload: $e');
    }
  }

  void _showLocationBottomSheet() {
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkTheme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.darkTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Select Performance Spot',
              style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: mockLocationSpots.length,
                separatorBuilder: (context, index) => Divider(
                  color: AppTheme.darkTheme.colorScheme.outline,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  try {
                    final spot = mockLocationSpots[index];
                    final spotName = spot['name'] as String?;
                    final spotBorough = spot['borough'] as String?;

                    if (spotName == null || spotBorough == null) {
                      return const SizedBox.shrink();
                    }

                    final isSelected = _specificSpot == spotName;

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      leading: CustomIconWidget(
                        iconName: 'location_on',
                        color: isSelected
                            ? AppTheme.darkTheme.colorScheme.primary
                            : AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                        size: 24,
                      ),
                      title: Text(
                        spotName,
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w400,
                          color: isSelected
                              ? AppTheme.darkTheme.colorScheme.primary
                              : AppTheme.darkTheme.colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        spotBorough,
                        style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          color:
                              AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: isSelected
                          ? CustomIconWidget(
                              iconName: 'check_circle',
                              color: AppTheme.darkTheme.colorScheme.primary,
                              size: 20,
                            )
                          : null,
                      onTap: () {
                        try {
                          if (mounted) {
                            setState(() {
                              _specificSpot = spotName;
                              _currentLocation = '$spotBorough, NYC';
                            });
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          debugPrint('Error selecting location: $e');
                        }
                      },
                    );
                  } catch (e) {
                    debugPrint('Error building location item: $e');
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    ).catchError((error) {
      debugPrint('Error showing bottom sheet: $error');
      _showErrorToast('Unable to show location options.');
    });
  }

  // Helper methods for consistent toast messaging
  void _showErrorToast(String message) {
    try {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.accentRed,
        textColor: AppTheme.textPrimary,
      );
    } catch (e) {
      debugPrint('Error showing error toast: $e');
    }
  }

  void _showSuccessToast(String message) {
    try {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.successGreen,
        textColor: AppTheme.textPrimary,
      );
    } catch (e) {
      debugPrint('Error showing success toast: $e');
    }
  }

  void _showInfoToast(String message) {
    try {
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.darkTheme.colorScheme.surface,
        textColor: AppTheme.textPrimary,
      );
    } catch (e) {
      debugPrint('Error showing info toast: $e');
    }
  }

  bool get _canShare {
    try {
      return _captionController.text.trim().isNotEmpty &&
          _selectedPerformanceType.isNotEmpty &&
          !_isUploading;
    } catch (e) {
      debugPrint('Error checking can share: $e');
      return false;
    }
  }

  Map<String, dynamic>? get _safeVideoData {
    try {
      return mockVideoData.isNotEmpty ? mockVideoData.first : null;
    } catch (e) {
      debugPrint('Error getting video data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            try {
              Navigator.pop(context);
            } catch (e) {
              debugPrint('Error navigating back: $e');
            }
          },
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.darkTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          'Post',
          style: AppTheme.darkTheme.appBarTheme.titleTextStyle?.copyWith(
            fontSize: 18.sp,
          ),
        ),
        actions: [
          if (!_isUploading)
            TextButton(
              onPressed: () {
                try {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/discovery-feed',
                    (route) => false,
                  );
                } catch (e) {
                  debugPrint('Error cancelling and navigating: $e');
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Cancel',
                style: AppTheme.darkTheme.textButtonTheme.style?.textStyle
                    ?.resolve({})?.copyWith(
                  fontSize: 14.sp,
                  color: AppTheme.darkTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video thumbnail section with safety check
                    VideoThumbnailWidget(
                      videoPath: _safeVideoData?['videoPath'] as String?,
                      duration:
                          _safeVideoData?['duration'] as String? ?? '0:00',
                      onRetake: _handleRetakeVideo,
                    ),

                    // Caption input
                    CaptionInputWidget(
                      controller: _captionController,
                      onChanged: _handleCaptionChanged,
                    ),

                    // Performance type selector
                    PerformanceTypeSelectorWidget(
                      selectedType: _selectedPerformanceType,
                      onTypeSelected: _handlePerformanceTypeSelected,
                    ),

                    // Location display
                    LocationDisplayWidget(
                      currentLocation: _currentLocation,
                      specificSpot: _specificSpot,
                      onLocationTap: _handleLocationTap,
                    ),

                    // Privacy settings
                    PrivacySettingsWidget(
                      isPublic: _isPublic,
                      onPrivacyChanged: _handlePrivacyChanged,
                    ),

                    // Upload progress
                    UploadProgressWidget(
                      isUploading: _isUploading,
                      progress: _uploadProgress,
                      statusText: _uploadStatus,
                      estimatedTime: _estimatedTime,
                      onCancel: _cancelUpload,
                    ),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),

            // Share button
            Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                color: AppTheme.darkTheme.scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.darkTheme.colorScheme.outline,
                    width: 0.5,
                  ),
                ),
              ),
              child: ShareButtonWidget(
                isEnabled: _canShare,
                isLoading: _isUploading,
                onPressed: _handleShareVideo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}