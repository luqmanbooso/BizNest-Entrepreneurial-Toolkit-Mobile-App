import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/widgets/performance_tab.dart';
import '../core/theme/modern_theme.dart';

class PerformanceTabDemo extends StatelessWidget {
  const PerformanceTabDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current user's business ID
    final businessId =
        FirebaseAuth.instance.currentUser?.uid ?? 'default_business';

    return Scaffold(
      backgroundColor: ModernTheme.backgroundLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Performance Tab Demo',
          style: ModernTheme.h3.copyWith(
            color: ModernTheme.primaryColor,
            fontSize: 20,
          ),
        ),
      ),
      body: PerformanceTab(businessId: businessId),
    );
  }
}
