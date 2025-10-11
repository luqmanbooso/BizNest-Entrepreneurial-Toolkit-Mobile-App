import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
      // Check and update streak on load
      await LearningEngine.checkAndUpdateStreak();

      // Update leaderboard entry on load
      await LearningEngine.updateLeaderboardEntry();

      final tutorials = await LearningEngine.getPersonalizedTutorials();
      final statistics = await LearningEngine.getLearningStatistics();
      final badges = await LearningEngine.getUserBadges();
      final level = await QuizService.getUserLevel();

      if (kDebugMode) {
        print('🎯 Learning Screen: Current level is $level');
        print('🎯 Learning Screen: ${tutorials.length} tutorials loaded');
        for (var tutorial in tutorials) {
          print('  📚 ${tutorial['title']} (${tutorial['difficulty']})');
        }
      }

      if (kDebugMode) {
        print('🎯 Final tutorial count: ${tutorials.length}');
      }

      if (mounted) {
        setState(() {
          _tutorials = tutorials;
          _statistics = statistics;
          _badges = badges;
          _userLevel = level;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading learning data: $e');
      }
      setState(() {
        _tutorials = [];
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
              Row(
                children: [
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
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _showResetDialog,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
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
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: QuizService.getQuizEligibilityInfo(),
                        builder: (context, snapshot) {
                          final canTakeQuiz =
                              snapshot.data?['canTakeQuiz'] ?? false;
                          final remainingTutorials =
                              snapshot.data?['remainingTutorials'] ?? 0;

                          return _buildQuickActionButton(
                            canTakeQuiz ? 'Take Quiz' : 'Quiz Locked',
                            canTakeQuiz ? Icons.quiz : Icons.lock,
                            canTakeQuiz
                                ? ModernTheme.primaryBlue
                                : Colors.orange,
                            _takeQuiz,
                            subtitle: canTakeQuiz
                                ? null
                                : '$remainingTutorials tutorials left',
                          );
                        },
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
    VoidCallback onTap, {
    String? subtitle,
  }) {
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
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: ModernTheme.bodySmall.copyWith(
                  color: color.withOpacity(0.7),
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
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

  void _takeQuiz() async {
    // Check if user can take quiz (completed current level tutorials)
    final eligibilityInfo = await QuizService.getQuizEligibilityInfo();
    final canTakeQuiz = eligibilityInfo['canTakeQuiz'] as bool;
    final remainingTutorials = eligibilityInfo['remainingTutorials'] as int;
    final userLevel = eligibilityInfo['userLevel'] as String;
    final remainingTitles =
        eligibilityInfo['remainingTutorialTitles'] as List<dynamic>;

    if (!canTakeQuiz) {
      // Show dialog explaining what tutorials need to be completed
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lock, color: Colors.orange),
              const SizedBox(width: 8),
              Text('Quiz Locked'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You need to complete all ${userLevel.toUpperCase()} level tutorials before taking the quiz.',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Text(
                'Remaining tutorials ($remainingTutorials):',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...remainingTitles.map((title) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 6, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(child: Text(title.toString())),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Complete these tutorials to unlock the quiz and advance to the next level!',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ],
        ),
      );
      return;
    }

    // If eligible, proceed with quiz
    if (kDebugMode) {
      print(
          '🎯 Taking quiz - User level: $userLevel, Can take quiz: $canTakeQuiz');
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QuizScreen()),
    ).then((_) {
      if (kDebugMode) {
        print('🔄 Returned from quiz screen, reloading learning data');
      }
      // Refresh data when returning from quiz
      _loadLearningData();
    });
  }

  void _viewProgress() {
    // Show detailed progress dialog
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ModernTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.analytics,
                      color: ModernTheme.primaryBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Learning Progress',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildProgressItem(
                'Tutorials Completed',
                '${_statistics['completed_tutorials']}',
                Icons.school,
                ModernTheme.primaryBlue,
              ),
              const SizedBox(height: 16),
              _buildProgressItem(
                'Badges Earned',
                '${_statistics['total_badges']}',
                Icons.emoji_events,
                ModernTheme.goldenYellow,
              ),
              const SizedBox(height: 16),
              _buildProgressItem(
                'Current Streak',
                '${_statistics['current_streak']} days',
                Icons.local_fire_department,
                ModernTheme.sunsetOrange,
              ),
              const SizedBox(height: 16),
              _buildProgressItem(
                'Longest Streak',
                '${_statistics['longest_streak'] ?? 0} days',
                Icons.stars,
                Colors.purple,
              ),
              const SizedBox(height: 16),
              _buildProgressItem(
                'Current Level',
                '${_statistics['current_level']}'.toUpperCase(),
                Icons.military_tech,
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildProgressItem(
                'Time Spent',
                '${(_statistics['total_time_spent'] ?? 0) ~/ 60} minutes',
                Icons.access_time,
                Colors.indigo,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ModernTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Reset Learning Progress',
                style: ModernTheme.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to reset all your learning progress?',
              style: ModernTheme.bodyMedium.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This will permanently delete:',
                    style: ModernTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildResetItem('• All completed tutorials'),
                  _buildResetItem('• Quiz scores and history'),
                  _buildResetItem('• Earned badges and achievements'),
                  _buildResetItem('• Learning streaks and statistics'),
                  _buildResetItem('• Current level progress'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: ModernTheme.bodyMedium.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performReset();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Reset All Progress'),
          ),
        ],
      ),
    );
  }

  Widget _buildResetItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: ModernTheme.bodySmall.copyWith(
          color: Colors.red[700],
        ),
      ),
    );
  }

  Future<void> _performReset() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(ModernTheme.primaryBlue),
              ),
              SizedBox(height: 16),
              Text('Resetting progress...'),
            ],
          ),
        ),
      );

      // Reset learning progress
      await LearningEngine.resetLearningProgress();

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Reload data
      await _loadLearningData();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Learning progress reset successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.pop(context);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error resetting progress: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _viewLeaderboard() async {
    final leaderboard = await LearningEngine.getLeaderboard();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.orange.shade600
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.leaderboard,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Leaderboard',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Top learners in the community',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final user = leaderboard[index];
                    final isTop3 = index < 3;
                    final medalColors = [
                      Colors.amber,
                      Colors.grey[400]!,
                      Colors.brown[400]!,
                    ];

                    final isCurrentUser = user['is_current_user'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: isTop3
                            ? LinearGradient(
                                colors: [
                                  medalColors[index].withOpacity(0.1),
                                  medalColors[index].withOpacity(0.05),
                                ],
                              )
                            : isCurrentUser
                                ? LinearGradient(
                                    colors: [
                                      ModernTheme.primaryBlue.withOpacity(0.15),
                                      ModernTheme.primaryBlue.withOpacity(0.05),
                                    ],
                                  )
                                : null,
                        color:
                            (isTop3 || isCurrentUser) ? null : Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isTop3
                              ? medalColors[index].withOpacity(0.3)
                              : isCurrentUser
                                  ? ModernTheme.primaryBlue.withOpacity(0.5)
                                  : Colors.grey[200]!,
                          width: (isTop3 || isCurrentUser) ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isTop3
                                    ? medalColors[index]
                                    : Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: isTop3
                                ? medalColors[index].withOpacity(0.3)
                                : Colors.grey[300],
                            child: Text(
                              (user['name'] ?? 'U').toString()[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    isTop3 ? medalColors[index] : Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        user['name'] ?? 'Unknown User',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: isCurrentUser
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: isCurrentUser
                                              ? ModernTheme.primaryBlue
                                              : null,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isCurrentUser) ...[
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ModernTheme.primaryBlue,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'YOU',
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: ModernTheme.primaryBlue
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          (user['level'] ?? 'novice')
                                              .toString()
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: ModernTheme.primaryBlue,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.emoji_events,
                                      size: 12,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 2),
                                    Flexible(
                                      child: Text(
                                        '${user['badges'] ?? 0}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${user['score'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isTop3
                                      ? medalColors[index]
                                      : ModernTheme.primaryBlue,
                                ),
                              ),
                              Text(
                                'pts',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewRecommendations() async {
    final recommendations = await QuizService.getPersonalizedRecommendations();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lightbulb,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Recommendations',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Personalized learning suggestions based on your progress',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: recommendations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No recommendations yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Complete more tutorials to get personalized suggestions',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: recommendations.length,
                        itemBuilder: (context, index) {
                          final rec = recommendations[index];
                          final colors = [
                            Colors.blue,
                            Colors.purple,
                            Colors.orange,
                            Colors.teal,
                            Colors.pink,
                          ];
                          final color = colors[index % colors.length];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  color.withOpacity(0.1),
                                  color.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: color.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome,
                                    color: color,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Recommendation ${index + 1}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: color,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        rec,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
