import 'package:flutter/material.dart';
import '../core/theme/modern_theme.dart';
import '../core/services/learning_engine.dart';

class TutorialScreen extends StatefulWidget {
  final Map<String, dynamic> tutorial;

  const TutorialScreen({super.key, required this.tutorial});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;

  int _currentSection = 0;
  Map<String, dynamic> _progress = {};
  List<Map<String, dynamic>> _sections = [];
  
  // Quiz state management
  bool _showQuizResults = false;
  int _currentQuizQuestionIndex = 0;
  Map<int, int> _quizAnswers = {}; // questionIndex -> selectedAnswerIndex
  List<Map<String, dynamic>> _currentQuizQuestions = [];
  int _quizScore = 0;
  bool _quizInProgress = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadTutorialData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  Future<void> _loadTutorialData() async {
    _sections = List<Map<String, dynamic>>.from(widget.tutorial['content']['sections']);
    _progress = await LearningEngine.getTutorialProgress(widget.tutorial['id']);

    if (_progress.isNotEmpty) {
      _currentSection = _progress['current_section'] ?? 0;
    }

    _updateProgressAnimation();
  }

  void _updateProgressAnimation() {
    final progress = (_currentSection + 1) / _sections.length;
    _progressController.animateTo(progress);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildHeader(),
                _buildProgressBar(),
                Expanded(
                  child: _buildTutorialContent(),
                ),
                _buildNavigationControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tutorial['title'],
                  style: ModernTheme.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Section ${_currentSection + 1} of ${_sections.length}',
                  style: ModernTheme.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getDifficultyColor(widget.tutorial['difficulty']).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.tutorial['difficulty'].toString().toUpperCase(),
              style: ModernTheme.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.white, Colors.white70],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            '${((_progressAnimation.value) * 100).round()}% Complete',
            style: ModernTheme.bodySmall.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialContent() {
    if (_sections.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    final currentSection = _sections[_currentSection];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Card(
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF8FAFC)],
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentSection['title'],
                  style: ModernTheme.headingLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ModernTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionContent(currentSection),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContent(Map<String, dynamic> section) {
    switch (section['type']) {
      case 'text':
        return Text(
          section['content'],
          style: ModernTheme.bodyLarge.copyWith(
            height: 1.6,
            color: Colors.grey[800],
          ),
        );
      case 'quiz':
        return _buildQuizSection(section);
      case 'interactive':
        return _buildInteractiveSection(section);
      default:
        return Text(
          section['content'],
          style: ModernTheme.bodyLarge.copyWith(
            height: 1.6,
            color: Colors.grey[800],
          ),
        );
    }
  }

  Widget _buildQuizSection(Map<String, dynamic> section) {
    final questions = List<Map<String, dynamic>>.from(section['questions']);
    
    // Initialize quiz if not already initialized
    if (!_quizInProgress && _currentQuizQuestions.isEmpty) {
      _currentQuizQuestions = questions;
      _quizAnswers.clear();
      _quizScore = 0;
      _currentQuizQuestionIndex = 0;
      _showQuizResults = false;
    }

    if (_showQuizResults) {
      return _buildQuizResults(section);
    }

    if (_quizInProgress) {
      return _buildProgressiveQuiz(section);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section['content'],
          style: ModernTheme.bodyLarge.copyWith(
            height: 1.6,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ModernTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ModernTheme.primaryBlue.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.quiz,
                size: 48,
                color: ModernTheme.primaryBlue,
              ),
              const SizedBox(height: 16),
              Text(
                'Knowledge Check',
                style: ModernTheme.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ModernTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Test your understanding with ${questions.length} questions',
                style: ModernTheme.bodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _startQuiz(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Start Quiz'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _startQuiz() {
    setState(() {
      _quizInProgress = true;
      _currentQuizQuestionIndex = 0;
      _quizAnswers.clear();
      _quizScore = 0;
      _showQuizResults = false;
    });
    
    // Enhance questions with AI if available
    _enhanceQuizWithAI();
  }

  Future<void> _enhanceQuizWithAI() async {
    try {
      // Get tutorial content for AI enhancement
      String tutorialContent = '';
      for (var section in _sections) {
        if (section['type'] == 'text') {
          tutorialContent += '${section['title']}: ${section['content']}\n\n';
        }
      }
      
      if (tutorialContent.isNotEmpty && _currentQuizQuestions.isNotEmpty) {
        // Generate AI-enhanced explanations for existing questions
        for (int i = 0; i < _currentQuizQuestions.length; i++) {
          final question = _currentQuizQuestions[i];
          if (question['explanation'] == null || question['explanation'].isEmpty) {
            try {
              // Create a simple AI-enhanced explanation
              final enhancedExplanation = await _generateEnhancedExplanation(
                tutorialContent,
                question,
              );
              
              if (enhancedExplanation.isNotEmpty) {
                setState(() {
                  _currentQuizQuestions[i]['explanation'] = enhancedExplanation;
                  _currentQuizQuestions[i]['learning_tip'] = 'Apply this concept from the tutorial: "${_extractKeyLearning(tutorialContent, question)}"';
                });
              }
            } catch (e) {
              // If AI fails, keep original question
              print('AI enhancement failed for question $i: $e');
            }
          }
        }
      }
    } catch (e) {
      print('AI enhancement failed: $e');
      // Continue with original questions if AI fails
    }
  }

  Future<String> _generateEnhancedExplanation(String tutorialContent, Map<String, dynamic> question) async {
    // For now, create a simple enhanced explanation based on the tutorial content
    // In a full implementation, this would call the OpenRouter AI service
    
    final questionText = question['question'];
    final correctAnswer = question['options'][question['correct']];
    
    // Simple keyword matching to relate to tutorial content
    final relevantContent = _findRelevantContent(tutorialContent, questionText);
    
    if (relevantContent.isNotEmpty) {
      return 'The correct answer is "$correctAnswer" because, as explained in the tutorial: $relevantContent This demonstrates the key principles covered in this learning module.';
    } else {
      return 'The correct answer is "$correctAnswer". This concept is fundamental to understanding the material covered in this tutorial section.';
    }
  }

  String _findRelevantContent(String tutorialContent, String question) {
    // Simple implementation - in reality, this could use more sophisticated matching
    final questionWords = question.toLowerCase().split(' ');
    final contentSentences = tutorialContent.split('.');
    
    for (final sentence in contentSentences) {
      final sentenceWords = sentence.toLowerCase().split(' ');
      int matchCount = 0;
      for (final word in questionWords) {
        if (word.length > 3 && sentenceWords.any((sw) => sw.contains(word))) {
          matchCount++;
        }
      }
      if (matchCount >= 2 && sentence.trim().length > 20) {
        return sentence.trim().substring(0, sentence.trim().length > 100 ? 100 : sentence.trim().length) + '...';
      }
    }
    return '';
  }

  String _extractKeyLearning(String tutorialContent, Map<String, dynamic> question) {
    // Extract a key learning point related to the question
    final relevantContent = _findRelevantContent(tutorialContent, question['question']);
    if (relevantContent.isNotEmpty) {
      return relevantContent.length > 60 ? '${relevantContent.substring(0, 60)}...' : relevantContent;
    }
    return 'Review the tutorial content to deepen your understanding';
  }

  Widget _buildProgressiveQuiz(Map<String, dynamic> section) {
    if (_currentQuizQuestions.isEmpty) return const SizedBox();
    
    final currentQuestion = _currentQuizQuestions[_currentQuizQuestionIndex];
    final progress = (_currentQuizQuestionIndex + 1) / _currentQuizQuestions.length;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ModernTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentQuizQuestionIndex + 1} of ${_currentQuizQuestions.length}',
                    style: ModernTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ModernTheme.primaryBlue,
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: ModernTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: ModernTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(ModernTheme.primaryBlue),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Question card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentQuestion['question'],
                style: ModernTheme.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(currentQuestion['options'].length, (index) {
                final isSelected = _quizAnswers[_currentQuizQuestionIndex] == index;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _selectQuizAnswer(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? ModernTheme.primaryBlue.withOpacity(0.1)
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? ModernTheme.primaryBlue
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected 
                                    ? ModernTheme.primaryBlue 
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected 
                                      ? ModernTheme.primaryBlue 
                                      : Colors.grey[400]!,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: ModernTheme.bodyMedium.copyWith(
                                    color: isSelected 
                                        ? Colors.white 
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                currentQuestion['options'][index],
                                style: ModernTheme.bodyMedium.copyWith(
                                  color: isSelected 
                                      ? ModernTheme.primaryBlue 
                                      : Colors.grey[800],
                                  fontWeight: isSelected 
                                      ? FontWeight.w600 
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Navigation buttons
        Row(
          children: [
            if (_currentQuizQuestionIndex > 0)
              Expanded(
                child: ElevatedButton(
                  onPressed: _previousQuizQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Previous'),
                ),
              ),
            if (_currentQuizQuestionIndex > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _quizAnswers.containsKey(_currentQuizQuestionIndex)
                    ? (_currentQuizQuestionIndex == _currentQuizQuestions.length - 1
                        ? _completeQuiz
                        : _nextQuizQuestion)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentQuizQuestionIndex == _currentQuizQuestions.length - 1
                      ? 'Complete Quiz'
                      : 'Next',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _selectQuizAnswer(int answerIndex) {
    setState(() {
      _quizAnswers[_currentQuizQuestionIndex] = answerIndex;
    });
  }

  void _nextQuizQuestion() {
    if (_currentQuizQuestionIndex < _currentQuizQuestions.length - 1) {
      setState(() {
        _currentQuizQuestionIndex++;
      });
    }
  }

  void _previousQuizQuestion() {
    if (_currentQuizQuestionIndex > 0) {
      setState(() {
        _currentQuizQuestionIndex--;
      });
    }
  }

  void _completeQuiz() {
    // Calculate score
    int correct = 0;
    for (int i = 0; i < _currentQuizQuestions.length; i++) {
      if (_quizAnswers[i] == _currentQuizQuestions[i]['correct']) {
        correct++;
      }
    }
    
    setState(() {
      _quizScore = correct;
      _quizInProgress = false;
      _showQuizResults = true;
    });
  }

  Widget _buildQuizResults(Map<String, dynamic> section) {
    final percentage = (_quizScore / _currentQuizQuestions.length * 100).round();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernTheme.primaryBlue.withOpacity(0.1),
            ModernTheme.teal.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ModernTheme.primaryBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            percentage >= 80 ? Icons.celebration : Icons.thumbs_up_down,
            size: 64,
            color: percentage >= 80 ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            'Quiz Completed!',
            style: ModernTheme.headingLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: ModernTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your Score: $_quizScore/${_currentQuizQuestions.length} ($percentage%)',
            style: ModernTheme.headingMedium.copyWith(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 24),
          
          // Results breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Question Review',
                  style: ModernTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(_currentQuizQuestions.length, (index) {
                  final question = _currentQuizQuestions[index];
                  final userAnswer = _quizAnswers[index];
                  final correctAnswer = question['correct'];
                  final isCorrect = userAnswer == correctAnswer;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCorrect 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCorrect ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Q${index + 1}: ${question['question']}',
                                style: ModernTheme.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!isCorrect) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Your answer: ${question['options'][userAnswer]}',
                            style: ModernTheme.bodySmall.copyWith(
                              color: Colors.red[700],
                            ),
                          ),
                          Text(
                            'Correct answer: ${question['options'][correctAnswer]}',
                            style: ModernTheme.bodySmall.copyWith(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (question['explanation'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            question['explanation'],
                            style: ModernTheme.bodySmall.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _retakeQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retake Quiz'),
          ),
        ],
      ),
    );
  }

  void _retakeQuiz() {
    setState(() {
      _quizInProgress = false;
      _showQuizResults = false;
      _currentQuizQuestionIndex = 0;
      _quizAnswers.clear();
      _quizScore = 0;
    });
  }

  Widget _buildInteractiveSection(Map<String, dynamic> section) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.touch_app,
            size: 48,
            color: ModernTheme.primaryBlue,
          ),
          const SizedBox(height: 16),
          Text(
            'Interactive Exercise',
            style: ModernTheme.headingMedium.copyWith(
              color: ModernTheme.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            section['content'],
            style: ModernTheme.bodyLarge.copyWith(
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentSection > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _previousSection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Previous'),
              ),
            ),
          if (_currentSection > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentSection < _sections.length - 1
                  ? _nextSection
                  : _completeTutorial,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: ModernTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentSection < _sections.length - 1 ? 'Next' : 'Complete',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _previousSection() {
    setState(() {
      _currentSection--;
      _updateProgressAnimation();
      _saveProgress();
    });
  }

  void _nextSection() {
    setState(() {
      _currentSection++;
      _updateProgressAnimation();
      _saveProgress();
    });
  }

  Future<void> _completeTutorial() async {
    final completionData = {
      'quiz_answers': _progress['quiz_answers'] ?? [],
      'time_spent': _progress['time_spent'] ?? 0,
      'sections_completed': _progress['sections_completed'] ?? 0,
    };

    await LearningEngine.completeTutorial(widget.tutorial['id'], completionData);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tutorial Completed!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.celebration,
                size: 64,
                color: ModernTheme.primaryBlue,
              ),
              const SizedBox(height: 16),
              Text(
                'Congratulations! You\'ve completed "${widget.tutorial['title']}".',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to learning screen
              },
              child: const Text('Continue Learning'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _saveProgress() async {
    final progress = {
      'tutorial_id': widget.tutorial['id'],
      'current_section': _currentSection,
      'total_sections': _sections.length,
      'progress_percentage': ((_currentSection + 1) / _sections.length) * 100,
      'last_updated': DateTime.now().toIso8601String(),
      'completed': false,
    };

    await LearningEngine.updateTutorialProgress(widget.tutorial['id'], progress);
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
}