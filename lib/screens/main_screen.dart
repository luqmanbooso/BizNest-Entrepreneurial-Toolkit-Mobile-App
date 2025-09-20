import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../core/theme/modern_theme.dart';
import 'ultra_modern_dashboard_screen.dart';
import 'business_screen.dart';
import 'financial_screen.dart';
import 'learning_screen.dart';

// Clean, single-definition MainScreen with overlay navigation and FAB.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _fabController;
  late final AnimationController _tabController;

  late final Animation<double> _fabAnimation;
  late final Animation<double> _tabAnimation;

  final List<MainTab> _tabs = [
    MainTab(
        page: const UltraModernDashboardScreen(),
        icon: Icons.dashboard_rounded,
        label: 'Dashboard',
        color: ModernTheme.primaryBlue),
    MainTab(
        page: const BusinessScreen(),
        icon: Icons.business_center_rounded,
        label: 'Business',
        color: ModernTheme.freshGreen),
    MainTab(
        page: const FinancialScreen(),
        icon: Icons.account_balance_wallet_rounded,
        label: 'Financial',
        color: ModernTheme.teal),
    MainTab(
        page: const LearningScreen(),
        icon: Icons.school_rounded,
        label: 'Learn',
        color: ModernTheme.goldenYellow),
  ];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _tabController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    _fabAnimation =
        CurvedAnimation(parent: _fabController, curve: Curves.easeInOut);
    _tabAnimation =
        CurvedAnimation(parent: _tabController, curve: Curves.easeInOut);

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
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // main content
          IndexedStack(
              index: _currentIndex,
              children: _tabs.map((t) => t.page).toList()),

          // FAB positioned above nav (raised slightly)
          Positioned(
            right: 28,
            bottom: 110 + (keyboardInset > 0 ? keyboardInset : 0),
            child: ScaleTransition(
              scale: _fabAnimation,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    Color(0xFF00D4FF),
                    Color(0xFF7C3AED),
                    Color(0xFF10B981)
                  ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: FloatingActionButton(
                  onPressed: _showQuickActions,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  mini: true,
                  child: const Icon(Icons.add_box, size: 22),
                ),
              ),
            ),
          ),

          // Floating nav overlay (centered and width-constrained so it's not too long)
          Positioned(
            left: 0,
            right: 0,
            bottom: 24 + (keyboardInset > 0 ? keyboardInset : 0),
            child: AnimatedBuilder(
              animation: _tabAnimation,
              builder: (context, child) => Transform.scale(
                scale: _tabAnimation.value,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        maxWidth:
                            760), // keep nav visually short on large screens
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.black.withOpacity(0.06), width: 1.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: SafeArea(
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                child: _buildMaterialNavigationBar()),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
            child: Column(
              children: [
                Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                        color: ModernTheme.mediumGray.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2))),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(children: [
                    Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: ModernTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.flash_on_rounded,
                            color: ModernTheme.primaryBlue, size: 24)),
                    const SizedBox(width: 16),
                    const Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Quick Actions',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: ModernTheme.textPrimary)),
                          Text('Choose what you want to do',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: ModernTheme.textSecondary))
                        ]))
                  ]),
                ),
                Expanded(
                  child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _buildQuickAction(
                            'Create Business Plan',
                            'Generate AI-powered business plan',
                            Icons.description_rounded,
                            ModernTheme.primaryBlue, () {
                          Navigator.pop(context);
                          setState(() => _currentIndex = 1);
                        }),
                        _buildQuickAction(
                            'Calculate ROI',
                            'Analyze your investment returns',
                            Icons.calculate_rounded,
                            ModernTheme.accentGreen, () {
                          Navigator.pop(context);
                          setState(() => _currentIndex = 2);
                        }),
                        _buildQuickAction(
                            'Find Mentors',
                            'Connect with industry experts',
                            Icons.people_alt_rounded,
                            ModernTheme.sunsetOrange, () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Networking features coming soon')));
                        }),
                        _buildQuickAction(
                            'Start Learning',
                            'Access courses and resources',
                            Icons.play_circle_rounded,
                            ModernTheme.goldenYellow, () {
                          Navigator.pop(context);
                          setState(() => _currentIndex = 3);
                        }),
                        _buildQuickAction(
                            'Create Pitch Deck',
                            'Build professional presentations',
                            Icons.slideshow_rounded,
                            ModernTheme.teal, () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Pitch Deck Builder coming soon')));
                        }),
                        _buildQuickAction(
                            'Market Research',
                            'Analyze market trends and competition',
                            Icons.analytics_rounded,
                            ModernTheme.sunsetOrange, () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Market Research coming soon')));
                        }),
                      ]),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMaterialNavigationBar() {
    return LayoutBuilder(builder: (context, constraints) {
      // Icons-only nav (forced) to minimize height
      // labels are intentionally hidden (icons-only)

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _currentIndex == index;

          return Expanded(
            child: Semantics(
              selected: isSelected,
              label: tab.label,
              child: GestureDetector(
                onTap: () => setState(() => _currentIndex = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: [
                            tab.color.withOpacity(0.95),
                            tab.color.withOpacity(0.8)
                          ])
                        : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Stack(alignment: Alignment.topRight, children: [
                      Icon(tab.icon,
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : ModernTheme.textSecondary),
                      if (index == 2)
                        Positioned(
                            right: -4,
                            top: -4,
                            child: _buildBadge('3', small: true)),
                    ]),
                    // labels hidden in icons-only mode
                  ]),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildBadge(String text, {bool small = false}) {
    if (small) {
      // Tight circular badge for compact nav
      return Container(
        width: 16,
        height: 16,
        decoration: const BoxDecoration(
            color: Colors.redAccent, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: const Text(
          '3',
          style: TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
        ),
      );
    }

    // regular badge (slightly rounded pill)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildQuickAction(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap) {
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
                border: Border.all(color: color.withOpacity(0.1), width: 1)),
            child: Row(children: [
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: color, size: 24)),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ModernTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 14, color: ModernTheme.textSecondary))
                  ])),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400], size: 16),
            ]),
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

  MainTab(
      {required this.page,
      required this.icon,
      required this.label,
      required this.color});
}
