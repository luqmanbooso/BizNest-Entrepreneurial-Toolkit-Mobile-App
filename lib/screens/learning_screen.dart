import 'package:flutter/material.dart';
import '../core/theme/modern_theme.dart';
import '../core/services/learning_engine.dart';
import '../core/services/quiz_service.dart';
import 'quiz_screen.dart';
import 'tutorial_screen.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _tutorials = [];
  Map<String, dynamic> _statistics = {};
  List<String> _badges = [];
  String _userLevel = 'novice';

  late AnimationController _staggerController;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _staggerController.forward(); // Start animation immediately
    _loadLearningData();
  }

  void _setupAnimations() {
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animations = List.generate(5, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _staggerController,
          curve: Interval(
            index * 0.15,
            (index + 1) * 0.15 + 0.2,
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _loadLearningData() async {
    try {
      final tutorials = await LearningEngine.getPersonalizedTutorials();
      final statistics = await LearningEngine.getLearningStatistics();
      final badges = await LearningEngine.getUserBadges();
      final level = await QuizService.getUserLevel();

      // If no tutorials loaded, add some default ones for testing
      List<Map<String, dynamic>> finalTutorials = tutorials;
      if (tutorials.isEmpty) {
        finalTutorials = [
          {
            'id': 'novice_1',
            'title': 'Introduction to Entrepreneurship',
            'description': 'Learn the basics of starting a business',
            'duration': 15,
            'category': 'fundamentals',
            'difficulty': 'novice',
            'content': {
              'sections': [
                {
                  'title': 'What is Entrepreneurship?',
                  'content': 'Entrepreneurship is the process of creating, developing, and managing a business venture...',
                  'type': 'text'
                }
              ]
            },
            'prerequisites': [],
            'badge': 'first_steps'
          },
          {
            'id': 'novice_2',
            'title': 'Understanding Your Market',
            'description': 'Learn how to identify and understand your target market',
            'duration': 20,
            'category': 'market_research',
            'difficulty': 'novice',
            'content': {
              'sections': [
                {
                  'title': 'What is Market Research?',
                  'content': 'Market research helps you understand your customers and competition...',
                  'type': 'text'
                }
              ]
            },
            'prerequisites': ['novice_1'],
            'badge': 'market_researcher'
          }
        ];
      }

      if (mounted) {
        setState(() {
          _tutorials = finalTutorials;
          _statistics = statistics;
          _badges = badges;
          _userLevel = level;
        });
      }
    } catch (e) {
      // Set some default tutorials even on error
      setState(() {
        _tutorials = [
          {
            'id': 'default_1',
            'title': 'Getting Started',
            'description': 'Welcome to the learning hub',
            'duration': 10,
            'category': 'introduction',
            'difficulty': 'novice',
            'content': {
              'sections': [
                {
                  'title': 'Welcome!',
                  'content': 'This is your interactive learning experience.',
                  'type': 'text'
                }
              ]
            },
            'prerequisites': [],
            'badge': 'welcome'
          }
        ];
        _statistics = {
          'current_level': 'novice',
          'completed_tutorials': 0,
          'total_badges': 0,
          'current_streak': 0,
          'longest_streak': 0,
          'total_time_spent': 0,
          'badges': [],
        };
        _badges = [];
        _userLevel = 'novice';
      });
    }
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
          child: _buildLearningContent(),
        ),
      ),
    );
  }

  Widget _buildLearningContent() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _animations[0],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _animations[0].value)),
              child: Opacity(
                opacity: _animations[0].value,
                child: _buildHeader(),
              ),
            );
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _animations[1],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - _animations[1].value)),
                      child: Opacity(
                        opacity: _animations[1].value,
                        child: _buildStatisticsCard(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _animations[2],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - _animations[2].value)),
                      child: Opacity(
                        opacity: _animations[2].value,
                        child: _buildBadgesSection(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _animations[3],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - _animations[3].value)),
                      child: Opacity(
                        opacity: _animations[3].value,
                        child: _buildTutorialsSection(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _animations[4],
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - _animations[4].value)),
                      child: Opacity(
                        opacity: _animations[4].value,
                        child: _buildQuickActions(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
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
              Text(
                'Learning Hub',
                style: ModernTheme.headingMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _userLevel.toUpperCase(),
                  style: ModernTheme.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8FAFC)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Progress',
                  style: ModernTheme.headingMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        'Tutorials',
                        '${_statistics['completed_tutorials'] ?? 0}',
                        Icons.school,
                        ModernTheme.primaryBlue,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Badges',
                        '${_statistics['total_badges'] ?? 0}',
                        Icons.emoji_events,
                        ModernTheme.goldenYellow,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        'Streak',
                        '${_statistics['current_streak'] ?? 0}',
                        Icons.local_fire_department,
                        ModernTheme.sunsetOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildProgressBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: ModernTheme.headingMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: ModernTheme.bodySmall.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final completed = _statistics['completed_tutorials'] as int? ?? 0;
    final total = completed + _tutorials.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Learning Progress',
              style: ModernTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: ModernTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: ModernTheme.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    ModernTheme.primaryBlue,
                    ModernTheme.secondaryPurple
                  ],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    if (_badges.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8FAFC)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Badges',
                  style: ModernTheme.headingMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _badges.map((badge) => _buildBadge(badge)).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String badgeName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [ModernTheme.primaryBlue, ModernTheme.secondaryPurple],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            badgeName.replaceAll('_', ' ').toUpperCase(),
            style: ModernTheme.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8FAFC)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended Tutorials',
                  style: ModernTheme.headingMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (_tutorials.isEmpty)
                  _buildEmptyTutorials()
                else
                  ..._tutorials
                      .take(3)
                      .map((tutorial) => _buildTutorialCard(tutorial)),
                if (_tutorials.length > 3)
                  TextButton(
                    onPressed: _viewAllTutorials,
                    child: const Text('View All Tutorials'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTutorials() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tutorials available',
            style: ModernTheme.bodyLarge.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete more quizzes to unlock tutorials',
            style: ModernTheme.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialCard(Map<String, dynamic> tutorial) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _startTutorial(tutorial),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ModernTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.play_circle_outline,
                  color: ModernTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutorial['title'],
                      style: ModernTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tutorial['description'],
                      style: ModernTheme.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(tutorial['difficulty'])
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tutorial['difficulty'].toString().toUpperCase(),
                            style: ModernTheme.bodySmall.copyWith(
                              color:
                                  _getDifficultyColor(tutorial['difficulty']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${tutorial['duration']} min',
                          style: ModernTheme.bodySmall.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF8FAFC)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: ModernTheme.headingMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        'Take Quiz',
                        Icons.quiz,
                        ModernTheme.primaryBlue,
                        _takeQuiz,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionButton(
                        'View Progress',
                        Icons.analytics,
                        ModernTheme.secondaryPurple,
                        _viewProgress,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionButton(
                        'Leaderboard',
                        Icons.leaderboard,
                        Colors.orange,
                        _viewLeaderboard,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickActionButton(
                        'Recommendations',
                        Icons.lightbulb,
                        Colors.green,
                        _viewRecommendations,
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

  Widget _buildQuickActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              text,
              style: ModernTheme.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'novice':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _startTutorial(Map<String, dynamic> tutorial) {
    // Navigate to tutorial screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorialScreen(tutorial: tutorial),
      ),
    ).then((_) {
      // Refresh tutorials when returning from tutorial
      _loadLearningData();
    });
  }

  void _takeQuiz() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuizScreen()),
    ).then((_) {
      // Refresh data when returning from quiz
      _loadLearningData();
    });
  }

  void _viewProgress() {
    // Show progress details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Learning Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Completed Tutorials: ${_statistics['completed_tutorials']}'),
            Text('Total Badges: ${_statistics['total_badges']}'),
            Text('Current Streak: ${_statistics['current_streak']} days'),
            Text('Current Level: ${_statistics['current_level']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewLeaderboard() async {
    final leaderboard = await LearningEngine.getLeaderboard();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leaderboard'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final user = leaderboard[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user['avatar']),
                ),
                title: Text(user['name']),
                subtitle: Text('Level: ${user['level']}'),
                trailing: Text('${user['score']} pts'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewRecommendations() async {
    final recommendations = await QuizService.getPersonalizedRecommendations();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personalized Recommendations'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: recommendations
                .map((rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb,
                              color: ModernTheme.primaryBlue, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(rec)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewAllTutorials() {
    // Navigate to all tutorials screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Tutorials'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _tutorials.length,
            itemBuilder: (context, index) {
              final tutorial = _tutorials[index];
              return ListTile(
                title: Text(tutorial['title']),
                subtitle: Text(tutorial['description']),
                trailing: Text('${tutorial['duration']} min'),
                onTap: () {
                  Navigator.pop(context);
                  _startTutorial(tutorial);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
