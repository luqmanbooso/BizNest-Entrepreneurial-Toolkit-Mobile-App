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
  late TextEditingController _avatarController;
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
    _avatarController = TextEditingController();

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
          _avatarController.text = user['avatar'] ?? user['photoUrl'] ?? '';
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
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final updates = <String, dynamic>{
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'avatar': _avatarController.text.trim(),
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
    final user = AuthService.currentUser ?? {};
    final avatar = _avatarController.text.isNotEmpty
        ? _avatarController.text
        : (user['avatar'] ?? user['photoUrl']);
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
                  backgroundImage:
                      avatar != null && avatar.toString().isNotEmpty
                          ? NetworkImage(avatar) as ImageProvider
                          : null,
                  child: (avatar == null || avatar.toString().isEmpty)
                      ? const Icon(Icons.person, size: 48)
                      : null,
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
                controller: _avatarController,
                decoration: const InputDecoration(
                    labelText: 'Avatar image URL (optional)'),
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
        // Navigate to splash screen which will check auth and redirect appropriately
        Navigator.of(context).pushNamedAndRemoveUntil('/splash', (route) => false);
      }
    } catch (e) {
      // Even if logout fails, try to navigate anyway
      if (kDebugMode) {
        print('Logout error: $e');
      }
      if (mounted) {
        try {
          Navigator.of(context).pushNamedAndRemoveUntil('/splash', (route) => false);
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
