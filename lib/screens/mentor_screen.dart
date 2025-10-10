import 'package:flutter/material.dart';
import '../core/theme/modern_theme.dart';
import '../core/services/mentorship_service.dart';
import 'mentorship_request_screen.dart';

class MentorScreen extends StatefulWidget {
  const MentorScreen({super.key});

  @override
  State<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends State<MentorScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedExpertise = 'All';
  String _selectedExperience = 'All';
  String _selectedLocation = 'All';
  String _selectedGoal = 'All';

  List<Map<String, dynamic>> _mentors = [];
  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _animationController;
  late AnimationController _cardController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _cardAnimation;

  final List<String> _expertiseCategories = [
    'All',
    'Business Strategy',
    'Funding',
    'Marketing',
    'Technology',
    'Legal',
    'Operations',
    'Sales',
  ];

  final List<String> _experienceLevels = [
    'All',
    '1-3 years',
    '3-5 years',
    '5-10 years',
    '10+ years',
  ];

  final List<String> _locations = [
    'All',
    'Remote',
    'New York',
    'San Francisco',
    'London',
    'Singapore',
    'Other',
  ];

  final List<String> _goals = [
    'All',
    'Start a business',
    'Scale my business',
    'Raise funding',
    'Improve operations',
    'Enter new markets',
    'Digital transformation',
  ];

  List<Map<String, dynamic>> get _filteredMentors {
    print(
        '🔍 [MentorScreen] _filteredMentors called. _mentors.length = ${_mentors.length}');
    print(
        '🔍 [MentorScreen] Filters: expertise=$_selectedExpertise, experience=$_selectedExperience, location=$_selectedLocation, goal=$_selectedGoal');

    final filtered = _mentors.where((mentor) {
      // Updated to work with your database field structure
      final matchesExpertise = _selectedExpertise == 'All' ||
          (mentor['expertise'] is List &&
              (mentor['expertise'] as List).any((exp) => exp
                  .toString()
                  .toLowerCase()
                  .contains(_selectedExpertise.toLowerCase())));

      // Updated to use experienceLevel field from your database
      final matchesExperience = _selectedExperience == 'All' ||
          (mentor['experienceLevel']?.toString() == _selectedExperience);

      // Updated location matching - simplified since you don't have is_remote field
      final matchesLocation = _selectedLocation == 'All' ||
          (mentor['location']
                  ?.toString()
                  .toLowerCase()
                  .contains(_selectedLocation.toLowerCase()) ??
              false);

      // Updated to use expertise array as specializations
      final matchesGoal = _selectedGoal == 'All' ||
          (mentor['expertise'] is List &&
              (mentor['expertise'] as List).any((exp) => exp
                  .toString()
                  .toLowerCase()
                  .contains(_selectedGoal.toLowerCase())));

      final matches = matchesExpertise &&
          matchesExperience &&
          matchesLocation &&
          matchesGoal;

      if (!matches) {
        print(
            '🔍 [MentorScreen] Mentor ${mentor['name']} filtered out: expertise=$matchesExpertise, experience=$matchesExperience, location=$matchesLocation, goal=$matchesGoal');
      }

      return matches;
    }).toList();

    print(
        '🔍 [MentorScreen] _filteredMentors returning ${filtered.length} mentors');
    return filtered;
  }

  // Removed _matchesExperienceLevel since we now directly match experienceLevel field

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadMentors();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));

    _cardAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
    _cardController.forward();
  }

  Future<void> _loadMentors() async {
    print('🔍 [MentorScreen] Starting _loadMentors...');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final mentors = await MentorshipService.getAllMentors();
      print(
          '🔍 [MentorScreen] Received ${mentors.length} mentors from service');

      setState(() {
        _mentors = mentors;
        _isLoading = false;
      });

      print(
          '🔍 [MentorScreen] State updated. _mentors.length = ${_mentors.length}');
      print(
          '🔍 [MentorScreen] _filteredMentors.length = ${_filteredMentors.length}');
    } catch (e) {
      print('❌ [MentorScreen] Error loading mentors: $e');

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load mentors: $e';
      });
    }
  }

  Future<void> _searchMentors(String query) async {
    if (query.isEmpty) {
      _loadMentors();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final mentors = await MentorshipService.searchMentors(query);
      setState(() {
        _mentors = mentors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Search failed: $e';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 1, 20, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'Find Your Perfect Mentor',
            style: ModernTheme.headingLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Connect with experienced entrepreneurs and industry experts',
              style: ModernTheme.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Search and Filter
            _buildSearchAndFilter(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _errorMessage != null
                      ? _buildErrorState()
                      : _filteredMentors.isEmpty
                          ? _buildEmptyState()
                          : _buildMentorList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ModernTheme.primaryBlue),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading mentors...',
            style: ModernTheme.bodyLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: ModernTheme.bodyLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadMentors,
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ModernTheme.primaryBlue,
              ModernTheme.teal,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.1),
                      end: Offset.zero,
                    ).animate(_slideAnimation),
                    child: Transform.translate(
                      offset: const Offset(0, -40),
                      child: _buildContent(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ModernTheme.primaryBlue,
              ModernTheme.teal,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ModernTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _showMentorFilters,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(
            Icons.filter_list_rounded,
            color: Colors.white,
          ),
          label: const Text(
            'Advanced Filters',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search mentors by name or expertise...',
                hintStyle: ModernTheme.bodyMedium.copyWith(
                  color: Colors.grey[500],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey[400],
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey[400],
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _loadMentors(); // Reload all mentors when search is cleared
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) => _searchMentors(value),
            ),
          ),
          const SizedBox(height: 16),

          // Filter Chips

          const SizedBox(height: 2),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _expertiseCategories.map((category) {
                final isSelected = _selectedExpertise == category;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: ModernTheme.bodySmall.copyWith(
                        color:
                            isSelected ? Colors.white : ModernTheme.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedExpertise = category;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: ModernTheme.primaryBlue,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? ModernTheme.primaryBlue
                            : Colors.grey[300]!,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorList() {
    return RefreshIndicator(
      color: ModernTheme.primaryBlue,
      onRefresh: _loadMentors,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _filteredMentors.length,
        itemBuilder: (context, index) {
          return AnimatedBuilder(
            animation: _cardAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _cardAnimation.value,
                child: _buildMentorCard(_filteredMentors[index]),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMentorCard(Map<String, dynamic> mentor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showMentorProfile(mentor),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with avatar and rating
                Row(
                  children: [
                    // Mentor Avatar with gradient background
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ModernTheme.primaryBlue,
                            ModernTheme.accentGreen,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: ModernTheme.primaryBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Name and rating
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mentor['name'] ?? 'Unknown Mentor',
                            style: ModernTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: ModernTheme.primaryBlue,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${mentor['rating'] ?? 5.0} (${mentor['total_sessions'] ?? 0} sessions)',
                                style: ModernTheme.bodySmall.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Contact Button
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ModernTheme.accentGreen,
                            ModernTheme.primaryBlue,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: ModernTheme.accentGreen.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Connect',
                        style: ModernTheme.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Expertise badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ModernTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ModernTheme.primaryBlue.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    mentor['expertise'] is List
                        ? (mentor['expertise'] as List).join(', ')
                        : mentor['expertise']?.toString() ?? 'General Business',
                    style: ModernTheme.bodySmall.copyWith(
                      color: ModernTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Company and experience
                Text(
                  '${mentor['experienceLevel'] ?? mentor['experience_years'] ?? 'Unknown'} years • ${mentor['company'] ?? 'Independent'}',
                  style: ModernTheme.bodyMedium.copyWith(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 8),

                // Bio preview
                Text(
                  mentor['bio'] ??
                      mentor['description'] ??
                      'Experienced mentor ready to help you succeed.',
                  style: ModernTheme.bodySmall.copyWith(
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Skills tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _getSkillsList(mentor).take(3).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        skill,
                        style: ModernTheme.bodySmall.copyWith(
                          color: Colors.grey[700],
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _getSkillsList(Map<String, dynamic> mentor) {
    // Try different possible field names for skills
    if (mentor['skills'] is List) {
      return (mentor['skills'] as List).map((e) => e.toString()).toList();
    }
    if (mentor['specializations'] is List) {
      return (mentor['specializations'] as List)
          .map((e) => e.toString())
          .toList();
    }
    if (mentor['areas_of_expertise'] is List) {
      return (mentor['areas_of_expertise'] as List)
          .map((e) => e.toString())
          .toList();
    }

    // Fallback based on expertise
    if (mentor['expertise'] is List) {
      return (mentor['expertise'] as List).map((e) => e.toString()).toList();
    } else if (mentor['expertise'] != null) {
      final expertise = mentor['expertise'].toString();
      if (expertise.isNotEmpty) {
        return [expertise];
      }
    }

    // Default fallback
    return ['Business Strategy', 'Leadership', 'Growth'];
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No mentors found',
            style: ModernTheme.headingMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: ModernTheme.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showMentorProfile(Map<String, dynamic> mentor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Enhanced Header with gradient
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ModernTheme.primaryBlue,
                      ModernTheme.primaryBlue.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Mentor Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Enhanced Profile Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced Avatar and Basic Info
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        ModernTheme.primaryBlue,
                                        ModernTheme.accentGreen,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ModernTheme.primaryBlue
                                            .withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: mentor['avatar'] != null &&
                                            mentor['avatar']
                                                .toString()
                                                .isNotEmpty
                                        ? Image.network(
                                            mentor['avatar'],
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 50,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 50,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: ModernTheme.accentGreen,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.verified,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              mentor['name'] ?? 'Unknown Mentor',
                              style: ModernTheme.headingLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ModernTheme.primaryBlue,
                                fontSize: 24,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ModernTheme.accentGreen.withOpacity(0.1),
                                    ModernTheme.accentGreen.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      ModernTheme.accentGreen.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                mentor['expertise'] is List
                                    ? (mentor['expertise'] as List).join(' • ')
                                    : mentor['expertise']?.toString() ??
                                        'General Business',
                                style: ModernTheme.bodyLarge.copyWith(
                                  color: ModernTheme.accentGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 18,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${mentor['rating'] ?? 4.8}',
                                    style: ModernTheme.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[800],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${mentor['total_sessions'] ?? 15} sessions',
                                    style: ModernTheme.bodySmall.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Professional Summary Card
                      _buildInfoCard(
                        icon: Icons.work_outline,
                        title: 'Professional Background',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.business,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    mentor['company'] ??
                                        'Independent Consultant',
                                    style: ModernTheme.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: ModernTheme.primaryBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.schedule,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  '${mentor['experienceLevel'] ?? mentor['experience_years'] ?? '5+'} years experience',
                                  style: ModernTheme.bodyMedium.copyWith(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            if (mentor['location'] != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    mentor['location'],
                                    style: ModernTheme.bodyMedium.copyWith(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // About Section
                      _buildInfoCard(
                        icon: Icons.info_outline,
                        title: 'About',
                        content: Text(
                          mentor['bio'] ??
                              mentor['description'] ??
                              'Experienced mentor passionate about helping entrepreneurs succeed. I bring years of industry knowledge and a proven track record of guiding startups to success.',
                          style: ModernTheme.bodyMedium.copyWith(
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Expertise Areas
                      _buildInfoCard(
                        icon: Icons.lightbulb_outline,
                        title: 'Expertise Areas',
                        content: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _getSkillsList(mentor).map((skill) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    ModernTheme.primaryBlue.withOpacity(0.1),
                                    ModernTheme.primaryBlue.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      ModernTheme.primaryBlue.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                skill,
                                style: ModernTheme.bodySmall.copyWith(
                                  color: ModernTheme.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Availability & Pricing
                      _buildInfoCard(
                        icon: Icons.access_time,
                        title: 'Availability & Pricing',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.schedule,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  mentor['availability'] ??
                                      'Flexible scheduling',
                                  style: ModernTheme.bodyMedium.copyWith(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (mentor['hourlyRate'] != null)
                              Row(
                                children: [
                                  Icon(Icons.attach_money,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    '\$${mentor['hourlyRate']}/hour',
                                    style: ModernTheme.bodyMedium.copyWith(
                                      color: ModernTheme.accentGreen,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Enhanced Contact Buttons
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _contactMentor(mentor),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ModernTheme.accentGreen,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 3,
                                shadowColor:
                                    ModernTheme.accentGreen.withOpacity(0.3),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.message,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Request Mentorship',
                                    style: ModernTheme.bodyLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                // TODO: Implement view profile action
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Full profile coming soon!'),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: const BorderSide(
                                  color: ModernTheme.primaryBlue,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.person_outline,
                                    color: ModernTheme.primaryBlue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'View Full Profile',
                                    style: ModernTheme.bodyLarge.copyWith(
                                      color: ModernTheme.primaryBlue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ModernTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: ModernTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: ModernTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ModernTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  void _contactMentor(Map<String, dynamic> mentor) {
    Navigator.pop(context); // Close the profile modal first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MentorshipRequestScreen(mentor: mentor),
      ),
    );
  }

  void _showMentorFilters() {
    // Create temporary variables for filter selection
    String tempExperience = _selectedExperience;
    String tempLocation = _selectedLocation;
    String tempGoal = _selectedGoal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Advanced Filters',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // Reset filters
                          setModalState(() {
                            tempExperience = 'All';
                            tempLocation = 'All';
                            tempGoal = 'All';
                          });
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            color: ModernTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                // Filter Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Experience Level
                        Text(
                          'Experience Level',
                          style: ModernTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ModernTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _experienceLevels.map((level) {
                            final isSelected = tempExperience == level;
                            return FilterChip(
                              label: Text(
                                level,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : ModernTheme.primaryBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  tempExperience = selected ? level : 'All';
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: ModernTheme.primaryBlue,
                              checkmarkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? ModernTheme.primaryBlue
                                      : Colors.grey,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Location
                        Text(
                          'Location',
                          style: ModernTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ModernTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _locations.map((location) {
                            final isSelected = tempLocation == location;
                            return FilterChip(
                              label: Text(
                                location,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : ModernTheme.primaryBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  tempLocation = selected ? location : 'All';
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: ModernTheme.primaryBlue,
                              checkmarkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? ModernTheme.primaryBlue
                                      : Colors.grey,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Goals
                        Text(
                          'Business Goals',
                          style: ModernTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ModernTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _goals.map((goal) {
                            final isSelected = tempGoal == goal;
                            return FilterChip(
                              label: Text(
                                goal,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : ModernTheme.primaryBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setModalState(() {
                                  tempGoal = selected ? goal : 'All';
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: ModernTheme.primaryBlue,
                              checkmarkColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? ModernTheme.primaryBlue
                                      : Colors.grey,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Rating (keeping existing)
                        Text(
                          'Minimum Rating',
                          style: ModernTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ModernTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              ['All', '4.5+', '4.0+', '3.5+'].map((rating) {
                            return FilterChip(
                              label: Text(rating),
                              selected: false, // TODO: implement rating filter
                              onSelected: (selected) {},
                              backgroundColor: Colors.white,
                              selectedColor: ModernTheme.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(color: Colors.grey),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 32),

                        // Apply Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Apply filters
                              setState(() {
                                _selectedExperience = tempExperience;
                                _selectedLocation = tempLocation;
                                _selectedGoal = tempGoal;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ModernTheme.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Apply Filters',
                              style: ModernTheme.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
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
