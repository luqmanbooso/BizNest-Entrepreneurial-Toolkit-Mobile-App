import 'package:flutter/material.dart';
import '../core/theme/modern_theme.dart';

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

  final List<Map<String, dynamic>> _mentors = [
    {
      'id': '1',
      'name': 'Sarah Johnson',
      'expertise': 'Business Strategy',
      'experience': '15 years',
      'company': 'Former CEO, TechStartup Inc.',
      'bio': 'Helping entrepreneurs build scalable business models and go-to-market strategies.',
      'skills': ['Strategy', 'Fundraising', 'Scaling'],
      'image': 'assets/images/mentor1.jpg',
      'rating': 4.9,
      'sessions': 127,
    },
    {
      'id': '2',
      'name': 'Michael Chen',
      'expertise': 'Funding',
      'experience': '12 years',
      'company': 'VC Partner, Growth Capital',
      'bio': 'Expert in startup funding, pitch preparation, and investor relations.',
      'skills': ['VC', 'Pitch Deck', 'Term Sheets'],
      'image': 'assets/images/mentor2.jpg',
      'rating': 4.8,
      'sessions': 89,
    },
    {
      'id': '3',
      'name': 'Emily Rodriguez',
      'expertise': 'Marketing',
      'experience': '10 years',
      'company': 'CMO, Digital Agency Pro',
      'bio': 'Specializing in digital marketing, brand building, and customer acquisition.',
      'skills': ['Digital Marketing', 'SEO', 'Social Media'],
      'image': 'assets/images/mentor3.jpg',
      'rating': 4.7,
      'sessions': 156,
    },
    {
      'id': '4',
      'name': 'David Kim',
      'expertise': 'Technology',
      'experience': '18 years',
      'company': 'CTO, Innovation Labs',
      'bio': 'Technical leadership and product development expertise for tech startups.',
      'skills': ['Product Development', 'Tech Strategy', 'Engineering'],
      'image': 'assets/images/mentor4.jpg',
      'rating': 4.9,
      'sessions': 203,
    },
  ];

  List<Map<String, dynamic>> get _filteredMentors {
    return _mentors.where((mentor) {
      final matchesExpertise = _selectedExpertise == 'All' || mentor['expertise'] == _selectedExpertise;
      final matchesSearch = _searchController.text.isEmpty ||
          mentor['name'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
          mentor['expertise'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
          mentor['bio'].toLowerCase().contains(_searchController.text.toLowerCase());

      // For now, we'll assume all mentors match the advanced filters since we don't have this data in the mock data
      // In a real app, you'd check against mentor['experience'], mentor['location'], mentor['goals']
      final matchesExperience = _selectedExperience == 'All' ||
          (_selectedExperience == '1-3 years' && mentor['experience'].contains('1') ||
           _selectedExperience == '3-5 years' && mentor['experience'].contains('3') ||
           _selectedExperience == '5-10 years' && mentor['experience'].contains('5') ||
           _selectedExperience == '10+ years' && mentor['experience'].contains('10'));

      final matchesLocation = _selectedLocation == 'All'; // All mentors are considered remote for now
      final matchesGoal = _selectedGoal == 'All'; // All mentors can help with any goal for now

      return matchesExpertise && matchesSearch && matchesExperience && matchesLocation && matchesGoal;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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
              child: _filteredMentors.isEmpty
                  ? _buildEmptyState()
                  : _buildMentorList(),
            ),
          ],
        ),
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
          gradient: LinearGradient(
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
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (value) => setState(() {}),
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
                        color: isSelected ? Colors.white : ModernTheme.primaryBlue,
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
                        color: isSelected ? ModernTheme.primaryBlue : Colors.grey[300]!,
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
    return ListView.builder(
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
                        gradient: LinearGradient(
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
                            mentor['name'],
                            style: ModernTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: ModernTheme.primaryBlue,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${mentor['rating']} (${mentor['sessions']} sessions)',
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ModernTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ModernTheme.primaryBlue.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    mentor['expertise'],
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
                  '${mentor['experience']} • ${mentor['company']}',
                  style: ModernTheme.bodyMedium.copyWith(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 8),

                // Bio preview
                Text(
                  mentor['bio'],
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
                  children: (mentor['skills'] as List<String>).take(3).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                      'Mentor Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Profile Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar and Basic Info
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: ModernTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.person,
                                color: ModernTheme.primaryBlue,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              mentor['name'],
                              style: ModernTheme.headingLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ModernTheme.primaryBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mentor['expertise'],
                              style: ModernTheme.bodyLarge.copyWith(
                                color: ModernTheme.accentGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 18,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${mentor['rating']} (${mentor['sessions']} sessions)',
                                  style: ModernTheme.bodyMedium.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Experience & Company
                      Text(
                        'Experience',
                        style: ModernTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ModernTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${mentor['experience']} • ${mentor['company']}',
                        style: ModernTheme.bodyMedium.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bio
                      Text(
                        'About',
                        style: ModernTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ModernTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mentor['bio'],
                        style: ModernTheme.bodyMedium.copyWith(
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Skills
                      Text(
                        'Expertise Areas',
                        style: ModernTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ModernTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (mentor['skills'] as List<String>).map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: ModernTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              skill,
                              style: ModernTheme.bodySmall.copyWith(
                                color: ModernTheme.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 32),

                      // Contact Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _contactMentor(mentor),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ModernTheme.accentGreen,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Request Mentorship',
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
    );
  }

  void _contactMentor(Map<String, dynamic> mentor) {
    // For MVP, show a simple contact form
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact ${mentor['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Send a mentorship request to ${mentor['name']}. They will be notified and can respond to your request.',
              style: ModernTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Briefly describe what you\'d like to discuss...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Mentorship request sent to ${mentor['name']}!'),
                  backgroundColor: ModernTheme.accentGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.accentGreen,
            ),
            child: const Text('Send Request'),
          ),
        ],
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
                        child: Text(
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
                                  color: isSelected ? Colors.white : ModernTheme.primaryBlue,
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
                                  color: isSelected ? ModernTheme.primaryBlue : Colors.grey,
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
                                  color: isSelected ? Colors.white : ModernTheme.primaryBlue,
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
                                  color: isSelected ? ModernTheme.primaryBlue : Colors.grey,
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
                                  color: isSelected ? Colors.white : ModernTheme.primaryBlue,
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
                                  color: isSelected ? ModernTheme.primaryBlue : Colors.grey,
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
                          children: ['All', '4.5+', '4.0+', '3.5+'].map((rating) {
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