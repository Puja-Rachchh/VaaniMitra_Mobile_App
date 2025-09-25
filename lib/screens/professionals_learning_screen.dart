import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/translation_service.dart';
import '../services/user_preferences.dart';
import '../services/text_to_speech_service.dart';

class ProfessionalsLearningScreen extends StatefulWidget {
  const ProfessionalsLearningScreen({super.key});

  @override
  State<ProfessionalsLearningScreen> createState() => _ProfessionalsLearningScreenState();
}

class _ProfessionalsLearningScreenState extends State<ProfessionalsLearningScreen> {
  String? knownLanguage;
  String? targetLanguage;
  int currentProfessionalIndex = 0;
  List<Map<String, String>> professionals = [];
  bool isLoading = true;
  String? translatedDescription;

  // Professionals data with images and English names
  final List<Map<String, String>> professionalsData = [
    {'name': 'Banker', 'image': 'assets/professionals/banker.jpg'},
    {'name': 'Chef', 'image': 'assets/professionals/chef.jpg'},
    {'name': 'Doctor', 'image': 'assets/professionals/doctor.jpg'},
    {'name': 'Driver', 'image': 'assets/professionals/driver.jpeg'},
    {'name': 'Engineer', 'image': 'assets/professionals/engineer.jpg'},
    {'name': 'Farmer', 'image': 'assets/professionals/farmer.jpg'},
    {'name': 'Lawyer', 'image': 'assets/professionals/lawyer.jpeg'},
    {'name': 'Nurse', 'image': 'assets/professionals/nurse.jpg'},
    {'name': 'Policeman', 'image': 'assets/professionals/police.jpg'},
    {'name': 'Teacher', 'image': 'assets/professionals/teacher.jpg'},
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
      await _loadProfessionals();
    }
  }

  Future<void> _loadProfessionals() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    List<Map<String, String>> professionalsList = [];
    for (var professional in professionalsData) {
      debugPrint('Loading professional: ${professional['name']} with image: ${professional['image']}');
      
      // Translate the professional name to target language
      final targetName = await TranslationService.translateText(
        professional['name']!, targetLanguage!, 'en'
      );
      
      // Translate the professional name to known language
      final knownName = await TranslationService.translateText(
        professional['name']!, knownLanguage!, 'en'
      );
      
      professionalsList.add({
        'englishName': professional['name']!,
        'targetName': targetName,
        'knownName': knownName,
        'image': professional['image']!,
      });
    }

    if (mounted) {
      setState(() {
        professionals = professionalsList;
        isLoading = false;
      });
    }

    await _loadProfessionalDescription();
  }

  Future<void> _loadProfessionalDescription() async {
    if (professionals.isNotEmpty && currentProfessionalIndex < professionals.length) {
      final currentProfessional = professionals[currentProfessionalIndex];
      final description = await TranslationService.translateText(
        'This is a ${currentProfessional['englishName']}. They work in different fields to serve the community.',
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

  void _nextProfessional() {
    if (currentProfessionalIndex < professionals.length - 1) {
      if (mounted) {
        setState(() {
          currentProfessionalIndex++;
          translatedDescription = null;
        });
      }
      _loadProfessionalDescription();
    }
  }

  void _previousProfessional() {
    if (currentProfessionalIndex > 0) {
      if (mounted) {
        setState(() {
          currentProfessionalIndex--;
          translatedDescription = null;
        });
      }
      _loadProfessionalDescription();
    }
  }

  Future<void> _playProfessionalSound() async {
    if (professionals.isNotEmpty && currentProfessionalIndex < professionals.length) {
      final currentProfessional = professionals[currentProfessionalIndex]['targetName']!;
      await TextToSpeechService.speakLetter(currentProfessional, targetLanguage!);
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
          title: const Text('Learning Professionals'),
          backgroundColor: const Color(0xFF3498DB),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (professionals.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Professionals'),
          backgroundColor: const Color(0xFF3498DB),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No professionals data available'),
        ),
      );
    }

    final currentProfessional = professionals[currentProfessionalIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Professionals'),
        backgroundColor: const Color(0xFF3498DB),
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
            onPressed: _playProfessionalSound,
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
              value: (currentProfessionalIndex + 1) / professionals.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Professional ${currentProfessionalIndex + 1} of ${professionals.length}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),
            
            // Professional image and name cards
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
                        currentProfessional['image']!,
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading image: ${currentProfessional['image']!}');
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
                                  currentProfessional['image']!,
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
                              currentProfessional['knownName']!, knownLanguage!),
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
                                      currentProfessional['knownName']!,
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
                              currentProfessional['targetName']!, targetLanguage!),
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
                                      currentProfessional['targetName']!,
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
                  onPressed: currentProfessionalIndex > 0 ? _previousProfessional : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: currentProfessionalIndex < professionals.length - 1 ? _nextProfessional : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
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