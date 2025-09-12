import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';
import 'quiz_service.dart';

class LearningEngine {
  static const String _learningProgressKey = 'learning_progress';
  static const String _tutorialsKey = 'tutorials';
  static const String _badgesKey = 'user_badges';
  static const String _achievementsKey = 'user_achievements';

  // Tutorial content based on skill levels
  static final Map<String, List<Map<String, dynamic>>> _tutorials = {
    'novice': [
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
            },
            {
              'title': 'Key Characteristics of Entrepreneurs',
              'content': 'Successful entrepreneurs share common traits like innovation, risk-taking, and resilience...',
              'type': 'text'
            },
            {
              'title': 'Quiz: Test Your Understanding',
              'content': 'Answer these questions to test your knowledge',
              'type': 'quiz',
              'questions': [
                {
                  'question': 'What is the main goal of entrepreneurship?',
                  'options': ['To make money', 'To create value', 'To avoid risk', 'To follow others'],
                  'correct': 1
                }
              ]
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
            },
            {
              'title': 'Identifying Target Customers',
              'content': 'Learn how to define your ideal customer profile...',
              'type': 'text'
            }
          ]
        },
        'prerequisites': ['novice_1'],
        'badge': 'market_researcher'
      }
    ],
    'beginner': [
      {
        'id': 'beginner_1',
        'title': 'Creating Your First Business Plan',
        'description': 'Step-by-step guide to writing a business plan',
        'duration': 30,
        'category': 'business_planning',
        'difficulty': 'beginner',
        'content': {
          'sections': [
            {
              'title': 'Executive Summary',
              'content': 'Learn how to write a compelling executive summary...',
              'type': 'text'
            },
            {
              'title': 'Market Analysis',
              'content': 'How to analyze your market and competition...',
              'type': 'text'
            },
            {
              'title': 'Financial Projections',
              'content': 'Creating realistic financial forecasts...',
              'type': 'text'
            }
          ]
        },
        'prerequisites': ['novice_1', 'novice_2'],
        'badge': 'business_planner'
      }
    ],
    'intermediate': [
      {
        'id': 'intermediate_1',
        'title': 'Advanced Financial Modeling',
        'description': 'Master financial modeling for startups',
        'duration': 45,
        'category': 'financial_management',
        'difficulty': 'intermediate',
        'content': {
          'sections': [
            {
              'title': 'Building Financial Models',
              'content': 'Create sophisticated financial models for your startup...',
              'type': 'text'
            },
            {
              'title': 'Valuation Methods',
              'content': 'Learn different startup valuation techniques...',
              'type': 'text'
            }
          ]
        },
        'prerequisites': ['beginner_1'],
        'badge': 'financial_expert'
      }
    ],
    'advanced': [
      {
        'id': 'advanced_1',
        'title': 'Scaling Your Startup',
        'description': 'Strategies for growing your business',
        'duration': 60,
        'category': 'growth',
        'difficulty': 'advanced',
        'content': {
          'sections': [
            {
              'title': 'Growth Strategies',
              'content': 'Different approaches to scaling your business...',
              'type': 'text'
            },
            {
              'title': 'Team Building',
              'content': 'Building and managing a growing team...',
              'type': 'text'
            }
          ]
        },
        'prerequisites': ['intermediate_1'],
        'badge': 'scale_master'
      }
    ],
    'expert': [
      {
        'id': 'expert_1',
        'title': 'Mentoring Other Entrepreneurs',
        'description': 'Share your knowledge and experience',
        'duration': 30,
        'category': 'leadership',
        'difficulty': 'expert',
        'content': {
          'sections': [
            {
              'title': 'Effective Mentoring',
              'content': 'How to be an effective mentor to other entrepreneurs...',
              'type': 'text'
            }
          ]
        },
        'prerequisites': ['advanced_1'],
        'badge': 'mentor'
      }
    ]
  };

  // Get personalized tutorials for user
  static Future<List<Map<String, dynamic>>> getPersonalizedTutorials() async {
    final userLevel = await QuizService.getUserLevel();
    final progress = await getLearningProgress();
    final completedTutorials = progress['completed_tutorials'] as List<dynamic>;
    
    List<Map<String, dynamic>> availableTutorials = [];
    
    // Get tutorials for current level and below
    for (String level in ['novice', 'beginner', 'intermediate', 'advanced', 'expert']) {
      if (_isLevelAccessible(level, userLevel)) {
        final levelTutorials = _tutorials[level] ?? [];
        for (var tutorial in levelTutorials) {
          if (!completedTutorials.contains(tutorial['id']) && 
              _arePrerequisitesMet(tutorial['prerequisites'], completedTutorials)) {
            availableTutorials.add(tutorial);
          }
        }
      }
    }
    
    return availableTutorials;
  }

  // Check if level is accessible based on user's current level
  static bool _isLevelAccessible(String level, String userLevel) {
    final levelOrder = ['novice', 'beginner', 'intermediate', 'advanced', 'expert'];
    final userIndex = levelOrder.indexOf(userLevel);
    final levelIndex = levelOrder.indexOf(level);
    return levelIndex <= userIndex;
  }

  // Check if prerequisites are met
  static bool _arePrerequisitesMet(List<dynamic> prerequisites, List<dynamic> completed) {
    for (var prereq in prerequisites) {
      if (!completed.contains(prereq)) {
        return false;
      }
    }
    return true;
  }

  // Start a tutorial
  static Future<void> startTutorial(String tutorialId) async {
    final progress = await getLearningProgress();
    final inProgress = progress['in_progress_tutorials'] as List<dynamic>;
    
    if (!inProgress.contains(tutorialId)) {
      inProgress.add(tutorialId);
      await _saveLearningProgress(progress);
    }
  }

  // Complete a tutorial
  static Future<TutorialCompletionResult> completeTutorial(
    String tutorialId, 
    Map<String, dynamic> completionData
  ) async {
    try {
      final progress = await getLearningProgress();
      final completed = progress['completed_tutorials'] as List<dynamic>;
      final inProgress = progress['in_progress_tutorials'] as List<dynamic>;
      
      // Remove from in-progress and add to completed
      inProgress.remove(tutorialId);
      if (!completed.contains(tutorialId)) {
        completed.add(tutorialId);
      }
      
      // Calculate score and determine if badge is earned
      final tutorial = _getTutorialById(tutorialId);
      final score = _calculateTutorialScore(completionData);
      final badge = tutorial?['badge'];
      
      // Award badge if earned
      if (badge != null && score >= 70) {
        await _awardBadge(badge);
      }
      
      // Update progress
      await _saveLearningProgress(progress);
      
      // Check for level up
      final newLevel = await _checkLevelUp();
      
      return TutorialCompletionResult(
        tutorialId: tutorialId,
        score: score,
        badgeEarned: badge != null && score >= 70 ? badge : null,
        levelUp: newLevel != null,
        newLevel: newLevel,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error completing tutorial: $e');
      }
      throw Exception('Failed to complete tutorial');
    }
  }

  // Get tutorial by ID
  static Map<String, dynamic>? _getTutorialById(String tutorialId) {
    for (var levelTutorials in _tutorials.values) {
      for (var tutorial in levelTutorials) {
        if (tutorial['id'] == tutorialId) {
          return tutorial;
        }
      }
    }
    return null;
  }

  // Calculate tutorial score
  static double _calculateTutorialScore(Map<String, dynamic> completionData) {
    // Simple scoring based on completion data
    // In a real app, this would be more sophisticated
    final quizAnswers = completionData['quiz_answers'] as List<dynamic>? ?? [];
    final timeSpent = completionData['time_spent'] as int? ?? 0;
    final sectionsCompleted = completionData['sections_completed'] as int? ?? 0;
    
    double score = 0;
    
    // Quiz score (70% weight)
    if (quizAnswers.isNotEmpty) {
      int correctAnswers = 0;
      for (var answer in quizAnswers) {
        if (answer['is_correct'] == true) {
          correctAnswers++;
        }
      }
      score += (correctAnswers / quizAnswers.length) * 70;
    }
    
    // Completion score (20% weight)
    score += (sectionsCompleted / 3) * 20; // Assuming 3 sections average
    
    // Time bonus (10% weight)
    if (timeSpent > 0) {
      score += 10; // Full bonus for spending time
    }
    
    return score.clamp(0, 100);
  }

  // Award badge to user
  static Future<void> _awardBadge(String badgeId) async {
    final badges = await getUserBadges();
    if (!badges.contains(badgeId)) {
      badges.add(badgeId);
      await StorageService.setString(_badgesKey, json.encode(badges));
    }
  }

  // Get user's badges
  static Future<List<String>> getUserBadges() async {
    final badgesJson = await StorageService.getString(_badgesKey);
    if (badgesJson != null) {
      final List<dynamic> badgesList = json.decode(badgesJson);
      return badgesList.cast<String>();
    }
    return [];
  }

  // Check if user should level up
  static Future<String?> _checkLevelUp() async {
    final progress = await getLearningProgress();
    final completed = progress['completed_tutorials'] as List<dynamic>;
    final currentLevel = await QuizService.getUserLevel();
    
    // Simple level up logic based on completed tutorials
    int completedCount = completed.length;
    String? newLevel;
    
    if (completedCount >= 20 && currentLevel != 'expert') {
      newLevel = 'expert';
    } else if (completedCount >= 15 && currentLevel != 'advanced') {
      newLevel = 'advanced';
    } else if (completedCount >= 10 && currentLevel != 'intermediate') {
      newLevel = 'intermediate';
    } else if (completedCount >= 5 && currentLevel != 'beginner') {
      newLevel = 'beginner';
    }
    
    if (newLevel != null) {
      await QuizService.updateUserLevel(newLevel);
    }
    
    return newLevel;
  }

  // Get learning progress
  static Future<Map<String, dynamic>> getLearningProgress() async {
    final progressJson = await StorageService.getString(_learningProgressKey);
    if (progressJson != null) {
      return Map<String, dynamic>.from(json.decode(progressJson));
    }
    return {
      'completed_tutorials': [],
      'in_progress_tutorials': [],
      'total_time_spent': 0,
      'current_streak': 0,
      'longest_streak': 0,
    };
  }

  // Save learning progress
  static Future<void> _saveLearningProgress(Map<String, dynamic> progress) async {
    await StorageService.setString(_learningProgressKey, json.encode(progress));
  }

  // Get learning statistics
  static Future<Map<String, dynamic>> getLearningStatistics() async {
    final progress = await getLearningProgress();
    final badges = await getUserBadges();
    final level = await QuizService.getUserLevel();
    
    return {
      'current_level': level,
      'completed_tutorials': (progress['completed_tutorials'] as List).length,
      'total_badges': badges.length,
      'current_streak': progress['current_streak'] ?? 0,
      'longest_streak': progress['longest_streak'] ?? 0,
      'total_time_spent': progress['total_time_spent'] ?? 0,
      'badges': badges,
    };
  }

  // Get leaderboard data
  static Future<List<Map<String, dynamic>>> getLeaderboard() async {
    // In a real app, this would fetch from a server
    // For now, return mock data
    return [
      {
        'user_id': 'user1',
        'name': 'Alex Johnson',
        'level': 'expert',
        'score': 2850,
        'badges': 12,
        'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100'
      },
      {
        'user_id': 'user2',
        'name': 'Sarah Chen',
        'level': 'advanced',
        'score': 2650,
        'badges': 10,
        'avatar': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100'
      },
      {
        'user_id': 'user3',
        'name': 'Mike Rodriguez',
        'level': 'intermediate',
        'score': 2100,
        'badges': 8,
        'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100'
      }
    ];
  }

  // Get recommended next tutorial
  static Future<Map<String, dynamic>?> getRecommendedTutorial() async {
    final tutorials = await getPersonalizedTutorials();
    if (tutorials.isEmpty) return null;
    
    // Return the first available tutorial
    return tutorials.first;
  }

  // Get tutorial progress
  static Future<Map<String, dynamic>> getTutorialProgress(String tutorialId) async {
    final progress = await getLearningProgress();
    final inProgress = progress['in_progress_tutorials'] as List<dynamic>;
    
    if (inProgress.contains(tutorialId)) {
      return {
        'status': 'in_progress',
        'progress_percentage': 50, // Mock progress
        'sections_completed': 1,
        'total_sections': 3,
      };
    }
    
    final completed = progress['completed_tutorials'] as List<dynamic>;
    if (completed.contains(tutorialId)) {
      return {
        'status': 'completed',
        'progress_percentage': 100,
        'sections_completed': 3,
        'total_sections': 3,
      };
    }
    
    return {
      'status': 'not_started',
      'progress_percentage': 0,
      'sections_completed': 0,
      'total_sections': 3,
    };
  }
}

// Tutorial completion result model
class TutorialCompletionResult {
  final String tutorialId;
  final double score;
  final String? badgeEarned;
  final bool levelUp;
  final String? newLevel;

  TutorialCompletionResult({
    required this.tutorialId,
    required this.score,
    this.badgeEarned,
    required this.levelUp,
    this.newLevel,
  });
}
