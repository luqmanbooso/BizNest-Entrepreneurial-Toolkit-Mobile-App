import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';
import '../utils/modern_theme.dart';
import '../utils/advanced_animations.dart';

class ModernOnboardingScreen extends StatefulWidget {
  const ModernOnboardingScreen({super.key});

  @override
  _ModernOnboardingScreenState createState() => _ModernOnboardingScreenState();
}

class _ModernOnboardingScreenState extends State<ModernOnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _progressController;
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Plan Your\nSuccess',
      subtitle:
          'Create comprehensive business plans with AI-powered insights and professional templates',
      icon: Icons.rocket_launch_rounded,
      gradient: AppTheme.primaryGradient,
      features: [
        'AI Business Planning',
        'Professional Templates',
        'Market Analysis',
      ],
    ),
    OnboardingPage(
      title: 'Smart Financial\nManagement',
      subtitle:
          'Track expenses, forecast revenue, and manage your startup finances with intelligent tools',
      icon: Icons.analytics_rounded,
      gradient: AppTheme.accentGradient,
      features: [
        'Revenue Forecasting',
        'Expense Tracking',
        'Financial Reports',
      ],
    ),
    OnboardingPage(
      title: 'Connect &\nGrow Network',
      subtitle:
          'Find mentors, investors, and partners to accelerate your entrepreneurial journey',
      icon: Icons.people_rounded,
      gradient: AppTheme.successGradient,
      features: ['Mentor Matching', 'Investor Network', 'Community Events'],
    ),
    OnboardingPage(
      title: 'Launch Your\nDream Business',
      subtitle:
          'Everything you need to turn your ideas into a successful business venture',
      icon: Icons.stars_rounded,
      gradient: LinearGradient(
        colors: [AppTheme.warningColor, AppTheme.tertiaryColor],
      ),
      features: ['Legal Compliance', 'Marketing Tools', 'Launch Support'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticleAnimation(
        particleCount: 30,
        particleColor: Colors.white.withOpacity(0.6),
        child: Container(
          decoration: BoxDecoration(gradient: _pages[_currentPage].gradient),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildPageView()),
                _buildBottomSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          FadeInLeft(
            child: GlassContainer(
              opacity: 0.2,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  'Entrepreneur Toolkit',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          FadeInRight(
            child: TextButton(
              onPressed: () => Get.offAllNamed('/login'),
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
        _progressController.forward().then((_) {
          _progressController.reset();
        });
      },
      itemCount: _pages.length,
      itemBuilder: (context, index) {
        return _buildPage(_pages[index], index);
      },
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const SizedBox(height: 60),

          // Animated Icon
          FadeInDown(
            delay: Duration(milliseconds: 200 * index),
            child: PulseAnimation(
              child: GlassContainer(
                opacity: 0.2,
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(page.icon, size: 80, color: Colors.white),
                ),
              ),
            ),
          ),

          const SizedBox(height: 50),

          // Title
          FadeInUp(
            delay: Duration(milliseconds: 400 + (200 * index)),
            child: ShimmerEffect(
              highlightColor: Colors.white,
              baseColor: Colors.white.withOpacity(0.7),
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

          const SizedBox(height: 24),

          // Subtitle
          FadeInUp(
            delay: Duration(milliseconds: 600 + (200 * index)),
            child: Text(
              page.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Features
          FadeInUp(
            delay: Duration(milliseconds: 800 + (200 * index)),
            child: Column(
              children: List.generate(page.features.length, (i) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: SlideInLeft(
                    delay: Duration(milliseconds: 100 * i),
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
                          page.features[i],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          // Progress Indicator
          FadeInUp(
            child: Row(
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
          ),

          const SizedBox(height: 40),

          // Action Buttons
          Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: FadeInLeft(
                    child: MorphingButton(
                      text: 'Back',
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                ),

              if (_currentPage > 0) const SizedBox(width: 16),

              Expanded(
                flex: _currentPage == 0 ? 1 : 2,
                child: FadeInRight(
                  child: MorphingButton(
                    text: _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: () {
                      if (_currentPage == _pages.length - 1) {
                        Get.offAllNamed('/login');
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.white.withOpacity(0.9)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final List<String> features;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.features,
  });
}
