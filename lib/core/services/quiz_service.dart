import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'storage_service.dart';

class QuizService {
  static const String _quizDataKey = 'quiz_data';
  static const String _userLevelKey = 'user_level';
  static const String _quizHistoryKey = 'quiz_history';

  // Quiz questions for entrepreneurial skills assessment
  static final List<Map<String, dynamic>> _quizQuestions = [
    {
      'id': 1,
      'question': 'What is the primary purpose of a business plan?',
      'options': [
        'To secure funding',
        'To outline business strategy and goals',
        'To impress investors',
        'To comply with regulations'
      ],
      'correct_answer': 1,
      'category': 'business_planning',
      'difficulty': 'beginner'
    },
    {
      'id': 2,
      'question': 'Which of the following is NOT a key component of market research?',
      'options': [
        'Target audience analysis',
        'Competitor analysis',
        'Personal preferences',
        'Industry trends'
      ],
      'correct_answer': 2,
      'category': 'market_research',
      'difficulty': 'beginner'
    },
    {
      'id': 3,
      'question': 'What does MVP stand for in startup terminology?',
      'options': [
        'Most Valuable Product',
        'Minimum Viable Product',
        'Maximum Value Proposition',
        'Most Valuable Person'
      ],
      'correct_answer': 1,
      'category': 'product_development',
      'difficulty': 'intermediate'
    },
    {
      'id': 4,
      'question': 'Which financial metric indicates how long a company can operate with current cash?',
      'options': [
        'Revenue',
        'Runway',
        'Profit margin',
        'Cash flow'
      ],
      'correct_answer': 1,
      'category': 'financial_management',
      'difficulty': 'intermediate'
    },
    {
      'id': 5,
      'question': 'What is the primary goal of customer validation?',
      'options': [
        'To increase sales',
        'To prove product-market fit',
        'To reduce costs',
        'To expand market reach'
      ],
      'correct_answer': 1,
      'category': 'customer_development',
      'difficulty': 'advanced'
    },
    {
      'id': 6,
      'question': 'Which funding stage typically comes after seed funding?',
      'options': [
        'Pre-seed',
        'Series A',
        'Angel investment',
        'Bootstrap'
      ],
      'correct_answer': 1,
      'category': 'funding',
      'difficulty': 'intermediate'
    },
    {
      'id': 7,
      'question': 'What is the main purpose of a SWOT analysis?',
      'options': [
        'To calculate financial projections',
        'To assess internal and external factors',
        'To design marketing campaigns',
        'To manage team performance'
      ],
      'correct_answer': 1,
      'category': 'strategic_planning',
      'difficulty': 'beginner'
    },
    {
      'id': 8,
      'question': 'Which legal structure offers the most personal liability protection?',
      'options': [
        'Sole proprietorship',
        'Partnership',
        'Corporation',
        'LLC'
      ],
      'correct_answer': 2,
      'category': 'legal',
      'difficulty': 'intermediate'
    },
    {
      'id': 9,
      'question': 'What is the primary benefit of networking for entrepreneurs?',
      'options': [
        'Reduced competition',
        'Access to resources and opportunities',
        'Lower marketing costs',
        'Simplified business operations'
      ],
      'correct_answer': 1,
      'category': 'networking',
      'difficulty': 'beginner'
    },
    {
      'id': 10,
      'question': 'Which metric is most important for measuring customer acquisition success?',
      'options': [
        'Total revenue',
        'Customer acquisition cost (CAC)',
        'Number of employees',
        'Office size'
      ],
      'correct_answer': 1,
      'category': 'marketing',
      'difficulty': 'advanced'
    }
  ];

  // Get quiz questions
  static List<Map<String, dynamic>> getQuizQuestions() {
    return _quizQuestions;
  }

  // Get questions by difficulty level
  static List<Map<String, dynamic>> getQuestionsByLevel(String level) {
    return _quizQuestions.where((q) => q['difficulty'] == level).toList();
  }

  // Get questions by category
  static List<Map<String, dynamic>> getQuestionsByCategory(String category) {
    return _quizQuestions.where((q) => q['category'] == category).toList();
  }

  // Submit quiz answers and calculate score
  static Future<QuizResult> submitQuiz(List<Map<String, dynamic>> answers) async {
    try {
      int totalQuestions = answers.length;
      int correctAnswers = 0;
      Map<String, int> categoryScores = {};
      Map<String, int> difficultyScores = {};

      for (var answer in answers) {
        int questionId = answer['question_id'];
        int selectedAnswer = answer['selected_answer'];
        
        var question = _quizQuestions.firstWhere((q) => q['id'] == questionId);
        int correctAnswer = question['correct_answer'];
        String category = question['category'];
        String difficulty = question['difficulty'];

        if (selectedAnswer == correctAnswer) {
          correctAnswers++;
        }

        // Track category and difficulty scores
        categoryScores[category] = (categoryScores[category] ?? 0) + 
            (selectedAnswer == correctAnswer ? 1 : 0);
        difficultyScores[difficulty] = (difficultyScores[difficulty] ?? 0) + 
            (selectedAnswer == correctAnswer ? 1 : 0);
      }

      double percentage = (correctAnswers / totalQuestions) * 100;
      String level = _determineUserLevel(percentage, categoryScores);
      
      var result = QuizResult(
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        percentage: percentage,
        level: level,
        categoryScores: categoryScores,
        difficultyScores: difficultyScores,
        timestamp: DateTime.now(),
      );

      // Save quiz result
      await _saveQuizResult(result);
      
      // Update user level
      await _updateUserLevel(level);

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting quiz: $e');
      }
      throw Exception('Failed to submit quiz');
    }
  }

  // Determine user level based on performance
  static String _determineUserLevel(double percentage, Map<String, int> categoryScores) {
    if (percentage >= 90) {
      return 'expert';
    } else if (percentage >= 75) {
      return 'advanced';
    } else if (percentage >= 60) {
      return 'intermediate';
    } else if (percentage >= 40) {
      return 'beginner';
    } else {
      return 'novice';
    }
  }

  // Get user's current level
  static Future<String> getUserLevel() async {
    return await StorageService.getString(_userLevelKey) ?? 'novice';
  }

  // Update user level
  static Future<void> _updateUserLevel(String level) async {
    await StorageService.setString(_userLevelKey, level);
  }

  // Save quiz result
  static Future<void> _saveQuizResult(QuizResult result) async {
    final history = await getQuizHistory();
    history.add(result.toMap());
    
    // Keep only last 10 quiz results
    if (history.length > 10) {
      history.removeRange(0, history.length - 10);
    }
    
    await StorageService.setString(_quizHistoryKey, json.encode(history));
  }

  // Get quiz history
  static Future<List<Map<String, dynamic>>> getQuizHistory() async {
    final historyJson = await StorageService.getString(_quizHistoryKey);
    if (historyJson != null) {
      final List<dynamic> historyList = json.decode(historyJson);
      return historyList.cast<Map<String, dynamic>>();
    }
    return [];
  }

  // Get user's strengths and weaknesses
  static Future<Map<String, dynamic>> getUserAnalysis() async {
    final history = await getQuizHistory();
    if (history.isEmpty) {
      return {
        'strengths': [],
        'weaknesses': [],
        'recommendations': [],
        'progress_trend': 'stable'
      };
    }

    // Analyze recent performance
    final recentResults = history.take(3).toList();
    Map<String, List<double>> categoryPerformance = {};
    
    for (var result in recentResults) {
      final categoryScores = Map<String, int>.from(result['category_scores']);
      for (var entry in categoryScores.entries) {
        categoryPerformance[entry.key] ??= [];
        categoryPerformance[entry.key]!.add(entry.value.toDouble());
      }
    }

    List<String> strengths = [];
    List<String> weaknesses = [];
    List<String> recommendations = [];

    for (var entry in categoryPerformance.entries) {
      double avgScore = entry.value.reduce((a, b) => a + b) / entry.value.length;
      if (avgScore >= 0.8) {
        strengths.add(entry.key);
      } else if (avgScore <= 0.4) {
        weaknesses.add(entry.key);
        recommendations.add('Focus on improving ${entry.key} skills');
      }
    }

    return {
      'strengths': strengths,
      'weaknesses': weaknesses,
      'recommendations': recommendations,
      'progress_trend': _calculateProgressTrend(history),
      'total_quizzes': history.length,
      'average_score': _calculateAverageScore(history),
    };
  }

  // Calculate progress trend
  static String _calculateProgressTrend(List<Map<String, dynamic>> history) {
    if (history.length < 2) return 'stable';
    
    final recent = history.take(3).toList();
    final older = history.skip(3).take(3).toList();
    
    if (recent.isEmpty || older.isEmpty) return 'stable';
    
    double recentAvg = recent.map((r) => r['percentage'] as double).reduce((a, b) => a + b) / recent.length;
    double olderAvg = older.map((r) => r['percentage'] as double).reduce((a, b) => a + b) / older.length;
    
    if (recentAvg > olderAvg + 5) return 'improving';
    if (recentAvg < olderAvg - 5) return 'declining';
    return 'stable';
  }

  // Calculate average score
  static double _calculateAverageScore(List<Map<String, dynamic>> history) {
    if (history.isEmpty) return 0.0;
    
    double total = history.map((r) => r['percentage'] as double).reduce((a, b) => a + b);
    return total / history.length;
  }

  // Get personalized recommendations based on level
  static Future<List<String>> getPersonalizedRecommendations() async {
    final level = await getUserLevel();
    final analysis = await getUserAnalysis();
    
    List<String> recommendations = [];
    
    switch (level) {
      case 'novice':
        recommendations = [
          'Start with basic business concepts',
          'Learn about market research fundamentals',
          'Understand the importance of customer validation',
          'Study successful startup case studies'
        ];
        break;
      case 'beginner':
        recommendations = [
          'Focus on business plan development',
          'Learn about different funding options',
          'Practice networking and communication',
          'Study your target market in detail'
        ];
        break;
      case 'intermediate':
        recommendations = [
          'Develop advanced financial modeling skills',
          'Learn about scaling strategies',
          'Focus on team building and leadership',
          'Study competitive analysis techniques'
        ];
        break;
      case 'advanced':
        recommendations = [
          'Master investor relations and pitching',
          'Learn about international expansion',
          'Focus on strategic partnerships',
          'Study advanced growth strategies'
        ];
        break;
      case 'expert':
        recommendations = [
          'Mentor other entrepreneurs',
          'Share your expertise through content',
          'Focus on innovation and disruption',
          'Consider angel investing or advising'
        ];
        break;
    }

    // Add specific recommendations based on weaknesses
    final weaknesses = analysis['weaknesses'] as List<dynamic>;
    for (var weakness in weaknesses) {
      recommendations.add('Improve your ${weakness} knowledge and skills');
    }

    return recommendations;
  }

  // Get quiz statistics
  static Future<Map<String, dynamic>> getQuizStatistics() async {
    final history = await getQuizHistory();
    final level = await getUserLevel();
    
    if (history.isEmpty) {
      return {
        'total_quizzes': 0,
        'average_score': 0.0,
        'best_score': 0.0,
        'current_level': level,
        'total_questions_answered': 0,
        'correct_answers': 0,
        'accuracy_percentage': 0.0,
      };
    }

    int totalQuizzes = history.length;
    double averageScore = _calculateAverageScore(history);
    double bestScore = history.map((r) => r['percentage'] as double).reduce((a, b) => a > b ? a : b);
    
    int totalQuestions = history.map((r) => r['total_questions'] as int).reduce((a, b) => a + b);
    int correctAnswers = history.map((r) => r['correct_answers'] as int).reduce((a, b) => a + b);
    double accuracy = (correctAnswers / totalQuestions) * 100;

    return {
      'total_quizzes': totalQuizzes,
      'average_score': averageScore,
      'best_score': bestScore,
      'current_level': level,
      'total_questions_answered': totalQuestions,
      'correct_answers': correctAnswers,
      'accuracy_percentage': accuracy,
    };
  }
}

// Quiz result model
class QuizResult {
  final int totalQuestions;
  final int correctAnswers;
  final double percentage;
  final String level;
  final Map<String, int> categoryScores;
  final Map<String, int> difficultyScores;
  final DateTime timestamp;

  QuizResult({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.percentage,
    required this.level,
    required this.categoryScores,
    required this.difficultyScores,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'percentage': percentage,
      'level': level,
      'category_scores': categoryScores,
      'difficulty_scores': difficultyScores,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      totalQuestions: map['total_questions'],
      correctAnswers: map['correct_answers'],
      percentage: map['percentage'].toDouble(),
      level: map['level'],
      categoryScores: Map<String, int>.from(map['category_scores']),
      difficultyScores: Map<String, int>.from(map['difficulty_scores']),
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
