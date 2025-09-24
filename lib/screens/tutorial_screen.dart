import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/modern_theme.dart';
import '../core/widgets/biznest_logo.dart';
import '../core/services/learning_engine.dart';
import '../core/services/quiz_service.dart';

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
  bool _isCompleted = false;
  Map<String, dynamic> _progress = {};
  List<Map<String, dynamic>> _sections = [];

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
      _isCompleted = _progress['completed'] ?? false;
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
        ...questions.map((question) => _buildQuizQuestion(question)),
      ],
    );
  }

  Widget _buildQuizQuestion(Map<String, dynamic> question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question['question'],
            style: ModernTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            question['options'].length,
            (index) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: ElevatedButton(
                onPressed: () => _answerQuestion(question, index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.grey[700],
                  elevation: 0,
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + index), // A, B, C, D
                          style: ModernTheme.bodySmall.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question['options'][index],
                        style: ModernTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

  void _answerQuestion(Map<String, dynamic> question, int selectedIndex) {
    final isCorrect = selectedIndex == question['correct'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCorrect ? 'Correct!' : 'Incorrect'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              size: 64,
              color: isCorrect ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isCorrect
                  ? 'Great job! You selected the correct answer.'
                  : 'The correct answer is: ${question['options'][question['correct']]}',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
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
      case 'beginner':
        return Colors.blue;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      case 'expert':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}