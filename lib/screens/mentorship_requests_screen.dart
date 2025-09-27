import 'package:flutter/material.dart';
import '../core/theme/modern_theme.dart';

class MentorshipRequestsScreen extends StatelessWidget {
  const MentorshipRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mentorship Requests',
          style: ModernTheme.textTheme.headlineSmall?.copyWith(
            color: ModernTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ModernTheme.lightGray,
        elevation: 0,
        iconTheme: IconThemeData(color: ModernTheme.primaryColor),
      ),
      backgroundColor: ModernTheme.backgroundColor,
      body: Center(
        child: Text(
          'Mentorship Requests Screen\n\nThis screen will display incoming mentorship requests from entrepreneurs.',
          style: ModernTheme.textTheme.bodyLarge?.copyWith(
            color: ModernTheme.navy,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}