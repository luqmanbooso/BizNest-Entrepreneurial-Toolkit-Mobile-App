import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../core/theme/modern_theme.dart';
import 'advanced_dashboard_screen.dart';
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
      page: const AdvancedDashboardScreen(),
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      color: ModernTheme.primaryBlue,
    ),
    MainTab(
      page: const BusinessScreen(),
      icon: Icons.business_center_rounded,
      label: 'Business',
      color: ModernTheme.secondaryPurple,
    ),
    MainTab(
      page: const FinancialScreen(),
      icon: Icons.account_balance_wallet_rounded,
      label: 'Financial',
      color: ModernTheme.accentGreen,
    ),
    MainTab(
      page: const NetworkingScreen(),
      icon: Icons.people_rounded,
      label: 'Network',
      color: ModernTheme.warningOrange,
    ),
    MainTab(
      page: const LearningScreen(),
      icon: Icons.school_rounded,
      label: 'Learn',
      color: ModernTheme.infoCyan,
    ),
    MainTab(
      page: const CommunityScreen(),
      icon: Icons.forum_rounded,
      label: 'Community',
      color: ModernTheme.primaryBlue,
    ),
    MainTab(
      page: const ProfileScreen(),
      icon: Icons.person_rounded,
      label: 'Profile',
      color: ModernTheme.errorRed,
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
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? tab.color.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? tab.color
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      tab.icon,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[600],
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tab.label,
                                    style: TextStyle(
                                      color: isSelected
                                          ? tab.color
                                          : Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
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
            child: FloatingActionButton.extended(
              onPressed: _showQuickActions,
              backgroundColor: ModernTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Quick Action',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
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
                    color: Colors.grey[300],
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
                        ModernTheme.warningOrange,
                        () {
                          Navigator.pop(context);
                          setState(() {
                            _currentIndex = 3; // Networking tab
                          });
                        },
                      ),
                      _buildQuickAction(
                        'Start Learning',
                        'Access courses and resources',
                        Icons.play_circle_rounded,
                        ModernTheme.infoCyan,
                        () {
                          Navigator.pop(context);
                          setState(() {
                            _currentIndex = 4; // Learning tab
                          });
                        },
                      ),
                      _buildQuickAction(
                        'Create Pitch Deck',
                        'Build professional presentations',
                        Icons.slideshow_rounded,
                        ModernTheme.secondaryPurple,
                        () {
                          Navigator.pop(context);
                          // TODO: Navigate to pitch deck builder
                        },
                      ),
                      _buildQuickAction(
                        'Market Research',
                        'Analyze market trends and competition',
                        Icons.analytics_rounded,
                        ModernTheme.errorRed,
                        () {
                          Navigator.pop(context);
                          // TODO: Navigate to market research
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
