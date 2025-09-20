import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:shimmer/shimmer.dart';
import '../core/theme/modern_theme.dart';
import '../core/services/auth_service.dart';
import '../core/services/realtime_service.dart';
import '../core/services/business_intelligence_service.dart';
import 'business_screen.dart';
import 'learning_screen.dart';
import 'profile_screen.dart';
import 'financial_screen.dart';
import 'networking_screen.dart';

class UltraModernDashboardScreen extends StatefulWidget {
  const UltraModernDashboardScreen({super.key});

  @override
  State<UltraModernDashboardScreen> createState() =>
      _UltraModernDashboardScreenState();
}

class _UltraModernDashboardScreenState extends State<UltraModernDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  // removed floating animation since background is static
  // pulse animation removed (no longer used in header)

  // Data variables
  Map<String, dynamic> _insights = {};
  // analytics field currently unused in this screen
  bool _isLoading = true;
  int _selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDashboardData();
    _setupRealtimeUpdates();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final insights = await BusinessIntelligenceService.generateInsights();
      if (mounted) {
        setState(() {
          _insights = insights;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
    ));

    _slideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    // floating animation removed; background is static now

    _mainController.forward();
    // Do not repeat floating controller — we will use a static background (no motion)
    // _floatingController.repeat();
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
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _openProfile() async {
    final result = await Navigator.of(context).push<bool?>(
      MaterialPageRoute(builder: (_) => ProfileScreen()),
    );
    // If profile was saved/updated, refresh local view
    if (result == true) {
      // reload user data if AuthService provides an async getter
      try {
        await AuthService.getUserProfile();
      } catch (_) {}
      if (mounted) setState(() {});
    }
  }

  void _openSettings() {
    // placeholder — navigate to settings screen when available
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading ? _buildLoadingState() : _buildProfessionalDashboard(),
    );
  }

  Widget _buildUltraModernBackground() {
    // Static background: gradient with responsive orbs (using LayoutBuilder)
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      // size caps to keep orbs reasonable on very large screens
      final largeSize = math.min(w * 0.45, 320).toDouble();
      final mediumSize = math.min(w * 0.28, 220).toDouble();
      final smallSize = math.min(w * 0.16, 140).toDouble();

      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE3F2FD),
              Color(0xFFF1F8E9),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Large static orb placed top-right responsively
            Align(
              alignment: const Alignment(0.9, -0.6),
              child: Container(
                width: largeSize,
                height: largeSize,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      ModernTheme.primaryBlue.withOpacity(0.08),
                      ModernTheme.primaryBlue.withOpacity(0.03),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Medium static orb placed bottom-left responsively
            Align(
              alignment: const Alignment(-0.9, 0.7),
              child: Container(
                width: mediumSize,
                height: mediumSize,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      ModernTheme.teal.withOpacity(0.08),
                      ModernTheme.teal.withOpacity(0.03),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Small static orb placed lower-left / center-left responsively
            Align(
              alignment: const Alignment(-0.4, 0.05),
              child: Container(
                width: smallSize,
                height: smallSize,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      ModernTheme.freshGreen.withOpacity(0.08),
                      ModernTheme.freshGreen.withOpacity(0.03),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Grid pattern overlay
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(spacing: 56.0),
              ),
            ),
          ],
        ),
      );
    });
  }

  // Floating elements removed — background simplified to a static gradient

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            height: 200,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  height: 120,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalDashboard() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Professional App Bar
        _buildProfessionalAppBar(),
        
        // Welcome Section
        SliverToBoxAdapter(
          child: _buildWelcomeSection(),
        ),
        
        // Business Metrics Cards
        SliverToBoxAdapter(
          child: _buildBusinessMetrics(),
        ),
        
        // Charts and Analytics
        SliverToBoxAdapter(
          child: _buildAnalyticsSection(),
        ),
        
        // Quick Actions
        SliverToBoxAdapter(
          child: _buildQuickActionsGrid(),
        ),
        
        // Recent Activity
        SliverToBoxAdapter(
          child: _buildRecentActivity(),
        ),
        
        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  // Professional Dashboard Methods
  Widget _buildProfessionalAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              'assets/images/biznest.png',
                              width: 40,
                              height: 40,
                              errorBuilder: (ctx, err, stack) => const Icon(
                                Icons.business_center,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'BizNest',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildAppBarAction(Icons.notifications_outlined, () {}),
                          const SizedBox(width: 8),
                          _buildAppBarAction(Icons.settings_outlined, _openSettings),
                          const SizedBox(width: 8),
                          _buildProfileAvatar(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: _openProfile,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        ),
        child: const Icon(
          Icons.person,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              // Increased top margin so header sits below the top bar overlay
              margin: const EdgeInsets.fromLTRB(16, 72, 16, 12),
              child: Column(
                children: [
                  // Ultra Modern Glassmorphism Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.9),
                          Colors.white.withOpacity(0.8),
                          Colors.white.withOpacity(0.7),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: ModernTheme.primaryBlue.withOpacity(0.1),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: ModernTheme.primaryBlue.withOpacity(0.1),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                          spreadRadius: -8,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      child: BackdropFilter(
                        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Builder(builder: (context) {
                                          final user = AuthService.currentUser;
                                          final name = user == null
                                              ? 'there'
                                              : (user['name'] ??
                                                  user['full_name'] ??
                                                  user['displayName'] ??
                                                  'there');
                                          return Text(
                                            'Welcome back, $name!',
                                            style: const TextStyle(
                                              color: ModernTheme.textPrimary,
                                              fontSize: 28,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -0.5,
                                              height: 1.1,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              ModernTheme.primaryBlue
                                                  .withOpacity(0.1),
                                              ModernTheme.primaryBlue
                                                  .withOpacity(0.05),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: ModernTheme.primaryBlue
                                                .withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: const Text(
                                          '👋',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Ready to grow your business?',
                                    style: TextStyle(
                                      color: ModernTheme.textSecondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                      height: 1.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Inner header actions removed (top bar provides settings/profile)
                            const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Modern Stats Row
                  _buildModernStatsRow(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernStatsRow() {
    // Stat cards removed: keep minimal vertical space so top tabs remain visible.
    return const SizedBox.shrink();
  }

  // Stat cards helper removed; no inline widget fragments remain here.

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ModernTheme.primaryBlue.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: -6,
          ),
          BoxShadow(
            color: ModernTheme.primaryBlue.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Row(
            children: [
              _buildUltraModernTabButton('Overview', 0),
              _buildUltraModernTabButton('Analytics', 1),
              _buildUltraModernTabButton('Insights', 2),
              _buildUltraModernTabButton('Trends', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUltraModernTabButton(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      ModernTheme.primaryBlue,
                      ModernTheme.teal,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: ModernTheme.primaryBlue.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      spreadRadius: -5,
                    ),
                  ]
                : null,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.3,
              color: isSelected ? Colors.white : ModernTheme.textSecondary,
              shadows: isSelected
                  ? [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) {
        final offset = Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        ));
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: IndexedStack(
        key: ValueKey(_selectedTabIndex),
        index: _selectedTabIndex,
        children: [
          _buildOverviewTab(),
          _buildAnalyticsTab(),
          _buildInsightsTab(),
          _buildTrendsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: const Color(0xFF00D4FF),
      backgroundColor: Colors.white,
      strokeWidth: 3.0,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        controller: _scrollController,
        child: Column(
          children: [
            _buildBusinessHealthCard(),
            const SizedBox(height: 20),
            _buildRecentActivityCard(),
            const SizedBox(height: 20),
            _buildQuickActionsCard(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessHealthCard() {
    final health = _insights['business_health'] as Map<String, dynamic>? ?? {};
    final healthScore = health['health_score'] ?? 0;
    final healthLevel = health['health_level'] ?? 'Unknown';

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 16),
            spreadRadius: -8,
          ),
          BoxShadow(
            color: _getHealthColor(healthScore).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
        border: Border.all(
          color: _getHealthColor(healthScore).withOpacity(0.08),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Business Health',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: ModernTheme.navy,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getHealthColor(healthScore).withOpacity(0.1),
                      _getHealthColor(healthScore).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getHealthColor(healthScore).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  healthLevel,
                  style: TextStyle(
                    color: _getHealthColor(healthScore),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: _buildHealthScoreChart(healthScore),
          ),
          const SizedBox(height: 32),
          _buildHealthMetrics(health),
        ],
      ),
    );
  }

  Widget _buildHealthScoreChart(int score) {
    return Container(
      height: 180,
      width: 180,
      child: Stack(
        children: [
          // Background circle
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[50],
              border: Border.all(
                color: Colors.grey[200]!,
                width: 2,
              ),
            ),
          ),
          // Progress circle
          CustomPaint(
            size: const Size(180, 180),
            painter: _HealthRingPainter(
              progress: score / 100,
              color: _getHealthColor(score),
            ),
          ),
          // Center content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$score',
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: ModernTheme.navy,
                    letterSpacing: -1.0,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getHealthLevel(score),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ModernTheme.textSecondary,
                    letterSpacing: 0.4,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetrics(Map<String, dynamic> health) {
    final strengths = health['strengths'] as List<dynamic>? ?? [];
    final weaknesses = health['weaknesses'] as List<dynamic>? ?? [];

    return Column(
      children: [
        if (strengths.isNotEmpty) ...[
          _buildMetricSection('Strengths', strengths, ModernTheme.freshGreen),
          const SizedBox(height: 16),
        ],
        if (weaknesses.isNotEmpty) ...[
          _buildMetricSection(
              'Areas for Improvement', weaknesses, ModernTheme.sunsetOrange),
        ],
      ],
    );
  }

  Widget _buildMetricSection(String title, List<dynamic> items, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                color == ModernTheme.freshGreen
                    ? Icons.trending_up
                    : Icons.priority_high,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.take(3).map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      color == ModernTheme.freshGreen
                          ? Icons.check_circle
                          : Icons.info_outline,
                      size: 16,
                      color: color,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: ModernTheme.navy,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 16),
            spreadRadius: -8,
          ),
          BoxShadow(
            color: ModernTheme.electricBlue.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: ModernTheme.navy,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          _buildActivityItem(
            'Business Plan Created',
            'New plan for Tech Startup',
            '2 hours ago',
            ModernTheme.electricBlue,
            Icons.business_center_rounded,
          ),
          _buildActivityItem(
            'Learning Module Completed',
            'Marketing Fundamentals',
            '1 day ago',
            ModernTheme.freshGreen,
            Icons.school_rounded,
          ),
          _buildActivityItem(
            'Milestone Achieved',
            'Market Research Complete',
            '3 days ago',
            ModernTheme.goldenYellow,
            Icons.flag_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ModernTheme.navy,
                    letterSpacing: -0.2,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: ModernTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: ModernTheme.textTertiary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: -6,
          ),
          BoxShadow(
            color: const Color(0xFF00D4FF).withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.3,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(builder: (context, constraints) {
                // Choose grid layout based on available width for better
                // responsiveness: on narrow screens keep 2 columns, on wide
                // screens allow 3.
                final width = constraints.maxWidth;
                final crossAxisCount = width > 700 ? 3 : 2;
                // childAspectRatio tuned so cards have comfortable height on
                // different widths.
                final childAspectRatio =
                    width > 900 ? 1.25 : (width > 700 ? 1.18 : 1.05);

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: childAspectRatio,
                  children: [
                    _buildActionCard(
                      'New Plan',
                      Icons.add_business_rounded,
                      const Color(0xFF00D4FF),
                      () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => BusinessScreen()),
                      ),
                    ),
                    _buildActionCard(
                      'Learn',
                      Icons.school_rounded,
                      const Color(0xFF10B981),
                      () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => LearningScreen()),
                      ),
                    ),
                    _buildActionCard(
                      'Analytics',
                      Icons.analytics_rounded,
                      const Color(0xFF7C3AED),
                      () => setState(() => _selectedTabIndex = 1),
                    ),
                    _buildActionCard(
                      'Insights',
                      Icons.lightbulb_rounded,
                      const Color(0xFFF59E0B),
                      () => setState(() => _selectedTabIndex = 2),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // quick-actions modal and helper removed (unused after FAB deletion)

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 92, minWidth: 92),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.08), color.withOpacity(0.04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.14),
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Semantics(
                  button: true,
                  label: title,
                  child: Tooltip(
                    message: title,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    // Compose a small internal tab UI for Analytics: Usage | Performance | Trends
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: ModernTheme.electricBlue.withOpacity(0.12),
                ),
                labelColor: ModernTheme.navy,
                unselectedLabelColor: ModernTheme.textTertiary,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Usage'),
                  Tab(text: 'Performance'),
                  Tab(text: 'Trends'),
                ],
                isScrollable: false,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Tab content area
          Expanded(
            child: TabBarView(
              children: [
                // Usage tab: reuse existing usage chart inside a scroll view
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildUsageChart(),
                    ],
                  ),
                ),

                // Performance tab: reuse performance metrics
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildPerformanceMetrics(),
                    ],
                  ),
                ),

                // Trends tab: small placeholders or compact cards
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Trends & Forecast',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: ModernTheme.navy,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Short term and long term trend cards will be shown here. Use charts to show moving averages, growth rates and seasonality.',
                              style: TextStyle(
                                fontSize: 14,
                                color: ModernTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageChart() {
    // Attempt to read a numeric series from insights (financial_forecast -> forecast)
    final forecast =
        (_insights['financial_forecast']?['forecast'] as List<dynamic>?)
                ?.map<double>((e) {
              if (e is Map<String, dynamic>) {
                final v = e['revenue'] ?? e['value'] ?? e['y'];
                if (v is num) return v.toDouble();
              }
              return 0.0;
            }).toList() ??
            // Fallback sample series (12 months)
            [50, 62, 58, 72, 80, 95, 110, 105, 125, 140, 155, 170];

    final labels =
        (_insights['financial_forecast']?['forecast'] as List<dynamic>?)
                ?.map<String>((e) {
              if (e is Map<String, dynamic>) {
                final m = e['month']?.toString() ?? e['label']?.toString();
                return m ?? '';
              }
              return '';
            }).toList() ??
            [
              'Jan',
              'Feb',
              'Mar',
              'Apr',
              'May',
              'Jun',
              'Jul',
              'Aug',
              'Sep',
              'Oct',
              'Nov',
              'Dec'
            ];

    final total = forecast.fold<double>(0.0, (s, v) => s + v);
    final avg = forecast.isNotEmpty ? total / forecast.length : 0.0;
    final growth = forecast.length >= 2
        ? ((forecast.last - forecast.first) /
            (forecast.first == 0 ? 1 : forecast.first) *
            100)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feature Usage',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: ModernTheme.navy,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total',
                        style: TextStyle(color: ModernTheme.textTertiary)),
                    const SizedBox(height: 6),
                    Text(total.round().toString(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Average',
                        style: TextStyle(color: ModernTheme.textTertiary)),
                    const SizedBox(height: 6),
                    Text(avg.round().toString(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Growth',
                        style: TextStyle(color: ModernTheme.textTertiary)),
                    const SizedBox(height: 6),
                    Text('${growth.round()}%',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: growth >= 0
                                ? ModernTheme.freshGreen
                                : ModernTheme.sunsetOrange)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: _SimpleLineChart(
              values: forecast,
              labels: labels,
              color: ModernTheme.electricBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 16),
            spreadRadius: -8,
          ),
          BoxShadow(
            color: ModernTheme.electricBlue.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.08),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Metrics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: ModernTheme.navy,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          _buildMetricRow('Completion Rate', '85%', ModernTheme.freshGreen),
          _buildMetricRow('Average Score', '78', ModernTheme.electricBlue),
          _buildMetricRow('Time Saved', '12h', ModernTheme.goldenYellow),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: ModernTheme.navy,
              letterSpacing: -0.2,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab() {
    final recommendations =
        _insights['recommendations'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildRecommendationsCard(recommendations),
          const SizedBox(height: 20),
          _buildTipsCard(),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(Map<String, dynamic> recommendations) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Recommendations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: ModernTheme.navy,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          if (recommendations.isEmpty)
            const Center(
              child: Text(
                'No recommendations available',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            )
          else
            ...recommendations.entries.map((entry) => _buildRecommendationItem(
                  entry.key,
                  entry.value.toString(),
                )),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernTheme.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernTheme.primaryBlue.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ModernTheme.navy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tips & Best Practices',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: ModernTheme.navy,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          _buildTipItem(
            'Set clear goals and milestones for your business',
            Icons.flag,
          ),
          _buildTipItem(
            'Regularly review and update your business plan',
            Icons.refresh,
          ),
          _buildTipItem(
            'Stay informed about market trends and opportunities',
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ModernTheme.freshGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: ModernTheme.freshGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                fontSize: 14,
                color: ModernTheme.navy,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    final growthOps =
        _insights['growth_opportunities'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTrendsChart(),
          const SizedBox(height: 20),
          _buildGrowthOpportunities(growthOps),
        ],
      ),
    );
  }

  Widget _buildTrendsChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Market Trends',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: ModernTheme.navy,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            child: const Center(
              child: Text(
                'Trend data will be displayed here',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthOpportunities(Map<String, dynamic> opportunities) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Growth Opportunities',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: ModernTheme.navy,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          if (opportunities.isEmpty)
            const Center(
              child: Text(
                'No growth opportunities identified yet',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            )
          else
            ...opportunities.entries.map((entry) => _buildOpportunityItem(
                  entry.key,
                  entry.value.toString(),
                )),
        ],
      ),
    );
  }

  Widget _buildOpportunityItem(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernTheme.teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernTheme.teal.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ModernTheme.navy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _getHealthLevel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs Work';
  }

  Color _getHealthColor(int score) {
    if (score >= 80) return ModernTheme.freshGreen;
    if (score >= 60) return ModernTheme.teal;
    if (score >= 40) return ModernTheme.goldenYellow;
    return ModernTheme.sunsetOrange;
  }
}

class _HealthRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _HealthRingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 24) / 2;
    final strokeWidth = 12.0;

    // Draw track
    final trackPaint = Paint()
      ..color = Colors.grey[100]!
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc with gradient effect
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color,
          color.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );

    // Add inner glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..strokeWidth = strokeWidth + 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

  // Professional Dashboard Methods
  Widget _buildProfessionalAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              'assets/images/biznest.png',
                              width: 40,
                              height: 40,
                              errorBuilder: (ctx, err, stack) => const Icon(
                                Icons.business_center,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'BizNest',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildAppBarAction(Icons.notifications_outlined, () {}),
                          const SizedBox(width: 8),
                          _buildAppBarAction(Icons.settings_outlined, _openSettings),
                          const SizedBox(width: 8),
                          _buildProfileAvatar(),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: _openProfile,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        ),
        child: const Icon(
          Icons.person,
          color: Colors.white,
          size: 18,
        ),
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
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good ${_getTimeOfDayGreeting()},',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Entrepreneur 👋',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Here\'s what\'s happening with your business today',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: change.startsWith('+') 
                    ? const Color(0xFF10B981) 
                    : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
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
                    childAspectRatio: 1.5,
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
                        () => setState(() => _selectedTabIndex = 1),
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
        padding: const EdgeInsets.all(16),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
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
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
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

  Future<void> _openProfile() async {
    final result = await Navigator.of(context).push<bool?>(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
    if (result == true) {
      try {
        await AuthService.getUserProfile();
      } catch (_) {}
      if (mounted) setState(() {});
    }
  }

  void _openSettings() {
    // Settings implementation
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

class _GridPainter extends CustomPainter {
  final double spacing;

  _GridPainter({this.spacing = 56.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final step = spacing;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Simple in-file line chart widget used by the Analytics Usage tab.
class _SimpleLineChart extends StatefulWidget {
  final List<double> values;
  final List<String>? labels;
  final Color color;

  const _SimpleLineChart(
      {required this.values, this.labels, required this.color, Key? key})
      : super(key: key);

  @override
  State<_SimpleLineChart> createState() => _SimpleLineChartState();
}

class _SimpleLineChartState extends State<_SimpleLineChart> {
  int? _selectedIndex;

  void _handleTapDown(TapDownDetails details, BoxConstraints constraints) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    final w = constraints.maxWidth;
    final leftPad = 32.0;
    final rightPad = 16.0;
    final usable = w - leftPad - rightPad;
    final n = widget.values.length;
    if (n == 0) return;
    final dx = (local.dx - leftPad).clamp(0.0, usable);
    final idx = ((dx / usable) * (n - 1)).round();
    setState(() {
      _selectedIndex = idx;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        onTapDown: (d) => _handleTapDown(d, constraints),
        child: CustomPaint(
          size: Size(constraints.maxWidth, 220),
          painter: _LineChartPainter(
            values: widget.values,
            color: widget.color,
            selectedIndex: _selectedIndex,
            labels: widget.labels,
          ),
        ),
      );
    });
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final int? selectedIndex;
  final List<String>? labels;

  _LineChartPainter(
      {required this.values,
      required this.color,
      this.selectedIndex,
      this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final bg =
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12));
    final bgPaint = Paint()..color = Colors.transparent;
    canvas.drawRRect(bg, bgPaint);

    if (values.isEmpty) return;

    final leftPad = 32.0;
    final bottomPad = 28.0;
    final topPad = 12.0;
    final rightPad = 16.0;
    final usableWidth = size.width - leftPad - rightPad;
    final usableHeight = size.height - topPad - bottomPad;

    final maxV = values.reduce((a, b) => a > b ? a : b);
    final minV = values.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV) == 0 ? 1.0 : (maxV - minV);

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = leftPad + (usableWidth) * (i / (values.length - 1));
      final y =
          topPad + usableHeight - ((values[i] - minV) / range) * usableHeight;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // shadow
    final shadowPaint = Paint()
      ..color = color.withOpacity(0.12)
      ..strokeWidth = paint.strokeWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    canvas.drawPath(path.shift(const Offset(0, 6)), shadowPaint);

    // line
    paint.color = color;
    canvas.drawPath(path, paint);

    // dots
    final dotPaint = Paint()..color = color;
    for (int i = 0; i < values.length; i++) {
      final x = leftPad + (usableWidth) * (i / (values.length - 1));
      final y =
          topPad + usableHeight - ((values[i] - minV) / range) * usableHeight;
      canvas.drawCircle(Offset(x, y), i == selectedIndex ? 5.0 : 3.5, dotPaint);
    }

    // labels (x-axis)
    final textStyle = TextStyle(color: ModernTheme.textTertiary, fontSize: 10);
    final tp = TextPainter(textDirection: TextDirection.ltr);
    if (labels != null && labels!.isNotEmpty) {
      final step = (values.length / 6).ceil();
      for (int i = 0; i < values.length; i += step) {
        final x = leftPad + (usableWidth) * (i / (values.length - 1));
        tp.text = TextSpan(text: labels![i].toString(), style: textStyle);
        tp.layout();
        tp.paint(canvas, Offset(x - tp.width / 2, size.height - bottomPad + 6));
      }
    }

    // selected value tooltip
    if (selectedIndex != null &&
        selectedIndex! >= 0 &&
        selectedIndex! < values.length) {
      final i = selectedIndex!;
      final x = leftPad + (usableWidth) * (i / (values.length - 1));
      final y =
          topPad + usableHeight - ((values[i] - minV) / range) * usableHeight;
      final val = values[i].round().toString();
      final text = TextSpan(
          text: val,
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700));
      final ttp = TextPainter(text: text, textDirection: TextDirection.ltr);
      ttp.layout();
      final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x - ttp.width / 2 - 8, y - 34, ttp.width + 16, 24),
          const Radius.circular(6));
      final rpaint = Paint()..color = color;
      canvas.drawRRect(rect, rpaint);
      ttp.paint(canvas, Offset(x - ttp.width / 2, y - 30));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
