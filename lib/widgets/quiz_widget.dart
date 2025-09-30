import 'package:flutter/material.dart';
import '../models/quiz_models.dart';
import '../services/quiz_service.dart';

class QuizWidget extends StatefulWidget {
  final String category;
  final String level;
  final Function(QuizSession) onQuizCompleted;

  const QuizWidget({
    Key? key,
    required this.category,
    required this.level,
    required this.onQuizCompleted,
  }) : super(key: key);

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> 
    with TickerProviderStateMixin {
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  List<QuizResult> _results = [];
  bool _isLoading = true;
  bool _showAnswer = false;
  String? _selectedAnswer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadQuiz();
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
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  Future<void> _loadQuiz() async {
    try {
      final questions = await QuizService.generateQuiz(
        category: widget.category,
        level: widget.level,
        questionCount: 5,
      );
      
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      debugPrint('Error loading quiz: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _selectAnswer(String answer) {
    if (_showAnswer) return;

    setState(() {
      _selectedAnswer = answer;
      _showAnswer = true;
    });

    final currentQuestion = _questions[_currentQuestionIndex];
    final isCorrect = answer == currentQuestion.correctAnswer;

    final result = QuizResult(
      questionId: currentQuestion.id,
      selectedAnswer: answer,
      correctAnswer: currentQuestion.correctAnswer,
      isCorrect: isCorrect,
      timestamp: DateTime.now(),
    );

    _results.add(result);

    // Show answer for 2 seconds, then move to next question
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _moveToNextQuestion();
      }
    });
  }

  void _moveToNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showAnswer = false;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      _completeQuiz();
    }
  }

  void _completeQuiz() {
    final score = QuizService.calculateScore(_results);
    
    final session = QuizSession(
      category: widget.category,
      level: widget.level,
      results: _results,
      startTime: DateTime.now().subtract(
        Duration(seconds: _results.length * 7), // Estimate
      ),
      endTime: DateTime.now(),
      score: score,
    );

    widget.onQuizCompleted(session);
  }

  Color _getButtonColor(String option) {
    if (!_showAnswer) {
      return _selectedAnswer == option 
          ? Colors.blue.shade300 
          : Colors.grey.shade200;
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    if (option == currentQuestion.correctAnswer) {
      return Colors.green.shade400;
    } else if (option == _selectedAnswer && option != currentQuestion.correctAnswer) {
      return Colors.red.shade400;
    } else {
      return Colors.grey.shade200;
    }
  }

  Color _getButtonTextColor(String option) {
    if (!_showAnswer) {
      return _selectedAnswer == option ? Colors.white : Colors.black87;
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    if (option == currentQuestion.correctAnswer) {
      return Colors.white;
    } else if (option == _selectedAnswer && option != currentQuestion.correctAnswer) {
      return Colors.white;
    } else {
      return Colors.black87;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading Quiz...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_questions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No quiz questions available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Column(
      children: [
        // Progress indicator
        Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
              ),
            ],
          ),
        ),

        // Quiz content
        Expanded(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Question text
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            currentQuestion.questionText,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Question image
                        if (currentQuestion.imageAsset.isNotEmpty)
                          Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                currentQuestion.imageAsset,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                        const SizedBox(height: 32),

                        // Answer options
                        ...currentQuestion.options.map((option) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ElevatedButton(
                              onPressed: _showAnswer ? null : () => _selectAnswer(option),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getButtonColor(option),
                                foregroundColor: _getButtonTextColor(option),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: _showAnswer ? 0 : 2,
                              ),
                              child: Text(
                                option,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),

                        // Show correct answer feedback
                        if (_showAnswer)
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _selectedAnswer == currentQuestion.correctAnswer
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedAnswer == currentQuestion.correctAnswer
                                    ? Colors.green.shade300
                                    : Colors.red.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _selectedAnswer == currentQuestion.correctAnswer
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: _selectedAnswer == currentQuestion.correctAnswer
                                      ? Colors.green.shade600
                                      : Colors.red.shade600,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedAnswer == currentQuestion.correctAnswer
                                        ? 'Correct! Well done!'
                                        : 'Correct answer: ${currentQuestion.correctAnswer}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _selectedAnswer == currentQuestion.correctAnswer
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
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
            },
          ),
        ),
      ],
    );
  }
}