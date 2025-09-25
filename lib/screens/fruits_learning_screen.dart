import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/translation_service.dart';
import '../services/user_preferences.dart';
import '../services/text_to_speech_service.dart';

class FruitsLearningScreen extends StatefulWidget {
  const FruitsLearningScreen({super.key});

  @override
  State<FruitsLearningScreen> createState() => _FruitsLearningScreenState();
}

class _FruitsLearningScreenState extends State<FruitsLearningScreen> {
  String? knownLanguage;
  String? targetLanguage;
  int currentFruitIndex = 0;
  List<Map<String, String>> fruits = [];
  bool isLoading = true;
  String? translatedDescription;

  // Fruits data with images and English names
  final List<Map<String, String>> fruitsData = [
    {'name': 'Apple', 'image': 'assets/fruits/apple.jpeg'},
    {'name': 'Banana', 'image': 'assets/fruits/banana.jpg'},
    {'name': 'Cherry', 'image': 'assets/fruits/cherry.jpeg'},
    {'name': 'Grapes', 'image': 'assets/fruits/grapes.jpeg'},
    {'name': 'Kiwi', 'image': 'assets/fruits/kiwi.jpeg'},
    {'name': 'Lychee', 'image': 'assets/fruits/lichi.jpeg'},
    {'name': 'Mango', 'image': 'assets/fruits/mango.jpg'},
    {'name': 'Orange', 'image': 'assets/fruits/orange.jpeg'},
    {'name': 'Papaya', 'image': 'assets/fruits/papaya.jpeg'},
    {'name': 'Pear', 'image': 'assets/fruits/pear.jpeg'},
    {'name': 'Pineapple', 'image': 'assets/fruits/pineapple.jpeg'},
    {'name': 'Pomegranate', 'image': 'assets/fruits/pomegranate.jpeg'},
    {'name': 'Strawberry', 'image': 'assets/fruits/strawberry.jpeg'},
    {'name': 'Sugarcane', 'image': 'assets/fruits/sugarcane.jpeg'},
    {'name': 'Watermelon', 'image': 'assets/fruits/watermelon.jpeg'},
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
      await _loadFruits();
    }
  }

  Future<void> _loadFruits() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    List<Map<String, String>> fruitsList = [];
    for (var fruit in fruitsData) {
      // Translate the fruit name to target language
      final targetName = await TranslationService.translateText(
        fruit['name']!, targetLanguage!, 'en'
      );
      
      // Translate the fruit name to known language
      final knownName = await TranslationService.translateText(
        fruit['name']!, knownLanguage!, 'en'
      );
      
      fruitsList.add({
        'englishName': fruit['name']!,
        'targetName': targetName,
        'knownName': knownName,
        'image': fruit['image']!,
      });
    }

    if (mounted) {
      setState(() {
        fruits = fruitsList;
        isLoading = false;
      });
    }

    await _loadFruitDescription();
  }

  Future<void> _loadFruitDescription() async {
    if (fruits.isNotEmpty && currentFruitIndex < fruits.length) {
      final currentFruit = fruits[currentFruitIndex];
      final description = await TranslationService.translateText(
        'This is a ${currentFruit['englishName']}. It is a delicious and nutritious fruit.',
        knownLanguage!,
        'en'
      );
      if (mounted) {
        setState(() {
          translatedDescription = description;
        });
      }
    }
  }

  void _nextFruit() {
    if (currentFruitIndex < fruits.length - 1) {
      if (mounted) {
        setState(() {
          currentFruitIndex++;
          translatedDescription = null;
        });
      }
      _loadFruitDescription();
    }
  }

  void _previousFruit() {
    if (currentFruitIndex > 0) {
      if (mounted) {
        setState(() {
          currentFruitIndex--;
          translatedDescription = null;
        });
      }
      _loadFruitDescription();
    }
  }

  Future<void> _playFruitSound() async {
    if (fruits.isNotEmpty && currentFruitIndex < fruits.length) {
      final currentFruit = fruits[currentFruitIndex]['targetName']!;
      await TextToSpeechService.speakLetter(currentFruit, targetLanguage!);
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Fruits'),
          backgroundColor: Colors.red.shade600,
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

    if (fruits.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Fruits'),
          backgroundColor: Colors.red.shade600,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No fruits data available.'),
        ),
      );
    }

    final currentFruit = fruits[currentFruitIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Fruits'),
        backgroundColor: Colors.red.shade600,
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
              value: (currentFruitIndex + 1) / fruits.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade600),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Fruit ${currentFruitIndex + 1} of ${fruits.length}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),

            // Fruit image with click-to-speak
            GestureDetector(
              onTap: _playFruitSound,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade300, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        currentFruit['image']!,
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
                          color: Colors.red.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Tap to hear',
                          style: TextStyle(
                            color: Colors.red.shade600,
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

            // Fruit names comparison
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 2,
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Learning Language',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentFruit['targetName']!,
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
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Your Language',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentFruit['knownName']!,
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
                      onPressed: currentFruitIndex > 0 ? _previousFruit : null,
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
                      onPressed: _playFruitSound,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
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
                  // Next button
                  SizedBox(
                    width: 80,
                    child: ElevatedButton(
                      onPressed: currentFruitIndex < fruits.length - 1 ? _nextFruit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
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