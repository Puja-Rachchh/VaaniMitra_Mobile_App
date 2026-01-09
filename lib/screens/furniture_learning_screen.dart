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

class FurnitureLearningScreen extends StatefulWidget {
  const FurnitureLearningScreen({super.key});

  @override
  State<FurnitureLearningScreen> createState() => _FurnitureLearningScreenState();
}

class _FurnitureLearningScreenState extends State<FurnitureLearningScreen> {
  String? knownLanguage;
  String? targetLanguage;
  int currentFurnitureIndex = 0;
  List<Map<String, String>> furniture = [];
  bool isLoading = true;
  String? translatedDescription;
  
  // Pronunciation practice variables
  bool _speechInitialized = false;
  bool _isListening = false;
  String _recognizedText = '';
  pron_service.PronunciationResult? _pronunciationResult;
  bool _showPronunciationFeedback = false;

  // Furniture data with images and English names
  final List<Map<String, String>> furnitureData = [
    {'name': 'Bed', 'image': 'assets/furniture/bed.jpg'},
    {'name': 'Chair', 'image': 'assets/furniture/chair.jpg'},
    {'name': 'Cupboard', 'image': 'assets/furniture/cupboard.jpg'},
    {'name': 'Door', 'image': 'assets/furniture/door.jpg'},
    {'name': 'Dresser', 'image': 'assets/furniture/dresser.jpeg'},
    {'name': 'Lamp', 'image': 'assets/furniture/lamp.jpg'},
    {'name': 'Mirror', 'image': 'assets/furniture/mirror.jpg'},
    {'name': 'Shelf', 'image': 'assets/furniture/shelf.jpeg'},
    {'name': 'Sofa', 'image': 'assets/furniture/sofa.jpg'},
    {'name': 'Table', 'image': 'assets/furniture/table.jpg'},
    {'name': 'Window', 'image': 'assets/furniture/window.jpeg'},
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
      await _loadFurniture();
    }
  }

  Future<void> _loadFurniture() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    List<Map<String, String>> furnitureList = [];
    for (var furnitureItem in furnitureData) {
      debugPrint('Loading furniture: ${furnitureItem['name']} with image: ${furnitureItem['image']}');
      
      // Translate the furniture name to target language
      final targetName = await TranslationService.translateText(
        furnitureItem['name']!, targetLanguage!, 'en'
      );
      
      // Translate the furniture name to known language
      final knownName = await TranslationService.translateText(
        furnitureItem['name']!, knownLanguage!, 'en'
      );
      
      furnitureList.add({
        'englishName': furnitureItem['name']!,
        'targetName': targetName,
        'knownName': knownName,
        'image': furnitureItem['image']!,
      });
    }

    if (mounted) {
      setState(() {
        furniture = furnitureList;
        isLoading = false;
      });
    }

    await _loadFurnitureDescription();
  }

  Future<void> _loadFurnitureDescription() async {
    if (furniture.isNotEmpty && currentFurnitureIndex < furniture.length) {
      final currentFurniture = furniture[currentFurnitureIndex];
      final description = 'This is a ${currentFurniture['englishName']}. It is a useful furniture item.';
      if (mounted) {
        setState(() {
          translatedDescription = description;
        });
      }
    }
  }

  void _nextFurniture() {
    if (currentFurnitureIndex < furniture.length - 1) {
      if (mounted) {
        setState(() {
          currentFurnitureIndex++;
          translatedDescription = null;          _recognizedText = '';
          _pronunciationResult = null;
          _showPronunciationFeedback = false;        });
      }
      _loadFurnitureDescription();
    }
  }

  void _previousFurniture() {
    if (currentFurnitureIndex > 0) {
      if (mounted) {
        setState(() {
          currentFurnitureIndex--;
          translatedDescription = null;
          _recognizedText = '';
          _pronunciationResult = null;
          _showPronunciationFeedback = false;
        });
      }
      _loadFurnitureDescription();
    }
  }

  Future<void> _playFurnitureSound() async {
    if (furniture.isNotEmpty && currentFurnitureIndex < furniture.length) {
      final currentFurniture = furniture[currentFurnitureIndex]['targetName']!;
      await TextToSpeechService.speakLetter(currentFurniture, targetLanguage!);
    }
  }

  TextStyle _getLanguageTextStyle(String? language, double fontSize) {
    if (language == null) return TextStyle(fontSize: fontSize);
    
    switch (language) {
      case 'hi':
        return GoogleFonts.notoSansDevanagari(fontSize: fontSize, fontWeight: FontWeight.w600);
      case 'ta':
        return GoogleFonts.notoSansTamil(fontSize: fontSize, fontWeight: FontWeight.w600);
      case 'te':
        return GoogleFonts.notoSansTelugu(fontSize: fontSize, fontWeight: FontWeight.w600);
      case 'bn':
        return GoogleFonts.notoSansBengali(fontSize: fontSize, fontWeight: FontWeight.w600);
      case 'mr':
        return GoogleFonts.notoSansDevanagari(fontSize: fontSize, fontWeight: FontWeight.w600);
      case 'gu':
        return GoogleFonts.notoSansGujarati(fontSize: fontSize, fontWeight: FontWeight.w600);
      case 'kn':
        return GoogleFonts.notoSansKannada(fontSize: fontSize, fontWeight: FontWeight.w600);
      case 'ml':
        return GoogleFonts.notoSansMalayalam(fontSize: fontSize, fontWeight: FontWeight.w600);
      case 'pa':
        return GoogleFonts.notoSansGurmukhi(fontSize: fontSize, fontWeight: FontWeight.w600);
      case 'or':
        return GoogleFonts.notoSansOriya(fontSize: fontSize, fontWeight: FontWeight.w600);
      case 'as':
        return GoogleFonts.notoSansBengali(fontSize: fontSize, fontWeight: FontWeight.w600);
      case 'ur':
        return GoogleFonts.notoSansArabic(fontSize: fontSize, fontWeight: FontWeight.w600);
      case 'ne':
        return GoogleFonts.notoSansDevanagari(fontSize: fontSize, fontWeight: FontWeight.w600);
      default:
        return GoogleFonts.poppins(fontSize: fontSize, fontWeight: FontWeight.w600);
    }
  }

  // Speech recognition methods
  Future<void> _initializeSpeechRecognition() async {
    debugPrint('FurnitureLearningScreen: Initializing speech recognition...');
    try {
      final initialized = await SpeechRecognitionService.initialize();
      debugPrint('FurnitureLearningScreen: Speech recognition initialization result: $initialized');
      if (mounted) {
        setState(() {
          _speechInitialized = initialized;
        });
      }
      if (initialized) {
        debugPrint('FurnitureLearningScreen: Speech recognition initialized successfully');
      } else {
        debugPrint('FurnitureLearningScreen: Speech recognition initialization failed');
      }
    } catch (e) {
      debugPrint('FurnitureLearningScreen: Error initializing speech recognition: $e');
      if (mounted) {
        setState(() {
          _speechInitialized = false;
        });
      }
    }
  }

  Future<void> _startListening() async {
    debugPrint('FurnitureLearningScreen: Attempting to start listening...');
    
    if (!_speechInitialized) {
      debugPrint('FurnitureLearningScreen: Speech not initialized, attempting reinitialization...');
      await _initializeSpeechRecognition();
      if (!_speechInitialized) {
        _showErrorMessage('Speech recognition not available. Please check permissions.');
        return;
      }
    }
    
    if (targetLanguage == null) {
      debugPrint('FurnitureLearningScreen: Target language is null');
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
      debugPrint('FurnitureLearningScreen: Starting speech recognition for language: $targetLanguage');
      final success = await SpeechRecognitionService.startListening(
        languageCode: targetLanguage!,
        onResult: (text) {
          debugPrint('FurnitureLearningScreen: Recognized text: $text');
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
        debugPrint('FurnitureLearningScreen: Failed to start speech recognition');
        if (mounted) {
          setState(() {
            _isListening = false;
          });
        }
        _showErrorMessage('Failed to start speech recognition. Please try again or check device settings.');
      }
    } catch (e) {
      debugPrint('FurnitureLearningScreen: Error starting speech recognition: $e');
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
    if (_recognizedText.isEmpty || currentFurnitureIndex >= furniture.length) return;

    final expectedWord = furniture[currentFurnitureIndex]['targetName']!;
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
            title: const Text('Furniture Quiz'),
            backgroundColor: const Color(0xFF8B4513),
            foregroundColor: Colors.white,
          ),
          body: QuizWidget(
            category: 'furniture',
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
          title: const Text('Learning Furniture'),
          backgroundColor: const Color(0xFF8B4513),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (furniture.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Furniture'),
          backgroundColor: const Color(0xFF8B4513),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No furniture data available'),
        ),
      );
    }

    final currentFurniture = furniture[currentFurnitureIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Furniture'),
        backgroundColor: const Color(0xFF8B4513),
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
            onPressed: _playFurnitureSound,
            icon: const Icon(Icons.volume_up),
            tooltip: 'Play sound',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (currentFurnitureIndex + 1) / furniture.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Furniture ${currentFurnitureIndex + 1} of ${furniture.length}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),
            
            // Furniture image and name cards
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        currentFurniture['image']!,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading image: ${currentFurniture['image']!}');
                          debugPrint('Error details: $error');
                          return Container(
                            width: 180,
                            height: 180,
                            color: Colors.grey.shade300,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Image not found',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  currentFurniture['image']!,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Language cards
                    Row(
                      children: [
                        // Known Language Card
                        Expanded(
                          child: GestureDetector(
                            onTap: () => TextToSpeechService.speakLetter(
                              currentFurniture['knownName']!, knownLanguage!),
                            child: Card(
                              color: Colors.blue.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    Text(
                                      'Known Language',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      currentFurniture['knownName']!,
                                      style: _getLanguageTextStyle(knownLanguage, 18),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Icon(Icons.volume_up, color: Colors.blue.shade600, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Target Language Card
                        Expanded(
                          child: GestureDetector(
                            onTap: () => TextToSpeechService.speakLetter(
                              currentFurniture['targetName']!, targetLanguage!),
                            child: Card(
                              color: Colors.green.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    Text(
                                      'Target Language',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      currentFurniture['targetName']!,
                                      style: _getLanguageTextStyle(targetLanguage, 18),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Icon(Icons.volume_up, color: Colors.green.shade600, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
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
                        'Tap the button and say: ${furniture[currentFurnitureIndex]['targetName']}',
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
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    translatedDescription!,
                    style: _getLanguageTextStyle(knownLanguage, 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            
            const SizedBox(height: 30),
            
            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 70,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: currentFurnitureIndex > 0 ? _previousFurniture : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B4513),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, size: 16),
                        SizedBox(height: 2),
                        Text('Prev', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 70,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _startQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.quiz, size: 16),
                        SizedBox(height: 2),
                        Text('Quiz', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 70,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: currentFurnitureIndex < furniture.length - 1 ? _nextFurniture : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B4513),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_forward, size: 16),
                        SizedBox(height: 2),
                        Text('Next', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}