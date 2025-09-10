import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/dashboard_screen.dart';
import 'screens/business_plan/business_plan_screen.dart';
import 'screens/market_research/market_research_screen.dart';
import 'screens/financial/financial_calculator_screen.dart';
import 'screens/funding/funding_screen.dart';
import 'screens/legal/legal_screen.dart';
import 'screens/networking/networking_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'utils/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Entrepreneur Toolkit',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => SplashScreen()),
        GetPage(name: '/onboarding', page: () => ModernOnboardingScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/dashboard', page: () => DashboardScreen()),
        GetPage(name: '/business-plan', page: () => BusinessPlanScreen()),
        GetPage(name: '/market-research', page: () => MarketResearchScreen()),
        GetPage(
          name: '/financial-calculator',
          page: () => FinancialCalculatorScreen(),
        ),
        GetPage(name: '/funding', page: () => FundingScreen()),
        GetPage(name: '/legal', page: () => LegalScreen()),
        GetPage(name: '/networking', page: () => NetworkingScreen()),
        GetPage(name: '/profile', page: () => ProfileScreen()),
      ],
    );
  }
}
