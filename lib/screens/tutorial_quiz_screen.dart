import 'package:flutter/material.dart';
import '../core/theme/modern_theme.dart';
import '../core/services/learning_engine.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TutorialQuizScreen extends StatefulWidget {
  final Map<String, dynamic> tutorial;

  const TutorialQuizScreen({super.key, required this.tutorial});

  @override
  State<TutorialQuizScreen> createState() => _TutorialQuizScreenState();
}

class _TutorialQuizScreenState extends State<TutorialQuizScreen> {
  bool _isLoading = true;
  bool _isGenerating = false;
  String? _error;
  
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  bool _hasSubmitted = false;
  bool _isCorrect = false;
  String _justification = '';
  
  int _correctAnswers = 0;
  List<Map<String, dynamic>> _answers = [];

  @override
  void initState() {
    super.initState();
    _generateQuizQuestions();
  }

  Future<void> _generateQuizQuestions() async {
    setState(() {
      _isLoading = true;
      _isGenerating = true;
      _error = null;
    });

    try {
      print('🎓 Generating AI quiz questions for tutorial: ${widget.tutorial['title']}');
      
      // Get tutorial content
      final sections = List<Map<String, dynamic>>.from(
        widget.tutorial['content']['sections'] ?? []
      );
      
      // Extract text content from all sections
      final contentSummary = sections
          .where((section) => section['type'] == 'text')
          .map((section) => section['content'])
          .join('\n\n');
      
      if (contentSummary.isEmpty) {
        throw Exception('No content found in tutorial to generate questions from.');
      }

      print('   Content length: ${contentSummary.length} characters');
      
      final prompt = '''
Based on the following tutorial content, generate exactly 5 multiple-choice questions to test the learner's understanding.

Tutorial Title: ${widget.tutorial['title']}
Difficulty: ${widget.tutorial['difficulty']}

Tutorial Content:
$contentSummary

Generate 5 questions with the following JSON format:
{
  "questions": [
    {
      "question": "Question text here?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correct_answer": 0,
      "justification": "Detailed explanation of why this answer is correct and why others are wrong."
    }
  ]
}

Requirements:
- Questions should test comprehension, not just memorization
- Each question must have exactly 4 options
- The correct_answer is the index (0-3) of the correct option
- Provide detailed justification explaining why the correct answer is right
- Mix difficulty levels: 2 easy, 2 medium, 1 challenging
- Ensure questions are directly related to the tutorial content
- Make incorrect options plausible but distinctly wrong

Return ONLY the JSON, no additional text.
''';

      print('   Calling OpenRouter AI...');
      
      final response = await _generateQuestionsWithAI(prompt);
      
      print('✅ AI Response received, parsing...');
      print('   Response preview: ${response.substring(0, response.length > 200 ? 200 : response.length)}');
      
      // Parse the AI response
      final parsedQuestions = _parseAIResponse(response);
      
      if (parsedQuestions.isEmpty) {
        throw Exception('AI generated no valid questions. Please try again.');
      }

      setState(() {
        _questions = parsedQuestions;
        _isLoading = false;
        _isGenerating = false;
      });
      
      print('✅ Successfully generated ${_questions.length} questions');
      
    } catch (e) {
      print('❌ Error generating questions: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isGenerating = false;
      });
    }
  }

  Future<String> _generateQuestionsWithAI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer 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',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://biznest.app',
          'X-Title': 'BizNest Tutorial Quiz Generator',
        },
        body: jsonEncode({
          'model': 'openai/gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an educational content expert who creates high-quality quiz questions. Always respond with valid JSON only, no additional text or markdown.'
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 3000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to generate questions: $e');
    }
  }

  List<Map<String, dynamic>> _parseAIResponse(String response) {
    try {
      // Remove markdown code blocks if present
      String cleanedResponse = response.trim();
      if (cleanedResponse.startsWith('```json')) {
        cleanedResponse = cleanedResponse.substring(7);
      }
      if (cleanedResponse.startsWith('```')) {
        cleanedResponse = cleanedResponse.substring(3);
      }
      if (cleanedResponse.endsWith('```')) {
        cleanedResponse = cleanedResponse.substring(0, cleanedResponse.length - 3);
      }
      cleanedResponse = cleanedResponse.trim();
      
      final parsed = jsonDecode(cleanedResponse);
      final questions = List<Map<String, dynamic>>.from(parsed['questions'] ?? []);
      
      // Validate each question
      return questions.where((q) {
        return q.containsKey('question') &&
               q.containsKey('options') &&
               q.containsKey('correct_answer') &&
               q.containsKey('justification') &&
               q['options'] is List &&
               q['options'].length == 4;
      }).toList();
      
    } catch (e) {
      print('❌ Failed to parse AI response: $e');
      print('   Raw response: $response');
      return [];
    }
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer before submitting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final correctIndex = currentQuestion['correct_answer'];
    final isCorrect = _selectedAnswer == correctIndex;

    setState(() {
      _hasSubmitted = true;
      _isCorrect = isCorrect;
      _justification = currentQuestion['justification'];
      
      if (isCorrect) {
        _correctAnswers++;
      }
      
      _answers.add({
        'question_index': _currentQuestionIndex,
        'selected_answer': _selectedAnswer,
        'correct_answer': correctIndex,
        'is_correct': isCorrect,
      });
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _hasSubmitted = false;
        _isCorrect = false;
        _justification = '';
      });
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    final score = (_correctAnswers / _questions.length * 100).round();
    
    // Save quiz completion
    await LearningEngine.completeTutorialQuiz(
      widget.tutorial['id'],
      {
        'score': score,
        'correct_answers': _correctAnswers,
        'total_questions': _questions.length,
        'answers': _answers,
        'completed_at': DateTime.now().toIso8601String(),
      },
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              score >= 80 ? Icons.emoji_events : Icons.check_circle,
              color: score >= 80 ? Colors.amber : ModernTheme.primaryBlue,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(score >= 80 ? 'Excellent!' : 'Quiz Completed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score%',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: ModernTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_correctAnswers out of ${_questions.length} correct',
              style: ModernTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              score >= 80
                  ? 'Outstanding work! You\'ve mastered this tutorial.'
                  : score >= 60
                      ? 'Good job! Consider reviewing the tutorial to improve.'
                      : 'Keep practicing! Review the tutorial and try again.',
              textAlign: TextAlign.center,
              style: ModernTheme.bodyMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          if (score < 60)
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Go back to tutorial with result
              },
              child: const Text('Review Tutorial'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Go back to learning screen with result
            },
            child: const Text('Continue Learning'),
          ),
        ],
      ),
    );
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
          child: _isLoading ? _buildLoadingState() : _buildQuizContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isGenerating) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  'Preparing Your Quiz...',
                  style: ModernTheme.headingMedium.copyWith(
                    color: ModernTheme.primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Please wait while we set up your questions',
                  style: ModernTheme.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else if (_error != null) ...[
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                Text(
                  'Failed to Generate Quiz',
                  style: ModernTheme.headingMedium.copyWith(
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: ModernTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _generateQuizQuestions,
                  child: const Text('Try Again'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    if (_questions.isEmpty) {
      return Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.quiz, size: 64, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  'No Questions Available',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildHeader(),
        _buildProgressIndicator(),
        Expanded(
          child: _buildQuestionCard(),
        ),
        _buildNavigationButtons(),
      ],
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
                  'Tutorial Quiz',
                  style: ModernTheme.headingMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.tutorial['title'],
                  style: ModernTheme.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Score: $_correctAnswers/${_currentQuestionIndex + (_hasSubmitted ? 1 : 0)}',
              style: ModernTheme.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                style: ModernTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${((_currentQuestionIndex + 1) / _questions.length * 100).round()}%',
                style: ModernTheme.bodyMedium.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    final question = _questions[_currentQuestionIndex];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ModernTheme.primaryBlue.withOpacity(0.1),
                        ModernTheme.teal.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    question['question'],
                    style: ModernTheme.headingMedium.copyWith(
                      color: ModernTheme.primaryBlue,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Options
                ...List.generate(
                  question['options'].length,
                  (index) => _buildOption(index, question),
                ),
                
                // Justification (shown after submission)
                if (_hasSubmitted) ...[
                  const SizedBox(height: 24),
                  _buildJustification(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(int index, Map<String, dynamic> question) {
    final isSelected = _selectedAnswer == index;
    final correctIndex = question['correct_answer'];
    
    Color? backgroundColor;
    Color? borderColor;
    Color? textColor;
    IconData? icon;
    Color? iconColor;
    
    if (_hasSubmitted) {
      if (index == correctIndex) {
        backgroundColor = Colors.green[50];
        borderColor = Colors.green;
        textColor = Colors.green[900];
        icon = Icons.check_circle;
        iconColor = Colors.green;
      } else if (isSelected) {
        backgroundColor = Colors.red[50];
        borderColor = Colors.red;
        textColor = Colors.red[900];
        icon = Icons.cancel;
        iconColor = Colors.red;
      } else {
        backgroundColor = Colors.grey[100];
        borderColor = Colors.grey[300];
        textColor = Colors.grey[600];
      }
    } else {
      backgroundColor = isSelected ? ModernTheme.primaryBlue.withOpacity(0.1) : Colors.white;
      borderColor = isSelected ? ModernTheme.primaryBlue : Colors.grey[300];
      textColor = isSelected ? ModernTheme.primaryBlue : Colors.grey[800];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _hasSubmitted ? null : () {
          setState(() {
            _selectedAnswer = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected || (_hasSubmitted && index == correctIndex)
                      ? borderColor
                      : Colors.transparent,
                  border: Border.all(
                    color: borderColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: _hasSubmitted && icon != null
                      ? Icon(icon, size: 20, color: Colors.white)
                      : Text(
                          String.fromCharCode(65 + index), // A, B, C, D
                          style: TextStyle(
                            color: isSelected ? Colors.white : borderColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  question['options'][index],
                  style: ModernTheme.bodyLarge.copyWith(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (_hasSubmitted && icon != null)
                Icon(icon, color: iconColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJustification() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isCorrect ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isCorrect ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isCorrect ? Icons.check_circle : Icons.info,
                color: _isCorrect ? Colors.green : Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                _isCorrect ? 'Correct!' : 'Incorrect',
                style: ModernTheme.headingMedium.copyWith(
                  color: _isCorrect ? Colors.green[900] : Colors.orange[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _justification,
            style: ModernTheme.bodyLarge.copyWith(
              color: _isCorrect ? Colors.green[900] : Colors.orange[900],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (!_hasSubmitted)
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedAnswer != null ? _submitAnswer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: ModernTheme.primaryBlue,
                  disabledBackgroundColor: Colors.white.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Answer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (_hasSubmitted)
            Expanded(
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: ModernTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentQuestionIndex < _questions.length - 1
                      ? 'Next Question'
                      : 'Finish Quiz',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
