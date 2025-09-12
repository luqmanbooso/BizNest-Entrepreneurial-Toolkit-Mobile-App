import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../core/theme/modern_theme.dart';
import 'ultra_modern_dashboard_screen.dart';
import 'business_screen.dart';
import 'financial_screen.dart';
import 'networking_screen.dart';
import 'learning_screen.dart';
import 'profile_screen.dart';
import 'community_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;
  late AnimationController _tabController;

  late Animation<double> _fabAnimation;
  late Animation<double> _tabAnimation;

  final List<MainTab> _tabs = [
    MainTab(
      page: const UltraModernDashboardScreen(),
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      color: ModernTheme.primaryBlue,
    ),
    MainTab(
      page: const BusinessScreen(),
      icon: Icons.business_center_rounded,
      label: 'Business',
      color: ModernTheme.freshGreen,
    ),
    MainTab(
      page: const FinancialScreen(),
      icon: Icons.account_balance_wallet_rounded,
      label: 'Financial',
      color: ModernTheme.teal,
    ),
    MainTab(
      page: const LearningScreen(),
      icon: Icons.school_rounded,
      label: 'Learn',
      color: ModernTheme.goldenYellow,
    ),
    MainTab(
      page: const ProfileScreen(),
      icon: Icons.person_rounded,
      label: 'Profile',
      color: ModernTheme.sunsetOrange,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _tabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    ));

    _tabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tabController,
      curve: Curves.easeInOut,
    ));

    _fabController.forward();
    _tabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs.map((tab) => tab.page).toList(),
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _tabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _tabAnimation.value,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                    spreadRadius: -8,
                  ),
                  BoxShadow(
                    color: const Color(0xFF00D4FF).withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: _tabs.asMap().entries.map((entry) {
                          final index = entry.key;
                          final tab = entry.value;
                          final isSelected = _currentIndex == index;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _currentIndex = index;
                              });
                              HapticFeedback.lightImpact();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeInOutCubic,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          tab.color,
                                          tab.color.withOpacity(0.8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: tab.color.withOpacity(0.4),
                                          blurRadius: 24,
                                          offset: const Offset(0, 12),
                                          spreadRadius: -6,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.easeInOutCubic,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      tab.icon,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.7),
                                      size: 20,
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        tab.label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.3,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black26,
                                              blurRadius: 6,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00D4FF),
                    const Color(0xFF7C3AED),
                    const Color(0xFF10B981),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D4FF).withOpacity(0.4),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                    spreadRadius: -10,
                  ),
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                    spreadRadius: -6,
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _showQuickActions,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(36),
                ),
                icon: const Icon(Icons.rocket_launch_rounded, size: 28),
                label: const Text(
                  'Quick Action',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    fontSize: 18,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: ModernTheme.mediumGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ModernTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.flash_on_rounded,
                          color: ModernTheme.primaryBlue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: ModernTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Choose what you want to do',
                              style: TextStyle(
                                fontSize: 14,
                                color: ModernTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick Actions List
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildQuickAction(
                        'Create Business Plan',
                        'Generate AI-powered business plan',
                        Icons.description_rounded,
                        ModernTheme.primaryBlue,
                        () {
                          Navigator.pop(context);
                          setState(() {
                            _currentIndex = 1; // Business tab
                          });
                        },
                      ),
                      _buildQuickAction(
                        'Calculate ROI',
                        'Analyze your investment returns',
                        Icons.calculate_rounded,
                        ModernTheme.accentGreen,
                        () {
                          Navigator.pop(context);
                          setState(() {
                            _currentIndex = 2; // Financial tab
                          });
                        },
                      ),
                      _buildQuickAction(
                        'Find Mentors',
                        'Connect with industry experts',
                        Icons.people_alt_rounded,
                        ModernTheme.sunsetOrange,
                        () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Networking features coming soon'),
                            ),
                          );
                        },
                      ),
                      _buildQuickAction(
                        'Start Learning',
                        'Access courses and resources',
                        Icons.play_circle_rounded,
                        ModernTheme.goldenYellow,
                        () {
                          Navigator.pop(context);
                          setState(() {
                            _currentIndex = 3; // Learning tab
                          });
                        },
                      ),
                      _buildQuickAction(
                        'Create Pitch Deck',
                        'Build professional presentations',
                        Icons.slideshow_rounded,
                        ModernTheme.teal,
                        () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pitch Deck Builder coming soon'),
                            ),
                          );
                        },
                      ),
                      _buildQuickAction(
                        'Market Research',
                        'Analyze market trends and competition',
                        Icons.analytics_rounded,
                        ModernTheme.sunsetOrange,
                        () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Market Research coming soon'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickAction(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ModernTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ModernTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainTab {
  final Widget page;
  final IconData icon;
  final String label;
  final Color color;

  MainTab({
    required this.page,
    required this.icon,
    required this.label,
    required this.color,
  });
}
