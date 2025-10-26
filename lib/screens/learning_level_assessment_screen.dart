import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../core/theme/modern_theme.dart';
import '../core/services/quiz_service.dart';

class LearningLevelAssessmentScreen extends StatefulWidget {
  const LearningLevelAssessmentScreen({super.key});

  @override
  State<LearningLevelAssessmentScreen> createState() =>
      _LearningLevelAssessmentScreenState();
}

class _LearningLevelAssessmentScreenState
    extends State<LearningLevelAssessmentScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {};
  bool _isLoading = false;

  // Onboarding assessment questions
  final List<Map<String, dynamic>> _assessmentQuestions = [
    {
      'question': 'What is a business model canvas?',
      'options': [
        'A painting tool for businesses',
        'A strategic management template showing how a business creates value',
        'A legal document',
        'A financial statement'
      ],
      'correct': 1,
      'difficulty': 'novice',
    },
    {
      'question': 'What does MVP stand for in startup terminology?',
      'options': [
        'Most Valuable Player',
        'Maximum Value Product',
        'Minimum Viable Product',
        'Most Visible Platform'
      ],
      'correct': 2,
      'difficulty': 'novice',
    },
    {
      'question': 'What is the primary purpose of market research?',
      'options': [
        'To copy competitors',
        'To understand customer needs and market dynamics',
        'To increase expenses',
        'To delay product launch'
      ],
      'correct': 1,
      'difficulty': 'novice',
    },
    {
      'question': 'What is a value proposition?',
      'options': [
        'The price of your product',
        'A clear statement explaining how your product solves customer problems',
        'Your company mission statement',
        'A marketing slogan'
      ],
      'correct': 1,
      'difficulty': 'novice',
    },
    {
      'question': 'What does "pivot" mean in the startup context?',
      'options': [
        'Closing down the business',
        'Hiring more employees',
        'A fundamental change in business direction based on learning',
        'Increasing marketing budget'
      ],
      'correct': 2,
      'difficulty': 'intermediate',
    },
    {
      'question': 'What is customer acquisition cost (CAC)?',
      'options': [
        'The price customers pay for products',
        'The cost of customer service',
        'The total cost of acquiring a new customer',
        'The cost of retaining existing customers'
      ],
      'correct': 2,
      'difficulty': 'intermediate',
    },
    {
      'question': 'What is a good LTV:CAC ratio for a healthy business?',
      'options': ['1:1', '2:1', '3:1 or higher', '10:1'],
      'correct': 2,
      'difficulty': 'intermediate',
    },
    {
      'question': 'What is the purpose of a pitch deck?',
      'options': [
        'To teach employees company values',
        'To present your business to potential investors or partners',
        'To advertise your product',
        'To train new hires'
      ],
      'correct': 1,
      'difficulty': 'intermediate',
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectAnswer(int answerIndex) {
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = answerIndex;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _assessmentQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      _completeAssessment();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  Future<void> _completeAssessment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate score
      int correctAnswers = 0;
      for (var i = 0; i < _assessmentQuestions.length; i++) {
        if (_selectedAnswers[i] == _assessmentQuestions[i]['correct']) {
          correctAnswers++;
        }
      }

      final double percentage =
          (correctAnswers / _assessmentQuestions.length) * 100;

      // Determine level based on score
      String level = 'novice';
      if (percentage >= 70) {
        level = 'intermediate'; // User gets intermediate if they score 70% or higher
      }

      if (kDebugMode) {
        print('🎯 Assessment completed: $correctAnswers/$_assessmentQuestions.length correct');
        print('📊 Percentage: ${percentage.toStringAsFixed(1)}%');
        print('🎓 Assigned level: $level');
      }

      // Update user level
      await QuizService.updateUserLevel(level);
      
      // Mark assessment as completed
      await QuizService.markAssessmentCompleted();

      if (mounted) {
        // Show results dialog
        _showResultsDialog(percentage, level, correctAnswers);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error completing assessment: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save assessment results')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showResultsDialog(double percentage, String level, int correctAnswers) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
              color: level == 'intermediate'
                  ? ModernTheme.accentGreen.withOpacity(0.1)
                  : ModernTheme.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                level == 'intermediate' ? Icons.emoji_events : Icons.school,
                size: 48,
                color: level == 'intermediate'
                    ? ModernTheme.accentGreen
                    : ModernTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Assessment Complete!',
              style: ModernTheme.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You scored ${percentage.toStringAsFixed(0)}%',
              style: ModernTheme.headingMedium.copyWith(
                fontSize: 18,
                color: ModernTheme.mediumGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$correctAnswers out of ${_assessmentQuestions.length} correct',
              style: ModernTheme.bodyMedium.copyWith(
                color: ModernTheme.mediumGray,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: level == 'intermediate'
                    ? ModernTheme.accentGreen.withOpacity(0.1)
                    : ModernTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Your Level',
                    style: ModernTheme.bodySmall.copyWith(
                      color: ModernTheme.mediumGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level.toUpperCase(),
                    style: ModernTheme.headingMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: level == 'intermediate'
                          ? ModernTheme.accentGreen
                          : ModernTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              level == 'intermediate'
                  ? 'Great job! You\'ll start with intermediate-level content.'
                  : 'Perfect! You\'ll start with foundational content to build a strong base.',
              style: ModernTheme.bodyMedium.copyWith(
                color: ModernTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(true); // Return to learning screen with success
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Start Learning'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _assessmentQuestions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _assessmentQuestions.length;

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
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Level Assessment',
                            style: ModernTheme.headingMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Question ${_currentQuestionIndex + 1} of ${_assessmentQuestions.length}',
                      style: ModernTheme.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Question Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: ModernTheme.modernShadow,
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Question
                                Text(
                                  currentQuestion['question'],
                                  style: ModernTheme.headingMedium.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Options
                                Expanded(
                                  child: ListView.builder(
                                    itemCount:
                                        currentQuestion['options'].length,
                                    itemBuilder: (context, index) {
                                      final isSelected =
                                          _selectedAnswers[
                                              _currentQuestionIndex] ==
                                              index;
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 12),
                                        child: InkWell(
                                          onTap: () => _selectAnswer(index),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? ModernTheme.primaryBlue
                                                      .withOpacity(0.1)
                                                  : ModernTheme.lightGray,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: isSelected
                                                    ? ModernTheme.primaryBlue
                                                    : Colors.transparent,
                                                width: 2,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? ModernTheme
                                                              .primaryBlue
                                                          : ModernTheme
                                                              .mediumGray,
                                                      width: 2,
                                                    ),
                                                    color: isSelected
                                                        ? ModernTheme
                                                            .primaryBlue
                                                        : Colors.transparent,
                                                  ),
                                                  child: isSelected
                                                      ? const Icon(
                                                          Icons.check,
                                                          size: 16,
                                                          color: Colors.white,
                                                        )
                                                      : null,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    currentQuestion['options']
                                                        [index],
                                                    style: ModernTheme
                                                        .bodyMedium
                                                        .copyWith(
                                                      fontWeight: isSelected
                                                          ? FontWeight.w600
                                                          : FontWeight.normal,
                                                      color: isSelected
                                                          ? ModernTheme
                                                              .primaryBlue
                                                          : ModernTheme
                                                              .textPrimary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Navigation Buttons
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    if (_currentQuestionIndex > 0)
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: _previousQuestion,
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                ModernTheme.primaryBlue,
                                            side: const BorderSide(
                                              color: ModernTheme.primaryBlue,
                                            ),
                                            padding: const EdgeInsets
                                                .symmetric(
                                                vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text('Previous'),
                                        ),
                                      ),
                                    if (_currentQuestionIndex > 0)
                                      const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: ElevatedButton(
                                        onPressed: _selectedAnswers
                                                    .containsKey(
                                                        _currentQuestionIndex)
                                            ? _nextQuestion
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              ModernTheme.primaryBlue,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets
                                              .symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          disabledBackgroundColor:
                                              ModernTheme.mediumGray,
                                        ),
                                        child: Text(
                                          _currentQuestionIndex ==
                                                  _assessmentQuestions
                                                          .length -
                                                      1
                                              ? 'Complete'
                                              : 'Next',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
