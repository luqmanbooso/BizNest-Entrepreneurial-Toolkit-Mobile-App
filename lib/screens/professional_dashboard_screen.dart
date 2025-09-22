import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/services/auth_service.dart';
import '../core/services/realtime_service.dart';
import '../core/services/business_intelligence_service.dart';
import 'business_screen.dart';
import 'learning_screen.dart';
import 'profile_screen.dart';

class ProfessionalDashboardScreen extends StatefulWidget {
  const ProfessionalDashboardScreen({super.key});

  @override
  State<ProfessionalDashboardScreen> createState() =>
      _ProfessionalDashboardScreenState();
}

class _ProfessionalDashboardScreenState extends State<ProfessionalDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();

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
                _buildAnalyticsSection(),
                _buildQuickActionsGrid(),
                _buildRecentActivity(),
                const SizedBox(height: 120), // Extra space for main screen navigation
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

  Widget _buildAnalyticsSection() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.2),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performance Analytics',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(24),
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
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Business Health Score',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Excellent',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildProgressIndicator('Overall Score', 0.87, const Color(0xFF10B981)),
                        const SizedBox(height: 12),
                        _buildProgressIndicator('Financial Health', 0.92, const Color(0xFF3B82F6)),
                        const SizedBox(height: 12),
                        _buildProgressIndicator('Market Position', 0.78, const Color(0xFF8B5CF6)),
                      ],
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

  Widget _buildProgressIndicator(String label, double progress, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
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
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                    children: [
                      _buildActionCard(
                        'Create Plan',
                        Icons.add_business,
                        const Color(0xFF3B82F6),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const BusinessScreen()),
                        ),
                      ),
                      _buildActionCard(
                        'Learn & Grow',
                        Icons.school,
                        const Color(0xFF10B981),
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LearningScreen()),
                        ),
                      ),
                      _buildActionCard(
                        'Analytics',
                        Icons.analytics,
                        const Color(0xFF8B5CF6),
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Analytics feature coming soon!')),
                          );
                        },
                      ),
                      _buildActionCard(
                        'View Profile',
                        Icons.person,
                        const Color(0xFFF59E0B),
                        _openProfile,
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              color.withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                _buildActivityItem(
                  'Business Plan Created',
                  'Tech Startup Plan completed',
                  Icons.description,
                  const Color(0xFF3B82F6),
                  '2 hours ago',
                ),
                _buildActivityItem(
                  'ROI Calculated',
                  'Project Alpha analysis done',
                  Icons.calculate,
                  const Color(0xFF10B981),
                  '5 hours ago',
                ),
                _buildActivityItem(
                  'Learning Module',
                  'Marketing Strategies completed',
                  Icons.school,
                  const Color(0xFF8B5CF6),
                  '1 day ago',
                ),
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
      height: 75,
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                Icons.analytics,
                'Analytics',
                3,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Analytics coming soon!')),
                  );
                },
              ),
              _buildNavItem(
                Icons.person,
                'Profile',
                4,
                _openProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, VoidCallback onTap) {
    final isActive = index == 0; // Home is always active in dashboard
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                )
              : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFF64748B),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
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
}