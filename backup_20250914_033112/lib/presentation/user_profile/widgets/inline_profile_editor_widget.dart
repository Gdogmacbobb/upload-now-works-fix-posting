import 'package:flutter/material.dart';
import 'package:ynfny/core/app_export.dart';
import '../../../services/role_service.dart';
import '../../../widgets/custom_icon_widget.dart';

class InlineProfileEditorWidget extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Function(Map<String, dynamic>) onSave;
  final bool isPerformer;

  const InlineProfileEditorWidget({
    super.key,
    required this.userData,
    required this.onSave,
    required this.isPerformer,
  });

  @override
  State<InlineProfileEditorWidget> createState() => _InlineProfileEditorWidgetState();
}

class _InlineProfileEditorWidgetState extends State<InlineProfileEditorWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bioController;
  late TextEditingController _instagramController;
  late TextEditingController _tiktokController;
  late TextEditingController _youtubeController;
  
  bool _isEditing = false;
  bool _isLoading = false;
  String? _selectedBorough;
  
  final List<String> _boroughs = [
    'Manhattan',
    'Brooklyn', 
    'Queens',
    'Bronx',
    'Staten Island',
    'Frequent Visitor', // Universal option for both roles
  ];

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.userData['bio'] ?? '');
    _instagramController = TextEditingController(text: widget.userData['instagram'] ?? '');
    _tiktokController = TextEditingController(text: widget.userData['tiktok'] ?? '');
    _youtubeController = TextEditingController(text: widget.userData['youtube'] ?? '');
    _selectedBorough = widget.userData['borough'];
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: AppTheme.performerCardDecoration(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Edit/Save/Cancel buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Profile Information",
                  style: AppTheme.darkTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!_isEditing)
                  TextButton.icon(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: CustomIconWidget(
                      iconName: 'edit',
                      color: AppTheme.primaryOrange,
                      size: 18,
                    ),
                    label: Text(
                      "Edit",
                      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
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
            
            // Bio Section
            _buildFieldSection(
              title: "Bio",
              child: _isEditing
                  ? _buildEditableBioField()
                  : _buildDisplayBioField(),
            ),
            
            SizedBox(height: AppSpacing.md),
            
            // Location Section
            _buildFieldSection(
              title: "Location",
              child: _isEditing
                  ? _buildEditableBoroughField()
                  : _buildDisplayBoroughField(),
            ),
            
            SizedBox(height: AppSpacing.md),
            
            // Social Media Section
            _buildFieldSection(
              title: "Social Media",
              child: _isEditing
                  ? _buildEditableSocialFields()
                  : _buildDisplaySocialFields(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.darkTheme.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        child,
      ],
    );
  }

  // Bio Field Widgets
  Widget _buildEditableBioField() {
    return Column(
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
            hintText: widget.isPerformer 
                ? "Tell NYC about your performances and style..."
                : "Tell others about yourself...",
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
    );
  }

  Widget _buildDisplayBioField() {
    final bio = _bioController.text.trim();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle.withOpacity(0.3)),
      ),
      child: Text(
        bio.isEmpty 
            ? (widget.isPerformer ? "No bio added yet" : "No bio added yet")
            : bio,
        style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
          color: bio.isEmpty ? AppTheme.textSecondary : AppTheme.textPrimary,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // Borough Field Widgets
  Widget _buildEditableBoroughField() {
    return DropdownButtonFormField<String>(
      value: _selectedBorough,
      onChanged: (value) => setState(() => _selectedBorough = value),
      style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: widget.isPerformer ? "Where you usually perform" : "Where you're usually located",
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
    );
  }

  Widget _buildDisplayBoroughField() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle.withOpacity(0.3)),
      ),
      child: Text(
        _selectedBorough ?? (widget.isPerformer ? "No location set" : "No location set"),
        style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
          color: _selectedBorough != null ? AppTheme.textPrimary : AppTheme.textSecondary,
        ),
      ),
    );
  }

  // Social Media Field Widgets
  Widget _buildEditableSocialFields() {
    return Column(
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
          prefix: widget.isPerformer ? "🎥 " : "",
        ),
      ],
    );
  }

  Widget _buildDisplaySocialFields() {
    return Column(
      children: [
        _buildSocialDisplayField("Instagram", _instagramController.text, "@"),
        SizedBox(height: AppSpacing.xs),
        _buildSocialDisplayField("TikTok", _tiktokController.text, "@"),
        SizedBox(height: AppSpacing.xs),
        _buildSocialDisplayField("YouTube", _youtubeController.text, widget.isPerformer ? "🎥 " : ""),
      ],
    );
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

  Widget _buildSocialDisplayField(String label, String value, String prefix) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderSubtle.withOpacity(0.3)),
            ),
            child: Text(
              value.trim().isEmpty 
                  ? "Not set"
                  : "$prefix${value.trim()}",
              style: AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                color: value.trim().isEmpty ? AppTheme.textSecondary : AppTheme.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      // Restore original values
      _bioController.text = widget.userData['bio'] ?? '';
      _instagramController.text = widget.userData['instagram'] ?? '';
      _tiktokController.text = widget.userData['tiktok'] ?? '';
      _youtubeController.text = widget.userData['youtube'] ?? '';
      _selectedBorough = widget.userData['borough'];
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 600));
      
      final updatedData = {
        'bio': _bioController.text.trim(),
        'instagram': _instagramController.text.trim(),
        'tiktok': _tiktokController.text.trim(),
        'youtube': _youtubeController.text.trim(),
        'borough': _selectedBorough,
      };
      
      widget.onSave(updatedData);
      
      setState(() => _isEditing = false);
      
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
}