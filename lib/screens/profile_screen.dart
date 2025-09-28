import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// kept minimal imports for profile editing
import '../core/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  // Profile form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _titleController;
  late TextEditingController _companyController;
  late TextEditingController _experienceController;
  late TextEditingController _bioController;
  late TextEditingController _linkedinController;
  late TextEditingController _locationController;
  late TextEditingController _hourlyRateController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animationController.forward();

    // Initialize controllers
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _titleController = TextEditingController();
    _companyController = TextEditingController();
    _experienceController = TextEditingController();
    _bioController = TextEditingController();
    _linkedinController = TextEditingController();
    _locationController = TextEditingController();
    _hourlyRateController = TextEditingController();

    // Load user data from current user
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // Use current user data from AuthService
      final user = AuthService.currentUser;
      if (user != null) {
        setState(() {
          _nameController.text = user['name'] ?? user['full_name'] ?? user['displayName'] ?? '';
          _emailController.text = user['email'] ?? '';
          _titleController.text = user['title'] ?? '';
          _companyController.text = user['company'] ?? '';
          _experienceController.text = user['experience'] ?? '';
          _bioController.text = user['bio'] ?? '';
          _linkedinController.text = user['linkedin'] ?? '';
          _locationController.text = user['location'] ?? '';
          _hourlyRateController.text = user['hourlyRate'] ?? '';
        });
      }
    } catch (e) {
      // If loading fails, show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    // dispose profile controllers
    _nameController.dispose();
    _emailController.dispose();
    _titleController.dispose();
    _companyController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _linkedinController.dispose();
    _locationController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final updates = <String, dynamic>{
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'title': _titleController.text.trim(),
      'company': _companyController.text.trim(),
      'experience': _experienceController.text.trim(),
      'bio': _bioController.text.trim(),
      'linkedin': _linkedinController.text.trim(),
      'location': _locationController.text.trim(),
      'hourlyRate': _hourlyRateController.text.trim(),
    };
    try {
      final result = await AuthService.updateProfile(updates);
      if (result.success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')),
          );
          // Refresh the profile data
          await _loadUserProfile();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save profile')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
                  child: Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Enter email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Professional Title'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Company'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _experienceController,
                decoration: const InputDecoration(labelText: 'Years of Experience'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _linkedinController,
                decoration: const InputDecoration(labelText: 'LinkedIn Profile'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hourlyRateController,
                decoration: const InputDecoration(labelText: 'Hourly Rate'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              // Display expertise and industries
              if (AuthService.currentUser?['expertise'] != null &&
                  (AuthService.currentUser!['expertise'] as List?)?.isNotEmpty == true)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expertise Areas',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (AuthService.currentUser!['expertise'] as List<dynamic>)
                          .map((expertise) => Chip(
                                label: Text(expertise.toString()),
                                backgroundColor: Colors.blue.withOpacity(0.1),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              if (AuthService.currentUser?['industries'] != null &&
                  (AuthService.currentUser!['industries'] as List?)?.isNotEmpty == true)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Industries',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (AuthService.currentUser!['industries'] as List<dynamic>)
                          .map((industry) => Chip(
                                label: Text(industry.toString()),
                                backgroundColor: Colors.green.withOpacity(0.1),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              if (AuthService.currentUser?['experienceLevel'] != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Experience Level',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(AuthService.currentUser!['experienceLevel'].toString()),
                    const SizedBox(height: 16),
                  ],
                ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Save profile'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await AuthService.logout();
      if (mounted) {
        // Navigate back to the main app navigation
        Navigator.of(context).popUntil((route) => route.isFirst);
        // Then navigate to splash screen
        Navigator.of(context).pushReplacementNamed('/splash');
      }
    } catch (e) {
      // Even if logout fails, try to navigate anyway
      if (kDebugMode) {
        print('Logout error: $e');
      }
      if (mounted) {
        try {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context).pushReplacementNamed('/splash');
        } catch (navError) {
          if (kDebugMode) {
            print('Navigation error: $navError');
          }
          // Last resort - show error to user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout completed but navigation failed')),
          );
        }
      }
    }
  }
}
