import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/translation_service.dart';
import '../services/user_preferences.dart';
import '../services/text_to_speech_service.dart';
import '../services/speech_recognition_service.dart';
import '../services/pronunciation_service.dart' as pron_service;
import '../widgets/quiz_widget.dart';
import '../screens/quiz_results_screen.dart';
import '../models/quiz_models.dart';

class VegetablesLearningScreen extends StatefulWidget {
  const VegetablesLearningScreen({super.key});

  @override
  State<VegetablesLearningScreen> createState() => _VegetablesLearningScreenState();
}

class _VegetablesLearningScreenState extends State<VegetablesLearningScreen> {
  String? knownLanguage;
  String? targetLanguage;
  int currentVegetableIndex = 0;
  List<Map<String, String>> vegetables = [];
  bool isLoading = true;
  String? translatedDescription;
  
  // Pronunciation practice variables
  bool _speechInitialized = false;
  bool _isListening = false;
  String _recognizedText = '';
  pron_service.PronunciationResult? _pronunciationResult;
  bool _showPronunciationFeedback = false;

  // Vegetables data with images and English names
  final List<Map<String, String>> vegetablesData = [
    {'name': 'Bitter Gourd', 'image': 'assets/vegetables/bitter_gourd.jpg'},
    {'name': 'Bottle Gourd', 'image': 'assets/vegetables/bottle_gourd.jpeg'},
    {'name': 'Brinjal', 'image': 'assets/vegetables/brinjal.jpg'},
    {'name': 'Cabbage', 'image': 'assets/vegetables/cabbage.jpg'},
    {'name': 'Capsicum', 'image': 'assets/vegetables/capcicum.jpeg'},
    {'name': 'Cauliflower', 'image': 'assets/vegetables/cauliflower.jpeg'},
    {'name': 'Chilli', 'image': 'assets/vegetables/chilli.jpg'},
    {'name': 'Lady Finger', 'image': 'assets/vegetables/lady_finger.jpg'},
    {'name': 'Mushroom', 'image': 'assets/vegetables/mushroom.jpeg'},
    {'name': 'Onion', 'image': 'assets/vegetables/onion.jpeg'},
    {'name': 'Potato', 'image': 'assets/vegetables/potato.jpg'},
    {'name': 'Pumpkin', 'image': 'assets/vegetables/pumpkin.jpeg'},
    {'name': 'Spinach', 'image': 'assets/vegetables/spinach.jpg'},
    {'name': 'Tomato', 'image': 'assets/vegetables/tomato.jpeg'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeSpeechRecognition();
  }

  @override
  void dispose() {
    TextToSpeechService.stop();
    SpeechRecognitionService.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final known = await UserPreferences.getKnownLanguage();
    final target = await UserPreferences.getTargetLanguage();
    
    if (known != null && target != null) {
      if (mounted) {
        setState(() {
          knownLanguage = known;
          targetLanguage = target;
        });
      }
      await _loadVegetables();
    }
  }

  Future<void> _loadVegetables() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    List<Map<String, String>> vegetablesList = [];
    for (var vegetable in vegetablesData) {
      // Translate the vegetable name to target language
      final targetName = await TranslationService.translateText(
        vegetable['name']!, targetLanguage!, 'en'
      );
      
      // Translate the vegetable name to known language
      final knownName = await TranslationService.translateText(
        vegetable['name']!, knownLanguage!, 'en'
      );
      
      vegetablesList.add({
        'englishName': vegetable['name']!,
        'targetName': targetName,
        'knownName': knownName,
        'image': vegetable['image']!,
      });
    }

    if (mounted) {
      setState(() {
        vegetables = vegetablesList;
        isLoading = false;
      });
    }

    await _loadVegetableDescription();
  }

  Future<void> _loadVegetableDescription() async {
    if (vegetables.isNotEmpty && currentVegetableIndex < vegetables.length) {
      final currentVegetable = vegetables[currentVegetableIndex];
      final description = 'This is a ${currentVegetable['englishName']}. It is a healthy and nutritious vegetable.';
      if (mounted) {
        setState(() {
          translatedDescription = description;
        });
      }
    }
  }

  void _nextVegetable() {
    if (currentVegetableIndex < vegetables.length - 1) {
      if (mounted) {
        setState(() {
          currentVegetableIndex++;
          translatedDescription = null;
          _recognizedText = '';
          _pronunciationResult = null;
          _showPronunciationFeedback = false;
        });
      }
      _loadVegetableDescription();
    }
  }

  void _previousVegetable() {
    if (currentVegetableIndex > 0) {
      if (mounted) {
        setState(() {
          currentVegetableIndex--;
          translatedDescription = null;
          _recognizedText = '';
          _pronunciationResult = null;
          _showPronunciationFeedback = false;
        });
      }
      _loadVegetableDescription();
    }
  }

  Future<void> _playVegetableSound() async {
    if (vegetables.isNotEmpty && currentVegetableIndex < vegetables.length) {
      final currentVegetable = vegetables[currentVegetableIndex]['targetName']!;
      await TextToSpeechService.speakLetter(currentVegetable, targetLanguage!);
    }
  }

  TextStyle _getLanguageTextStyle(String? language, double fontSize) {
    if (language == null) return TextStyle(fontSize: fontSize);
    
    switch (language) {
      case 'hi':
      case 'mr':
      case 'ne':
        return GoogleFonts.notoSansDevanagari(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'ta':
        return GoogleFonts.notoSansTamil(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'bn':
      case 'as':
        return GoogleFonts.notoSansBengali(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'gu':
        return GoogleFonts.notoSansGujarati(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'kn':
        return GoogleFonts.notoSansKannada(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'ml':
        return GoogleFonts.notoSansMalayalam(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'te':
        return GoogleFonts.notoSansTelugu(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'pa':
        return GoogleFonts.notoSansGurmukhi(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'or':
        return GoogleFonts.notoSansOriya(fontSize: fontSize, fontWeight: FontWeight.bold);
      case 'ur':
      case 'sd':
        return GoogleFonts.notoSansArabic(fontSize: fontSize, fontWeight: FontWeight.bold);
      default:
        return GoogleFonts.notoSans(fontSize: fontSize, fontWeight: FontWeight.bold);
    }
  }

  // Speech recognition methods
  Future<void> _initializeSpeechRecognition() async {
    debugPrint('VegetablesLearningScreen: Initializing speech recognition...');
    try {
      final initialized = await SpeechRecognitionService.initialize();
      debugPrint('VegetablesLearningScreen: Speech recognition initialization result: $initialized');
      if (mounted) {
        setState(() {
          _speechInitialized = initialized;
        });
      }
      if (initialized) {
        debugPrint('VegetablesLearningScreen: Speech recognition initialized successfully');
      } else {
        debugPrint('VegetablesLearningScreen: Speech recognition initialization failed');
      }
    } catch (e) {
      debugPrint('VegetablesLearningScreen: Error initializing speech recognition: $e');
      if (mounted) {
        setState(() {
          _speechInitialized = false;
        });
      }
    }
  }

  Future<void> _startListening() async {
    debugPrint('VegetablesLearningScreen: Attempting to start listening...');
    
    if (!_speechInitialized) {
      debugPrint('VegetablesLearningScreen: Speech not initialized, attempting reinitialization...');
      await _initializeSpeechRecognition();
      if (!_speechInitialized) {
        _showErrorMessage('Speech recognition not available. Please check permissions.');
        return;
      }
    }
    
    if (targetLanguage == null) {
      debugPrint('VegetablesLearningScreen: Target language is null');
      _showErrorMessage('Target language not set');
      return;
    }
    
    setState(() {
      _recognizedText = '';
      _pronunciationResult = null;
      _showPronunciationFeedback = false;
      _isListening = true;
    });

    try {
      debugPrint('VegetablesLearningScreen: Starting speech recognition for language: $targetLanguage');
      final success = await SpeechRecognitionService.startListening(
        languageCode: targetLanguage!,
        onResult: (text) {
          debugPrint('VegetablesLearningScreen: Recognized text: $text');
          if (mounted) {
            setState(() {
              _recognizedText = text;
            });
            // Check pronunciation immediately if we have recognized text
            if (text.isNotEmpty && !_isListening) {
              _checkPronunciation();
            }
          }
        },
        onListening: (isListening) {
          debugPrint('🎤 Listening state: $isListening');
          if (mounted) {
            setState(() {
              _isListening = isListening;
            });
            // Check pronunciation when listening stops and we have text
            if (!isListening && _recognizedText.isNotEmpty) {
              _checkPronunciation();
            }
          }
        },
        onError: (message) {
          debugPrint('⚠️ Speech recognition warning: $message');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        timeout: const Duration(seconds: 10),
      );

      if (!success) {
        debugPrint('VegetablesLearningScreen: Failed to start speech recognition');
        if (mounted) {
          setState(() {
            _isListening = false;
          });
        }
        _showErrorMessage('Failed to start speech recognition. Please try again or check device settings.');
      }
    } catch (e) {
      debugPrint('VegetablesLearningScreen: Error starting speech recognition: $e');
      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
      _showErrorMessage('Speech recognition error: ${e.toString()}');
    }
  }

  Future<void> _stopListening() async {
    try {
      await SpeechRecognitionService.stopListening();
      if (mounted) {
        setState(() {
          _isListening = false;
        });
        if (_recognizedText.isNotEmpty) {
          _checkPronunciation();
        }
      }
    } catch (e) {
      debugPrint('Error stopping speech recognition: $e');
    }
  }

  void _checkPronunciation() {
    if (_recognizedText.isEmpty || currentVegetableIndex >= vegetables.length) return;

    final expectedWord = vegetables[currentVegetableIndex]['targetName']!;
    final result = pron_service.PronunciationService.evaluate(
      expectedWord,
      _recognizedText,
    );

    setState(() {
      _pronunciationResult = result;
      _showPronunciationFeedback = true;
    });
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildPronunciationFeedback() {
    if (!_showPronunciationFeedback || _pronunciationResult == null) {
      return const SizedBox.shrink();
    }

    final result = _pronunciationResult!;
    final color = result.isCorrect ? Colors.green : Colors.orange;

    return Card(
      elevation: 4,
      color: color.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              result.isCorrect ? Icons.check_circle : Icons.info,
              color: color,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              result.feedback,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Accuracy: ${(result.score * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 16, color: color.shade600),
            ),
            if (_recognizedText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'You said: $_recognizedText',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Quiz navigation methods
  void _startQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Vegetables Quiz'),
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
          ),
          body: QuizWidget(
            category: 'vegetables',
            level: 'beginner',
            onQuizCompleted: _onQuizCompleted,
          ),
        ),
      ),
    );
  }

  void _onQuizCompleted(QuizSession session) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizResultsScreen(
          session: session,
          onRetakeQuiz: () {
            Navigator.of(context).pop();
            _startQuiz();
          },
          onBackToMenu: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Vegetables'),
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed('/intermediate-learning');
              }
            },
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              icon: const Icon(Icons.home),
              tooltip: 'Home',
            ),
          ],
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (vegetables.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Vegetables'),
          backgroundColor: Colors.green.shade600,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No vegetables data available.'),
        ),
      );
    }

    final currentVegetable = vegetables[currentVegetableIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Vegetables'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/intermediate-learning');
            }
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            icon: const Icon(Icons.home),
            tooltip: 'Home',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (currentVegetableIndex + 1) / vegetables.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade600),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Vegetable ${currentVegetableIndex + 1} of ${vegetables.length}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),

            // Vegetable image with click-to-speak
            GestureDetector(
              onTap: _playVegetableSound,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.shade300, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        currentVegetable['image']!,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 180,
                            height: 180,
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.volume_up,
                          color: Colors.green.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Tap to hear',
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Vegetable names comparison
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 2,
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Learning Language',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentVegetable['targetName']!,
                            style: _getLanguageTextStyle(targetLanguage, 24),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Card(
                    elevation: 2,
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Your Language',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentVegetable['knownName']!,
                            style: _getLanguageTextStyle(knownLanguage, 24),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Pronunciation practice section
            if (_speechInitialized) ...[
              Card(
                elevation: 3,
                color: Colors.purple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mic, color: Colors.purple.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Pronunciation Practice',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap the button and say: ${vegetables[currentVegetableIndex]['targetName']}',
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _isListening ? _stopListening : _startListening,
                        icon: Icon(_isListening ? Icons.stop : Icons.mic),
                        label: Text(_isListening ? 'Stop Listening' : 'Start Practice'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isListening ? Colors.red : Colors.purple.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                      if (_isListening) ...[
                        const SizedBox(height: 12),
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        const Text('Listening...', style: TextStyle(color: Colors.red)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildPronunciationFeedback(),
              const SizedBox(height: 20),
            ],

            // Description
            if (translatedDescription != null)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        translatedDescription!,
                        style: _getLanguageTextStyle(knownLanguage, 16),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 30),

            // Navigation buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous button
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      onPressed: currentVegetableIndex > 0 ? _previousVegetable : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, size: 20),
                          Text('Previous', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Speak button
                  SizedBox(
                    width: 80,
                    child: ElevatedButton(
                      onPressed: _playVegetableSound,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.volume_up, size: 20),
                          Text('Speak', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Quiz button
                  SizedBox(
                    width: 80,
                    child: ElevatedButton(
                      onPressed: _startQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.quiz, size: 20),
                          Text('Quiz', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Next button
                  SizedBox(
                    width: 80,
                    child: ElevatedButton(
                      onPressed: currentVegetableIndex < vegetables.length - 1 ? _nextVegetable : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_forward, size: 20),
                          Text('Next', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}