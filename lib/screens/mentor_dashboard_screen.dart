import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme/modern_theme.dart';
import '../core/services/auth_service.dart';
import '../core/services/realtime_service.dart';
import '../core/services/session_service.dart';
import 'mentorship_requests_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';
import 'inbox_screen.dart';
import 'schedule_session_screen.dart';
import 'sessions_screen.dart';

class MentorDashboardScreen extends StatefulWidget {
  const MentorDashboardScreen({super.key});

  @override
  State<MentorDashboardScreen> createState() => _MentorDashboardScreenState();
}

class _MentorDashboardScreenState extends State<MentorDashboardScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupAnimations();
    _loadDashboardData();
    _setupRealtimeUpdates();
    // Set status bar when dashboard is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setDashboardStatusBar();
    });
  }

  void _setDashboardStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: ModernTheme.electricBlue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  void _resetStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app resumes and we're on dashboard, restore status bar
    if (state == AppLifecycleState.resumed) {
      _setDashboardStatusBar();
    }
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

  List<Map<String, dynamic>> _recentRequests = [];
  List<Map<String, dynamic>> _upcomingSessions = [];
  int _menteesHelpedCount = 0;
  int _totalSessionsCount = 0;

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Load mentor-specific data
      await _loadRecentRequests();
      await _loadUpcomingSessions();
      await _loadMenteesCount();
      await _loadSessionsCount();
      
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

  Future<void> _loadMenteesCount() async {
    try {
      // Get all sessions for this mentor and filter on client side
      final querySnapshot = await FirebaseFirestore.instance
          .collection('sessions')
          .where('mentor_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();
      
      // Filter for completed sessions and get unique mentee IDs
      final uniqueMentees = <String>{};
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data['status'] == 'completed') {
          final menteeId = data['mentee_id'];
          if (menteeId != null) {
            uniqueMentees.add(menteeId);
          }
        }
      }
      
      _menteesHelpedCount = uniqueMentees.length;
      print('✅ Mentees helped count: $_menteesHelpedCount');
    } catch (e) {
      print('❌ Error loading mentees count: $e');
      _menteesHelpedCount = 0;
    }
  }

  Future<void> _loadSessionsCount() async {
    try {
      // Get all sessions for this mentor and filter on client side
      final querySnapshot = await FirebaseFirestore.instance
          .collection('sessions')
          .where('mentor_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();
      
      // Count only completed sessions
      _totalSessionsCount = querySnapshot.docs.where((doc) {
        return doc.data()['status'] == 'completed';
      }).length;
      
      print('✅ Total sessions count: $_totalSessionsCount');
    } catch (e) {
      print('❌ Error loading sessions count: $e');
      _totalSessionsCount = 0;
    }
  }

  Future<void> _loadRecentRequests() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userRole = await _getCurrentUserRole();
      print('🔍 Loading recent requests for mentor: ${currentUser?.uid}');
      print('🔍 Current user role: $userRole');
      
      if (currentUser == null) {
        print('❌ No current user found');
        _recentRequests = [];
        return;
      }

      if (userRole != 'mentor') {
        print('❌ Current user is not a mentor (role: $userRole)');
        _recentRequests = [];
        return;
      }

      // Fetch real mentorship requests from Firebase
      final querySnapshot = await FirebaseFirestore.instance
          .collection('mentorship_requests')
          .where('mentor_id', isEqualTo: currentUser.uid)
          .orderBy('created_at', descending: true)
          .limit(4)
          .get();
      
      print('📊 Found ${querySnapshot.docs.length} mentorship requests');
      
      _recentRequests = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print('📋 Request ${doc.id}: ${data['mentee_info']?['name']} - ${data['status']}');
        return {
          'id': doc.id,
          'mentee_name': data['mentee_info']?['name'] ?? 'Unknown',
          'mentee_avatar': 'https://ui-avatars.com/api/?name=${data['mentee_info']?['name']?.replaceAll(' ', '+') ?? 'User'}&background=random',
          'business_name': data['mentee_info']?['business_name'] ?? '',
          'request_type': data['request_type'] ?? 'Mentorship',
          'timestamp': (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'status': data['status'] ?? 'pending',
        };
      }).toList();
      
      print('✅ Loaded ${_recentRequests.length} recent requests');
    } catch (e) {
      print('❌ Error loading recent requests: $e');
      _recentRequests = [];
    }
  }

  Future<String?> _getCurrentUserRole() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return null;
      
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      
      return userDoc.data()?['role'];
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  Future<void> _loadUpcomingSessions() async {
    try {
      final sessions = await SessionService.getUpcomingSessions(isMentor: true);
      print('📊 Loaded ${sessions.length} upcoming sessions for dashboard');
      _upcomingSessions = sessions.map((session) {
        return {
          'id': session['id'],
          'mentee_name': session['mentee_name'],
          'business_name': '', // Can be added if needed
          'session_type': session['session_title'],
          'scheduled_date': (session['scheduled_date'] as Timestamp).toDate(),
          'scheduled_time': session['scheduled_time'], // Store the time string
          'duration': session['duration_minutes'],
          'meeting_link': session['meeting_link'],
        };
      }).toList();
    } catch (e) {
      print('Error loading upcoming sessions: $e');
      _upcomingSessions = [];
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
    WidgetsBinding.instance.removeObserver(this);
    _mainController.dispose();
    _scrollController.dispose();
    _resetStatusBar();
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
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF1F5F9),
        drawer: _buildSidebar(),
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
            child: _buildDashboardContent(),
          ),
        );
      },
    );
  }

  Widget _buildDashboardContent() {
    return SafeArea(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildWelcomeSection(),
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
      toolbarHeight: 80,
      floating: false,
      pinned: true,
      snap: false,
      backgroundColor: ModernTheme.electricBlue,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        width: double.infinity,
        height: 80,
        decoration: const BoxDecoration(
          color: ModernTheme.electricBlue,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
                children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withOpacity(0.3),
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
              _buildImpactStat('$_menteesHelpedCount', 'Mentees Helped'),
              const SizedBox(width: 24),
              _buildImpactStat('$_totalSessionsCount', 'Sessions'),
              const SizedBox(width: 24),
              _buildImpactStat('${_upcomingSessions.length}', 'Upcoming'),
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
                  _resetStatusBar();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScheduleSessionScreen()),
                  ).then((_) => _setDashboardStatusBar());
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
                  _resetStatusBar();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MentorshipRequestsScreen()),
                  ).then((_) => _setDashboardStatusBar());
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
                  _resetStatusBar();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InboxScreen()),
                  ).then((_) => _setDashboardStatusBar());
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'View Sessions',
                Icons.event_note,
                ModernTheme.freshGreen,
                () {
                  _resetStatusBar();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SessionsScreen()),
                  ).then((_) => _setDashboardStatusBar());
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
          child: _recentRequests.isEmpty 
            ? Padding(
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
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _recentRequests.length > 4 ? 4 : _recentRequests.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final request = _recentRequests[index];
                  String timeAgo = _getTimeAgo(request['timestamp']);
                  IconData activityIcon = request['status'] == 'pending' 
                    ? Icons.person_add 
                    : Icons.check_circle;
                  Color activityColor = request['status'] == 'pending' 
                    ? ModernTheme.sunsetOrange 
                    : ModernTheme.freshGreen;
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: activityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(activityIcon, color: activityColor, size: 24),
                    ),
                    title: Text(
                      request['mentee_name'],
                      style: ModernTheme.bodyMedium.copyWith(
                        color: ModernTheme.navy,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'New ${request['request_type']} • $timeAgo',
                      style: ModernTheme.bodySmall.copyWith(
                        color: ModernTheme.mediumGray,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: request['status'] == 'pending' 
                          ? ModernTheme.sunsetOrange.withOpacity(0.1)
                          : ModernTheme.freshGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        request['status'] == 'pending' ? 'Pending' : 'Accepted',
                        style: ModernTheme.bodySmall.copyWith(
                          color: request['status'] == 'pending' 
                            ? ModernTheme.sunsetOrange
                            : ModernTheme.freshGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
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

  String _formatSessionTime(DateTime scheduledDate, String timeString) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final sessionDate = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);
    
    if (sessionDate == today) {
      return 'Today at $timeString';
    } else if (sessionDate == tomorrow) {
      return 'Tomorrow at $timeString';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[scheduledDate.month - 1]} ${scheduledDate.day} at $timeString';
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
                  String formattedTime = _formatSessionTime(
                    session['scheduled_date'] as DateTime,
                    session['scheduled_time'] as String,
                  );
                  
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
              _buildNavItem(Icons.menu, 'Menu', 3),
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
        if (index == 0) {
          // Already on dashboard, do nothing
          return;
        } else if (index == 1) {
          // Navigate to Mentorship Requests
          _resetStatusBar();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MentorshipRequestsScreen()),
          ).then((_) => _setDashboardStatusBar());
        } else if (index == 2) {
          // Navigate to Community
          _resetStatusBar();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CommunityScreen()),
          ).then((_) => _setDashboardStatusBar());
        } else if (index == 3) {
          // Open menu drawer
          _scaffoldKey.currentState?.openDrawer();
        }
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

  Widget _buildSidebar() {
    return Drawer(
      backgroundColor: Colors.white,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ModernTheme.primaryBlue,
              ModernTheme.teal,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Mentor Dashboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Manage your mentoring journey',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Menu Items
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildSidebarItem(
                          Icons.event_available,
                          'Schedule Session',
                          'Create a new mentorship session',
                          () {
                            Navigator.pop(context);
                            _resetStatusBar();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ScheduleSessionScreen(),
                              ),
                            ).then((_) {
                              _setDashboardStatusBar();
                              _loadDashboardData(); // Refresh dashboard data
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildSidebarItem(
                          Icons.chat_bubble_outline,
                          'Inbox',
                          'Chat with your mentees',
                          () {
                            Navigator.pop(context);
                            _resetStatusBar();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const InboxScreen(),
                              ),
                            ).then((_) => _setDashboardStatusBar());
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildSidebarItem(
                          Icons.event_note,
                          'My Sessions',
                          'View all your mentorship sessions',
                          () {
                            Navigator.pop(context);
                            _resetStatusBar();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SessionsScreen(isMentor: true),
                              ),
                            ).then((_) => _setDashboardStatusBar());
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildSidebarItem(
                          Icons.person_outline,
                          'Profile',
                          'View and edit your profile',
                          () {
                            Navigator.pop(context);
                            _resetStatusBar();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            ).then((_) => _setDashboardStatusBar());
                          },
                        ),
                        const Spacer(),
                        _buildSidebarItem(
                          Icons.logout,
                          'Sign Out',
                          'Sign out of your account',
                          () async {
                            Navigator.pop(context);
                            await AuthService.logout();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? Colors.red.withOpacity(0.1)
                      : ModernTheme.electricBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isDestructive
                      ? Colors.red
                      : ModernTheme.electricBlue,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? Colors.red
                            : ModernTheme.navy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: ModernTheme.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: ModernTheme.mediumGray,
              ),
            ],
          ),
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