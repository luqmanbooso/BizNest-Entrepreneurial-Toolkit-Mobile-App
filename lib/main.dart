import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'utils/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/modern_onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/business_plan/business_plan_screen.dart';
import 'screens/market_research/market_research_screen.dart';
import 'screens/networking/networking_screen.dart';
import 'screens/financial/financial_calculator_screen.dart';
import 'screens/funding/funding_tracker_screen.dart';
import 'screens/legal/legal_compliance_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Entrepreneur Toolkit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(name: '/onboarding', page: () => ModernOnboardingScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/dashboard', page: () => DashboardScreen()),
        GetPage(name: '/business-plan', page: () => BusinessPlanScreen()),
        GetPage(name: '/market-research', page: () => MarketResearchScreen()),
        GetPage(name: '/networking', page: () => NetworkingScreen()),
        GetPage(
            name: '/financial-calculator',
            page: () => FinancialCalculatorScreen()),
        GetPage(name: '/funding', page: () => FundingTrackerScreen()),
        GetPage(name: '/legal', page: () => LegalComplianceScreen()),
        GetPage(name: '/profile', page: () => ProfileScreen()),
      ],
    );
  }
}
