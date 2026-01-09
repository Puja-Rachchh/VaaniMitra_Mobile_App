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

class AnimalsLearningScreen extends StatefulWidget {
  const AnimalsLearningScreen({super.key});

  @override
  State<AnimalsLearningScreen> createState() => _AnimalsLearningScreenState();
}

class _AnimalsLearningScreenState extends State<AnimalsLearningScreen> {
  String? knownLanguage;
  String? targetLanguage;
  int currentAnimalIndex = 0;
  List<Map<String, String>> animals = [];
  bool isLoading = true;
  String? translatedDescription;
  
  // Pronunciation practice variables
  bool _speechInitialized = false;
  bool _isListening = false;
  String _recognizedText = '';
  pron_service.PronunciationResult? _pronunciationResult;
  bool _showPronunciationFeedback = false;

  // Animals data with images and English names
  final List<Map<String, String>> animalsData = [
    {'name': 'Bear', 'image': 'assets/animals/bear.jpg'},
    {'name': 'Butterfly', 'image': 'assets/animals/butterfly.jpg'},
    {'name': 'Camel', 'image': 'assets/animals/camel.jpeg'},
    {'name': 'Cat', 'image': 'assets/animals/cat.jpg'},
    {'name': 'Cow', 'image': 'assets/animals/cow.jpg'},
    {'name': 'Crane', 'image': 'assets/animals/crane.jpg'},
    {'name': 'Crow', 'image': 'assets/animals/crow.jpeg'},
    {'name': 'Dog', 'image': 'assets/animals/dog.jpg'},
    {'name': 'Donkey', 'image': 'assets/animals/donkey.jpg'},
    {'name': 'Duck', 'image': 'assets/animals/duck.jpg'},
    {'name': 'Eagle', 'image': 'assets/animals/eagle.jpeg'},
    {'name': 'Elephant', 'image': 'assets/animals/elephant.jpg'},
    {'name': 'Fish', 'image': 'assets/animals/fish.jpeg'},
    {'name': 'Flamingo', 'image': 'assets/animals/flamingo.jpg'},
    {'name': 'Fox', 'image': 'assets/animals/fox.jpg'},
    {'name': 'Goat', 'image': 'assets/animals/goat.jpeg'},
    {'name': 'Hen', 'image': 'assets/animals/hen.jpg'},
    {'name': 'Horse', 'image': 'assets/animals/horse.jpg'},
    {'name': 'Kingfisher', 'image': 'assets/animals/kingfisher.jpg'},
    {'name': 'Lion', 'image': 'assets/animals/lion.jpg'},
    {'name': 'Monkey', 'image': 'assets/animals/monkey.jpg'},
    {'name': 'Mouse', 'image': 'assets/animals/mouse.jpg'},
    {'name': 'Owl', 'image': 'assets/animals/owl.jpg'},
    {'name': 'Parrot', 'image': 'assets/animals/parrot.jpg'},
    {'name': 'Peacock', 'image': 'assets/animals/peacock.jpg'},
    {'name': 'Pigeon', 'image': 'assets/animals/pigeon.jpg'},
    {'name': 'Rabbit', 'image': 'assets/animals/rabbit.jpg'},
    {'name': 'Rhino', 'image': 'assets/animals/rhino.jpeg'},
    {'name': 'Sheep', 'image': 'assets/animals/sheep.jpg'},
    {'name': 'Snake', 'image': 'assets/animals/snake.jpg'},
    {'name': 'Sparrow', 'image': 'assets/animals/sparrow.jpeg'},
    {'name': 'Squirrel', 'image': 'assets/animals/squirrel.jpeg'},
    {'name': 'Swan', 'image': 'assets/animals/swan.JPG'},
    {'name': 'Tiger', 'image': 'assets/animals/tiger.jpg'},
    {'name': 'Turtle', 'image': 'assets/animals/turtle.jpg'},
    {'name': 'Woodpecker', 'image': 'assets/animals/woodpecker.jpeg'},
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
      await _loadAnimals();
    }
  }

  Future<void> _loadAnimals() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    List<Map<String, String>> animalsList = [];
    for (var animal in animalsData) {
      // Translate the animal name to target language
      final targetName = await TranslationService.translateText(
        animal['name']!, targetLanguage!, 'en'
      );
      
      // Translate the animal name to known language
      final knownName = await TranslationService.translateText(
        animal['name']!, knownLanguage!, 'en'
      );
      
      animalsList.add({
        'englishName': animal['name']!,
        'targetName': targetName,
        'knownName': knownName,
        'image': animal['image']!,
      });
    }

    if (mounted) {
      setState(() {
        animals = animalsList;
        isLoading = false;
      });
    }

    await _loadAnimalDescription();
  }

  Future<void> _loadAnimalDescription() async {
    if (animals.isNotEmpty && currentAnimalIndex < animals.length) {
      final currentAnimal = animals[currentAnimalIndex];
      final description = 'This is a ${currentAnimal['englishName']}. It is a wonderful animal found in nature.';
      if (mounted) {
        setState(() {
          translatedDescription = description;
        });
      }
    }
  }

  void _nextAnimal() {
    if (currentAnimalIndex < animals.length - 1) {
      if (mounted) {
        setState(() {
          currentAnimalIndex++;
          translatedDescription = null;
          _recognizedText = '';
          _pronunciationResult = null;
          _showPronunciationFeedback = false;
        });
      }
      _loadAnimalDescription();
    }
  }

  void _previousAnimal() {
    if (currentAnimalIndex > 0) {
      if (mounted) {
        setState(() {
          currentAnimalIndex--;
          translatedDescription = null;
          _recognizedText = '';
          _pronunciationResult = null;
          _showPronunciationFeedback = false;
        });
      }
      _loadAnimalDescription();
    }
  }

  Future<void> _playAnimalSound() async {
    if (animals.isNotEmpty && currentAnimalIndex < animals.length) {
      final currentAnimal = animals[currentAnimalIndex]['targetName']!;
      await TextToSpeechService.speakLetter(currentAnimal, targetLanguage!);
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
    debugPrint('AnimalsLearningScreen: Initializing speech recognition...');
    try {
      final initialized = await SpeechRecognitionService.initialize();
      debugPrint('AnimalsLearningScreen: Speech recognition initialization result: $initialized');
      if (mounted) {
        setState(() {
          _speechInitialized = initialized;
        });
      }
      if (initialized) {
        debugPrint('AnimalsLearningScreen: Speech recognition initialized successfully');
      } else {
        debugPrint('AnimalsLearningScreen: Speech recognition initialization failed');
      }
    } catch (e) {
      debugPrint('AnimalsLearningScreen: Error initializing speech recognition: $e');
      if (mounted) {
        setState(() {
          _speechInitialized = false;
        });
      }
    }
  }

  Future<void> _startListening() async {
    debugPrint('AnimalsLearningScreen: Attempting to start listening...');
    
    if (!_speechInitialized) {
      debugPrint('AnimalsLearningScreen: Speech not initialized, attempting reinitialization...');
      await _initializeSpeechRecognition();
      if (!_speechInitialized) {
        _showErrorMessage('Speech recognition not available. Please check permissions.');
        return;
      }
    }
    
    if (targetLanguage == null) {
      debugPrint('AnimalsLearningScreen: Target language is null');
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
      debugPrint('AnimalsLearningScreen: Starting speech recognition for language: $targetLanguage');
      final success = await SpeechRecognitionService.startListening(
        languageCode: targetLanguage!,
        onResult: (text) {
          debugPrint('AnimalsLearningScreen: Recognized text: $text');
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
        debugPrint('AnimalsLearningScreen: Failed to start speech recognition');
        if (mounted) {
          setState(() {
            _isListening = false;
          });
        }
        _showErrorMessage('Failed to start speech recognition. Please try again or check device settings.');
      }
    } catch (e) {
      debugPrint('AnimalsLearningScreen: Error starting speech recognition: $e');
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
    if (_recognizedText.isEmpty || currentAnimalIndex >= animals.length) return;

    final expectedWord = animals[currentAnimalIndex]['targetName']!;
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
            title: const Text('Animals Quiz'),
            backgroundColor: Colors.brown.shade600,
            foregroundColor: Colors.white,
          ),
          body: QuizWidget(
            category: 'animals',
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
          title: const Text('Learning Animals'),
          backgroundColor: Colors.brown.shade600,
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

    if (animals.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Animals'),
          backgroundColor: Colors.brown.shade600,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No animals data available.'),
        ),
      );
    }

    final currentAnimal = animals[currentAnimalIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Animals'),
        backgroundColor: Colors.brown.shade600,
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
              value: (currentAnimalIndex + 1) / animals.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.brown.shade600),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Animal ${currentAnimalIndex + 1} of ${animals.length}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),

            // Animal image with click-to-speak
            GestureDetector(
              onTap: _playAnimalSound,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.brown.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.brown.shade300, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        currentAnimal['image']!,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading image: ${currentAnimal['image']!}');
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
                              ],
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
                          color: Colors.brown.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Tap to hear',
                          style: TextStyle(
                            color: Colors.brown.shade600,
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

            // Animal names comparison
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 2,
                    color: Colors.brown.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Learning Language',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.brown.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentAnimal['targetName']!,
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
                            currentAnimal['knownName']!,
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
                        'Tap the button and say: ${animals[currentAnimalIndex]['targetName']}',
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
                      onPressed: currentAnimalIndex > 0 ? _previousAnimal : null,
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
                      onPressed: _playAnimalSound,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown.shade600,
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
                      onPressed: currentAnimalIndex < animals.length - 1 ? _nextAnimal : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown.shade600,
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