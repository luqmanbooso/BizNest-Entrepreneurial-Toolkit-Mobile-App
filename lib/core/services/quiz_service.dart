import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'firebase_data_service.dart';
import 'learning_engine.dart';

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
      'difficulty': 'novice',
      'explanation': 'A business plan serves as a roadmap for your business, outlining your strategy, goals, and how you plan to achieve them. While securing funding is important, the primary purpose is to provide a clear direction for your business operations.',
      'hint': 'Think about what guides your business decisions and operations.',
      'learning_tip': 'A good business plan should be reviewed and updated regularly as your business evolves.'
    },
    {
      'id': 2,
      'question':
          'Which of the following is NOT a key component of market research?',
      'options': [
        'Target audience analysis',
        'Competitor analysis',
        'Personal preferences',
        'Industry trends'
      ],
      'correct_answer': 2,
      'category': 'market_research',
      'difficulty': 'novice',
      'explanation': 'Market research focuses on objective data about markets, customers, and competitors. Personal preferences are subjective and not part of formal market research methodology.',
      'hint': 'Market research should be based on data, not personal opinions.',
      'learning_tip': 'Always validate your assumptions with real market data before making business decisions.'
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
      'difficulty': 'intermediate',
      'explanation': 'MVP stands for Minimum Viable Product - the simplest version of your product that allows you to test your business hypothesis with real customers.',
      'hint': 'It\'s about testing your idea with the least amount of resources.',
      'learning_tip': 'Focus on building an MVP that solves the core problem for your target customers.'
    },
    {
      'id': 4,
      'question':
          'Which financial metric indicates how long a company can operate with current cash?',
      'options': ['Revenue', 'Runway', 'Profit margin', 'Cash flow'],
      'correct_answer': 1,
      'category': 'financial_management',
      'difficulty': 'intermediate',
      'explanation': 'Runway measures how many months a company can continue operating with its current cash reserves. It\'s calculated by dividing current cash by monthly burn rate.',
      'hint': 'It\'s about how long your current cash will last.',
      'learning_tip': 'Monitor your runway closely and plan fundraising before you run out of cash.'
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
      'difficulty': 'advanced',
      'explanation': 'Customer validation proves that your product solves a real problem for a specific group of customers who are willing to pay for it.',
      'hint': 'It\'s about confirming that customers actually want and need your solution.',
      'learning_tip': 'Never assume you know what customers want - always validate with real users.'
    },
    {
      'id': 6,
      'question': 'Which funding stage typically comes after seed funding?',
      'options': ['Pre-seed', 'Series A', 'Angel investment', 'Bootstrap'],
      'correct_answer': 1,
      'category': 'funding',
      'difficulty': 'intermediate',
      'explanation': 'The typical startup funding progression is: Pre-seed → Seed → Series A → Series B → Series C. Series A comes after seed funding.',
      'hint': 'Seed funding is the first institutional round of funding.',
      'learning_tip': 'Each funding stage has different requirements and expectations from investors.'
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
      'difficulty': 'novice',
      'explanation': 'SWOT (Strengths, Weaknesses, Opportunities, Threats) analysis helps you understand your internal capabilities and external environment.',
      'hint': 'It examines both internal and external factors affecting your business.',
      'learning_tip': 'Conduct SWOT analysis regularly as your business and market conditions change.'
    },
    {
      'id': 8,
      'question':
          'Which legal structure offers the most personal liability protection?',
      'options': ['Sole proprietorship', 'Partnership', 'Corporation', 'LLC'],
      'correct_answer': 2,
      'category': 'legal',
      'difficulty': 'intermediate',
      'explanation': 'A corporation provides the strongest liability protection by creating a separate legal entity. However, it also has more complex requirements and potential double taxation.',
      'hint': 'It creates a separate legal entity from its owners.',
      'learning_tip': 'Choose your legal structure based on liability protection, tax implications, and operational complexity.'
    },
    {
      'id': 9,
      'question':
          'What is the primary benefit of networking for entrepreneurs?',
      'options': [
        'Reduced competition',
        'Access to resources and opportunities',
        'Lower marketing costs',
        'Simplified business operations'
      ],
      'correct_answer': 1,
      'category': 'networking',
      'difficulty': 'novice',
      'explanation': 'Networking provides access to mentors, partners, investors, customers, and other valuable resources that can accelerate your business growth.',
      'hint': 'It\'s about building relationships that provide value to your business.',
      'learning_tip': 'Focus on building genuine relationships rather than just collecting business cards.'
    },
    {
      'id': 10,
      'question':
          'Which metric is most important for measuring customer acquisition success?',
      'options': [
        'Total revenue',
        'Customer acquisition cost (CAC)',
        'Number of employees',
        'Office size'
      ],
      'correct_answer': 1,
      'category': 'marketing',
      'difficulty': 'advanced',
      'explanation': 'CAC measures how much it costs to acquire each new customer. It\'s crucial for understanding the efficiency of your marketing and sales efforts.',
      'hint': 'It measures the cost effectiveness of gaining new customers.',
      'learning_tip': 'Compare your CAC with customer lifetime value (LTV) to ensure profitability.'
    },
    {
      'id': 11,
      'question': 'What is the main difference between a product and a service?',
      'options': [
        'Products are tangible, services are intangible',
        'Products are cheaper than services',
        'Services don\'t require marketing',
        'Products can be stored, services cannot'
      ],
      'correct_answer': 0,
      'category': 'business_fundamentals',
      'difficulty': 'novice',
      'explanation': 'Products are physical items that customers can touch and own, while services are intangible experiences or actions performed for customers.',
      'hint': 'Think about what you can hold in your hand vs. what you experience.',
      'learning_tip': 'Understanding this difference helps you choose the right business model and marketing strategies.'
    },
    {
      'id': 12,
      'question': 'Which of these is NOT a common pricing strategy?',
      'options': [
        'Cost-plus pricing',
        'Value-based pricing',
        'Competition-based pricing',
        'Random pricing'
      ],
      'correct_answer': 3,
      'category': 'pricing_strategy',
      'difficulty': 'novice',
      'explanation': 'Random pricing is not a legitimate pricing strategy. Businesses use cost-plus, value-based, or competition-based pricing to set prices strategically.',
      'hint': 'Businesses set prices for specific business reasons, not randomly.',
      'learning_tip': 'Choose a pricing strategy that aligns with your business goals and target market.'
    },
    {
      'id': 13,
      'question': 'What does ROI stand for in business?',
      'options': [
        'Return on Investment',
        'Rate of Income',
        'Revenue on Inventory',
        'Return of Interest'
      ],
      'correct_answer': 0,
      'category': 'financial_management',
      'difficulty': 'novice',
      'explanation': 'ROI (Return on Investment) measures the profitability of an investment by comparing the gain or loss relative to the cost.',
      'hint': 'It\'s a percentage that shows how much profit you make from your investment.',
      'learning_tip': 'Always calculate ROI before making business investments to ensure they\'re worthwhile.'
    },
    {
      'id': 14,
      'question': 'What is a target market?',
      'options': [
        'The location of your business',
        'The group of customers most likely to buy your product',
        'Your business competitors',
        'Your marketing budget'
      ],
      'correct_answer': 1,
      'category': 'market_research',
      'difficulty': 'novice',
      'explanation': 'A target market is a specific group of customers who are most likely to buy your products or services based on demographics, interests, and needs.',
      'hint': 'It\'s about knowing who your ideal customers are.',
      'learning_tip': 'Define your target market clearly to focus your marketing efforts effectively.'
    },
    {
      'id': 15,
      'question': 'Which of these is a fixed cost for most businesses?',
      'options': [
        'Raw materials',
        'Rent',
        'Packaging',
        'Shipping'
      ],
      'correct_answer': 1,
      'category': 'financial_management',
      'difficulty': 'novice',
      'explanation': 'Fixed costs remain the same regardless of business activity level, like rent, insurance, and salaries. Variable costs change with production volume.',
      'hint': 'It doesn\'t change based on how much you sell.',
      'learning_tip': 'Understanding fixed vs. variable costs helps with pricing and profitability analysis.'
    },
    {
      'id': 16,
      'question': 'What is a competitive advantage?',
      'options': [
        'Having the lowest prices',
        'Something that makes your business better than competitors',
        'Having the most employees',
        'Being the oldest business in town'
      ],
      'correct_answer': 1,
      'category': 'strategic_planning',
      'difficulty': 'intermediate',
      'explanation': 'A competitive advantage is any factor that allows a company to provide value to customers better than its competitors, such as unique products, better service, or cost efficiency.',
      'hint': 'It\'s what sets you apart from the competition.',
      'learning_tip': 'Identify and leverage your competitive advantages to stand out in the market.'
    },
    {
      'id': 17,
      'question': 'What is the break-even point?',
      'options': [
        'When you start making a profit',
        'When revenue equals total costs',
        'When you have no more debt',
        'When you reach your sales goal'
      ],
      'correct_answer': 1,
      'category': 'financial_management',
      'difficulty': 'intermediate',
      'explanation': 'The break-even point is when total revenue equals total costs, meaning you\'re neither making nor losing money.',
      'hint': 'It\'s the point where you stop losing money.',
      'learning_tip': 'Calculate your break-even point to understand how much you need to sell to be profitable.'
    },
    {
      'id': 18,
      'question': 'What is a value proposition?',
      'options': [
        'Your product\'s price',
        'The unique value your product offers customers',
        'Your business location',
        'Your marketing budget'
      ],
      'correct_answer': 1,
      'category': 'marketing',
      'difficulty': 'intermediate',
      'explanation': 'A value proposition is a clear statement of the unique value your product or service provides to customers and why they should choose you over competitors.',
      'hint': 'It\'s about what makes your offering special and valuable.',
      'learning_tip': 'Craft a compelling value proposition to attract and retain customers.'
    },
    {
      'id': 19,
      'question': 'What is market penetration?',
      'options': [
        'Entering a new market',
        'Selling more in your existing market',
        'Reducing your prices',
        'Expanding your product line'
      ],
      'correct_answer': 1,
      'category': 'marketing',
      'difficulty': 'intermediate',
      'explanation': 'Market penetration involves selling more of your existing products to your existing market through strategies like increasing market share or frequency of purchase.',
      'hint': 'It\'s about growing within your current market.',
      'learning_tip': 'Market penetration is often the first growth strategy businesses should consider.'
    },
    {
      'id': 20,
      'question': 'What is a pivot in startup terminology?',
      'options': [
        'Changing your business direction significantly',
        'Hiring new employees',
        'Moving to a new location',
        'Increasing your prices'
      ],
      'correct_answer': 0,
      'category': 'strategic_planning',
      'difficulty': 'intermediate',
      'explanation': 'A pivot is a fundamental change in a business strategy, often involving changing the product, target market, or business model when the original approach isn\'t working.',
      'hint': 'It\'s when you change course dramatically.',
      'learning_tip': 'Be willing to pivot when data shows your current strategy isn\'t working.'
    },
    {
      'id': 21,
      'question': 'What is the customer acquisition cost (CAC) payback period?',
      'options': [
        'How long it takes to recover CAC through customer revenue',
        'How long customers stay with your business',
        'How much customers spend in their first purchase',
        'How many customers you acquire per month'
      ],
      'correct_answer': 0,
      'category': 'financial_management',
      'difficulty': 'advanced',
      'explanation': 'CAC payback period is the time it takes for a customer to generate enough revenue to cover the cost of acquiring them.',
      'hint': 'It measures how quickly you recover your customer acquisition investment.',
      'learning_tip': 'Aim for a CAC payback period of 12 months or less for sustainable growth.'
    },
    {
      'id': 22,
      'question': 'What is a cohort analysis?',
      'options': [
        'Analyzing groups of customers who joined at the same time',
        'Comparing different market segments',
        'Tracking competitor performance',
        'Measuring employee productivity'
      ],
      'correct_answer': 0,
      'category': 'analytics',
      'difficulty': 'advanced',
      'explanation': 'Cohort analysis groups customers by shared characteristics (like signup date) and tracks their behavior over time to understand retention and engagement patterns.',
      'hint': 'It\'s about studying groups of customers with similar characteristics.',
      'learning_tip': 'Use cohort analysis to understand customer lifetime value and retention strategies.'
    },
    {
      'id': 23,
      'question': 'What is the concept of "product-market fit"?',
      'options': [
        'When your product is ready for market',
        'When customers love your product and it sells itself',
        'When you have enough funding',
        'When your product is better than competitors'
      ],
      'correct_answer': 1,
      'category': 'product_development',
      'difficulty': 'advanced',
      'explanation': 'Product-market fit occurs when your product satisfies a strong market demand and customers are enthusiastic about it, often evidenced by high retention and organic growth.',
      'hint': 'It\'s when your product meets a real need that customers are excited about.',
      'learning_tip': 'Focus on achieving product-market fit before scaling your business.'
    },
    {
      'id': 24,
      'question': 'What is a SaaS business model?',
      'options': [
        'Software as a Service - subscription-based software delivery',
        'Sell as a Service - focus on sales',
        'Support as a Service - customer service model',
        'Scale as a Service - growth consulting'
      ],
      'correct_answer': 0,
      'category': 'business_models',
      'difficulty': 'advanced',
      'explanation': 'SaaS (Software as a Service) is a software delivery model where customers pay a subscription fee to access software hosted by the provider, rather than purchasing it outright.',
      'hint': 'It\'s subscription-based software that you access online.',
      'learning_tip': 'SaaS businesses benefit from recurring revenue and scalable delivery.'
    },
    {
      'id': 25,
      'question': 'What is the difference between gross margin and net margin?',
      'options': [
        'Gross margin excludes all expenses, net margin includes everything',
        'Gross margin is revenue minus COGS, net margin is after all expenses',
        'Gross margin is for products, net margin is for services',
        'There is no difference'
      ],
      'correct_answer': 1,
      'category': 'financial_management',
      'difficulty': 'advanced',
      'explanation': 'Gross margin is revenue minus cost of goods sold (COGS). Net margin is gross profit minus all operating expenses, taxes, and other costs.',
      'hint': 'Gross margin shows profitability from sales, net margin shows overall profitability.',
      'learning_tip': 'Monitor both margins to understand different aspects of your business profitability.'
    },
    {
      'id': 26,
      'question': 'What is a key performance indicator (KPI)?',
      'options': [
        'A measure of business performance',
        'A type of employee evaluation',
        'A financial statement',
        'A marketing campaign'
      ],
      'correct_answer': 0,
      'category': 'analytics',
      'difficulty': 'intermediate',
      'explanation': 'KPIs are measurable values that demonstrate how effectively a company is achieving key business objectives.',
      'hint': 'It\'s a metric that shows if you\'re meeting your goals.',
      'learning_tip': 'Choose KPIs that align with your business objectives and track them regularly.'
    },
    {
      'id': 27,
      'question': 'What is A/B testing?',
      'options': [
        'Testing two versions of something to see which performs better',
        'A type of financial audit',
        'Employee performance testing',
        'Product quality testing'
      ],
      'correct_answer': 0,
      'category': 'marketing',
      'difficulty': 'intermediate',
      'explanation': 'A/B testing compares two versions of a webpage, email, or other marketing element to determine which one performs better.',
      'hint': 'It\'s about comparing option A vs. option B.',
      'learning_tip': 'Use A/B testing to optimize your marketing and improve conversion rates.'
    },
    {
      'id': 28,
      'question': 'What is the customer journey?',
      'options': [
        'The path customers take from discovering to buying your product',
        'A travel itinerary for business trips',
        'The process of hiring customers',
        'A customer feedback survey'
      ],
      'correct_answer': 0,
      'category': 'customer_experience',
      'difficulty': 'intermediate',
      'explanation': 'The customer journey maps all the touchpoints and experiences a customer has with your brand from initial awareness to post-purchase.',
      'hint': 'It\'s the complete experience customers have with your business.',
      'learning_tip': 'Map your customer journey to identify opportunities for improvement.'
    },
    {
      'id': 29,
      'question': 'What is churn rate?',
      'options': [
        'How fast your business is growing',
        'The rate at which customers stop using your service',
        'Your monthly revenue growth',
        'Employee turnover rate'
      ],
      'correct_answer': 1,
      'category': 'analytics',
      'difficulty': 'advanced',
      'explanation': 'Churn rate measures the percentage of customers who stop using your product or service over a given period.',
      'hint': 'It measures customer loss, not gain.',
      'learning_tip': 'Monitor churn rate closely and implement retention strategies to reduce it.'
    },
    {
      'id': 30,
      'question': 'What is a minimum viable product (MVP)?',
      'options': [
        'The cheapest product you can make',
        'The simplest version of your product that solves the core problem',
        'Your first product prototype',
        'A product with minimum features'
      ],
      'correct_answer': 1,
      'category': 'product_development',
      'difficulty': 'intermediate',
      'explanation': 'An MVP is the most basic version of your product that allows you to test your business hypothesis with real customers and gather feedback.',
      'hint': 'It\'s about testing your idea with the least effort possible.',
      'learning_tip': 'Launch an MVP early to validate your assumptions and learn from real users.'
    }
  ];
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
  static Future<QuizResult> submitQuiz(
      List<Map<String, dynamic>> answers) async {
    if (kDebugMode) {
      print('🚀 SUBMIT_QUIZ CALLED - Starting quiz submission');
    }
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

      // Get current level for advancement logic
      String currentLevel = await getUserLevel();
      if (kDebugMode) {
        print('🎯 Quiz completed: $correctAnswers/$totalQuestions correct = $percentage%');
        print('🎯 Current user level before progression check: $currentLevel');
        print('🎯 About to call _determineUserLevel($percentage, $currentLevel)');
      }
      
      String newLevel = _determineUserLevel(percentage, currentLevel);
      
      if (kDebugMode) {
        print('🎯 _determineUserLevel returned: $newLevel');
        print('🎯 Level changed? ${newLevel != currentLevel}');
      }

      var result = QuizResult(
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        percentage: percentage,
        level: newLevel,
        categoryScores: categoryScores,
        difficultyScores: difficultyScores,
        timestamp: DateTime.now(),
      );

      // Save quiz result
      await _saveQuizResult(result);

      // Update user level only if advanced
      if (newLevel != currentLevel) {
        if (kDebugMode) {
          print('🚀 Updating user level from $currentLevel to $newLevel');
        }
        await updateUserLevel(newLevel);
        if (kDebugMode) {
          print('✅ User level updated successfully');
          // Verify the update worked
          final verifyLevel = await getUserLevel();
          print('🔍 Verification: User level is now $verifyLevel');
        }
      } else {
        if (kDebugMode) {
          print('⭕ No level change needed: $currentLevel remains the same');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting quiz: $e');
      }
      throw Exception('Failed to submit quiz');
    }
  }

  // Determine user level based on performance
  static String _determineUserLevel(double percentage, String currentLevel) {
    if (kDebugMode) {
      print('=== LEVEL DETERMINATION DEBUG ===');
      print('Input: Score $percentage%, Current level: $currentLevel');
    }
    
    // Only advance if score >= 70%
    if (percentage >= 70) {
      String newLevel = currentLevel;
      
      // Sequential progression only - no level skipping
      if (currentLevel == 'novice') {
        newLevel = 'intermediate';
        if (kDebugMode) print('✅ NOVICE -> INTERMEDIATE progression');
      } else if (currentLevel == 'intermediate') {
        newLevel = 'advanced';
        if (kDebugMode) print('✅ INTERMEDIATE -> ADVANCED progression');
      } else if (currentLevel == 'advanced') {
        newLevel = 'expert';
        if (kDebugMode) print('✅ ADVANCED -> EXPERT progression');
      } else if (currentLevel == 'expert') {
        newLevel = 'expert'; // Stay at expert
        if (kDebugMode) print('✅ Already at max level: EXPERT');
      } else {
        if (kDebugMode) print('⚠️ Unknown level: $currentLevel, staying same');
      }
      
      if (kDebugMode) {
        print('Output: Level advancement: $currentLevel -> $newLevel');
        print('=== END LEVEL DETERMINATION ===');
      }
      return newLevel;
    }

    // Stay at current level if score < 70%
    if (kDebugMode) {
      print('❌ No level advancement: Score $percentage% < 70%');
      print('Output: Staying at $currentLevel');
      print('=== END LEVEL DETERMINATION ===');
    }
    return currentLevel;
  }

  // Get user's current level
  static Future<String> getUserLevel() async {
    try {
      final level = await FirebaseDataService.getString(_userLevelKey) ?? 'novice';
      if (kDebugMode) {
        print('📖 Retrieved user level from database: $level');
      }
      return level;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting user level: $e, defaulting to novice');
      }
      return 'novice';
    }
  }

  // Update user level
  static Future<void> updateUserLevel(String level) async {
    if (kDebugMode) {
      print('💾 Saving new user level to database: $level');
    }
    await FirebaseDataService.setString(_userLevelKey, level);
    if (kDebugMode) {
      print('✅ User level saved successfully: $level');
    }
  }

  // Save quiz result
  static Future<void> _saveQuizResult(QuizResult result) async {
    final history = await getQuizHistory();
    history.add(result.toMap());

    // Keep only last 10 quiz results
    if (history.length > 10) {
      history.removeRange(0, history.length - 10);
    }

    await FirebaseDataService.setString(_quizHistoryKey, json.encode(history));
  }

  // Get quiz history
  static Future<List<Map<String, dynamic>>> getQuizHistory() async {
    final historyJson = await FirebaseDataService.getString(_quizHistoryKey);
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
      double avgScore =
          entry.value.reduce((a, b) => a + b) / entry.value.length;
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

    double recentAvg =
        recent.map((r) => r['percentage'] as double).reduce((a, b) => a + b) /
            recent.length;
    double olderAvg =
        older.map((r) => r['percentage'] as double).reduce((a, b) => a + b) /
            older.length;

    if (recentAvg > olderAvg + 5) return 'improving';
    if (recentAvg < olderAvg - 5) return 'declining';
    return 'stable';
  }

  // Calculate average score
  static double _calculateAverageScore(List<Map<String, dynamic>> history) {
    if (history.isEmpty) return 0.0;

    double total =
        history.map((r) => r['percentage'] as double).reduce((a, b) => a + b);
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
          'Start with basic business concepts and terminology',
          'Learn about market research fundamentals',
          'Understand the importance of customer validation',
          'Study successful startup case studies',
          'Practice creating simple business plans'
        ];
        break;
      case 'intermediate':
        recommendations = [
          'Focus on business plan development and financial projections',
          'Learn about different funding options and pitching',
          'Practice networking and communication skills',
          'Study your target market in detail',
          'Learn about product development and MVP creation'
        ];
        break;
      case 'advanced':
        recommendations = [
          'Develop advanced financial modeling and analysis skills',
          'Learn about scaling strategies and operations',
          'Focus on team building and leadership development',
          'Study competitive analysis and strategic planning',
          'Master investor relations and advanced pitching techniques'
        ];
        break;
    }

    // Add specific recommendations based on weaknesses
    final weaknesses = analysis['weaknesses'] as List<dynamic>;
    for (var weakness in weaknesses) {
      recommendations.add('Improve your $weakness knowledge and skills');
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
    double bestScore = history
        .map((r) => r['percentage'] as double)
        .reduce((a, b) => a > b ? a : b);

    int totalQuestions =
        history.map((r) => r['total_questions'] as int).reduce((a, b) => a + b);
    int correctAnswers =
        history.map((r) => r['correct_answers'] as int).reduce((a, b) => a + b);
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

  // Test function to verify level progression logic
  static void testLevelProgression() {
    if (kDebugMode) {
      print('🧪 Testing Level Progression Logic:');
      print('Test 1: novice with 80% -> ${_determineUserLevel(80.0, 'novice')}');
      print('Test 2: intermediate with 75% -> ${_determineUserLevel(75.0, 'intermediate')}');
      print('Test 3: advanced with 90% -> ${_determineUserLevel(90.0, 'advanced')}');
      print('Test 4: expert with 85% -> ${_determineUserLevel(85.0, 'expert')}');
      print('Test 5: novice with 60% -> ${_determineUserLevel(60.0, 'novice')}');
      
      // Verify exact progression
      print('🔍 LEVEL PROGRESSION VERIFICATION:');
      print('NOVICE should advance to: ${_determineUserLevel(70.0, 'novice')}');
      print('INTERMEDIATE should advance to: ${_determineUserLevel(70.0, 'intermediate')}');
      print('ADVANCED should advance to: ${_determineUserLevel(70.0, 'advanced')}');
      print('🧪 Level Progression Test Complete');
    }
  }

  // Debug function to check current user state
  static Future<void> debugUserState() async {
    if (kDebugMode) {
      print('🔍 === USER STATE DEBUG ===');
      final level = await getUserLevel();
      print('Current Level: $level');
      
      final history = await getQuizHistory();
      print('Quiz History Count: ${history.length}');
      
      if (history.isNotEmpty) {
        final lastQuiz = history.last;
        print('Last Quiz Score: ${lastQuiz['percentage']}%');
        print('Last Quiz Level: ${lastQuiz['level']}');
      }
      print('🔍 === END USER STATE ===');
    }
  }

  // Force reset user to novice (for testing)
  static Future<void> forceResetToNovice() async {
    if (kDebugMode) {
      print('🔄 Force resetting user to novice level...');
    }
    await updateUserLevel('novice');
    // Clear quiz history to start fresh
    await FirebaseDataService.setString(_quizHistoryKey, '[]');
    
    // Also reset learning progress to ensure clean state
    await LearningEngine.resetLearningProgress();
    
    if (kDebugMode) {
      print('✅ User completely reset to novice level');
      // Verify the reset
      final currentLevel = await getUserLevel();
      print('🔍 Verified current level: $currentLevel');
    }
  }

  // Check if user should be allowed to take quiz (has completed current level tutorials)
  static Future<bool> canTakeQuiz() async {
    try {
      final userLevel = await getUserLevel();
      
      // Import the learning engine to check tutorial completion
      final tutorialsCompleted = await LearningEngine.areCurrentLevelTutorialsCompleted();
      
      if (kDebugMode) {
        print('🎯 Quiz eligibility check for level: $userLevel');
        print('🎯 Current level tutorials completed: $tutorialsCompleted');
      }
      
      return tutorialsCompleted;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking quiz eligibility: $e');
      }
      return false; // Default to not allowing quiz if error
    }
  }

  // Get quiz eligibility info for UI display
  static Future<Map<String, dynamic>> getQuizEligibilityInfo() async {
    try {
      final userLevel = await getUserLevel();
      final canTake = await canTakeQuiz();
      final remainingTutorials = await LearningEngine.getRemainingCurrentLevelTutorials();
      
      return {
        'canTakeQuiz': canTake,
        'userLevel': userLevel,
        'remainingTutorials': remainingTutorials.length,
        'remainingTutorialTitles': remainingTutorials.map((t) => t['title']).toList(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting quiz eligibility info: $e');
      }
      return {
        'canTakeQuiz': false,
        'userLevel': 'novice',
        'remainingTutorials': 0,
        'remainingTutorialTitles': [],
      };
    }
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
