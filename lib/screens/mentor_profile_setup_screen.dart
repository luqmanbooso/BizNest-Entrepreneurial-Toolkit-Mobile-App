import 'package:flutter/material.dart';
import '../core/theme/modern_theme.dart';
import '../core/services/auth_service.dart';
import 'mentor_dashboard_screen.dart';

class MentorProfileSetupScreen extends StatefulWidget {
  const MentorProfileSetupScreen({super.key});

  @override
  State<MentorProfileSetupScreen> createState() =>
      _MentorProfileSetupScreenState();
}

class _MentorProfileSetupScreenState extends State<MentorProfileSetupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _locationController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  int _currentPage = 0;
  final int _totalPages = 3;

  late AnimationController _animationController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isLoading = false;

  // Expertise and Industry selections
  final List<String> _selectedExpertise = [];
  final List<String> _selectedIndustries = [];
  String? _selectedExperienceLevel;

  final List<String> _expertiseOptions = [
    'Business Strategy',
    'Marketing & Sales',
    'Product Development',
    'Financial Planning',
    'Operations',
    'Technology',
    'Leadership',
    'Fundraising',
    'Legal & Compliance',
    'International Business',
    'E-commerce',
    'Digital Transformation',
  ];

  final List<String> _industryOptions = [
    'Technology',
    'Healthcare',
    'Finance',
    'E-commerce',
    'Manufacturing',
    'Education',
    'Real Estate',
    'Food & Beverage',
    'Fashion',
    'Travel & Tourism',
    'Media & Entertainment',
    'Non-profit',
  ];

  final List<String> _experienceLevels = [
    '1-3 years',
    '3-5 years',
    '5-10 years',
    '10-15 years',
    '15+ years',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();

    // Pre-fill name from current user data
    final currentUser = AuthService.currentUser;
    if (currentUser != null && currentUser['name'] != null) {
      final fullName = currentUser['name'].toString().split(' ');
      if (fullName.isNotEmpty) {
        _firstNameController.text = fullName.first;
        if (fullName.length > 1) {
          _lastNameController.text = fullName.sublist(1).join(' ');
        }
      }
    }
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
    _scaleController.forward();
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _titleController.dispose();
    _companyController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _linkedinController.dispose();
    _locationController.dispose();
    _hourlyRateController.dispose();
    _pageController.dispose();
    _animationController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeProfile();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Additional validation for required fields
    if (_selectedExpertise.isEmpty ||
        _selectedIndustries.isEmpty ||
        _selectedExperienceLevel == null) {
      _showErrorSnackBar('Please complete all required sections');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare profile data
      final profileData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'title': _titleController.text,
        'company': _companyController.text,
        'experience': _experienceController.text,
        'bio': _bioController.text,
        'linkedin': _linkedinController.text,
        'location': _locationController.text,
        'hourlyRate': _hourlyRateController.text,
        'expertise': _selectedExpertise,
        'industries': _selectedIndustries,
        'experienceLevel': _selectedExperienceLevel,
        'role': 'mentor',
        'isProfileComplete': true,
      };

      // Save to AuthService (which handles Firebase)
      final result = await AuthService.updateProfile(profileData);

      if (!result.success) {
        throw Exception(result.message);
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MentorDashboardScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to save profile. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ModernTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: ModernTheme.primaryGradient,
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                children: [
                  // Header with progress
                  _buildHeader(),

                  // Progress indicator
                  _buildProgressIndicator(),

                  // Form content
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: ModernTheme.modernShadow,
                      ),
                      child: Form(
                        key: _formKey,
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildBasicInfoPage(),
                            _buildProfessionalInfoPage(),
                            _buildExpertisePage(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Navigation buttons
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              const Spacer(),
              Text(
                'Complete Your Profile',
                style: ModernTheme.h2.copyWith(color: Colors.white),
              ),
              const Spacer(),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Help entrepreneurs find the perfect mentor',
            style: ModernTheme.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(_totalPages, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < _totalPages - 1 ? 8 : 0),
              decoration: BoxDecoration(
                color: index <= _currentPage
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: ModernTheme.h3.copyWith(color: ModernTheme.navy),
          ),
          const SizedBox(height: 20),

          // Profile Avatar with name initial
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: ModernTheme.primaryColor.withOpacity(0.3),
              child: Text(
                _firstNameController.text.isNotEmpty
                    ? _firstNameController.text[0].toUpperCase()
                    : 'U',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Name fields
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _locationController,
            label: 'Location',
            prefixIcon: Icons.location_on,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your location';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _linkedinController,
            label: 'LinkedIn Profile (Optional)',
            prefixIcon: Icons.link,
            hintText: 'https://linkedin.com/in/yourprofile',
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Professional Background',
            style: ModernTheme.h3.copyWith(color: ModernTheme.navy),
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _titleController,
            label: 'Professional Title',
            prefixIcon: Icons.work,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your professional title';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _companyController,
            label: 'Current Company',
            prefixIcon: Icons.business,
          ),
          const SizedBox(height: 20),

          // Experience Level Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedExperienceLevel,
            decoration: InputDecoration(
              labelText: 'Years of Experience',
              prefixIcon: const Icon(Icons.timeline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ModernTheme.mediumGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: ModernTheme.mediumGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: ModernTheme.electricBlue, width: 2),
              ),
            ),
            items: _experienceLevels.map((level) {
              return DropdownMenuItem(
                value: level,
                child: Text(level),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedExperienceLevel = value;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your experience level';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _hourlyRateController,
            label: 'Hourly Rate (USD)',
            prefixIcon: Icons.attach_money,
            keyboardType: TextInputType.number,
            hintText: '50',
          ),
          const SizedBox(height: 20),

          _buildTextField(
            controller: _bioController,
            label: 'Professional Bio',
            prefixIcon: Icons.person,
            maxLines: 4,
            hintText:
                'Tell entrepreneurs about your background, achievements, and how you can help them...',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your bio';
              }
              if (value.length < 50) {
                return 'Bio should be at least 50 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpertisePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expertise & Industries',
            style: ModernTheme.h3.copyWith(color: ModernTheme.navy),
          ),
          const SizedBox(height: 20),

          // Expertise Selection
          Text(
            'Areas of Expertise',
            style: ModernTheme.h4.copyWith(color: ModernTheme.navy),
          ),
          const SizedBox(height: 10),
          Text(
            'Select up to 5 areas where you can provide mentorship',
            style:
                ModernTheme.bodyMedium.copyWith(color: ModernTheme.mediumGray),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _expertiseOptions.map((expertise) {
              final isSelected = _selectedExpertise.contains(expertise);
              return FilterChip(
                label: Text(expertise),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected && _selectedExpertise.length < 5) {
                      _selectedExpertise.add(expertise);
                    } else if (!selected) {
                      _selectedExpertise.remove(expertise);
                    }
                  });
                },
                selectedColor: ModernTheme.electricBlue.withOpacity(0.2),
                checkmarkColor: ModernTheme.electricBlue,
                labelStyle: TextStyle(
                  color:
                      isSelected ? ModernTheme.electricBlue : ModernTheme.navy,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),

          if (_selectedExpertise.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Please select at least one area of expertise',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 12,
                ),
              ),
            ),

          const SizedBox(height: 30),

          // Industry Selection
          Text(
            'Industries',
            style: ModernTheme.h4.copyWith(color: ModernTheme.navy),
          ),
          const SizedBox(height: 10),
          Text(
            'Select industries you have experience in',
            style:
                ModernTheme.bodyMedium.copyWith(color: ModernTheme.mediumGray),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _industryOptions.map((industry) {
              final isSelected = _selectedIndustries.contains(industry);
              return FilterChip(
                label: Text(industry),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedIndustries.add(industry);
                    } else {
                      _selectedIndustries.remove(industry);
                    }
                  });
                },
                selectedColor: ModernTheme.freshGreen.withOpacity(0.2),
                checkmarkColor: ModernTheme.freshGreen,
                labelStyle: TextStyle(
                  color: isSelected ? ModernTheme.freshGreen : ModernTheme.navy,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? prefixIcon,
    String? hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ModernTheme.mediumGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ModernTheme.mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: ModernTheme.electricBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ModernTheme.errorRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ModernTheme.errorRed, width: 2),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: ModernTheme.bodyLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : (_currentPage == _totalPages - 1 &&
                          _selectedExpertise.isEmpty)
                      ? null
                      : _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: ModernTheme.electricBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ModernTheme.electricBlue,
                      ),
                    )
                  : Text(
                      _currentPage == _totalPages - 1
                          ? 'Complete Profile'
                          : 'Next',
                      style: ModernTheme.bodyLarge.copyWith(
                        color: ModernTheme.electricBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
