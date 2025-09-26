import 'package:flutter/material.dart';
import '../core/theme/modern_theme.dart';

class MentorScreen extends StatefulWidget {
  const MentorScreen({super.key});

  @override
  State<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends State<MentorScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedExpertise = 'All';

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
      return matchesExpertise && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: _filteredMentors.isEmpty
                ? _buildEmptyState()
                : _buildMentorList(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'Find a Mentor',
        style: ModernTheme.headingMedium.copyWith(
          color: ModernTheme.primaryBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: ModernTheme.primaryBlue),
        onPressed: () => Navigator.pop(context),
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
          Text(
            'Filter by Expertise',
            style: ModernTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: ModernTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 12),
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
        final mentor = _filteredMentors[index];
        return _buildMentorCard(mentor);
      },
    );
  }

  Widget _buildMentorCard(Map<String, dynamic> mentor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showMentorProfile(mentor),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Mentor Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: ModernTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person,
                    color: ModernTheme.primaryBlue,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),

                // Mentor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mentor['name'],
                        style: ModernTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ModernTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mentor['expertise'],
                        style: ModernTheme.bodyMedium.copyWith(
                          color: ModernTheme.accentGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mentor['company'],
                        style: ModernTheme.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
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
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Contact Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ModernTheme.accentGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Contact',
                    style: ModernTheme.bodySmall.copyWith(
                      color: ModernTheme.accentGreen,
                      fontWeight: FontWeight.w600,
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
}