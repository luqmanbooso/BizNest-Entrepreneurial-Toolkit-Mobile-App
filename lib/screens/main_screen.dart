import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../screens/professional_dashboard_screen.dart';
import '../screens/mentor_dashboard_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userRole = AuthService.currentUser?['role'] ?? 'entrepreneur';
    
    if (userRole == 'mentor') {
      return const MentorDashboardScreen();
    } else {
      return const Scaffold(
        body: ProfessionalDashboardScreen(),
      );
    }
  }
}
