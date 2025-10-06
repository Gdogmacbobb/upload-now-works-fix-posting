import 'package:flutter/material.dart';

import 'package:ynfny/core/app_export.dart';
import '../services/role_service.dart';
import '../widgets/role_gate_widget.dart';

class FeedNavigationBottomWidget extends StatelessWidget {
  final String currentFeed; // 'following', 'discovery', or 'for_you'
  final bool showSearch;
  final int unreadCount;
  final VoidCallback? onRefresh;

  const FeedNavigationBottomWidget({
    Key? key,
    required this.currentFeed,
    this.showSearch = true,
    this.unreadCount = 0,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 1.20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withAlpha(153),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Search Button - Moved to first position
            GestureDetector(
              onTap: () => _showSearchOverlay(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                child: Icon(
                  Icons.search,
                  size: AppSpacing.lg,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),

            SizedBox(width: AppSpacing.xl),

            // Camera Button - Only for Street Performers
            RoleGate.requiresFeature(
              feature: PerformerFeature.recordVideo,
              hideWhenRestricted: true,
              child: GestureDetector(
                onTap: () => _navigateToCamera(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  child: Icon(
                    Icons.camera_alt,
                    size: AppSpacing.lg,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ),
            ),

            // Dynamic spacing - only show spacing if camera button is visible
            RoleGate.requiresFeature(
              feature: PerformerFeature.recordVideo,
              hideWhenRestricted: true,
              child: SizedBox(width: AppSpacing.xl),
            ),

            // Community Button - Only for New Yorkers
            RoleGate.newYorkerOnly(
              hideWhenRestricted: true,
              child: GestureDetector(
                onTap: () => _navigateToCommunity(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  child: Icon(
                    Icons.group,
                    size: AppSpacing.lg,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ),
            ),

            // Dynamic spacing - only show spacing if community button is visible
            RoleGate.newYorkerOnly(
              hideWhenRestricted: true,
              child: SizedBox(width: AppSpacing.xl),
            ),

            // Home Button - Remains in same position
            GestureDetector(
              onTap: () => _navigateToHome(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                child: Icon(
                  Icons.home,
                  size: AppSpacing.lg,
                  color: currentFeed == 'home'
                      ? AppTheme.primaryOrange
                      : AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCamera(BuildContext context) {
    AppRoutes.pushNamed(context, AppRoutes.videoRecording);
  }

  void _navigateToHome(BuildContext context) {
    // Navigate to performer profile page for both Street Performers and New Yorkers
    AppRoutes.pushNamed(context, AppRoutes.performerProfile);
  }

  void _navigateToCommunity(BuildContext context) {
    // Navigate to community/social features for New Yorkers
    AppRoutes.pushNamed(context, AppRoutes.discoveryFeed);
  }

  void _showSearchOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchOverlayWidget(
        currentFeed: currentFeed,
      ),
    );
  }
}

class _SearchOverlayWidget extends StatefulWidget {
  final String currentFeed;

  const _SearchOverlayWidget({
    Key? key,
    required this.currentFeed,
  }) : super(key: key);

  @override
  State<_SearchOverlayWidget> createState() => _SearchOverlayWidgetState();
}

class _SearchOverlayWidgetState extends State<_SearchOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  String? _selectedPerformanceType;
  String? _selectedBorough;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  final List<String> _performanceTypes = [
    'Music',
    'Dance',
    'Magic',
    'Comedy',
    'Art',
    'Acrobatics',
    'Poetry',
    'Theater',
  ];

  final List<String> _boroughs = [
    'Manhattan',
    'Brooklyn',
    'Queens',
    'Bronx',
    'Staten Island',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleClose() {
    _animationController.reverse().then((_) {
      Navigator.pop(context);
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Simulate search results - In real implementation, this would call a service
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchResults = _getMockSearchResults(query);
          _isSearching = false;
        });
      }
    });
  }

  List<Map<String, dynamic>> _getMockSearchResults(String query) {
    // Mock search results - In real implementation, this would come from a service
    final mockResults = [
      {
        'type': 'performer',
        'name': 'Jazz Marcus',
        'username': '@jazzy_marcus',
        'avatar':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        'performanceType': 'Music',
        'location': 'Washington Square Park',
        'isFollowing': true,
      },
      {
        'type': 'performer',
        'name': 'Brooklyn Beats',
        'username': '@brooklyn_beats',
        'avatar':
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
        'performanceType': 'Music',
        'location': 'Brooklyn Bridge',
        'isFollowing': true,
      },
      {
        'type': 'location',
        'name': 'Times Square',
        'borough': 'Manhattan',
        'activePerformers': 12,
      },
      {
        'type': 'location',
        'name': 'Central Park',
        'borough': 'Manhattan',
        'activePerformers': 8,
      },
    ];

    return mockResults
        .where((result) =>
            result['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            (result['username']
                    ?.toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()) ??
                false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * double.infinity),
          child: Container(
            width: double.infinity,
            height: 85,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowDark,
                  blurRadius: 8,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Handle indicator
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header with close button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Search ${widget.currentFeed == 'following' ? 'Following' : 'Discovery'}',
                          style:
                              AppTheme.darkTheme.textTheme.titleLarge?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: _handleClose,
                          child: Container(
                            padding: EdgeInsets.all(AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: AppTheme.borderSubtle,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: AppTheme.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpacing.sm),

                  // Search bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.inputBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.borderSubtle,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style:
                            AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search performers, locations...',
                          hintStyle:
                              AppTheme.darkTheme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(AppSpacing.sm),
                            child: Icon(
                              Icons.search,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                        onChanged: _performSearch,
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.sm),

                  // Filter chips
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: SizedBox(
                      height: 60,
                      child: Row(
                        children: [
                          // Performance type filter
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Performance Type',
                                  style: AppTheme
                                      .darkTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                SizedBox(height: AppSpacing.xxs),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Wrap(
                                      spacing: AppSpacing.xs,
                                      runSpacing: AppSpacing.xxs,
                                      children: _performanceTypes.map((type) {
                                        final isSelected =
                                            _selectedPerformanceType == type;
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedPerformanceType =
                                                  isSelected ? null : type;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: AppSpacing.sm,
                                              vertical: AppSpacing.xxs,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppTheme.primaryOrange
                                                  : AppTheme.borderSubtle,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              type,
                                              style: AppTheme.darkTheme
                                                  .textTheme.labelSmall
                                                  ?.copyWith(
                                                color: isSelected
                                                    ? AppTheme.backgroundDark
                                                    : AppTheme.textSecondary,
                                                fontWeight: isSelected
                                                    ? FontWeight.w500
                                                    : FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: AppSpacing.md),

                          // Borough filter
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Borough',
                                  style: AppTheme
                                      .darkTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                SizedBox(height: AppSpacing.xxs),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: _boroughs.map((borough) {
                                        final isSelected =
                                            _selectedBorough == borough;
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedBorough =
                                                  isSelected ? null : borough;
                                            });
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            margin:
                                                EdgeInsets.only(bottom: AppSpacing.xxs),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: AppSpacing.sm,
                                              vertical: AppSpacing.xxs,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AppTheme.primaryOrange
                                                  : AppTheme.borderSubtle,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              borough,
                                              style: AppTheme.darkTheme
                                                  .textTheme.labelSmall
                                                  ?.copyWith(
                                                color: isSelected
                                                    ? AppTheme.backgroundDark
                                                    : AppTheme.textSecondary,
                                                fontWeight: isSelected
                                                    ? FontWeight.w500
                                                    : FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.xs),

                  // Search results
                  Expanded(
                    child: _isSearching
                        ? Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryOrange,
                            ),
                          )
                        : _searchResults.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search,
                                      size: 48,
                                      color: AppTheme.textSecondary,
                                    ),
                                    SizedBox(height: AppSpacing.xs),
                                    Text(
                                      _searchController.text.isEmpty
                                          ? 'Start typing to search...'
                                          : 'No results found',
                                      style: AppTheme
                                          .darkTheme.textTheme.bodyLarge
                                          ?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final result = _searchResults[index];
                                  return _SearchResultTile(
                                    result: result,
                                    onTap: () => _handleResultTap(result),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleResultTap(Map<String, dynamic> result) {
    if (result['type'] == 'performer') {
      Navigator.pop(context);
      Navigator.pushNamed(
        context,
        AppRoutes.performerProfile,
        arguments: result['username'],
      );
    } else if (result['type'] == 'location') {
      // Handle location tap - could navigate to discovery feed with location filter
      Navigator.pop(context);
      Navigator.pushNamed(context, AppRoutes.discoveryFeed);
    }
  }
}

class _SearchResultTile extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onTap;

  const _SearchResultTile({
    Key? key,
    required this.result,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.xs),
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppTheme.inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.borderSubtle,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar or icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.borderSubtle,
              ),
              child: result['type'] == 'performer'
                  ? ClipOval(
                      child: Image.network(
                        result['avatar'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: AppTheme.textSecondary,
                            size: AppSpacing.lg,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.location_on,
                      color: AppTheme.primaryOrange,
                      size: AppSpacing.lg,
                    ),
            ),

            SizedBox(width: AppSpacing.sm),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result['name'] ?? '',
                    style: AppTheme.darkTheme.textTheme.titleSmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (result['username'] != null) ...[
                    SizedBox(height: 0.20),
                    Text(
                      result['username'],
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  if (result['performanceType'] != null ||
                      result['location'] != null) ...[
                    SizedBox(height: 0.20),
                    Text(
                      result['performanceType'] != null
                          ? '${result['performanceType']} • ${result['location']}'
                          : '${result['borough']} • ${result['activePerformers']} active',
                      style: AppTheme.darkTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Action indicator
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textSecondary,
              size: AppSpacing.md,
            ),
          ],
        ),
      ),
    );
  }
}
