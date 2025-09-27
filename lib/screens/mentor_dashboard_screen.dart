import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/modern_theme.dart';
import '../core/services/auth_service.dart';
import '../core/services/realtime_service.dart';
import 'mentorship_requests_screen.dart';
import 'chat_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';

class MentorDashboardScreen extends StatefulWidget {
  const MentorDashboardScreen({super.key});

  @override
  State<MentorDashboardScreen> createState() => _MentorDashboardScreenState();
}

class _MentorDashboardScreenState extends State<MentorDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDashboardData();
    _setupRealtimeUpdates();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    _mainController.forward();
  }

  Map<String, dynamic> _mentorStats = {};
  List<Map<String, dynamic>> _recentRequests = [];
  List<Map<String, dynamic>> _upcomingSessions = [];

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Load mentor-specific data
      await _loadMentorStats();
      await _loadRecentRequests();
      await _loadUpcomingSessions();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMentorStats() async {
    // In a real app, this would fetch from Firebase/API
    _mentorStats = {
      'total_mentees': 12,
      'active_sessions': 5,
      'completed_sessions': 48,
      'avg_rating': 4.8,
      'total_hours': 120,
      'monthly_earnings': 2400,
      'growth_rate': 15.2,
    };
  }

  Future<void> _loadRecentRequests() async {
    // Mock data - in real app, fetch from Firebase/API
    _recentRequests = [
      {
        'id': '1',
        'mentee_name': 'Sarah Johnson',
        'mentee_avatar': 'https://ui-avatars.com/api/?name=Sarah+Johnson&background=random',
        'business_name': 'TechStart Solutions',
        'request_type': 'Business Strategy',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'status': 'pending',
      },
      {
        'id': '2',
        'mentee_name': 'Mike Chen',
        'mentee_avatar': 'https://ui-avatars.com/api/?name=Mike+Chen&background=random',
        'business_name': 'GreenTech Innovations',
        'request_type': 'Funding Guidance',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
        'status': 'pending',
      },
      {
        'id': '3',
        'mentee_name': 'Emma Davis',
        'mentee_avatar': 'https://ui-avatars.com/api/?name=Emma+Davis&background=random',
        'business_name': 'Creative Studio',
        'request_type': 'Marketing Strategy',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'status': 'accepted',
      },
    ];
  }

  Future<void> _loadUpcomingSessions() async {
    // Mock data - in real app, fetch from Firebase/API
    _upcomingSessions = [
      {
        'id': '1',
        'mentee_name': 'Alex Rodriguez',
        'business_name': 'FoodieApp',
        'session_type': '1-on-1 Strategy Session',
        'scheduled_time': DateTime.now().add(const Duration(hours: 3)),
        'duration': 60,
        'meeting_link': 'https://meet.google.com/abc-defg-hij',
      },
      {
        'id': '2',
        'mentee_name': 'Lisa Wang',
        'business_name': 'EduTech Platform',
        'session_type': 'Product Review',
        'scheduled_time': DateTime.now().add(const Duration(days: 1, hours: 2)),
        'duration': 45,
        'meeting_link': 'https://zoom.us/j/123456789',
      },
    ];
  }

  void _setupRealtimeUpdates() {
    RealtimeService.generalStream.listen((data) {
      if (mounted) {
        _loadDashboardData();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        
        final bool? shouldPop = await _showExitConfirmation(context);
        if (shouldPop == true && context.mounted) {
          // For mentor dashboard as home screen, we exit the app
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: _isLoading ? _buildLoadingState() : _buildModernDashboard(),
        bottomNavigationBar: _buildModernNavigationBar(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildLoadingHeader(),
            const SizedBox(height: 20),
            _buildLoadingCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingHeader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: 200,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCards() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 180,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildModernDashboard() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: _buildContent(),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return MentorshipRequestsScreen();
      case 2:
        return _buildCommunityWrapper();
      case 3:
        return _buildProfileWrapper();
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildCommunityWrapper() {
    return SafeArea(
      child: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const CommunityScreen(),
          );
        },
      ),
    );
  }

  Widget _buildProfileWrapper() {
    return SafeArea(
      child: Navigator(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          );
        },
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SafeArea(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildWelcomeSection(),
                const SizedBox(height: 24),
                _buildStatsGrid(),
                const SizedBox(height: 24),
                _buildQuickActions(),
                const SizedBox(height: 24),
                _buildRecentActivity(),
                const SizedBox(height: 24),
                _buildUpcomingSessions(),
                const SizedBox(height: 100), // Space for bottom nav
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: ModernTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    AuthService.currentUser?['name']?.toString().substring(0, 1).toUpperCase() ?? 'M',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome back,',
                        style: ModernTheme.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        AuthService.currentUser?['name'] ?? 'Mentor',
                        style: ModernTheme.h4.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Implement notifications
                  },
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications_outlined, color: Colors.white),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: ModernTheme.sunsetOrange,
                            shape: BoxShape.circle,
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
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ModernTheme.electricBlue, ModernTheme.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: ModernTheme.modernShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Mentoring Impact',
            style: ModernTheme.h3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Empowering the next generation of entrepreneurs',
            style: ModernTheme.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildImpactStat('23', 'Mentees Helped'),
              const SizedBox(width: 24),
              _buildImpactStat('156', 'Hours Mentored'),
              const SizedBox(width: 24),
              _buildImpactStat('4.9', 'Rating'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImpactStat(String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: ModernTheme.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: ModernTheme.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Total Mentees',
          '${_mentorStats['total_mentees'] ?? 0}',
          Icons.people_outline,
          ModernTheme.freshGreen,
          'Active: ${_mentorStats['active_sessions'] ?? 0}',
        ),
        _buildStatCard(
          'Pending Requests',
          '${_recentRequests.where((r) => r['status'] == 'pending').length}',
          Icons.schedule,
          ModernTheme.sunsetOrange,
          '${_recentRequests.length} total',
        ),
        _buildStatCard(
          'Total Hours',
          '${_mentorStats['total_hours'] ?? 0}h',
          Icons.access_time,
          ModernTheme.electricBlue,
          'Avg rating: ${_mentorStats['avg_rating'] ?? 0}★',
        ),
        _buildStatCard(
          'This Month',
          '\$${_mentorStats['monthly_earnings'] ?? 0}',
          Icons.trending_up,
          ModernTheme.teal,
          '${_mentorStats['completed_sessions'] ?? 0} sessions',
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.modernShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(Icons.more_vert, color: Colors.grey[400], size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: ModernTheme.h2.copyWith(
              color: ModernTheme.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            title,
            style: ModernTheme.bodyMedium.copyWith(
              color: ModernTheme.mediumGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: ModernTheme.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: ModernTheme.h3.copyWith(
            color: ModernTheme.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Schedule Session',
                Icons.calendar_today,
                ModernTheme.electricBlue,
                () {
                  // TODO: Implement schedule session
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'View Requests',
                Icons.inbox,
                ModernTheme.sunsetOrange,
                () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Start Chat',
                Icons.chat_bubble_outline,
                ModernTheme.teal,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(
                        entrepreneurName: 'Sarah Johnson',
                        entrepreneurAvatar: 'https://via.placeholder.com/50',
                        businessName: 'TechStart Solutions',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Resources',
                Icons.library_books,
                ModernTheme.freshGreen,
                () {
                  // TODO: Implement resources
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: ModernTheme.modernShadow,
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: ModernTheme.bodyMedium.copyWith(
                color: ModernTheme.navy,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: ModernTheme.h3.copyWith(
            color: ModernTheme.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: ModernTheme.modernShadow,
          ),
          child: Column(
            children: _recentRequests.isEmpty 
              ? [
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: ModernTheme.mediumGray,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recent activity',
                          style: ModernTheme.bodyLarge.copyWith(
                            color: ModernTheme.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]
              : _recentRequests.take(4).map((request) {
                  String timeAgo = _getTimeAgo(request['timestamp']);
                  String activityText = 'New ${request['request_type'].toLowerCase()} request from ${request['mentee_name']}';
                  IconData activityIcon = request['status'] == 'pending' 
                    ? Icons.person_add 
                    : Icons.check_circle;
                  Color activityColor = request['status'] == 'pending' 
                    ? ModernTheme.sunsetOrange 
                    : ModernTheme.freshGreen;
                    
                  return _buildActivityItem(
                    activityText,
                    timeAgo,
                    activityIcon,
                    activityColor,
                  );
                }).toList(),
          ),    ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ModernTheme.bodyMedium.copyWith(
                    color: ModernTheme.navy,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: ModernTheme.bodySmall.copyWith(
                    color: ModernTheme.mediumGray,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Color _getSessionColor(String sessionType) {
    String type = sessionType.toLowerCase();
    if (type.contains('strategy')) {
      return ModernTheme.electricBlue;
    } else if (type.contains('product') || type.contains('review')) {
      return ModernTheme.teal;
    } else if (type.contains('funding')) {
      return ModernTheme.sunsetOrange;
    } else if (type.contains('technical')) {
      return ModernTheme.navy;
    } else {
      return ModernTheme.freshGreen;
    }
  }

  String _formatSessionTime(DateTime scheduledTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final sessionDate = DateTime(scheduledTime.year, scheduledTime.month, scheduledTime.day);
    
    String timeStr = '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}';
    
    if (sessionDate == today) {
      return 'Today, $timeStr';
    } else if (sessionDate == tomorrow) {
      return 'Tomorrow, $timeStr';
    } else {
      final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return '${weekdays[scheduledTime.weekday - 1]}, $timeStr';
    }
  }

  Widget _buildUpcomingSessions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Sessions',
          style: ModernTheme.h3.copyWith(
            color: ModernTheme.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: ModernTheme.modernShadow,
          ),
          child: _upcomingSessions.isEmpty
            ? Column(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 48,
                    color: ModernTheme.mediumGray,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No upcoming sessions',
                    style: ModernTheme.bodyLarge.copyWith(
                      color: ModernTheme.mediumGray,
                    ),
                  ),
                ],
              )
            : Column(
                children: _upcomingSessions.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> session = entry.value;
                  bool isLast = index == _upcomingSessions.length - 1;
                  
                  Color sessionColor = _getSessionColor(session['session_type']);
                  String formattedTime = _formatSessionTime(session['scheduled_time']);
                  
                  return Column(
                    children: [
                      _buildSessionItem(
                        session['session_type'] ?? 'Session',
                        'with ${session['mentee_name'] ?? 'Unknown'}',
                        formattedTime,
                        sessionColor,
                      ),
                      if (!isLast) const Divider(height: 24),
                    ],
                  );
                }).toList(),
              ),
        ),
      ],
    );
  }

  Widget _buildSessionItem(String title, String subtitle, String time, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ModernTheme.bodyLarge.copyWith(
                  color: ModernTheme.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: ModernTheme.bodyMedium.copyWith(
                  color: ModernTheme.mediumGray,
                ),
              ),
              Text(
                time,
                style: ModernTheme.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            // TODO: Join session
          },
          icon: Icon(Icons.video_call, color: color),
        ),
      ],
    );
  }

  Widget _buildModernNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.dashboard, 'Dashboard', 0),
              _buildNavItem(Icons.inbox, 'Requests', 1),
              _buildNavItem(Icons.people, 'Community', 2),
              _buildNavItem(Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? ModernTheme.electricBlue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? ModernTheme.electricBlue : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? ModernTheme.electricBlue : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showExitConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Exit BizNest?',
            style: ModernTheme.h4.copyWith(
              color: ModernTheme.navy,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to exit the application?',
            style: ModernTheme.bodyMedium.copyWith(
              color: ModernTheme.mediumGray,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: ModernTheme.mediumGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernTheme.electricBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Exit'),
            ),
          ],
        );
      },
    );
  }
}