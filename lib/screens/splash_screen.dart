import 'package:flutter/material.dart';
import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:get/get.dart';
import '../utils/advanced_animations.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _navigateToNext();
  }

  void _initAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _logoController.forward();
    _backgroundController.forward();
  }

  void _navigateToNext() {
    Timer(const Duration(seconds: 3), () {
      Get.offNamed('/onboarding');
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticleAnimation(
        particleCount: 80,
        particleColor: Colors.white,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6366F1),
                Color(0xFF8B5CF6),
                Color(0xFFEC4899),
                Color(0xFF10B981),
              ],
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                PulseAnimation(
                  duration: const Duration(milliseconds: 2000),
                  minScale: 0.9,
                  maxScale: 1.1,
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 1000),
                    child: GlassContainer(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 140,
                        height: 140,
                        padding: const EdgeInsets.all(30),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.rocket_launch_rounded,
                            size: 50,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // App Title
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: ShimmerEffect(
                    child: const Text(
                      'Entrepreneur\nToolkit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Subtitle
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: const Text(
                    'Transform Ideas into Success',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 80),

                // Loading Animation
                FadeInUp(
                  delay: const Duration(milliseconds: 1200),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white60,
                          fontWeight: FontWeight.w300,
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
}
