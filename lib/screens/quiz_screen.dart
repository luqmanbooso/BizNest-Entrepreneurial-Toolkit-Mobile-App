import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/modern_theme.dart';
import '../core/widgets/biznest_logo.dart';
import '../core/services/quiz_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  bool _isLoading = true;
  bool _quizCompleted = false;
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  List<Map<String, dynamic>> _questions = [];
  final List<Map<String, dynamic>> _answers = [];
  QuizResult? _quizResult;
  String _userLevel = 'novice';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadQuizData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  Future<void> _loadQuizData() async {
    setState(() => _isLoading = true);

    try {
      final level = await QuizService.getUserLevel();
      _questions = QuizService.getQuestionsByLevel(level);
      _userLevel = level;

      if (_questions.isEmpty) {
        _questions = QuizService.getQuizQuestions().take(5).toList();
      }

      await Future.delayed(const Duration(seconds: 1));

      setState(() => _isLoading = false);
      _fadeController.forward();
      _slideController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
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
          child: _isLoading ? _buildLoadingScreen() : _buildQuizContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.white.withOpacity(0.3),
            highlightColor: Colors.white.withOpacity(0.8),
            child: const BizNestLogo(size: 80),
          ),
          const SizedBox(height: 24),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Preparing your personalized quiz...',
            style: ModernTheme.headingMedium.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    if (_quizCompleted) {
      return _buildResultsScreen();
    }

    return FadeTransition(
      opacity: _fadeController,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _slideController,
          curve: Curves.easeOutCubic,
        )),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildQuestionCard()),
            _buildNavigationButtons(),
          ],
        ),
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
            Text(
              '${(progress * 100).round()}%',
              style: ModernTheme.bodyMedium.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: MediaQuery.of(context).size.width * progress,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
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
                  return _buildOptionButton(
                    index: index,
                    option: question['options'][index],
                    isSelected: _selectedAnswer == index,
                    onTap: () => _selectAnswer(index),
                  );
                }),
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
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? ModernTheme.primaryBlue.withOpacity(0.1)
                : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? ModernTheme.primaryBlue
                  : Colors.grey.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected
                      ? ModernTheme.primaryBlue
                      : Colors.grey.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
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
                    color:
                        isSelected ? ModernTheme.primaryBlue : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: ModernTheme.primaryBlue,
                  size: 20,
                ),
            ],
          ),
        ),
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
              text: _currentQuestionIndex == _questions.length - 1
                  ? 'Finish'
                  : 'Next',
              onPressed: _selectedAnswer != null ? _nextQuestion : null,
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

    return FadeTransition(
      opacity: _fadeController,
      child: SingleChildScrollView(
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
              _buildResultRow('New Level', _quizResult!.level.toUpperCase()),
              const SizedBox(height: 20),
              Text(
                'Category Performance',
                style: ModernTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._quizResult!.categoryScores.entries.map((entry) {
                final percentage = (entry.value / _questions.length) * 100;
                return _buildCategoryPerformance(entry.key, percentage.round());
              }),
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

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswer = index;
    });
  }

  void _nextQuestion() async {
    if (_selectedAnswer == null) return;

    // Save answer
    _answers.add({
      'question_id': _questions[_currentQuestionIndex]['id'],
      'selected_answer': _selectedAnswer,
    });

    if (_currentQuestionIndex == _questions.length - 1) {
      // Quiz completed
      await _completeQuiz();
    } else {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedAnswer =
            _answers.isNotEmpty ? _answers.last['selected_answer'] : null;
      });
    }
  }

  Future<void> _completeQuiz() async {
    try {
      final result = await QuizService.submitQuiz(_answers);
      setState(() {
        _quizResult = result;
        _quizCompleted = true;
      });

      _pulseController.repeat();
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
    setState(() {
      _quizCompleted = false;
      _currentQuestionIndex = 0;
      _selectedAnswer = null;
      _answers.clear();
      _quizResult = null;
    });
    _loadQuizData();
  }

  void _continueLearning() {
    Navigator.pushReplacementNamed(context, '/learning');
  }
}
