import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/auth_service.dart';
import '../core/services/realtime_service.dart';
import '../core/services/business_intelligence_service.dart';
import '../core/services/mentorship_service.dart';
import '../core/services/session_service.dart';
import '../core/theme/modern_theme.dart';
import 'business_screen.dart';
import 'learning_screen.dart';
import 'profile_screen.dart';
import 'community_screen.dart';
import 'mentor_screen.dart';
import 'inbox_screen.dart';
import 'sessions_screen.dart';
import 'business_analytics_screen.dart';
import 'business_data_entry_screen.dart';
import 'collab_investment_screen.dart';

class ProfessionalDashboardScreen extends StatefulWidget {
  const ProfessionalDashboardScreen({super.key});

  @override
  State<ProfessionalDashboardScreen> createState() =>
      _ProfessionalDashboardScreenState();
}

class _ProfessionalDashboardScreenState
    extends State<ProfessionalDashboardScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  bool _isLoading = true;
  bool _hasAcceptedRequests = false;
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _recentActivities = [];

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

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      await BusinessIntelligenceService.generateInsights();
      await _checkAcceptedRequests();
      await _loadRecentActivities();
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

  Future<void> _loadRecentActivities() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      List<Map<String, dynamic>> activities = [];

      // Get recent sessions
      final sessions = await SessionService.getEntrpreneurSessions();
      for (var session in sessions.take(2)) {
        activities.add({
          'title': 'Session with ${session['mentor_name']}',
          'subtitle': session['session_title'] ?? 'Mentorship Session',
          'icon': Icons.event,
          'color': const Color(0xFF3B82F6),
          'timestamp': (session['scheduled_date'] as Timestamp).toDate(),
        });
      }

      // Get recent mentorship requests
      final requests = await MentorshipService.getMenteeRequests();
      for (var request in requests.take(2)) {
        final status = request['status'];
        activities.add({
          'title': status == 'accepted'
              ? 'Request Accepted'
              : status == 'pending'
                  ? 'Request Sent'
                  : 'Request ${status[0].toUpperCase()}${status.substring(1)}',
          'subtitle':
              'Mentorship request to ${request['mentor_info']?['mentor_name'] ?? 'mentor'}',
          'icon': status == 'accepted' ? Icons.check_circle : Icons.send,
          'color': status == 'accepted'
              ? const Color(0xFF10B981)
              : const Color(0xFF8B5CF6),
          'timestamp': (request['created_at'] as Timestamp).toDate(),
        });
      }

      // Sort by timestamp descending
      activities.sort((a, b) =>
          (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

      if (mounted) {
        setState(() {
          _recentActivities = activities.take(3).toList();
        });
      }
    } catch (e) {
      print('Error loading recent activities: $e');
      _recentActivities = [];
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _checkAcceptedRequests() async {
    try {
      // For entrepreneurs (mentees), check their own requests
      final requests = await MentorshipService.getMenteeRequests();
      final hasAccepted =
          requests.any((request) => request['status'] == 'accepted');
      print(
          '🔍 [ProfessionalDashboard] Found ${requests.length} mentee requests, hasAccepted: $hasAccepted');
      if (mounted) {
        setState(() {
          _hasAcceptedRequests = hasAccepted;
        });
        print(
            '🔍 [ProfessionalDashboard] Updated _hasAcceptedRequests to: $_hasAcceptedRequests');
      }
    } catch (e) {
      print('❌ [ProfessionalDashboard] Error checking accepted requests: $e');
      // Handle error silently, inbox will remain hidden
    }
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
    _scrollController.dispose();
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: _isLoading ? _buildLoadingState() : _buildModernDashboard(),
      bottomNavigationBar: _buildModernNavigationBar(),
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDashboard() {
    return Column(
      children: [
        _buildModernFixedHeader(),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildWelcomeSection(),
                _buildBusinessMetrics(),
                _buildQuickActionsGrid(),
                _buildRecentActivity(),
                const SizedBox(
                    height: 120), // Extra space for main screen navigation
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernFixedHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2563EB),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A2563EB),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
          child: Row(
            children: [
              Transform.translate(
                offset: const Offset(0, -8),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/images/biznest.png',
                    width: 100,
                    height: 80,
                    errorBuilder: (ctx, err, stack) => const Icon(
                      Icons.business_center,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              _buildModernHeaderAction(Icons.notifications_none, () {}),
              const SizedBox(width: 8),
              _buildModernHeaderAction(Icons.settings_outlined, _openSettings),
              const SizedBox(width: 8),
              _buildModernProfileAvatar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeaderAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildModernProfileAvatar() {
    return GestureDetector(
      onTap: _openProfile,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF10B981),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        ),
        child: const Icon(Icons.person, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.5),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 25, 20, 0),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFFBEB),
                    Color(0xFFFEF3C7),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good ${_getTimeOfDayGreeting()},',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF92400E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Entrepreneur! 👋',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF92400E),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your business is growing strong today',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFA16207),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.rocket_launch,
                      color: Colors.white,
                      size: 28,
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

  String _getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildBusinessMetrics() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.3),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Business Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          'Revenue',
                          '\$24,580',
                          '+12.5%',
                          Icons.trending_up,
                          const Color(0xFF10B981),
                          const Color(0xFFECFDF5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          'Growth',
                          '28.4%',
                          '+5.2%',
                          Icons.analytics,
                          const Color(0xFF3B82F6),
                          const Color(0xFFEFF6FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          'Customers',
                          '1,247',
                          '+18.3%',
                          Icons.people,
                          const Color(0xFF8B5CF6),
                          const Color(0xFFF3E8FF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(
                          'Plans Active',
                          '6',
                          'This month',
                          Icons.description,
                          const Color(0xFFF59E0B),
                          const Color(0xFFFEF3C7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String change,
    IconData icon,
    Color iconColor,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [iconColor, iconColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: change.startsWith('+')
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFF64748B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: change.startsWith('+')
                        ? const Color(0xFF10B981)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.1),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _buildActionCard(
                        'Find Mentor',
                        Icons.person_search,
                        const Color(0xFF3B82F6),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MentorScreen()),
                        ),
                      ),
                      _buildActionCard(
                        'My Sessions',
                        Icons.event_note,
                        const Color(0xFF10B981),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const SessionsScreen(isMentor: false)),
                        ),
                      ),
                      _buildActionCard(
                        'Business Plan',
                        Icons.add_business,
                        const Color(0xFF8B5CF6),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const BusinessScreen()),
                        ),
                      ),
                      _buildActionCard(
                        'Learn & Grow',
                        Icons.school,
                        const Color(0xFFF59E0B),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LearningScreen()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circle in background
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: -10,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Tap to open',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E293B).withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                if (_recentActivities.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.history,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No recent activity',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._recentActivities.map((activity) {
                    final DateTime timestamp = activity['timestamp'];
                    final String timeAgo = _getTimeAgo(timestamp);

                    return _buildActivityItem(
                      activity['title'],
                      activity['subtitle'],
                      activity['icon'],
                      activity['color'],
                      timeAgo,
                    );
                  }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernNavigationBar() {
    return Container(
      height: 90, // Increased from 75 to accommodate larger icons/text
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16), // Adjusted for 5 items
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                Icons.home,
                'Home',
                0,
                () {},
              ),
              _buildNavItem(
                Icons.business_center,
                'Business',
                1,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BusinessScreen()),
                ),
              ),
              _buildNavItem(
                Icons.school,
                'Learn',
                2,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LearningScreen()),
                ),
              ),
              _buildNavItem(
                Icons.account_balance,
                'Finance',
                3,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CollabInvestmentScreen()),
                ),
              ),
              _buildNavItem(
                Icons.menu,
                'More',
                4,
                () => _showSideMenu(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, int index, VoidCallback onTap) {
    final isActive = index == 0; // Home is always active in dashboard
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4), // Increased padding for larger icons/text
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFF64748B),
              size: 20, // Increased from 12
            ),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF64748B),
                fontSize: 10, // Increased from 6
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openProfile() async {
    final result = await Navigator.of(context).push<bool?>(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
    if (result == true && mounted) {
      try {
        await AuthService.getUserProfile();
      } catch (_) {}
      setState(() {});
    }
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: const Text('Settings feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSideMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        width: MediaQuery.of(context).size.width * 0.8,
        margin: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.2,
          top: 120,
          bottom: 40,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Menu',
                    style: ModernTheme.headingMedium.copyWith(
                      color: ModernTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildMenuItem(
                    Icons.people,
                    'Community',
                    'Connect with entrepreneurs',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CommunityScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    Icons.school,
                    'Mentors',
                    'Find expert guidance',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MentorScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    Icons.data_usage,
                    'Manage Business Data',
                    'Add your real business metrics',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BusinessDataEntryScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    Icons.analytics,
                    'Analytics',
                    'View business insights and reports',
                    () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BusinessAnalyticsScreen()),
                      );
                    },
                  ),
                  if (_hasAcceptedRequests) ...[
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      Icons.event_note,
                      'Sessions',
                      'View your mentorship sessions',
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const SessionsScreen(isMentor: false)),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuItem(
                      Icons.chat_bubble_outline,
                      'Messages',
                      'Chat with your mentors',
                      () {
                        print(
                            '🔍 [ProfessionalDashboard] Messages menu tapped');
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const InboxScreen()),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ModernTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: ModernTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ModernTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ModernTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: ModernTheme.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
