import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/translation_service.dart';
import '../services/user_preferences.dart';
import '../services/text_to_speech_service.dart';

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
      final description = await TranslationService.translateText(
        'This is your ${currentRelation['englishName']}. Family relationships are very important in our culture.',
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

  void _nextRelation() {
    if (currentRelationIndex < relations.length - 1) {
      if (mounted) {
        setState(() {
          currentRelationIndex++;
          translatedDescription = null;
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: currentRelationIndex > 0 ? _previousRelation : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE74C3C),
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: currentRelationIndex < relations.length - 1 ? _nextRelation : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE74C3C),
                    foregroundColor: Colors.white,
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