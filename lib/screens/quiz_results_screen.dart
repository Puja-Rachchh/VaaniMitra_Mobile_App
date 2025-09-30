import 'package:flutter/material.dart';
import '../models/quiz_models.dart';

class QuizResultsScreen extends StatelessWidget {
  final QuizSession session;
  final VoidCallback onRetakeQuiz;
  final VoidCallback onBackToMenu;

  const QuizResultsScreen({
    Key? key,
    required this.session,
    required this.onRetakeQuiz,
    required this.onBackToMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final correctAnswers = session.results.where((r) => r.isCorrect).length;
    final totalQuestions = session.results.length;
    final percentage = (session.score).round();
    final isPassed = percentage >= 60;

    return Scaffold(
      backgroundColor: isPassed ? Colors.green.shade50 : Colors.red.shade50,
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: isPassed ? Colors.green.shade400 : Colors.red.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Score display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    isPassed ? Icons.celebration : Icons.sentiment_dissatisfied,
                    size: 80,
                    color: isPassed ? Colors.green.shade400 : Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPassed ? 'Congratulations!' : 'Keep Practicing!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isPassed ? Colors.green.shade600 : Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: isPassed ? Colors.green.shade600 : Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$correctAnswers out of $totalQuestions correct',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Performance breakdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performance Breakdown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPerformanceRow(
                    'Correct Answers',
                    correctAnswers.toString(),
                    Colors.green.shade400,
                    Icons.check_circle,
                  ),
                  _buildPerformanceRow(
                    'Incorrect Answers',
                    (totalQuestions - correctAnswers).toString(),
                    Colors.red.shade400,
                    Icons.cancel,
                  ),
                  _buildPerformanceRow(
                    'Category',
                    _formatCategory(session.category),
                    Colors.blue.shade400,
                    Icons.category,
                  ),
                  _buildPerformanceRow(
                    'Level',
                    _formatLevel(session.level),
                    Colors.purple.shade400,
                    Icons.stars,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Question review
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Question Review',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...session.results.asMap().entries.map((entry) {
                    final index = entry.key;
                    final result = entry.value;
                    return _buildQuestionReview(index + 1, result);
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRetakeQuiz,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retake Quiz'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onBackToMenu,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Menu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceRow(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionReview(int questionNumber, QuizResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: result.isCorrect 
            ? Colors.green.shade50 
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.isCorrect 
              ? Colors.green.shade200 
              : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: result.isCorrect 
                  ? Colors.green.shade400 
                  : Colors.red.shade400,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                questionNumber.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      result.isCorrect ? Icons.check : Icons.close,
                      color: result.isCorrect 
                          ? Colors.green.shade600 
                          : Colors.red.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      result.isCorrect ? 'Correct' : 'Incorrect',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: result.isCorrect 
                            ? Colors.green.shade600 
                            : Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
                if (!result.isCorrect) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Your answer: ${result.selectedAnswer}',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Correct answer: ${result.correctAnswer}',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCategory(String category) {
    return category.split('_').map((word) => 
        word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }

  String _formatLevel(String level) {
    return level[0].toUpperCase() + level.substring(1).toLowerCase();
  }
}