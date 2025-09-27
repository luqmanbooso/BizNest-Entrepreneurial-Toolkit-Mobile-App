import 'package:flutter/material.dart';
import '../../core/theme/modern_theme.dart';
import '../screens/main_screen.dart';

class MentorProfileSetupScreen extends StatefulWidget {
  const MentorProfileSetupScreen({super.key});

  @override
  State<MentorProfileSetupScreen> createState() => _MentorProfileSetupScreenState();
}

class _MentorProfileSetupScreenState extends State<MentorProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _expertiseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _expertiseController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  Future<void> _completeSetup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Here you would save the mentor profile data
      // For now, just navigate to main screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save profile')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Profile Setup'),
        backgroundColor: ModernTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete Your Mentor Profile',
                  style: ModernTheme.h2.copyWith(color: ModernTheme.navy),
                ),
                const SizedBox(height: 8),
                Text(
                  'Help entrepreneurs find you by providing your expertise details.',
                  style: ModernTheme.bodyMedium.copyWith(color: ModernTheme.mediumGray),
                ),
                const SizedBox(height: 32),

                // Expertise
                Text(
                  'Areas of Expertise',
                  style: ModernTheme.bodyMedium.copyWith(
                    color: ModernTheme.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _expertiseController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Business Strategy, Marketing, Funding',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your areas of expertise';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Years of Experience
                Text(
                  'Years of Experience',
                  style: ModernTheme.bodyMedium.copyWith(
                    color: ModernTheme.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _experienceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g., 5',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your years of experience';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Bio
                Text(
                  'Professional Bio',
                  style: ModernTheme.bodyMedium.copyWith(
                    color: ModernTheme.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Tell entrepreneurs about your background and what you can help with...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your professional bio';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Hourly Rate (optional)
                Text(
                  'Hourly Rate (USD) - Optional',
                  style: ModernTheme.bodyMedium.copyWith(
                    color: ModernTheme.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _hourlyRateController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g., 100',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _completeSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ModernTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Complete Setup'),
                  ),
                ),

                const SizedBox(height: 20),

                // Skip for now
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const MainScreen()),
                      );
                    },
                    child: Text(
                      'Skip for now',
                      style: ModernTheme.bodyMedium.copyWith(
                        color: ModernTheme.mediumGray,
                      ),
                    ),
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