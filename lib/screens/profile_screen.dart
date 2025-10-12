import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../core/theme/modern_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _locationController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = AuthService.currentUser ?? {};
    _nameController.text = user['name']?.toString() ?? '';
    _emailController.text = user['email']?.toString() ?? '';
    _titleController.text = user['title']?.toString() ?? '';
    _companyController.text = user['company']?.toString() ?? '';
    _experienceController.text = user['experience']?.toString() ?? '';
    _bioController.text = user['bio']?.toString() ?? '';
    _linkedinController.text = user['linkedin']?.toString() ?? '';
    _locationController.text = user['location']?.toString() ?? '';
    _hourlyRateController.text = user['hourlyRate']?.toString() ?? '';
  }

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernTheme.lightGray,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: ModernTheme.navy,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ModernTheme.lightGray,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 20),
                _buildStatsCards(),
                const SizedBox(height: 20),
                _buildProfileForm(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final user = AuthService.currentUser ?? {};
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile Avatar with enhanced styling (no background card)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: ModernTheme.electricBlue.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: ModernTheme.electricBlue.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: ModernTheme.electricBlue.withOpacity(0.1),
                  child: Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text[0].toUpperCase()
                        : user['name']?.toString()[0].toUpperCase() ?? 'M',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: ModernTheme.electricBlue,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                // Online status indicator
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: ModernTheme.freshGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Name with improved typography
          Text(
            _nameController.text.isNotEmpty
                ? _nameController.text
                : user['name']?.toString() ?? 'Mentor',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: ModernTheme.navy,
              letterSpacing: 0.5,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Title with elegant styling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: ModernTheme.electricBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: ModernTheme.electricBlue.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              _titleController.text.isNotEmpty
                  ? _titleController.text
                  : user['title']?.toString() ?? 'Professional Mentor',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ModernTheme.electricBlue,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          // Location and additional info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: ModernTheme.mediumGray,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                _locationController.text.isNotEmpty
                    ? _locationController.text
                    : user['location']?.toString() ?? 'Location',
                style: const TextStyle(
                  fontSize: 15,
                  color: ModernTheme.mediumGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 20),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: ModernTheme.mediumGray,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 20),
              const Icon(
                Icons.verified,
                color: ModernTheme.freshGreen,
                size: 18,
              ),
              const SizedBox(width: 6),
              const Text(
                'Verified',
                style: TextStyle(
                  fontSize: 15,
                  color: ModernTheme.freshGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final user = AuthService.currentUser ?? {};
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Experience',
            '${_experienceController.text.isNotEmpty ? _experienceController.text : user['experience']?.toString() ?? '0'} years',
            Icons.work_history,
            ModernTheme.electricBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Expertise',
            '${(user['expertise'] as List?)?.length ?? 0} areas',
            Icons.star,
            ModernTheme.sunsetOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ModernTheme.navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: ModernTheme.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ModernTheme.navy,
            ),
          ),
          const SizedBox(height: 20),
          _buildEnhancedTextField(
            controller: _nameController,
            label: 'Full name',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          _buildEnhancedTextField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email,
          ),
          const SizedBox(height: 16),
          _buildEnhancedTextField(
            controller: _titleController,
            label: 'Professional Title',
            icon: Icons.work,
          ),
          const SizedBox(height: 16),
          _buildEnhancedTextField(
            controller: _companyController,
            label: 'Company',
            icon: Icons.business,
          ),
          const SizedBox(height: 16),
          _buildEnhancedTextField(
            controller: _experienceController,
            label: 'Years of Experience',
            icon: Icons.timeline,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildEnhancedTextField(
            controller: _locationController,
            label: 'Location',
            icon: Icons.location_on,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: ModernTheme.electricBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: ModernTheme.mediumGray.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: ModernTheme.mediumGray.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: ModernTheme.electricBlue, width: 2),
        ),
        filled: true,
        fillColor: ModernTheme.lightGray.withOpacity(0.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveProfile,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(_isSaving ? 'Saving...' : 'Save Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.electricBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.errorRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      final updateData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'title': _titleController.text.trim(),
        'company': _companyController.text.trim(),
        'experience': _experienceController.text.trim(),
      };

      await AuthService.updateProfile(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: ModernTheme.freshGreen,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: ModernTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _logout() async {
    try {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushReplacementNamed('/splash');
      }
    } catch (e) {
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Logout completed but navigation failed')),
          );
        }
      }
    }
  }
}
