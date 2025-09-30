import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/translation_service.dart';
import '../services/user_preferences.dart';
import '../services/text_to_speech_service.dart';
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
  }

  @override
  void dispose() {
    TextToSpeechService.stop();
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