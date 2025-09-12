import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/modern_theme.dart';
import '../core/services/analytics_service.dart';
import '../core/services/realtime_service.dart';
import '../core/services/business_intelligence_service.dart';
import '../core/widgets/modern_animations.dart';
import 'business_screen.dart';
import 'learning_screen.dart';

class AdvancedDashboardScreen extends StatefulWidget {
  const AdvancedDashboardScreen({super.key});

  @override
  State<AdvancedDashboardScreen> createState() =>
      _AdvancedDashboardScreenState();
}

class _AdvancedDashboardScreenState extends State<AdvancedDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _chartController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _chartAnimation;
  late Animation<double> _floatingAnimation;

  // Data variables
  Map<String, dynamic> _insights = {};
  Map<String, dynamic> _analytics = {};
  bool _isLoading = true;
  final String _selectedTimeRange = '7d';
  int _selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();
  double _headerOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDashboardData();
    _setupRealtimeUpdates();

    _scrollController.addListener(() {
      setState(() {
        _headerOffset = (_scrollController.offset).clamp(0, 60);
      });
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _chartController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutCubic,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.linear,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
    _chartController.forward();
    _floatingController.repeat();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load insights and analytics in parallel
      final insights = await BusinessIntelligenceService.generateInsights();
      final analytics = await AnalyticsService.getUserInsights();

      setState(() {
        _insights = insights;
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setupRealtimeUpdates() {
    // Listen to real-time updates
    RealtimeService.generalStream.listen((data) {
      if (mounted) {
        _loadDashboardData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _chartController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernTheme.lightGray,
      body: Stack(
        children: [
          _buildBackgroundEffects(),
          SafeArea(
            child: _isLoading
                ? _buildLoadingState()
                : FloatingElementsAnimation(
                    elementCount: 10,
                    child: _buildDashboard(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundEffects() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -100 + 20 * math.sin(_floatingAnimation.value * math.pi * 2),
              left: -100 + 20 * math.cos(_floatingAnimation.value * math.pi),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ModernTheme.primaryBlue.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -150 + 30 * math.sin(_floatingAnimation.value * math.pi),
              right:
                  -100 + 25 * math.cos(_floatingAnimation.value * math.pi * 2),
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ModernTheme.teal.withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Subtle grid pattern
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                      'https://transparenttextures.com/patterns/grid-me.png'),
                  repeat: ImageRepeat.repeat,
                  opacity: 0.05,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          _buildShimmerHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildShimmerCard(),
                const SizedBox(height: 20),
                _buildShimmerCard(),
                const SizedBox(height: 20),
                _buildShimmerCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerHeader() {
    return Container(
      height: 140,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }

  Widget _buildDashboard() {
    return Column(
      children: [
        Transform.translate(
          offset: Offset(0, -_headerOffset * 0.3),
          child: Transform.scale(
            scale: 1.0 - (_headerOffset / 600),
            child: _buildHeader(),
          ),
        ),
        _buildTabBar(),
        Expanded(
          child: _buildTabContent(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: ModernTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          ModernTheme.primaryBlue.withOpacity(0.95),
                          ModernTheme.teal.withOpacity(0.9),
                          ModernTheme.freshGreen.withOpacity(0.85),
                        ],
                        stops: const [0.1, 0.6, 0.9],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back!',
                                  style: ModernTheme.textTheme.headlineSmall
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Here\'s your business overview',
                                  style:
                                      ModernTheme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ModernTheme.primaryBlue
                                              .withOpacity(0.3),
                                          blurRadius: 15,
                                          spreadRadius: -2,
                                        ),
                                      ],
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.25),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.trending_up,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        _buildQuickStats(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStats() {
    final overview = _insights['overview'] as Map<String, dynamic>? ?? {};
    final totalPlans = overview['total_business_plans'] ?? 0;
    final completedPlans = overview['completed_plans'] ?? 0;
    final completionRate = overview['completion_rate'] ?? 0;

    return Container(
      height: 200, // Fixed height to prevent overflow
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8, // Adjusted aspect ratio
        children: [
          _buildStatCard(
            'Business Plans',
            totalPlans.toString(),
            Icons.business_center_rounded,
            Colors.white,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BusinessScreen()),
              );
            },
          ),
          _buildStatCard(
            'Completed',
            completedPlans.toString(),
            Icons.verified_rounded,
            ModernTheme.freshGreen,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BusinessScreen()),
              );
            },
          ),
          _buildStatCard(
            'Progress',
            '$completionRate%',
            Icons.trending_up_rounded,
            ModernTheme.goldenYellow,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => LearningScreen()),
              );
            },
          ),
          _buildStatCard(
            'Health',
            _getHealthLevel(_insights['business_health']?['health_score'] ?? 0),
            Icons.favorite_rounded,
            ModernTheme.teal,
            onTap: () {
              setState(() {
                _selectedTabIndex = 1; // Analytics tab
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.8, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.2),
                          color.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: -3,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Row(
              children: [
                _buildTabButton('Overview', 0),
                _buildTabButton('Analytics', 1),
                _buildTabButton('Insights', 2),
                _buildTabButton('Trends', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      ModernTheme.primaryBlue,
                      ModernTheme.teal.withOpacity(0.85)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: ModernTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              letterSpacing: 0.5,
              color:
                  isSelected ? Colors.white : ModernTheme.navy.withOpacity(0.7),
            ),
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
                begin: const Offset(0.05, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
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
      color: ModernTheme.primaryColor,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        controller: _scrollController,
        child: Column(
          children: [
            _isLoading
                ? _buildSkeletonCard(height: 220)
                : _buildBusinessHealthCard(),
            const SizedBox(height: 20),
            _isLoading
                ? _buildSkeletonCard(height: 260)
                : _buildRecentActivityCard(),
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

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ModernTheme.primaryBlue.withOpacity(0.85),
                    ModernTheme.teal.withOpacity(0.75),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: ModernTheme.primaryBlue.withOpacity(0.25),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: -10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Business Health',
                        style: ModernTheme.headingMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                              spreadRadius: -3,
                            ),
                          ],
                        ),
                        child: Text(
                          healthLevel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(child: _buildHealthScoreChart(healthScore)),
                  const SizedBox(height: 30),
                  _buildHealthMetrics(health),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthScoreChart(int score) {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Container(
          height: 180,
          width: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ModernTheme.teal.withOpacity(0.25),
                blurRadius: 25,
                spreadRadius: 5,
              ),
            ],
          ),
          child: CustomPaint(
            painter: _HealthRingPainter(
              progress: (score / 100) * _chartAnimation.value,
              startColor: ModernTheme.freshGreen,
              endColor: ModernTheme.teal,
              trackColor: Colors.white.withOpacity(0.2),
              tickColor: Colors.white.withOpacity(0.35),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: ModernTheme.headingLarge.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 42,
                      ),
                    ),
                    Text(
                      _getHealthLevel(score),
                      style: ModernTheme.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthMetrics(Map<String, dynamic> health) {
    final strengths = health['strengths'] as List<dynamic>? ?? [];
    final weaknesses = health['weaknesses'] as List<dynamic>? ?? [];

    return Column(
      children: [
        if (strengths.isNotEmpty) ...[
          _buildMetricSection('Strengths', strengths, Colors.green),
          const SizedBox(height: 16),
        ],
        if (weaknesses.isNotEmpty) ...[
          _buildMetricSection(
              'Areas for Improvement', weaknesses, Colors.orange),
        ],
      ],
    );
  }

  Widget _buildMetricSection(String title, List<dynamic> items, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      color == Colors.green
                          ? Icons.trending_up
                          : Icons.priority_high,
                      size: 18,
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: ModernTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 20),
                ...items.take(3).map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Icon(
                              color == Colors.green
                                  ? Icons.check_circle
                                  : Icons.info_outline,
                              size: 16,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.toString(),
                              style: ModernTheme.bodyMedium.copyWith(
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivityCard() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.5),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: ModernTheme.headingMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildActivityItem(
                    'Business Plan Created',
                    'New plan for Tech Startup',
                    '2 hours ago',
                    ModernTheme.primaryBlue,
                    Icons.business_center,
                  ),
                  _buildActivityItem(
                    'Learning Module Completed',
                    'Marketing Fundamentals',
                    '1 day ago',
                    ModernTheme.freshGreen,
                    Icons.school,
                  ),
                  _buildActivityItem(
                    'Milestone Achieved',
                    'Market Research Complete',
                    '3 days ago',
                    ModernTheme.goldenYellow,
                    Icons.flag,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(
      String title, String subtitle, String time, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 20),
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
                  ),
                ),
                Text(
                  subtitle,
                  style: ModernTheme.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: ModernTheme.bodySmall.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * 0.3),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: ModernTheme.headingMedium.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildActionCard(
                        'New Plan',
                        Icons.add_business,
                        ModernTheme.primaryBlue,
                        () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => BusinessScreen()),
                        ),
                      ),
                      _buildActionCard(
                        'Learn',
                        Icons.school,
                        ModernTheme.freshGreen,
                        () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => LearningScreen()),
                        ),
                      ),
                      _buildActionCard(
                        'Analytics',
                        Icons.analytics,
                        ModernTheme.teal,
                        () => setState(() => _selectedTabIndex = 1),
                      ),
                      _buildActionCard(
                        'Insights',
                        Icons.lightbulb,
                        ModernTheme.goldenYellow,
                        () => setState(() => _selectedTabIndex = 2),
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
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: ModernTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildUsageChart(),
              const SizedBox(height: 20),
              _buildPerformanceMetrics(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUsageChart() {
    final usage = _analytics['feature_usage'] as Map<String, int>? ?? {};

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feature Usage',
            style: ModernTheme.headingMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            child: usage.isEmpty
                ? Center(child: Text('No usage data available'))
                : BarChart(
                    BarChartData(
                      // Chart configuration would go here
                      barGroups: [],
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Metrics',
            style: ModernTheme.headingMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          _buildMetricRow('Completion Rate', '85%', ModernTheme.freshGreen),
          _buildMetricRow('Average Score', '78', ModernTheme.primaryBlue),
          _buildMetricRow('Time Saved', '12h', ModernTheme.goldenYellow),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: ModernTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: ModernTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Recommendations',
            style: ModernTheme.headingMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          if (recommendations.isEmpty)
            Center(
              child: Text(
                'No recommendations available',
                style: ModernTheme.bodyMedium.copyWith(
                  color: Colors.grey[600],
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
            style: ModernTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: ModernTheme.bodyMedium.copyWith(
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
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tips & Best Practices',
            style: ModernTheme.headingMedium.copyWith(
              fontWeight: FontWeight.w800,
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
              style: ModernTheme.bodyMedium.copyWith(
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
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Market Trends',
                style: ModernTheme.headingMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 200,
                child: LineChart(
                  LineChartData(
                    // Chart configuration would go here
                    lineBarsData: [],
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGrowthOpportunities(Map<String, dynamic> opportunities) {
    final trends = _insights['trends'] as Map<String, dynamic>? ?? {};

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Growth Opportunities',
            style: ModernTheme.headingMedium.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          if (opportunities.isEmpty && trends.isEmpty)
            Center(
              child: Text(
                'No growth opportunities identified yet',
                style: ModernTheme.bodyMedium.copyWith(
                  color: Colors.grey[600],
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
            style: ModernTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: ModernTheme.bodyMedium.copyWith(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }

  String _getHealthLevel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs Work';
  }
}

class _HealthRingPainter extends CustomPainter {
  final double progress;
  final Color startColor;
  final Color endColor;
  final Color trackColor;
  final Color tickColor;

  _HealthRingPainter({
    required this.progress,
    required this.startColor,
    required this.endColor,
    required this.trackColor,
    required this.tickColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;
    final strokeWidth = 12.0;

    // Draw track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(center.dx - radius, center.dy),
        Offset(center.dx + radius, center.dy),
        [startColor, endColor],
      )
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

    // Draw tick marks
    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 2.0;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 2 * math.pi / 12) - math.pi / 2;
      final startPoint = Offset(
        center.dx + (radius - 8) * math.cos(angle),
        center.dy + (radius - 8) * math.sin(angle),
      );
      final endPoint = Offset(
        center.dx + (radius + 2) * math.cos(angle),
        center.dy + (radius + 2) * math.sin(angle),
      );
      canvas.drawLine(startPoint, endPoint, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
