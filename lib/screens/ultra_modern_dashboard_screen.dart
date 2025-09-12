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
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;

  // Data variables
  Map<String, dynamic> _insights = {};
  Map<String, dynamic> _analytics = {};
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

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _mainController.forward();
    _floatingController.repeat();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          _buildUltraModernBackground(),
          _buildFloatingElements(),
          SafeArea(
            child: _isLoading
                ? _buildLoadingState()
                : _buildDashboard(),
          ),
        ],
      ),
    );
  }

  Widget _buildUltraModernBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0E1A),
            Color(0xFF1A1F3A),
            Color(0xFF0F1419),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated gradient orbs
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Large floating orb
                  Positioned(
                    top: 50 + 100 * math.sin(_floatingAnimation.value * math.pi * 2),
                    right: -100 + 80 * math.cos(_floatingAnimation.value * math.pi),
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF00D4FF).withOpacity(0.15),
                            const Color(0xFF00D4FF).withOpacity(0.05),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.7, 1.0],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Medium floating orb
                  Positioned(
                    bottom: 150 + 60 * math.sin(_floatingAnimation.value * math.pi),
                    left: -80 + 50 * math.cos(_floatingAnimation.value * math.pi * 2),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF7C3AED).withOpacity(0.12),
                            const Color(0xFF7C3AED).withOpacity(0.04),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Small floating orb
                  Positioned(
                    top: 200 + 80 * math.sin(_floatingAnimation.value * math.pi * 1.5),
                    left: 50 + 40 * math.cos(_floatingAnimation.value * math.pi),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF10B981).withOpacity(0.1),
                            const Color(0xFF10B981).withOpacity(0.03),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          // Grid pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingElements() {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Floating particles
            for (int i = 0; i < 8; i++)
              Positioned(
                top: 100 + (i * 100) + 30 * math.sin(_floatingAnimation.value * math.pi * 2 + i),
                left: 50 + (i * 50) + 20 * math.cos(_floatingAnimation.value * math.pi + i),
                child: Container(
                  width: 4 + (i % 3),
                  height: 4 + (i % 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D4FF).withOpacity(0.6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D4FF).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
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

  Widget _buildDashboard() {
    return Column(
      children: [
        _buildModernHeader(),
        _buildTabBar(),
        Expanded(
          child: _buildTabContent(),
        ),
      ],
    );
  }

  Widget _buildModernHeader() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                          const Color(0xFF00D4FF).withOpacity(0.2),
                          const Color(0xFF7C3AED).withOpacity(0.15),
                          const Color(0xFF10B981).withOpacity(0.1),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D4FF).withOpacity(0.2),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                          spreadRadius: -8,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
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
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Welcome back!',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.5,
                                            height: 1.1,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.2),
                                              Colors.white.withOpacity(0.1),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.3),
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
                                      color: Colors.white.withOpacity(0.9),
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
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.2),
                                          Colors.white.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.1),
                                          blurRadius: 16,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.rocket_launch_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                );
                              },
                            ),
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
    final overview = _insights['overview'] as Map<String, dynamic>? ?? {};
    final totalPlans = overview['total_business_plans'] ?? 0;
    final completedPlans = overview['completed_plans'] ?? 0;
    final completionRate = overview['completion_rate'] ?? 0;
    final healthScore = _insights['business_health']?['health_score'] ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildUltraModernStatCard(
            'Business',
            totalPlans.toString(),
            Icons.business_center_rounded,
            const Color(0xFF00D4FF),
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BusinessScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildUltraModernStatCard(
            'Done',
            completedPlans.toString(),
            Icons.check_circle_rounded,
            const Color(0xFF10B981),
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BusinessScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildUltraModernStatCard(
            'Progress',
            '$completionRate%',
            Icons.trending_up_rounded,
            const Color(0xFFF59E0B),
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => LearningScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildUltraModernStatCard(
            'Health',
            _getHealthLevel(healthScore),
            Icons.favorite_rounded,
            const Color(0xFF7C3AED),
            () {
              setState(() {
                _selectedTabIndex = 1;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUltraModernStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 12),
              spreadRadius: -6,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.2),
                        color.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    height: 1.0,
                    shadows: [
                      Shadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    height: 1.2,
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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
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
                      const Color(0xFF00D4FF),
                      const Color(0xFF7C3AED),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF00D4FF).withOpacity(0.3),
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
              color: isSelected
                  ? Colors.white
                  : Colors.white.withOpacity(0.7),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          _buildMetricSection('Areas for Improvement', weaknesses, ModernTheme.sunsetOrange),
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
                color == ModernTheme.freshGreen ? Icons.trending_up : Icons.priority_high,
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
                  color == ModernTheme.freshGreen ? Icons.check_circle : Icons.info_outline,
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
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
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
              ),
            ],
          ),
        ),
      ),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: -4,
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
                  colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildUsageChart(),
          const SizedBox(height: 24),
          _buildPerformanceMetrics(),
        ],
      ),
    );
  }

  Widget _buildUsageChart() {
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
            'Feature Usage',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: ModernTheme.navy,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: ModernTheme.lightGray,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_rounded,
                    size: 48,
                    color: ModernTheme.textTertiary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Analytics data will be displayed here',
                    style: TextStyle(
                      color: ModernTheme.textTertiary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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
    final recommendations = _insights['recommendations'] as Map<String, dynamic>? ?? {};
    
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
    final growthOps = _insights['growth_opportunities'] as Map<String, dynamic>? ?? {};
    
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

