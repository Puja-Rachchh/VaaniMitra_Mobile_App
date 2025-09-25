import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/translation_service.dart';
import '../services/user_preferences.dart';
import '../services/text_to_speech_service.dart';

class BeginnerLearningScreen extends StatefulWidget {
  const BeginnerLearningScreen({super.key});

  @override
  State<BeginnerLearningScreen> createState() => _BeginnerLearningScreenState();
}

class _BeginnerLearningScreenState extends State<BeginnerLearningScreen> {
  String? knownLanguage;
  String? targetLanguage;
  int currentLetterIndex = 0;
  List<Map<String, String>> letters = [];
  bool isLoading = true;
  String? translatedExplanation;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    // Stop any ongoing TTS when leaving the screen
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
      await _loadLetters();
    }
  }

  Future<void> _loadLetters() async {
    setState(() {
      isLoading = true;
    });

    // Basic letters for different languages
    Map<String, List<String>> languageLetters = {
      'en': ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O'],
      'hi': ['अ', 'आ', 'इ', 'ई', 'उ', 'ऊ', 'ए', 'ऐ', 'ओ', 'औ', 'क', 'ख', 'ग', 'घ', 'च'],
      'ta': ['அ', 'ஆ', 'இ', 'ஈ', 'உ', 'ஊ', 'எ', 'ஏ', 'ஐ', 'ஒ', 'ஓ', 'ஔ', 'க', 'ங', 'ச'],
      'bn': ['অ', 'আ', 'ই', 'ঈ', 'উ', 'ঊ', 'ঋ', 'এ', 'ঐ', 'ও', 'ঔ', 'ক', 'খ', 'গ', 'ঘ'],
      'mr': ['अ', 'आ', 'इ', 'ई', 'उ', 'ऊ', 'ए', 'ऐ', 'ओ', 'औ', 'क', 'ख', 'ग', 'घ', 'च'],
      'gu': ['અ', 'આ', 'ઇ', 'ઈ', 'ઉ', 'ઊ', 'એ', 'ઐ', 'ઓ', 'ઔ', 'ક', 'ખ', 'ગ', 'ઘ', 'ચ'],
      'kn': ['ಅ', 'ಆ', 'ಇ', 'ಈ', 'ಉ', 'ಊ', 'ಎ', 'ಏ', 'ಐ', 'ಒ', 'ಓ', 'ಔ', 'ಕ', 'ಖ', 'ಗ'],
      'ml': ['അ', 'ആ', 'ഇ', 'ഈ', 'ഉ', 'ഊ', 'ഋ', 'എ', 'ഏ', 'ഐ', 'ഒ', 'ഓ', 'ഔ', 'ക', 'ഖ'],
      'te': ['అ', 'ఆ', 'ఇ', 'ఈ', 'ఉ', 'ఊ', 'ఋ', 'ఎ', 'ఏ', 'ఐ', 'ఒ', 'ఓ', 'ఔ', 'క', 'ఖ'],
      'pa': ['ਅ', 'ਆ', 'ਇ', 'ਈ', 'ਉ', 'ਊ', 'ਏ', 'ਐ', 'ਓ', 'ਔ', 'ਕ', 'ਖ', 'ਗ', 'ਘ', 'ਚ'],
      'or': ['ଅ', 'ଆ', 'ଇ', 'ଈ', 'ଉ', 'ଊ', 'ଋ', 'ଏ', 'ଐ', 'ଓ', 'ଔ', 'କ', 'ଖ', 'ଗ', 'ଘ'],
      'as': ['অ', 'আ', 'ই', 'ঈ', 'উ', 'ঊ', 'ঋ', 'এ', 'ঐ', 'ও', 'ঔ', 'ক', 'খ', 'গ', 'ঘ'],
      'ur': ['ا', 'ب', 'پ', 'ت', 'ٹ', 'ث', 'ج', 'چ', 'ح', 'خ', 'د', 'ڈ', 'ذ', 'ر', 'ڑ'],
      'sd': ['ا', 'ب', 'پ', 'ت', 'ٿ', 'ث', 'ج', 'ڄ', 'ح', 'خ', 'د', 'ڌ', 'ذ', 'ر', 'ڙ'],
      'ne': ['अ', 'आ', 'इ', 'ई', 'उ', 'ऊ', 'ए', 'ऐ', 'ओ', 'औ', 'क', 'ख', 'ग', 'घ', 'च'],
    };

    final targetLetters = languageLetters[targetLanguage] ?? languageLetters['en']!;
    final knownLanguageLetters = languageLetters[knownLanguage] ?? languageLetters['en']!;
    
    List<Map<String, String>> letterData = [];
    for (int i = 0; i < targetLetters.length; i++) {
      String targetLetter = targetLetters[i];
      String knownLetter = i < knownLanguageLetters.length ? knownLanguageLetters[i] : knownLanguageLetters[0];
      
      // If both languages are the same, show a translation attempt
      if (targetLetter == knownLetter && targetLanguage != knownLanguage) {
        // Try to get translation via API
        final translated = await TranslationService.translateText(
          targetLetter, knownLanguage!, targetLanguage!
        );
        knownLetter = translated;
      }
      
      letterData.add({
        'letter': targetLetter,
        'knownLetter': knownLetter,
        'translation': 'Letter $targetLetter corresponds to $knownLetter',
      });
    }

    setState(() {
      letters = letterData;
      isLoading = false;
    });

    // Load explanation for current letter
    await _loadLetterExplanation();
  }

  Future<void> _loadLetterExplanation() async {
    if (letters.isNotEmpty && currentLetterIndex < letters.length) {
      final currentLetter = letters[currentLetterIndex]['letter']!;
      final explanation = await TranslationService.translateText(
        'This is the letter "$currentLetter". It is used in writing and has its own sound.',
        knownLanguage!,
        targetLanguage!
      );
      setState(() {
        translatedExplanation = explanation;
      });
    }
  }

  void _nextLetter() {
    if (currentLetterIndex < letters.length - 1) {
      setState(() {
        currentLetterIndex++;
        translatedExplanation = null;
      });
      _loadLetterExplanation();
    }
  }

  void _previousLetter() {
    if (currentLetterIndex > 0) {
      setState(() {
        currentLetterIndex--;
        translatedExplanation = null;
      });
      _loadLetterExplanation();
    }
  }

  Future<void> _playLetterSound() async {
    if (letters.isNotEmpty && currentLetterIndex < letters.length) {
      final currentLetter = letters[currentLetterIndex]['letter']!;
      await TextToSpeechService.speakLetter(currentLetter, targetLanguage!);
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
          title: const Text('Learning Letters'),
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed('/level-selection');
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

    if (letters.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Learning Letters'),
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          leading: IconButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed('/level-selection');
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
          child: Text('No letters available for this language.'),
        ),
      );
    }

    final currentLetter = letters[currentLetterIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Letters'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/level-selection');
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
              value: (currentLetterIndex + 1) / letters.length,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Letter ${currentLetterIndex + 1} of ${letters.length}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 30),

            // Letter display with click-to-speak
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Target language letter (learning)
                Expanded(
                  child: GestureDetector(
                    onTap: _playLetterSound,
                    child: Container(
                      height: 200,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade300, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Learning',
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            currentLetter['letter']!,
                            style: _getLanguageTextStyle(targetLanguage, 60),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.volume_up,
                                color: Colors.blue.shade600,
                                size: 18,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Tap to hear',
                                style: TextStyle(
                                  color: Colors.blue.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Known language letter (comparison)
                Expanded(
                  child: Container(
                    height: 200,
                    margin: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade300, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Your Language',
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currentLetter['knownLetter'] ?? currentLetter['letter']!,
                          style: _getLanguageTextStyle(knownLanguage, 60),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Similar sound',
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Letter Comparison
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Letter Comparison:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Target Letter:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentLetter['letter']!,
                                style: _getLanguageTextStyle(targetLanguage, 30),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey.shade300,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Your Language:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentLetter['knownLetter'] ?? currentLetter['letter']!,
                                style: _getLanguageTextStyle(knownLanguage, 30),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Explanation
            if (translatedExplanation != null)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explanation:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        translatedExplanation!,
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
                      onPressed: currentLetterIndex > 0 ? _previousLetter : null,
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
                      onPressed: _playLetterSound,
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
                      onPressed: currentLetterIndex < letters.length - 1 ? _nextLetter : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
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