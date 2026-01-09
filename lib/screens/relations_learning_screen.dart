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

class RelationsLearningScreen extends StatefulWidget {
  const RelationsLearningScreen({super.key});

  @override
  State<RelationsLearningScreen> createState() => _RelationsLearningScreenState();
}

class _RelationsLearningScreenState extends State<RelationsLearningScreen> {
  String? knownLanguage;
  String? targetLanguage;
  int currentRelationIndex = 0;
  List<Map<String, String>> relations = [];
  bool isLoading = true;
  String? translatedDescription;
  
  // Pronunciation practice variables
  bool _speechInitialized = false;
  bool _isListening = false;
  String _recognizedText = '';
  pron_service.PronunciationResult? _pronunciationResult;
  bool _showPronunciationFeedback = false;

  // Relations data with images and English names
  final List<Map<String, String>> relationsData = [
    {'name': 'Father', 'image': 'assets/relations/father.jpg'},
    {'name': 'Mother', 'image': 'assets/relations/mother.jpg'},
    {'name': 'Brother', 'image': 'assets/relations/brother.jpg'},
    {'name': 'Sister', 'image': 'assets/relations/sister.jpg'},
    {'name': 'Son', 'image': 'assets/relations/son.jpg'},
    {'name': 'Daughter', 'image': 'assets/relations/daughter.jpg'},
    {'name': 'Grandfather', 'image': 'assets/relations/grandfather.jpg'},
    {'name': 'Grandmother', 'image': 'assets/relations/grandmother.jpg'},
    {'name': 'Uncle', 'image': 'assets/relations/uncle.jpg'},
    {'name': 'Aunty', 'image': 'assets/relations/aunty.jpg'},
    {'name': 'Nephew', 'image': 'assets/relations/nephew.jpg'},
    {'name': 'Niece', 'image': 'assets/relations/niece.jpg'},
    {'name': 'Grandson', 'image': 'assets/relations/grandson.jpg'},
    {'name': 'Granddaughter', 'image': 'assets/relations/granddaughter.jpg'},
    {'name': 'Cousins', 'image': 'assets/relations/cousins.jpeg'},
    {'name': 'Husband', 'image': 'assets/relations/husband-wife.jpg'},
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
      await _loadRelations();
    }
  }

  Future<void> _loadRelations() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    List<Map<String, String>> relationsList = [];
    for (var relation in relationsData) {
      debugPrint('Loading relation: ${relation['name']} with image: ${relation['image']}');
      
      // Translate the relation name to target language
      final targetName = await TranslationService.translateText(
        relation['name']!, targetLanguage!, 'en'
      );
      
      // Translate the relation name to known language
      final knownName = await TranslationService.translateText(
        relation['name']!, knownLanguage!, 'en'
      );
      
      relationsList.add({
        'englishName': relation['name']!,
        'targetName': targetName,
        'knownName': knownName,
        'image': relation['image']!,
      });
    }

    if (mounted) {
      setState(() {
        relations = relationsList;
        isLoading = false;
      });
    }

    await _loadRelationDescription();
  }

  Future<void> _loadRelationDescription() async {
    if (relations.isNotEmpty && currentRelationIndex < relations.length) {
      final currentRelation = relations[currentRelationIndex];
      final description = 'This is your ${currentRelation['englishName']}. Family relationships are very important in our culture.';
      if (mounted) {
        setState(() {
          translatedDescription = description;
        });
      }
    }
  }

  void _nextRelation() {
    if (currentRelationIndex < relations.length - 1) {
      if (mounted) {
        setState(() {
          currentRelationIndex++;
          translatedDescription = null;
          _recognizedText = '';
          _pronunciationResult = null;
          _showPronunciationFeedback = false;
        });
      }
      _loadRelationDescription();
    }
  }

  void _previousRelation() {
    if (currentRelationIndex > 0) {
      if (mounted) {
        setState(() {
          currentRelationIndex--;
          translatedDescription = null;
          _recognizedText = '';
          _pronunciationResult = null;
          _showPronunciationFeedback = false;
        });
      }
      _loadRelationDescription();
    }
  }

  Future<void> _playRelationSound() async {
    if (relations.isNotEmpty && currentRelationIndex < relations.length) {
      final currentRelation = relations[currentRelationIndex]['targetName']!;
      await TextToSpeechService.speakLetter(currentRelation, targetLanguage!);
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
    debugPrint('RelationsLearningScreen: Initializing speech recognition...');
    try {
      final initialized = await SpeechRecognitionService.initialize();
      debugPrint('RelationsLearningScreen: Speech recognition initialization result: $initialized');
      if (mounted) {
        setState(() {
          _speechInitialized = initialized;
        });
      }
      if (initialized) {
        debugPrint('RelationsLearningScreen: Speech recognition initialized successfully');
      } else {
        debugPrint('RelationsLearningScreen: Speech recognition initialization failed');
      }
    } catch (e) {
      debugPrint('RelationsLearningScreen: Error initializing speech recognition: $e');
      if (mounted) {
        setState(() {
          _speechInitialized = false;
        });
      }
    }
  }

  Future<void> _startListening() async {
    debugPrint('RelationsLearningScreen: Attempting to start listening...');
    
    if (!_speechInitialized) {
      debugPrint('RelationsLearningScreen: Speech not initialized, attempting reinitialization...');
      await _initializeSpeechRecognition();
      if (!_speechInitialized) {
        _showErrorMessage('Speech recognition not available. Please check permissions.');
        return;
      }
    }
    
    if (targetLanguage == null) {
      debugPrint('RelationsLearningScreen: Target language is null');
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
      debugPrint('RelationsLearningScreen: Starting speech recognition for language: $targetLanguage');
      final success = await SpeechRecognitionService.startListening(
        languageCode: targetLanguage!,
        onResult: (text) {
          debugPrint('RelationsLearningScreen: Recognized text: $text');
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
        debugPrint('RelationsLearningScreen: Failed to start speech recognition');
        if (mounted) {
          setState(() {
            _isListening = false;
          });
        }
        _showErrorMessage('Failed to start speech recognition. Please try again or check device settings.');
      }
    } catch (e) {
      debugPrint('RelationsLearningScreen: Error starting speech recognition: $e');
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
    if (_recognizedText.isEmpty || currentRelationIndex >= relations.length) return;

    final expectedWord = relations[currentRelationIndex]['targetName']!;
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
            title: const Text('Relations Quiz'),
            backgroundColor: const Color(0xFFE91E63),
            foregroundColor: Colors.white,
          ),
          body: QuizWidget(
            category: 'relations',
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
          title: const Text('Learning Relations'),
          backgroundColor: const Color(0xFFE74C3C),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (relations.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Relations'),
          backgroundColor: const Color(0xFFE74C3C),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No relations data available'),
        ),
      );
    }

    final currentRelation = relations[currentRelationIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Relations'),
        backgroundColor: const Color(0xFFE74C3C),
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
            onPressed: _playRelationSound,
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
              value: (currentRelationIndex + 1) / relations.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE74C3C)),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Relation ${currentRelationIndex + 1} of ${relations.length}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),
            
            // Relation image and name cards
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
                        currentRelation['image']!,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading image: ${currentRelation['image']!}');
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
                                  currentRelation['image']!,
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
                              currentRelation['knownName']!, knownLanguage!),
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
                                      currentRelation['knownName']!,
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
                              currentRelation['targetName']!, targetLanguage!),
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
                                      currentRelation['targetName']!,
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
                        'Tap the button and say: ${relations[currentRelationIndex]['targetName']}',
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
                    onPressed: currentRelationIndex > 0 ? _previousRelation : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
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
                    onPressed: currentRelationIndex < relations.length - 1 ? _nextRelation : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
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