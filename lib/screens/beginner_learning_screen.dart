import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/translation_service.dart';
import '../services/user_preferences.dart';
import '../services/text_to_speech_service.dart';
import '../services/speech_recognition_service.dart';
import '../services/pronunciation_service.dart' as pron_service;
import '../widgets/quiz_widget.dart';
import '../screens/quiz_results_screen.dart';
import '../screens/letter_tracing_screen.dart';
import '../models/quiz_models.dart';

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
  
  // Speech recognition variables
  bool _speechInitialized = false;
  bool _isListening = false;
  String _recognizedText = '';
  pron_service.PronunciationResult? _pronunciationResult;
  bool _showPronunciationFeedback = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeSpeechRecognition();
  }

  @override
  void dispose() {
    // Stop any ongoing TTS when leaving the screen
    TextToSpeechService.stop();
    SpeechRecognitionService.dispose();
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

  // Navigation method for letter tracing
  void _navigateToLetterTracing() {
    if (targetLanguage == null) {
      _showErrorMessage('Target language not set');
      return;
    }

    final languageNames = TranslationService.getSupportedLanguages();
    final languageName = languageNames[targetLanguage!] ?? 'Unknown';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LetterTracingScreen(
          language: targetLanguage!,
          languageName: languageName,
        ),
      ),
    );
  }

  // Speech recognition methods
  Future<void> _initializeSpeechRecognition() async {
    try {
      debugPrint('📱 Initializing speech recognition...');
      
      // Try primary initialization method first
      debugPrint('📱 Trying primary initialization...');
      _speechInitialized = await SpeechRecognitionService.initialize();
      
      // If primary failed, try basic initialization
      if (!_speechInitialized) {
        debugPrint('📱 Primary failed, trying basic initialization...');
        _speechInitialized = await SpeechRecognitionService.initializeBasic();
      }
      
      // If still failed, try with retries
      if (!_speechInitialized) {
        debugPrint('📱 Both methods failed, trying with retries...');
        int attempts = 0;
        const maxAttempts = 3;
        
        while (attempts < maxAttempts && !_speechInitialized) {
          attempts++;
          debugPrint('📱 Retry attempt $attempts/$maxAttempts');
          
          // Alternate between both methods
          if (attempts % 2 == 1) {
            _speechInitialized = await SpeechRecognitionService.initialize();
          } else {
            _speechInitialized = await SpeechRecognitionService.initializeBasic();
          }
          
          if (!_speechInitialized && attempts < maxAttempts) {
            debugPrint('📱 Retrying in 1 second...');
            await Future.delayed(const Duration(seconds: 1));
          }
        }
      }
      
      debugPrint('📱 Final initialization result: $_speechInitialized');
      
      if (mounted) {
        setState(() {});
      }
      
      if (!_speechInitialized) {
        // Show more specific error message
        _showErrorMessage('Speech recognition initialization failed after multiple attempts.\n\nPlease check:\n• Device supports speech recognition\n• Google app is installed and updated\n• Try restarting the app');
      } else {
        debugPrint('✅ Speech recognition successfully initialized!');
      }
    } catch (e) {
      debugPrint('💥 Error initializing speech recognition: $e');
      _showErrorMessage('Error initializing speech recognition: $e');
    }
  }

  Future<void> _checkMicrophonePermission() async {
    debugPrint('📱 Checking microphone permission and capabilities...');
    
    try {
      // Perform comprehensive capability check
      final capabilities = await SpeechRecognitionService.checkDeviceCapabilities();
      
      debugPrint('📱 Device capabilities: $capabilities');
      
      final permissionGranted = capabilities['permissionGranted'] as bool;
      final speechAvailable = capabilities['speechToTextAvailable'] as bool;
      final initSuccess = capabilities['initializationSuccess'] as bool;
      final localesAvailable = capabilities['localesAvailable'] as bool;
      final errors = capabilities['errorDetails'] as List<String>;
      
      String message = 'Device Check Results:\n';
      message += '• Permission: ${permissionGranted ? "✅ Granted" : "❌ Denied"}\n';
      message += '• Initialization: ${initSuccess ? "✅ Success" : "❌ Failed"}\n';
      message += '• Service Available: ${speechAvailable ? "✅ Yes" : "❌ No"}\n';
      message += '• Locales Available: ${localesAvailable ? "✅ Yes" : "❌ No"}\n';
      
      if (errors.isNotEmpty) {
        message += '\nErrors:\n';
        for (String error in errors) {
          message += '• $error\n';
        }
      }
      
      // If everything looks good, test basic functionality
      if (permissionGranted && initSuccess && speechAvailable) {
        if (!_speechInitialized) {
          message += '\nRetrying initialization...';
          _showErrorMessage(message);
          await _initializeSpeechRecognition();
        } else {
          message += '\nTesting basic speech functionality...';
          _showErrorMessage(message);
          
          final testResult = await SpeechRecognitionService.testBasicListening();
          if (testResult) {
            message += '\n✅ Basic test successful!';
          } else {
            message += '\n❌ Basic test failed - speech service not working';
          }
          _showErrorMessage(message);
        }
      } else if (!permissionGranted) {
        message += '\nPlease grant microphone permission in settings.';
        _showErrorMessage(message);
      } else if (!speechAvailable) {
        message += '\nSpeech recognition not supported on this device.';
        _showErrorMessage(message);
      } else {
        _showErrorMessage(message);
      }
      
    } catch (e) {
      debugPrint('💥 Error in capability check: $e');
      _showErrorMessage('Error checking device capabilities: $e');
    }
  }

  Future<void> _startListening() async {
    debugPrint('📱 === BEGINNER SCREEN: START LISTENING ===');
    debugPrint('📱 speechInitialized: $_speechInitialized');
    debugPrint('📱 targetLanguage: $targetLanguage');
    debugPrint('📱 isListening: $_isListening');
    
    if (!_speechInitialized) {
      debugPrint('❌ Speech recognition not initialized');
      _showErrorMessage('Speech recognition not initialized. Please restart the app.');
      return;
    }
    
    if (targetLanguage == null) {
      debugPrint('❌ No target language selected');
      _showErrorMessage('No target language selected');
      return;
    }

    try {
      debugPrint('📱 Resetting UI state...');
      setState(() {
        _isListening = false; // Reset listening state
        _recognizedText = ''; // Clear previous results
      });

      debugPrint('📱 Calling SpeechRecognitionService.startListening...');
      final success = await SpeechRecognitionService.startListening(
        languageCode: targetLanguage!,
        onResult: (text) {
          debugPrint('📱 Speech result received in UI: "$text"');
          if (mounted) {
            setState(() {
              _recognizedText = text;
            });
          }
        },
        onListening: (isListening) {
          debugPrint('📱 Listening state changed: $isListening');
          if (mounted) {
            setState(() {
              _isListening = isListening;
            });
          }
        },
        timeout: const Duration(seconds: 10),
      );

      debugPrint('📱 StartListening result: $success');

      if (success) {
        setState(() {
          _isListening = true;
        });
        debugPrint('✅ Speech recognition started successfully in UI');
      } else {
        setState(() {
          _isListening = false;
        });
        debugPrint('❌ Failed to start speech recognition');
        _showErrorMessage('Failed to start speech recognition. Check logs for details.');
      }
    } catch (e) {
      setState(() {
        _isListening = false;
      });
      debugPrint('💥 Error in _startListening: $e');
      debugPrint('💥 Error type: ${e.runtimeType}');
      _showErrorMessage('Error starting speech recognition: $e');
    }
    debugPrint('📱 === BEGINNER SCREEN: START LISTENING COMPLETE ===');
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
    if (_recognizedText.isEmpty || currentLetterIndex >= letters.length) return;

    final expectedLetter = letters[currentLetterIndex]['letter']!;

    // Option A: transliterate expected and recognized strings to Latin before comparing.
    final expectedLatin = _transliterateToLatin(expectedLetter, targetLanguage);
    final recognizedLatin = _transliterateToLatin(_recognizedText, targetLanguage);

  final result = pron_service.PronunciationService.evaluate(expectedLatin, recognizedLatin);

    setState(() {
      _pronunciationResult = result;
      _showPronunciationFeedback = true;
    });

    // Auto-hide feedback after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showPronunciationFeedback = false;
          _recognizedText = '';
        });
      }
    });
  }

  // Basic transliteration helper for letters used in this app.
  // This maps a small set of common letters (vowels/consonants) to simple
  // Latin phonetic approximations. It's intentionally small and focused on
  // the characters present in `languageLetters` defined above. If the
  // input already contains Latin characters, it is returned normalized.
  String _transliterateToLatin(String input, String? lang) {
    final normalized = input.trim();
    // If input already contains ASCII letters/digits, return lowercased
    if (RegExp(r'^[\x00-\x7F]+$').hasMatch(normalized) &&
        RegExp(r'[A-Za-z0-9]').hasMatch(normalized)) {
      return normalized.toLowerCase();
    }

    // Per-language small maps
    final Map<String, Map<String, String>> maps = {
      'hi': {
        'अ': 'a', 'आ': 'aa', 'इ': 'i', 'ई': 'ii', 'उ': 'u', 'ऊ': 'uu', 'ए': 'e', 'ऐ': 'ai', 'ओ': 'o', 'औ': 'au',
        'क': 'ka', 'ख': 'kha', 'ग': 'ga', 'घ': 'gha', 'च': 'cha'
      },
      'mr': {
        'अ': 'a', 'आ': 'aa', 'इ': 'i', 'ई': 'ii', 'उ': 'u', 'ऊ': 'uu', 'ए': 'e', 'ऐ': 'ai', 'ओ': 'o', 'औ': 'au',
        'क': 'ka', 'ख': 'kha', 'ग': 'ga', 'घ': 'gha', 'च': 'cha'
      },
      'ta': {
        'அ': 'a', 'ஆ': 'aa', 'இ': 'i', 'ஈ': 'ii', 'உ': 'u', 'ஊ': 'uu', 'எ': 'e', 'ஏ': 'ee', 'ஐ': 'ai', 'ஒ': 'o', 'ஓ': 'oo', 'ஔ': 'au', 'க': 'ka', 'ங': 'nga', 'ச': 'cha'
      },
      'bn': {
        'অ': 'a', 'আ': 'aa', 'ই': 'i', 'ঈ': 'ii', 'উ': 'u', 'ঊ': 'uu', 'এ': 'e', 'ঐ': 'oi', 'ও': 'o', 'ঔ': 'ou', 'ক': 'ka', 'খ': 'kha', 'গ': 'ga', 'ঘ': 'gha', 'চ': 'cha'
      },
      'gu': {
        'અ': 'a', 'આ': 'aa', 'ઇ': 'i', 'ઈ': 'ii', 'ઉ': 'u', 'ઊ': 'uu', 'એ': 'e', 'ઐ': 'ai', 'ઓ': 'o', 'ઔ': 'au', 'ક': 'ka', 'ખ': 'kha', 'ગ': 'ga', 'ઘ': 'gha', 'ચ': 'cha'
      },
      'kn': {
        'ಅ': 'a', 'ಆ': 'aa', 'ಇ': 'i', 'ಈ': 'ii', 'ಉ': 'u', 'ಊ': 'uu', 'ಎ': 'e', 'ಏ': 'ee', 'ಐ': 'ai', 'ಒ': 'o', 'ಓ': 'oo', 'ಔ': 'au', 'ಕ': 'ka', 'ಖ': 'kha', 'ಗ': 'ga'
      },
      'ml': {
        'അ': 'a', 'ആ': 'aa', 'ഇ': 'i', 'ഈ': 'ii', 'ഉ': 'u', 'ഊ': 'uu', 'എ': 'e', 'ഏ': 'ee', 'ഐ': 'ai', 'ഒ': 'o', 'ഓ': 'oo', 'ഔ': 'au', 'ക': 'ka', 'ഖ': 'kha'
      },
      'te': {
        'అ': 'a', 'ఆ': 'aa', 'ఇ': 'i', 'ఈ': 'ii', 'ఉ': 'u', 'ఊ': 'uu', 'ఎ': 'e', 'ఏ': 'ee', 'ఐ': 'ai', 'ఒ': 'o', 'ఓ': 'oo', 'ఔ': 'au', 'క': 'ka', 'ఖ': 'kha'
      },
      'pa': {
        'ਅ': 'a', 'ਆ': 'aa', 'ਇ': 'i', 'ਈ': 'ii', 'ਉ': 'u', 'ਊ': 'uu', 'ਏ': 'e', 'ਐ': 'ai', 'ਓ': 'o', 'ਔ': 'au', 'ਕ': 'ka', 'ਖ': 'kha', 'ਗ': 'ga', 'ਘ': 'gha', 'ਚ': 'cha'
      },
      'or': {
        'ଅ': 'a', 'ଆ': 'aa', 'ଇ': 'i', 'ଈ': 'ii', 'ଉ': 'u', 'ଊ': 'uu', 'ଋ': 'ri', 'ଏ': 'e', 'ଐ': 'ai', 'ଓ': 'o', 'ଔ': 'au', 'କ': 'ka', 'ଖ': 'kha', 'ଗ': 'ga', 'ଘ': 'gha'
      },
      'as': {
        'অ': 'a', 'আ': 'aa', 'ই': 'i', 'ঈ': 'ii', 'উ': 'u', 'ঊ': 'uu', 'এ': 'e', 'ঐ': 'oi', 'ও': 'o', 'ঔ': 'ou', 'ক': 'ka', 'খ': 'kha', 'গ': 'ga', 'ঘ': 'gha'
      },
      'ur': {
        'ا': 'a', 'ب': 'b', 'پ': 'p', 'ت': 't', 'ٹ': 't', 'ث': 's', 'ج': 'j', 'چ': 'ch', 'ح': 'h', 'خ': 'kh', 'د': 'd', 'ڈ': 'd', 'ذ': 'z', 'ر': 'r', 'ڑ': 'r'
      },
      'sd': {
        'ا': 'a', 'ب': 'b', 'پ': 'p', 'ت': 't', 'ٿ': 'th', 'ث': 's', 'ج': 'j', 'ڄ': 'j', 'ح': 'h', 'خ': 'kh', 'د': 'd', 'ڌ': 'dh', 'ذ': 'z', 'ر': 'r', 'ڙ': 'r'
      },
      'ne': {
        'अ': 'a', 'आ': 'aa', 'इ': 'i', 'ई': 'ii', 'उ': 'u', 'ऊ': 'uu', 'ए': 'e', 'ऐ': 'ai', 'ओ': 'o', 'औ': 'au', 'क': 'ka', 'ख': 'kha', 'ग': 'ga', 'घ': 'gha'
      },
      // fallback for languages not mapped
      'default': {}
    };

    final map = maps[lang] ?? maps['default']!;

    // Try per-character mapping
    final buffer = StringBuffer();
    for (var rune in normalized.runes) {
      final ch = String.fromCharCode(rune);
      if (map.containsKey(ch)) {
        buffer.write(map[ch]);
      } else if (RegExp(r'[A-Za-z0-9]').hasMatch(ch)) {
        buffer.write(ch);
      } else {
        // If unknown, skip or attempt basic decomposition
        // Keep it simple: skip unknown characters
      }
    }

    final out = buffer.toString().toLowerCase();
    return out.isEmpty ? normalized.toLowerCase() : out;
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildPronunciationFeedback() {
    if (!_showPronunciationFeedback || _pronunciationResult == null) {
      return const SizedBox.shrink();
    }

    final result = _pronunciationResult!;
    final color = result.isCorrect ? Colors.green : Colors.orange;
    final icon = result.isCorrect ? Icons.check_circle : Icons.info;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.feedback,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          if (result.recognizedNormalized.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'You said: "${result.recognizedNormalized}"',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: result.score,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 4),
          Text(
            'Accuracy: ${(result.score * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Quiz navigation methods
  void _startQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Letters Quiz'),
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
          ),
          body: QuizWidget(
            category: 'letters',
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
          if (!_speechInitialized)
            IconButton(
              onPressed: _checkMicrophonePermission,
              icon: const Icon(Icons.settings, color: Colors.orange),
              tooltip: 'Check microphone permissions',
            ),
          if (_speechInitialized)
            IconButton(
              onPressed: _isListening ? _stopListening : _startListening,
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Colors.red : Colors.white,
              ),
              tooltip: _isListening ? 'Stop listening' : 'Start pronunciation practice',
            ),
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
            const SizedBox(height: 20),

            // Speech recognition feedback
            if (_isListening)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.mic,
                      color: Colors.red,
                      size: 30,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Listening... Say the letter',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    if (_recognizedText.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Heard: $_recognizedText',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ],
                ),
              ),

            // Pronunciation feedback
            _buildPronunciationFeedback(),
            
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
            const SizedBox(height: 30),

            // Divider
            Divider(
              thickness: 2,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),

            // Practice Writing Section
            Text(
              '✏️ Practice Writing',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 15),

            // Practice Writing Card
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: InkWell(
                onTap: _navigateToLetterTracing,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.shade400,
                        Colors.deepPurple.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.draw,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Letter Tracing',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Learn to write ${TranslationService.getSupportedLanguages()[targetLanguage] ?? "letters"} by tracing',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}