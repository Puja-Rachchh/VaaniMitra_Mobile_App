import 'package:flutter/material.dart';
import '../models/letter_tracing_models.dart';
import '../services/letter_progress_manager.dart';
import '../utils/tracing_validator.dart';
import '../widgets/tracing_canvas.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Main screen for letter tracing functionality
class LetterTracingScreen extends StatefulWidget {
  final String language;
  final String languageName;

  const LetterTracingScreen({
    Key? key,
    required this.language,
    required this.languageName,
  }) : super(key: key);

  @override
  State<LetterTracingScreen> createState() => _LetterTracingScreenState();
}

class _LetterTracingScreenState extends State<LetterTracingScreen> {
  late LetterProgressManager _progressManager;
  late List<TraceableLetter> _letters;
  late TraceableLetter _currentLetter;
  late FlutterTts _tts;
  
  final GlobalKey _canvasKey = GlobalKey();
  
  bool _isLoading = true;
  bool _showFeedback = false;
  String _feedbackMessage = '';
  bool _isSuccess = false;
  bool _showHints = true; // Show tracing hints by default
  double _currentAccuracy = 0.0;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _initializeScreen();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  /// Initialize the screen with letters and progress manager
  Future<void> _initializeScreen() async {
    try {
      // Initialize progress manager
      _progressManager = await LetterProgressManager.create(widget.language);
      
      // Load letters for the selected language
      _letters = _getLettersForLanguage(widget.language);
      
      if (_letters.isEmpty) {
        throw Exception('No letters available for ${widget.language}');
      }
      
      // Get current letter or first uncompleted letter
      _currentLetter = _progressManager.getNextUncompletedLetter(_letters) ??
          _letters.first;
      
      // Set TTS language
      await _setTtsLanguage();
      
      setState(() {
        _isLoading = false;
      });
      
      // Speak the letter
      _speakLetter();
    } catch (e) {
      debugPrint('Error initializing tracing screen: $e');
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to initialize: $e');
    }
  }

  /// Set TTS language based on selected language
  Future<void> _setTtsLanguage() async {
    final languageMap = {
      'hi': 'hi-IN',
      'gu': 'gu-IN',
      'ta': 'ta-IN',
      'te': 'te-IN',
      'kn': 'kn-IN',
      'ml': 'ml-IN',
      'mr': 'mr-IN',
      'bn': 'bn-IN',
      'pa': 'pa-IN',
      'ur': 'ur-IN',
    };
    
    final ttsLanguage = languageMap[widget.language] ?? 'en-US';
    await _tts.setLanguage(ttsLanguage);
  }

  /// Speak the current letter
  Future<void> _speakLetter() async {
    try {
      await _tts.speak(_currentLetter.character);
    } catch (e) {
      debugPrint('Error speaking letter: $e');
    }
  }

  /// Get letters for specific language
  /// Uses simplified approach - shows actual character to trace over
  List<TraceableLetter> _getLettersForLanguage(String language) {
    // Use the helper class for better letter data
    return _getSimplifiedLetters(language);
  }

  /// Get simplified letters that just use basic shape approximations
  /// This is better than geometric shapes as it focuses on coverage
  List<TraceableLetter> _getSimplifiedLetters(String language) {
    final letters = <TraceableLetter>[];
    
    // Define letters for each language
    final lettersByLanguage = {
      'hi': ['अ', 'आ', 'इ', 'ई', 'उ', 'ऊ', 'ए', 'ऐ', 'ओ', 'औ'],
      'gu': ['અ', 'આ', 'ઇ', 'ઈ', 'ઉ', 'ઊ', 'એ', 'ઐ', 'ઓ', 'ઔ'],
      'ta': ['அ', 'ஆ', 'இ', 'ஈ', 'உ', 'ஊ', 'எ', 'ஏ', 'ஐ', 'ஒ'],
      'te': ['అ', 'ఆ', 'ఇ', 'ఈ', 'ఉ', 'ఊ', 'ఎ', 'ఏ', 'ఐ', 'ఒ'],
      'kn': ['ಅ', 'ಆ', 'ಇ', 'ಈ', 'ಉ', 'ಊ', 'ಎ', 'ಏ', 'ಐ', 'ಒ'],
      'ml': ['അ', 'ആ', 'ഇ', 'ഈ', 'ഉ', 'ഊ', 'എ', 'ഏ', 'ഐ', 'ഒ'],
      'mr': ['अ', 'आ', 'इ', 'ई', 'उ', 'ऊ', 'ए', 'ऐ', 'ओ', 'औ'],
      'bn': ['অ', 'আ', 'ই', 'ঈ', 'উ', 'ঊ', 'এ', 'ঐ', 'ও', 'ঔ'],
      'pa': ['ਅ', 'ਆ', 'ਇ', 'ਈ', 'ਉ', 'ਊ', 'ਏ', 'ਐ', 'ਓ', 'ਔ'],
    };

    final transliterations = ['a', 'aa', 'i', 'ii', 'u', 'uu', 'e', 'ai', 'o', 'au'];
    
    final languageLetters = lettersByLanguage[language] ?? lettersByLanguage['hi']!;
    
    for (int i = 0; i < languageLetters.length; i++) {
      letters.add(TraceableLetter(
        character: languageLetters[i],
        language: language,
        pronunciation: transliterations[i],
        transliteration: transliterations[i],
        referenceSegments: _createSimpleReferenceForLetter(),
      ));
    }
    
    return letters;
  }

  /// Create a simple reference area covering the typical letter space
  /// This allows free-form tracing within the letter area
  /// Note: These are normalized coordinates (0-1) that will be scaled to actual canvas size
  List<ReferencePathSegment> _createSimpleReferenceForLetter() {
    // Create a dense grid of reference points covering the letter area
    // Using normalized coordinates (0-1 range) for device independence
    final points = <Offset>[];
    
    // Cover center 70% of canvas (0.15 to 0.85) with dense grid
    // This ensures the entire letter area is covered
    for (double x = 0.15; x <= 0.85; x += 0.025) {
      for (double y = 0.15; y <= 0.85; y += 0.025) {
        points.add(Offset(x, y));
      }
    }
    
    return [
      ReferencePathSegment(
        points: points,
        order: 1,
        strokeDirection: 'free-form',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.languageName} Letter Tracing'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.languageName} Letter Tracing'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [          // Hint toggle button
          IconButton(
            icon: Icon(_showHints ? Icons.lightbulb : Icons.lightbulb_outline),
            onPressed: () {
              setState(() {
                _showHints = !_showHints;
              });
            },
            tooltip: _showHints ? 'Hide Hints' : 'Show Hints',
          ),          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _showStatistics,
            tooltip: 'Statistics',
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressBar(),
          
          // Letter display and info
          _buildLetterInfo(),
          
          // Tracing canvas
          Expanded(
            child: _buildTracingArea(),
          ),
          
          // Feedback area
          if (_showFeedback) _buildFeedbackArea(),
          
          // Control buttons
          _buildControlButtons(),
        ],
      ),
    );
  }

  /// Build progress bar showing completion
  Widget _buildProgressBar() {
    final stats = _progressManager.getStatistics(_letters);
    final completed = stats['completedCount'] as int;
    final total = stats['totalCount'] as int;
    final progress = total > 0 ? completed / total : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress: $completed / $total',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  /// Build letter info section
  Widget _buildLetterInfo() {
    final progress = _progressManager.getProgress(_currentLetter.id);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Letter: ${_currentLetter.character}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_currentLetter.transliteration != null)
                    Text(
                      'Sound: ${_currentLetter.transliteration}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 36),
                    onPressed: _speakLetter,
                    color: Theme.of(context).primaryColor,
                    tooltip: 'Play sound',
                  ),
                  if (progress != null && progress.isCompleted)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 32,
                    ),
                ],
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            Text(
              'Attempts: ${progress.attemptCount} | '
              'Best Score: ${(progress.bestScore * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build tracing canvas area
  Widget _buildTracingArea() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[400]!, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: TracingCanvas(
          key: _canvasKey,
          letter: _currentLetter,
          onTracingComplete: _onTracingComplete,
          enableRealTimeFeedback: true,
          showHints: _showHints, // Pass hint visibility state
        ),
      ),
    );
  }

  /// Build feedback area
  Widget _buildFeedbackArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: _isSuccess ? Colors.green[50] : Colors.red[50],
      child: Row(
        children: [
          Icon(
            _isSuccess ? Icons.check_circle : Icons.error,
            color: _isSuccess ? Colors.green : Colors.red,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _feedbackMessage,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _isSuccess ? Colors.green[900] : Colors.red[900],
                  ),
                ),
                if (_currentAccuracy > 0)
                  Text(
                    'Accuracy: ${(_currentAccuracy * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build control buttons
  Widget _buildControlButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Reset button
          ElevatedButton.icon(
            onPressed: _resetTracing,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
          
          // Validate button
          ElevatedButton.icon(
            onPressed: _validateTracing,
            icon: const Icon(Icons.check),
            label: const Text('Check'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
          
          // Next button (enabled only after completion)
          ElevatedButton.icon(
            onPressed: _isSuccess ? _loadNextLetter : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle tracing completion
  void _onTracingComplete(List<Stroke> strokes) {
    // Strokes updated, ready for validation
  }

  /// Validate current tracing
  Future<void> _validateTracing() async {
    final canvasState = _canvasKey.currentState as TracingCanvasState?;
    final strokes = canvasState?.strokes ?? [];
    
    if (strokes.isEmpty) {
      _showError('Please trace the letter first');
      return;
    }

    // Get canvas size for coordinate scaling
    final canvasSize = canvasState?.canvasSize ?? Size.zero;

    // Validate using TracingValidator
    final result = TracingValidator.validate(
      userStrokes: strokes,
      referenceSegments: _currentLetter.referenceSegments,
      accuracyThreshold: 0.50, // More forgiving threshold - 50%
      canvasSize: canvasSize, // Pass canvas size for scaling normalized coordinates
    );

    // Update progress
    await _progressManager.updateProgress(
      letterId: _currentLetter.id,
      score: result.accuracyScore,
      completed: result.isValid,
    );

    // Show feedback
    setState(() {
      _showFeedback = true;
      _isSuccess = result.isValid;
      _currentAccuracy = result.accuracyScore;
      _feedbackMessage = result.feedback.join('\n');
    });

    // Visual feedback on canvas
    if (result.isValid) {
      canvasState?.showSuccessFeedback();
      // Play success sound or animation
      await _speakLetter();
    } else {
      canvasState?.showErrorFeedback();
    }
  }

  /// Reset tracing canvas
  void _resetTracing() {
    final canvasState = _canvasKey.currentState as TracingCanvasState?;
    canvasState?.clearStrokes();
    setState(() {
      _showFeedback = false;
      _isSuccess = false;
      _currentAccuracy = 0.0;
    });
  }

  /// Load next letter
  Future<void> _loadNextLetter() async {
    // Move to next letter
    final nextIndex = await _progressManager.moveToNextLetter(_letters);
    
    setState(() {
      _currentLetter = _letters[nextIndex];
      _showFeedback = false;
      _isSuccess = false;
      _currentAccuracy = 0.0;
    });
    
    // Clear canvas
    final canvasState = _canvasKey.currentState as TracingCanvasState?;
    canvasState?.clearStrokes();
    
    // Speak new letter
    await _speakLetter();
  }

  /// Show statistics dialog
  void _showStatistics() {
    final stats = _progressManager.getStatistics(_letters);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Progress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow(
              'Completed Letters',
              '${stats['completedCount']} / ${stats['totalCount']}',
            ),
            _buildStatRow(
              'Completion Rate',
              '${stats['completionPercentage']}%',
            ),
            _buildStatRow(
              'Total Attempts',
              '${stats['totalAttempts']}',
            ),
            _buildStatRow(
              'Average Score',
              '${stats['averageScore']}%',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showResetConfirmation();
            },
            child: const Text(
              'Reset Progress',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Build statistics row
  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Show reset confirmation dialog
  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will clear all your progress for this language. '
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _progressManager.clearAllProgress();
              Navigator.pop(context);
              _initializeScreen();
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
