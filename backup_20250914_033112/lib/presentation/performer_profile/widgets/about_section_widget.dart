import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';

class AboutSectionWidget extends StatefulWidget {
  final Map<String, dynamic> performerData;
  final bool isEditing;
  final Function(Map<String, dynamic>)? onSave;
  final VoidCallback? onEditToggle;

  const AboutSectionWidget({
    super.key,
    required this.performerData,
    this.isEditing = false,
    this.onSave,
    this.onEditToggle,
  });

  @override
  State<AboutSectionWidget> createState() => _AboutSectionWidgetState();
}

class _AboutSectionWidgetState extends State<AboutSectionWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bioController;
  late TextEditingController _instagramController;
  late TextEditingController _tiktokController;
  late TextEditingController _youtubeController;
  
  bool _isLoading = false;
  String? _selectedBorough;
  
  final List<String> _boroughs = [
    'Manhattan',
    'Brooklyn',
    'Queens',
    'Bronx',
    'Staten Island',
    'Frequent Visitor',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _bioController = TextEditingController(text: widget.performerData['bio'] ?? '');
    
    // Extract social media from nested socialMedia object
    final socialMedia = widget.performerData['socialMedia'] as Map<String, dynamic>? ?? {};
    _instagramController = TextEditingController(text: socialMedia['instagram'] ?? '');
    _tiktokController = TextEditingController(text: socialMedia['tiktok'] ?? '');
    _youtubeController = TextEditingController(text: socialMedia['youtube'] ?? '');
    
    // Handle borough field for location selection
    final borough = widget.performerData['borough'] as String?;
    _selectedBorough = borough;
    if (_selectedBorough != null && !_boroughs.contains(_selectedBorough)) {
      _selectedBorough = 'Frequent Visitor';
    }
  }

  @override
  void didUpdateWidget(AboutSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isEditing && oldWidget.isEditing) {
      // Reset to original values when exiting edit mode
      _resetControllers();
    }
  }

  void _resetControllers() {
    _bioController.text = widget.performerData['bio'] ?? '';
    final socialMedia = widget.performerData['socialMedia'] as Map<String, dynamic>? ?? {};
    _instagramController.text = socialMedia['instagram'] ?? '';
    _tiktokController.text = socialMedia['tiktok'] ?? '';
    _youtubeController.text = socialMedia['youtube'] ?? '';
    
    final borough = widget.performerData['borough'] as String?;
    _selectedBorough = borough;
    if (_selectedBorough != null && !_boroughs.contains(_selectedBorough)) {
      _selectedBorough = 'Frequent Visitor';
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Edit Controls (when in editing mode)
            if (widget.isEditing) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Profile",
                    style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _isLoading ? null : _cancelEdit,
                        child: Text(
                          "Cancel",
                          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.xs),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveProfile,
                        icon: _isLoading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.backgroundDark,
                                  ),
                                ),
                              )
                            : CustomIconWidget(
                                iconName: 'check',
                                color: AppTheme.backgroundDark,
                                size: 18,
                              ),
                        label: Text(
                          _isLoading ? "Saving..." : "Save",
                          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.backgroundDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),
            ],

            // Bio Section (editable/display)
            _buildBioSection(),

            // Location Section (editable/display)
            if (widget.isEditing) _buildLocationSection(),

            // Social Media Section (editable/display)
            _buildSocialMediaSection(),

            // Performance Details (display only)
            if (widget.performerData["performanceTypes"] != null)
              _buildSection(
              "Performance Types",
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xxs,
                children: (widget.performerData["performanceTypes"] as List)
                    .map((type) => Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.primaryOrange.withOpacity( 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  AppTheme.primaryOrange.withOpacity( 0.5),
                            ),
                          ),
                          child: Text(
                            type as String,
                            style: AppTheme.darkTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.primaryOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),

            // Performance Schedule
            if (widget.performerData["schedule"] != null)
              _buildSection(
              "Performance Schedule",
              Column(
                children: (widget.performerData["schedule"] as List)
                    .map((schedule) => Container(
                          margin: EdgeInsets.only(bottom: AppSpacing.xxs),
                          padding: EdgeInsets.all(AppSpacing.sm),
                          decoration: AppTheme.performerCardDecoration(),
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'schedule',
                                color: AppTheme.primaryOrange,
                                size: 20,
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (schedule as Map<String, dynamic>)["day"]
                                              as String? ??
                                          "",
                                      style: AppTheme
                                          .darkTheme.textTheme.titleSmall,
                                    ),
                                    Text(
                                      "${schedule["time"]} at ${schedule["location"]}",
                                      style: AppTheme
                                          .darkTheme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),

            // Borough Section (display when not editing)
            if (!widget.isEditing) _buildBoroughDisplaySection(),

          // Note: Social Media section is now handled by _buildSocialMediaSection()

          // Stats Section
          _buildSection(
            "Statistics",
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: AppTheme.performerCardDecoration(),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(
                          "Total Videos",
                          (widget.performerData["videoCount"] as int? ?? 0)
                              .toString()),
                      _buildStatItem(
                          "Total Views",
                          _formatCount(
                              widget.performerData["totalViews"] as int? ?? 0)),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(
                          "Total Likes",
                          _formatCount(
                              widget.performerData["totalLikes"] as int? ?? 0)),
                      _buildStatItem(
                          "Member Since",
                          _formatJoinDate(
                              widget.performerData["joinDate"] as String? ?? "")),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: AppSpacing.md),
        ],
      ),
    ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        content,
        SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTheme.performerStatsStyle(isLight: false).copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.bodySmall,
        ),
      ],
    );
  }

  String _getSocialMediaIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return 'camera_alt';
      case 'tiktok':
        return 'music_note';
      case 'youtube':
        return 'play_circle_filled';
      case 'twitter':
        return 'alternate_email';
      default:
        return 'link';
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return "${(count / 1000000).toStringAsFixed(1)}M";
    } else if (count >= 1000) {
      return "${(count / 1000).toStringAsFixed(1)}K";
    }
    return count.toString();
  }

  String _formatJoinDate(String dateString) {
    if (dateString.isEmpty) return "Unknown";
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays >= 365) {
        return "${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago";
      } else if (difference.inDays >= 30) {
        return "${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago";
      } else {
        return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
      }
    } catch (e) {
      return "Unknown";
    }
  }

  Widget _buildBioSection() {
    if (widget.isEditing) {
      return _buildSection(
        "About",
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _bioController,
              maxLines: 4,
              maxLength: 150,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: "Tell NYC about your performances and style...",
                hintStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                filled: true,
                fillColor: AppTheme.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.borderSubtle),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.borderSubtle),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.primaryOrange, width: 2),
                ),
                counterStyle: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Display mode - always show section with "Not provided" placeholder
      final bio = widget.performerData["bio"] as String?;
      final displayBio = (bio == null || bio.trim().isEmpty) ? "Not set" : bio;
      final isEmpty = bio == null || bio.trim().isEmpty;
      
      return _buildSection(
        "About",
        Text(
          displayBio,
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: isEmpty ? AppTheme.textSecondary : AppTheme.textPrimary,
            fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      );
    }
  }

  Widget _buildLocationSection() {
    return _buildSection(
      "Primary Location",
      DropdownButtonFormField<String>(
        value: _selectedBorough,
        onChanged: (value) => setState(() => _selectedBorough = value),
        style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: "Where you usually perform",
          hintStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
          filled: true,
          fillColor: AppTheme.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.borderSubtle),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.borderSubtle),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primaryOrange, width: 2),
          ),
        ),
        dropdownColor: AppTheme.surfaceDark,
        items: _boroughs.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    if (widget.isEditing) {
      return _buildSection(
        "Social Media",
        Column(
          children: [
            _buildSocialTextField(
              controller: _instagramController,
              label: "Instagram",
              hint: "your_username",
              prefix: "@",
            ),
            SizedBox(height: AppSpacing.sm),
            _buildSocialTextField(
              controller: _tiktokController,
              label: "TikTok",
              hint: "your_username", 
              prefix: "@",
            ),
            SizedBox(height: AppSpacing.sm),
            _buildSocialTextField(
              controller: _youtubeController,
              label: "YouTube",
              hint: "channel_name or full URL",
              prefix: "🎥 ",
            ),
          ],
        ),
      );
    } else {
      // Display mode - always show all platforms with "Not provided" for empty ones
      final socialMedia = widget.performerData["socialMedia"] as Map<String, dynamic>? ?? {};
      final platforms = ['instagram', 'tiktok', 'youtube'];
      
      return _buildSection(
        "Social Media",
        Column(
          children: platforms.map((platform) {
            final value = socialMedia[platform] as String?;
            final displayValue = (value == null || value.trim().isEmpty) ? "Not set" : value;
            final isEmpty = value == null || value.trim().isEmpty;
            
            return Container(
              margin: EdgeInsets.only(bottom: platform == platforms.last ? 0 : AppSpacing.xxs),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                decoration: AppTheme.performerCardDecoration(),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: _getSocialMediaIcon(platform),
                      color: isEmpty ? AppTheme.textSecondary : AppTheme.primaryOrange,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            platform.toUpperCase(),
                            style: AppTheme.darkTheme.textTheme.titleSmall,
                          ),
                          Text(
                            displayValue,
                            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                              color: isEmpty ? AppTheme.textSecondary : AppTheme.primaryOrange,
                              fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isEmpty)
                      CustomIconWidget(
                        iconName: 'open_in_new',
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    }
  }

  Widget _buildSocialTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppSpacing.xxs),
        TextFormField(
          controller: controller,
          validator: (value) => _validateSocialMediaField(value, label),
          style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            prefixStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            hintStyle: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            filled: true,
            fillColor: AppTheme.surfaceDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryOrange, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBoroughDisplaySection() {
    final borough = widget.performerData["borough"] as String?;
    final displayBorough = (borough == null || borough.trim().isEmpty) ? "Not set" : borough;
    final isEmpty = borough == null || borough.trim().isEmpty;
    
    return _buildSection(
      "Location",
      Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: AppTheme.performerCardDecoration(),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'location_on',
              color: isEmpty ? AppTheme.textSecondary : AppTheme.primaryOrange,
              size: 20,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                displayBorough,
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: isEmpty ? AppTheme.textSecondary : AppTheme.textPrimary,
                  fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _cancelEdit() {
    _resetControllers();
    widget.onEditToggle?.call();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 600));
      
      final updatedData = {
        'bio': _bioController.text.trim(),
        'socialMedia': {
          'instagram': _instagramController.text.trim(),
          'tiktok': _tiktokController.text.trim(),
          'youtube': _youtubeController.text.trim(),
        },
        'borough': _selectedBorough,
      };
      
      widget.onSave?.call(updatedData);
      widget.onEditToggle?.call();
      
    } catch (e) {
      debugPrint('Profile save error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CustomIconWidget(
                iconName: 'error',
                color: AppTheme.accentRed,
                size: 20,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                "Failed to update profile. Please try again.",
                style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.surfaceDark,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _validateSocialMediaField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return null; // Allow empty social media fields
    }
    
    final trimmedValue = value.trim();
    
    switch (fieldName.toLowerCase()) {
      case 'instagram':
      case 'tiktok':
        // Remove @ prefix if present for validation
        final username = trimmedValue.startsWith('@') ? trimmedValue.substring(1) : trimmedValue;
        if (username.length < 3) {
          return 'Username must be at least 3 characters';
        }
        if (username.length > 30) {
          return 'Username must be less than 30 characters';
        }
        if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(username)) {
          return 'Username can only contain letters, numbers, dots, and underscores';
        }
        break;
        
      case 'youtube':
        // Accept channel names or full URLs
        if (trimmedValue.length < 3) {
          return 'Channel name must be at least 3 characters';
        }
        if (trimmedValue.length > 100) {
          return 'Channel name/URL is too long';
        }
        // If it looks like a URL, validate it's a YouTube URL
        if (trimmedValue.contains('youtube.com') || trimmedValue.contains('youtu.be')) {
          if (!RegExp(r'^https?:\/\/(www\.)?(youtube\.com|youtu\.be)\/.*').hasMatch(trimmedValue)) {
            return 'Please enter a valid YouTube URL';
          }
        }
        break;
    }
    
    return null;
  }
}
