import 'package:flutter/material.dart';
import '../core/theme/modern_theme.dart';
import '../core/widgets/biznest_logo.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _cardAnimation;

  final List<IdeaPost> _ideas = [
    IdeaPost(
      id: '1',
      title: 'AI-Powered Customer Service Bot',
      description:
          'Developing an AI chatbot that can handle customer inquiries 24/7 with natural language processing.',
      author: 'Sarah Chen',
      authorAvatar:
          'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100',
      category: 'Technology',
      likes: 24,
      comments: 8,
      isLiked: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      tags: ['AI', 'Customer Service', 'Automation'],
    ),
    IdeaPost(
      id: '2',
      title: 'Sustainable Packaging Solution',
      description:
          'Creating biodegradable packaging materials from agricultural waste for e-commerce businesses.',
      author: 'Mike Rodriguez',
      authorAvatar:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
      category: 'Sustainability',
      likes: 18,
      comments: 12,
      isLiked: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      tags: ['Sustainability', 'E-commerce', 'Innovation'],
    ),
    IdeaPost(
      id: '3',
      title: 'Remote Team Collaboration Platform',
      description:
          'Building a platform that combines project management, communication, and team building for remote teams.',
      author: 'Emily Johnson',
      authorAvatar:
          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=100',
      category: 'Productivity',
      likes: 31,
      comments: 15,
      isLiked: false,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      tags: ['Remote Work', 'Collaboration', 'Productivity'],
    ),
  ];

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
    super.dispose();
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
                    child: _buildContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateIdeaDialog,
        backgroundColor: Colors.white,
        foregroundColor: ModernTheme.primaryBlue,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Share Idea'),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              const BizNestLogo(size: 40, showText: false),
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
          const SizedBox(height: 20),
          Text(
            'Community Ideas',
            style: ModernTheme.headingLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share, collaborate, and innovate together',
            style: ModernTheme.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: _buildIdeasList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final categories = [
      'All',
      'Technology',
      'Sustainability',
      'Productivity',
      'Finance'
    ];
    String selectedCategory = 'All';

    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = category == selectedCategory;
            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ModernTheme.primaryBlue
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isSelected
                          ? ModernTheme.primaryBlue
                          : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    category,
                    style: ModernTheme.bodyMedium.copyWith(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildIdeasList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _ideas.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _cardAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _cardAnimation.value,
              child: _buildIdeaCard(_ideas[index]),
            );
          },
        );
      },
    );
  }

  Widget _buildIdeaCard(IdeaPost idea) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8FAFC)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(idea.authorAvatar),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            idea.author,
                            style: ModernTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _formatTimestamp(idea.timestamp),
                            style: ModernTheme.bodySmall.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color:
                            _getCategoryColor(idea.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        idea.category,
                        style: ModernTheme.bodySmall.copyWith(
                          color: _getCategoryColor(idea.category),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  idea.title,
                  style: ModernTheme.headingMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  idea.description,
                  style: ModernTheme.bodyMedium.copyWith(
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: idea.tags.map((tag) => _buildTag(tag)).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _toggleLike(idea.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: idea.isLiked
                              ? ModernTheme.primaryBlue.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              idea.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: idea.isLiked
                                  ? ModernTheme.primaryBlue
                                  : Colors.grey[600],
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${idea.likes}',
                              style: ModernTheme.bodySmall.copyWith(
                                color: idea.isLiked
                                    ? ModernTheme.primaryBlue
                                    : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _showComments(idea.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.grey[600],
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${idea.comments}',
                              style: ModernTheme.bodySmall.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _shareIdea(idea),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.share_rounded,
                          color: Colors.grey[600],
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ModernTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        '#$tag',
        style: ModernTheme.bodySmall.copyWith(
          color: ModernTheme.primaryBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Technology':
        return ModernTheme.primaryBlue;
      case 'Sustainability':
        return ModernTheme.accentGreen;
      case 'Productivity':
        return ModernTheme.secondaryPurple;
      case 'Finance':
        return ModernTheme.warningOrange;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _toggleLike(String ideaId) {
    setState(() {
      final idea = _ideas.firstWhere((i) => i.id == ideaId);
      idea.isLiked = !idea.isLiked;
      idea.likes += idea.isLiked ? 1 : -1;
    });
  }

  void _showComments(String ideaId) {
    // Show comments dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comments'),
        content: const Text('Comments feature would be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _shareIdea(IdeaPost idea) {
    // Share idea functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${idea.title}"'),
        backgroundColor: ModernTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showCreateIdeaDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Your Idea'),
        content: const Text('Idea creation form would be implemented here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Create idea
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }
}

class IdeaPost {
  final String id;
  final String title;
  final String description;
  final String author;
  final String authorAvatar;
  final String category;
  int likes;
  final int comments;
  bool isLiked;
  final DateTime timestamp;
  final List<String> tags;

  IdeaPost({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.authorAvatar,
    required this.category,
    required this.likes,
    required this.comments,
    required this.isLiked,
    required this.timestamp,
    required this.tags,
  });
}
