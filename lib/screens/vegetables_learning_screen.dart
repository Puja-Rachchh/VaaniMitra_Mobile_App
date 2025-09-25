import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/translation_service.dart';
import '../services/user_preferences.dart';
import '../services/text_to_speech_service.dart';

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
      setState(() {
        knownLanguage = known;
        targetLanguage = target;
      });
      await _loadVegetables();
    }
  }

  Future<void> _loadVegetables() async {
    setState(() {
      isLoading = true;
    });

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

    setState(() {
      vegetables = vegetablesList;
      isLoading = false;
    });

    await _loadVegetableDescription();
  }

  Future<void> _loadVegetableDescription() async {
    if (vegetables.isNotEmpty && currentVegetableIndex < vegetables.length) {
      final currentVegetable = vegetables[currentVegetableIndex];
      final description = await TranslationService.translateText(
        'This is a ${currentVegetable['englishName']}. It is a healthy and nutritious vegetable.',
        knownLanguage!,
        'en'
      );
      setState(() {
        translatedDescription = description;
      });
    }
  }

  void _nextVegetable() {
    if (currentVegetableIndex < vegetables.length - 1) {
      setState(() {
        currentVegetableIndex++;
        translatedDescription = null;
      });
      _loadVegetableDescription();
    }
  }

  void _previousVegetable() {
    if (currentVegetableIndex > 0) {
      setState(() {
        currentVegetableIndex--;
        translatedDescription = null;
      });
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