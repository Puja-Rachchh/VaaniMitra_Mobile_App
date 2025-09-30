import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/translation_service.dart';
import '../services/user_preferences.dart';
import '../services/text_to_speech_service.dart';
import '../widgets/quiz_widget.dart';
import '../screens/quiz_results_screen.dart';
import '../models/quiz_models.dart';

class PlacesLearningScreen extends StatefulWidget {
  const PlacesLearningScreen({super.key});

  @override
  State<PlacesLearningScreen> createState() => _PlacesLearningScreenState();
}

class _PlacesLearningScreenState extends State<PlacesLearningScreen> {
  String? knownLanguage;
  String? targetLanguage;
  int currentPlaceIndex = 0;
  List<Map<String, String>> places = [];
  bool isLoading = true;
  String? translatedDescription;

  // Places data with images and English names
  final List<Map<String, String>> placesData = [
    {'name': 'Home', 'image': 'assets/places/home.jpeg'},
    {'name': 'Hospital', 'image': 'assets/places/hospital.jpg'},
    {'name': 'Market', 'image': 'assets/places/market.jpg'},
    {'name': 'Park', 'image': 'assets/places/park.jpg'},
    {'name': 'Police', 'image': 'assets/places/police.jpg'},
    {'name': 'Restaurant', 'image': 'assets/places/restaurant.jpg'},
    {'name': 'School', 'image': 'assets/places/school.jpg'},
    {'name': 'Temple', 'image': 'assets/places/temple.jpg'},
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
      await _loadPlaces();
    }
  }

  Future<void> _loadPlaces() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    List<Map<String, String>> placesList = [];
    for (var place in placesData) {
      // Translate the place name to target language
      final targetName = await TranslationService.translateText(
        place['name']!, targetLanguage!, 'en'
      );
      
      // Translate the place name to known language
      final knownName = await TranslationService.translateText(
        place['name']!, knownLanguage!, 'en'
      );
      
      placesList.add({
        'englishName': place['name']!,
        'targetName': targetName,
        'knownName': knownName,
        'image': place['image']!,
      });
    }

    if (mounted) {
      setState(() {
        places = placesList;
        isLoading = false;
      });
    }

    await _loadPlaceDescription();
  }

  Future<void> _loadPlaceDescription() async {
    if (places.isNotEmpty && currentPlaceIndex < places.length) {
      final currentPlace = places[currentPlaceIndex];
      final description = 'This is a ${currentPlace['englishName']}. It is an important place in our community.';
      if (mounted) {
        setState(() {
          translatedDescription = description;
        });
      }
    }
  }

  void _nextPlace() {
    if (currentPlaceIndex < places.length - 1) {
      if (mounted) {
        setState(() {
          currentPlaceIndex++;
          translatedDescription = null;
        });
      }
      _loadPlaceDescription();
    }
  }

  void _previousPlace() {
    if (currentPlaceIndex > 0) {
      if (mounted) {
        setState(() {
          currentPlaceIndex--;
          translatedDescription = null;
        });
      }
      _loadPlaceDescription();
    }
  }

  Future<void> _playPlaceSound() async {
    if (places.isNotEmpty && currentPlaceIndex < places.length) {
      final currentPlace = places[currentPlaceIndex]['targetName']!;
      await TextToSpeechService.speakLetter(currentPlace, targetLanguage!);
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

  // Quiz navigation methods
  void _startQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Places Quiz'),
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
          ),
          body: QuizWidget(
            category: 'places',
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
          title: const Text('Learning Places'),
          backgroundColor: const Color(0xFF9B59B6),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (places.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Places'),
          backgroundColor: const Color(0xFF9B59B6),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No places data available'),
        ),
      );
    }

    final currentPlace = places[currentPlaceIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Places'),
        backgroundColor: const Color(0xFF9B59B6),
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
            onPressed: _playPlaceSound,
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
              value: (currentPlaceIndex + 1) / places.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9B59B6)),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Place ${currentPlaceIndex + 1} of ${places.length}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),
            
            // Place image and name cards
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
                        currentPlace['image']!,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading image: ${currentPlace['image']!}');
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
                    const SizedBox(height: 30),
                    
                    // Language cards
                    Row(
                      children: [
                        // Known Language Card
                        Expanded(
                          child: GestureDetector(
                            onTap: () => TextToSpeechService.speakLetter(
                              currentPlace['knownName']!, knownLanguage!),
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
                                      currentPlace['knownName']!,
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
                              currentPlace['targetName']!, targetLanguage!),
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
                                      currentPlace['targetName']!,
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
                    onPressed: currentPlaceIndex > 0 ? _previousPlace : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B59B6),
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
                    onPressed: currentPlaceIndex < places.length - 1 ? _nextPlace : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B59B6),
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