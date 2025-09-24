import 'package:flutter/material.dart';
import 'dart:async';
import '../core/theme/modern_theme.dart';
import '../core/services/quiz_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _quizCompleted = false;
  bool _showExplanation = false;
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  int _correctStreak = 0;
  int _timeRemaining = 30; // 30 seconds per question
  Timer? _questionTimer;
  List<Map<String, dynamic>> _questions = [];
  final List<Map<String, dynamic>> _answers = [];
  final List<bool> _answerCorrectness = [];
  QuizResult? _quizResult;
  String _userLevel = 'novice';
  DateTime? _questionStartTime;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    try {
      final level = await QuizService.getUserLevel();
      _questions = QuizService.getQuestionsByLevel(level);
      _userLevel = level;

      if (_questions.isEmpty) {
        // Show 8 questions for novices, 10 for intermediate, 12 for advanced
        int questionCount = _userLevel == 'novice' ? 8 : _userLevel == 'intermediate' ? 10 : 12;
        _questions = QuizService.getQuizQuestions().take(questionCount).toList();
      }

      // Show content immediately without animation delay
      setState(() {});
      _startQuestionTimer();
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
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
          child: _buildQuizContent(),
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    if (_quizCompleted) {
      return _buildResultsScreen();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                _buildHeader(),
                _buildQuestionCard(),
                _buildNavigationButtons(),
                const SizedBox(height: 20), // Extra padding at bottom
              ],
            ),
          ),
        );
      },
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
                'Skill Assessment',
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
          const SizedBox(height: 20),
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    if (_questions.isEmpty) return const SizedBox();
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
              style: ModernTheme.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            Row(
              children: [
                if (_correctStreak > 0) ...[
                  const Icon(
                    Icons.local_fire_department,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_correctStreak',
                    style: ModernTheme.bodySmall.copyWith(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _timeRemaining <= 10 ? Colors.red.withOpacity(0.8) : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: _timeRemaining <= 10 ? Colors.white : Colors.white.withOpacity(0.8),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_timeRemaining}s',
                        style: ModernTheme.bodySmall.copyWith(
                          color: _timeRemaining <= 10 ? Colors.white : Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _questions.isEmpty ? 0 : MediaQuery.of(context).size.width * progress,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    if (_currentQuestionIndex >= _questions.length) return const SizedBox();

    final question = _questions[_currentQuestionIndex];

    return Container(
      margin: const EdgeInsets.all(20),
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ModernTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    question['category']
                        .toString()
                        .replaceAll('_', ' ')
                        .toUpperCase(),
                    style: ModernTheme.bodySmall.copyWith(
                      color: ModernTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  question['question'],
                  style: ModernTheme.headingMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),
                ...List.generate(question['options'].length, (index) {
                  final isCorrect = index == question['correct_answer'];
                  final isSelected = _selectedAnswer == index;
                  final showResult = _showExplanation;

                  return _buildOptionButton(
                    index: index,
                    option: question['options'][index],
                    isSelected: isSelected,
                    isCorrect: isCorrect,
                    showResult: showResult,
                    onTap: _showExplanation ? null : () => _selectAnswer(index),
                  );
                }),
                if (_showExplanation) ...[
                  const SizedBox(height: 24),
                  _buildExplanationCard(question),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required int index,
    required String option,
    required bool isSelected,
    bool isCorrect = false,
    bool showResult = false,
    required VoidCallback? onTap,
  }) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? trailingIcon;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        textColor = Colors.green;
        trailingIcon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
        textColor = Colors.red;
        trailingIcon = Icons.cancel;
      } else {
        backgroundColor = Colors.grey.withOpacity(0.05);
        borderColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
        trailingIcon = null;
      }
    } else {
      backgroundColor = isSelected
          ? ModernTheme.primaryBlue.withOpacity(0.1)
          : Colors.grey.withOpacity(0.05);
      borderColor = isSelected
          ? ModernTheme.primaryBlue
          : Colors.grey.withOpacity(0.2);
      textColor = isSelected ? ModernTheme.primaryBlue : Colors.black87;
      trailingIcon = isSelected ? Icons.check_circle : null;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: isSelected || showResult ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: showResult
                      ? (isCorrect ? Colors.green : isSelected ? Colors.red : Colors.grey.withOpacity(0.3))
                      : (isSelected ? ModernTheme.primaryBlue : Colors.grey.withOpacity(0.3)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      color: showResult
                          ? (isCorrect || isSelected ? Colors.white : Colors.grey)
                          : (isSelected ? Colors.white : Colors.grey),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: ModernTheme.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  color: showResult
                      ? (isCorrect ? Colors.green : Colors.red)
                      : ModernTheme.primaryBlue,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationCard(Map<String, dynamic> question) {
    final isCorrect = _selectedAnswer == question['correct_answer'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question['explanation'],
            style: ModernTheme.bodyMedium.copyWith(
              height: 1.4,
            ),
          ),
          if (question['hint'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.tips_and_updates,
                    color: Colors.blue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hint: ${question['hint']}',
                      style: ModernTheme.bodySmall.copyWith(
                        color: Colors.blue[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (question['learning_tip'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.school,
                    color: Colors.purple,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Learning Tip: ${question['learning_tip']}',
                      style: ModernTheme.bodySmall.copyWith(
                        color: Colors.purple[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentQuestionIndex > 0)
            Expanded(
              child: _buildButton(
                text: 'Previous',
                onPressed: _previousQuestion,
                isSecondary: true,
              ),
            ),
          if (_currentQuestionIndex > 0) const SizedBox(width: 16),
          Expanded(
            child: _buildButton(
              text: _showExplanation
                  ? (_currentQuestionIndex == _questions.length - 1 ? 'Complete Quiz' : 'Next Question')
                  : 'Submit Answer',
              onPressed: _showExplanation
                  ? (_currentQuestionIndex == _questions.length - 1 ? _completeQuiz : _nextQuestion)
                  : (_selectedAnswer != null ? _submitAnswer : null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback? onPressed,
    bool isSecondary = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: onPressed != null
              ? (isSecondary ? Colors.white.withOpacity(0.2) : Colors.white)
              : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border:
              isSecondary ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Center(
          child: Text(
            text,
            style: ModernTheme.bodyLarge.copyWith(
              color: onPressed != null
                  ? (isSecondary ? Colors.white : ModernTheme.primaryBlue)
                  : Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsScreen() {
    if (_quizResult == null) return const SizedBox();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(
              Icons.celebration,
                size: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 24),
              Text(
                'Quiz Completed!',
                style: ModernTheme.headingLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Score: ${_quizResult!.percentage.round()}%',
                style: ModernTheme.headingMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 32),
              _buildResultsCard(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      );
  }

  Widget _buildResultsCard() {
    return Card(
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
                'Your Results',
                style: ModernTheme.headingMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildResultRow('Correct Answers',
                  '${_quizResult!.correctAnswers}/${_quizResult!.totalQuestions}'),
              _buildResultRow(
                  'Accuracy', '${_quizResult!.percentage.round()}%'),
              _buildResultRow('Best Streak', _correctStreak.toString()),
              _buildResultRow('Average Time per Question',
                  '${(_answers.fold<int>(0, (sum, answer) => sum + (answer['time_taken'] as int)) / _answers.length).round()}s'),
              _buildResultRow('New Level', _quizResult!.level.toUpperCase()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: ModernTheme.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: ModernTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: ModernTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPerformance(String category, int percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.replaceAll('_', ' ').toUpperCase(),
                style: ModernTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$percentage%',
                style: ModernTheme.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ModernTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: percentage >= 70
                      ? Colors.green
                      : percentage >= 50
                          ? Colors.orange
                          : Colors.red,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildButton(
          text: 'Review Answers',
          onPressed: _reviewAnswers,
        ),
        const SizedBox(height: 12),
        _buildButton(
          text: 'View Recommendations',
          onPressed: _viewRecommendations,
        ),
        const SizedBox(height: 12),
        _buildButton(
          text: 'Take Another Quiz',
          onPressed: _retakeQuiz,
          isSecondary: true,
        ),
        const SizedBox(height: 12),
        _buildButton(
          text: 'Continue Learning',
          onPressed: _continueLearning,
          isSecondary: true,
        ),
      ],
    );
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    setState(() {
      _timeRemaining = 30;
      _questionStartTime = DateTime.now();
    });

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          // Time's up - auto-submit current answer or skip
          _questionTimer?.cancel();
          if (_selectedAnswer != null) {
            _submitAnswer();
          } else {
            // Auto-select first option if time runs out
            _selectAnswer(0);
            Future.delayed(const Duration(milliseconds: 500), _submitAnswer);
          }
        }
      });
    });
  }

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswer = index;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) return;

    final question = _questions[_currentQuestionIndex];
    final isCorrect = _selectedAnswer == question['correct_answer'];

    // Track correctness
    _answerCorrectness.add(isCorrect);

    // Update streak
    if (isCorrect) {
      _correctStreak++;
    } else {
      _correctStreak = 0;
    }

    // Save answer
    _answers.add({
      'question_id': question['id'],
      'selected_answer': _selectedAnswer,
      'time_taken': DateTime.now().difference(_questionStartTime!).inSeconds,
      'is_correct': isCorrect,
    });

    // Show explanation
    setState(() {
      _showExplanation = true;
    });

    // Stop the timer when showing explanation
    _questionTimer?.cancel();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showExplanation = false;
      });
      _startQuestionTimer();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedAnswer = _answers.isNotEmpty ? _answers.last['selected_answer'] : null;
        _showExplanation = false;
        // Restore previous answer correctness
        if (_answerCorrectness.isNotEmpty) {
          _answerCorrectness.removeLast();
        }
      });
      _startQuestionTimer();
    }
  }

  Future<void> _completeQuiz() async {
    try {
      final result = await QuizService.submitQuiz(_answers);
      setState(() {
        _quizResult = result;
        _quizCompleted = true;
      });
    } catch (e) {
      // Handle error
    }
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

  void _retakeQuiz() {
    _questionTimer?.cancel();
    setState(() {
      _quizCompleted = false;
      _currentQuestionIndex = 0;
      _selectedAnswer = null;
      _answers.clear();
      _answerCorrectness.clear();
      _quizResult = null;
      _showExplanation = false;
      _correctStreak = 0;
      _timeRemaining = 30;
    });
    _loadQuizData();
  }

  void _continueLearning() {
    Navigator.pop(context); // Go back to learning screen
  }

  void _reviewAnswers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewAnswersScreen(
          questions: _questions,
          answers: _answers,
          answerCorrectness: _answerCorrectness,
        ),
      ),
    );
  }
}

class ReviewAnswersScreen extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final List<Map<String, dynamic>> answers;
  final List<bool> answerCorrectness;

  const ReviewAnswersScreen({
    super.key,
    required this.questions,
    required this.answers,
    required this.answerCorrectness,
  });

  @override
  State<ReviewAnswersScreen> createState() => _ReviewAnswersScreenState();
}

class _ReviewAnswersScreenState extends State<ReviewAnswersScreen> {
  int _currentReviewIndex = 0;

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_currentReviewIndex];
    final answer = widget.answers[_currentReviewIndex];
    final isCorrect = widget.answerCorrectness[_currentReviewIndex];

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
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
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
                      'Review Answers',
                      style: ModernTheme.headingMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 40), // Placeholder for symmetry
                  ],
                ),
              ),

              // Progress indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: List.generate(widget.questions.length, (index) {
                    final isAnswered = index < widget.answers.length;
                    final isCorrect = isAnswered ? widget.answerCorrectness[index] : false;

                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: isAnswered
                              ? (isCorrect ? Colors.green : Colors.red)
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 20),

              // Question content
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.all(20),
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
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: ModernTheme.primaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  question['category'].toString().replaceAll('_', ' ').toUpperCase(),
                                  style: ModernTheme.bodySmall.copyWith(
                                    color: ModernTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                question['question'],
                                style: ModernTheme.headingMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ...List.generate(question['options'].length, (index) {
                                final isSelected = answer['selected_answer'] == index;
                                final isCorrectOption = index == question['correct_answer'];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isCorrectOption
                                        ? Colors.green.withOpacity(0.1)
                                        : (isSelected && !isCorrectOption)
                                            ? Colors.red.withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isCorrectOption
                                          ? Colors.green
                                          : (isSelected && !isCorrectOption)
                                              ? Colors.red
                                              : Colors.grey.withOpacity(0.2),
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isCorrectOption
                                              ? Colors.green
                                              : (isSelected && !isCorrectOption)
                                                  ? Colors.red
                                                  : Colors.grey.withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            String.fromCharCode(65 + index),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          question['options'][index],
                                          style: ModernTheme.bodyMedium.copyWith(
                                            color: isCorrectOption
                                                ? Colors.green
                                                : (isSelected && !isCorrectOption)
                                                    ? Colors.red
                                                    : Colors.black87,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (isCorrectOption)
                                        const Icon(Icons.check_circle, color: Colors.green, size: 20)
                                      else if (isSelected && !isCorrectOption)
                                        const Icon(Icons.cancel, color: Colors.red, size: 20),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isCorrect ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isCorrect ? Colors.green : Colors.orange,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isCorrect ? Icons.check_circle : Icons.lightbulb,
                                          color: isCorrect ? Colors.green : Colors.orange,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          isCorrect ? 'Correct!' : 'Incorrect',
                                          style: ModernTheme.bodyLarge.copyWith(
                                            color: isCorrect ? Colors.green : Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      question['explanation'],
                                      style: ModernTheme.bodyMedium.copyWith(
                                        height: 1.4,
                                      ),
                                    ),
                                    if (question['learning_tip'] != null) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.purple.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              Icons.school,
                                              color: Colors.purple,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Learning Tip: ${question['learning_tip']}',
                                                style: ModernTheme.bodySmall.copyWith(
                                                  color: Colors.purple[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),              // Navigation
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    if (_currentReviewIndex > 0)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentReviewIndex--;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                'Previous',
                                style: ModernTheme.bodyLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_currentReviewIndex > 0) const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: _currentReviewIndex < widget.questions.length - 1
                            ? () {
                                setState(() {
                                  _currentReviewIndex++;
                                });
                              }
                            : () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              _currentReviewIndex == widget.questions.length - 1 ? 'Finish Review' : 'Next',
                              style: ModernTheme.bodyLarge.copyWith(
                                color: ModernTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
