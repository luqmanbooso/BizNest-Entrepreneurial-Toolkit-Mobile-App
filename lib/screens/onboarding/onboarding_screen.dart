import 'package:flutter/material.dart';
import '../../core/theme/modern_theme.dart';
import '../../core/services/storage_service.dart';
import '../../core/widgets/biznest_logo.dart';
import '../../core/widgets/modern_animations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late AnimationController _progressController;
  late AnimationController _logoController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to\nBizNest',
      subtitle: 'Your Ultimate Business Companion',
      description: 'Transform your entrepreneurial journey with our comprehensive AI-powered toolkit designed for modern business builders.',
      icon: '🚀',
      gradient: [ModernTheme.primaryBlue, ModernTheme.secondaryPurple],
      features: ['AI-Powered Planning', 'Smart Analytics', 'Professional Tools'],
    ),
    OnboardingPage(
      title: 'Plan & Strategize',
      subtitle: 'Build Your Business Foundation',
      description: 'Create professional business plans, conduct market research, and develop winning strategies with our AI-powered tools.',
      icon: '📊',
      gradient: [ModernTheme.primaryBlue, ModernTheme.accentGreen],
      features: ['Business Plan Generator', 'Market Analysis', 'SWOT Analysis'],
    ),
    OnboardingPage(
      title: 'Financial Management',
      subtitle: 'Master Your Numbers',
      description: 'Calculate ROI, track funding, manage cash flow, and make data-driven financial decisions with ease.',
      icon: '💰',
      gradient: [ModernTheme.accentGreen, ModernTheme.warningOrange],
      features: ['ROI Calculator', 'Cash Flow Tracking', 'Financial Reports'],
    ),
    OnboardingPage(
      title: 'Network & Grow',
      subtitle: 'Connect with Success',
      description: 'Find mentors, investors, and partners. Join a thriving community of entrepreneurs and accelerate your growth.',
      icon: '🤝',
      gradient: [ModernTheme.secondaryPurple, ModernTheme.infoCyan],
      features: ['Mentor Matching', 'Investor Network', 'Community Events'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _logoController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _progressController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() async {
    await StorageService.setBool('is_first_time', false);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _pages[_currentPage].gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ParticleAnimation(
          particleCount: 30,
          particleColor: Colors.white,
          particleSpeed: 0.3,
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      AnimatedBuilder(
                        animation: _logoScaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: const BizNestLogo(
                              size: 40,
                              showText: false,
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Page Content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                      _progressController.reset();
                      _progressController.forward();
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index], index);
                    },
                  ),
                ),
                
                // Bottom Section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Progress Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 32 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Navigation Buttons
                      Row(
                        children: [
                          if (_currentPage > 0)
                            Expanded(
                              child: MorphingButton(
                                text: 'Back',
                                onPressed: _previousPage,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                textColor: Colors.white,
                                gradient: null,
                              ),
                            ),
                          
                          if (_currentPage > 0) const SizedBox(width: 16),
                          
                          Expanded(
                            flex: _currentPage == 0 ? 1 : 2,
                            child: MorphingButton(
                              text: _currentPage == _pages.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              onPressed: _nextPage,
                              gradient: const LinearGradient(
                                colors: [Colors.white, Colors.white70],
                              ),
                              textColor: ModernTheme.primaryBlue,
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
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    page.icon,
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Title
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ShimmerEffect(
                baseColor: Colors.white.withOpacity(0.8),
                highlightColor: Colors.white,
                child: Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Subtitle
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              page.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Description
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Features
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: page.features.map((feature) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        feature,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String icon;
  final List<Color> gradient;
  final List<String> features;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.features,
  });
}