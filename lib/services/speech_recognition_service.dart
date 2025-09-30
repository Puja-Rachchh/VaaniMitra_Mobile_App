import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:string_similarity/string_similarity.dart';

/// Result class for pronunciation checking
class PronunciationResult {
  final String expectedText;
  final String? recognizedText;
  final double accuracy;
  final bool isCorrect;
  final String feedback;

  PronunciationResult({
    required this.expectedText,
    this.recognizedText,
    required this.accuracy,
    required this.isCorrect,
    required this.feedback,
  });
}

/// Comprehensive Speech Recognition Service
class SpeechRecognitionService {
  static final SpeechToText _speechToText = SpeechToText();
  static bool _isInitialized = false;
  static bool _hasPermission = false;

  /// Language mapping for Indian languages
  static const Map<String, String> _languageLocales = {
    // Full language names
    'english': 'en-US',
    'hindi': 'hi-IN',
    'gujarati': 'gu-IN',
    'bengali': 'bn-IN',
    'tamil': 'ta-IN',
    'telugu': 'te-IN',
    'marathi': 'mr-IN',
    'kannada': 'kn-IN',
    'malayalam': 'ml-IN',
    'punjabi': 'pa-IN',
    'odia': 'or-IN',
    'assamese': 'as-IN',
    'urdu': 'ur-IN',
    'sanskrit': 'sa-IN',
    'nepali': 'ne-IN',
    
    // Language codes
    'en': 'en-US',
    'hi': 'hi-IN',
    'gu': 'gu-IN',
    'bn': 'bn-IN',
    'ta': 'ta-IN',
    'te': 'te-IN',
    'mr': 'mr-IN',
    'kn': 'kn-IN',
    'ml': 'ml-IN',
    'pa': 'pa-IN',
    'or': 'or-IN',
    'as': 'as-IN',
    'ur': 'ur-IN',
    'sa': 'sa-IN',
    'ne': 'ne-IN',
  };

  /// Initialize speech recognition service
  static Future<bool> initialize() async {
    try {
      debugPrint('🎤 Starting speech recognition initialization...');
      
      // Reset initialization status
      _isInitialized = false;
      _hasPermission = false;
      
      // Request microphone permission FIRST
      debugPrint('🎤 Requesting microphone permission...');
      final permissionStatus = await Permission.microphone.request();
      debugPrint('🎤 Permission status: $permissionStatus');
      
      if (!permissionStatus.isGranted) {
        debugPrint('❌ Microphone permission denied. Status: $permissionStatus');
        
        // Check if permission is permanently denied
        if (permissionStatus.isPermanentlyDenied) {
          debugPrint('❌ Permission permanently denied. Please enable in settings.');
        }
        return false;
      }

      _hasPermission = true;
      debugPrint('✅ Microphone permission granted');

      // Wait a bit for permission to be processed
      await Future.delayed(const Duration(milliseconds: 500));

      // Try simple initialization first
      debugPrint('🎤 Attempting simple initialization...');
      try {
        _isInitialized = await _speechToText.initialize();
        debugPrint('🎤 Simple initialization result: $_isInitialized');
      } catch (e) {
        debugPrint('⚠️ Simple initialization failed: $e');
        _isInitialized = false;
      }

      // If simple initialization failed, try with callbacks
      if (!_isInitialized) {
        debugPrint('🎤 Trying initialization with callbacks...');
        try {
          _isInitialized = await _speechToText.initialize(
            onError: (error) {
              debugPrint('❌ Speech recognition error: ${error.errorMsg}');
            },
            onStatus: (status) => debugPrint('🎤 Speech recognition status: $status'),
          );
          debugPrint('🎤 Callback initialization result: $_isInitialized');
        } catch (e) {
          debugPrint('⚠️ Callback initialization failed: $e');
          _isInitialized = false;
        }
      }

      // Check if speech recognition is available after initialization
      if (_isInitialized) {
        final isAvailable = _speechToText.isAvailable;
        debugPrint('🎤 Speech recognition available: $isAvailable');
        
        if (!isAvailable) {
          debugPrint('❌ Speech recognition initialized but not available - device may not support it');
          _isInitialized = false;
          return false;
        }

        // Log available locales for debugging
        try {
          final locales = await _speechToText.locales();
          debugPrint('🌍 Available locales (${locales.length}): ${locales.take(5).map((l) => '${l.localeId}: ${l.name}').join(', ')}${locales.length > 5 ? '...' : ''}');
        } catch (e) {
          debugPrint('⚠️ Error getting locales: $e');
        }
        
        debugPrint('✅ Speech recognition fully initialized and ready!');
      } else {
        debugPrint('❌ Speech recognition initialization failed completely');
      }
      
      return _isInitialized;
    } catch (e) {
      debugPrint('💥 Error initializing speech recognition: $e');
      _isInitialized = false;
      _hasPermission = false;
      return false;
    }
  }

  /// Alternative initialization method using a more basic approach
  static Future<bool> initializeBasic() async {
    try {
      debugPrint('🔄 Trying basic speech recognition initialization...');
      
      // Reset state
      _isInitialized = false;
      
      // Check and request permission
      final permission = await Permission.microphone.status;
      if (!permission.isGranted) {
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          debugPrint('❌ Basic init: Permission denied');
          return false;
        }
      }
      
      // Try most basic initialization
      _isInitialized = await _speechToText.initialize();
      debugPrint('🔄 Basic initialization result: $_isInitialized');
      
      return _isInitialized;
    } catch (e) {
      debugPrint('💥 Basic initialization error: $e');
      return false;
    }
  }

  /// Test basic speech recognition functionality
  static Future<bool> testBasicListening() async {
    if (!_isInitialized) {
      debugPrint('❌ Not initialized for test');
      return false;
    }

    try {
      debugPrint('🧪 Testing basic listening functionality...');
      
      // Test with the most basic setup
      final success = await _speechToText.listen(
        onResult: (speechResult) {
          debugPrint('🧪 Test result: "${speechResult.recognizedWords}"');
        },
      );
      
      final actualResult = success ?? false;
      debugPrint('🧪 Basic listen test result: $success (treated as: $actualResult)');
      
      // Stop listening after a short time
      await Future.delayed(const Duration(seconds: 2));
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
      
      return actualResult;
    } catch (e) {
      debugPrint('🧪 Basic test failed: $e');
      return false;
    }
  }

  /// Check device speech recognition capabilities
  static Future<Map<String, dynamic>> checkDeviceCapabilities() async {
    final Map<String, dynamic> capabilities = {
      'permissionGranted': false,
      'speechToTextAvailable': false,
      'initializationSuccess': false,
      'localesAvailable': false,
      'errorDetails': <String>[],
    };

    try {
      debugPrint('🔍 === DEVICE CAPABILITIES CHECK ===');
      
      // Check permission
      final permission = await Permission.microphone.status;
      capabilities['permissionGranted'] = permission.isGranted;
      debugPrint('🔍 Permission granted: ${permission.isGranted}');
      
      if (!permission.isGranted) {
        capabilities['errorDetails'].add('Microphone permission not granted');
        return capabilities;
      }

      // Try to initialize a fresh instance
      final testSpeech = SpeechToText();
      
      try {
        final initResult = await testSpeech.initialize();
        capabilities['initializationSuccess'] = initResult;
        debugPrint('🔍 Initialization success: $initResult');
        
        if (initResult) {
          final isAvailable = testSpeech.isAvailable;
          capabilities['speechToTextAvailable'] = isAvailable;
          debugPrint('🔍 Service available: $isAvailable');
          
          if (isAvailable) {
            try {
              final locales = await testSpeech.locales();
              capabilities['localesAvailable'] = locales.isNotEmpty;
              capabilities['localeCount'] = locales.length;
              debugPrint('🔍 Locales available: ${locales.length}');
            } catch (e) {
              capabilities['errorDetails'].add('Error getting locales: $e');
            }
          } else {
            capabilities['errorDetails'].add('Speech recognition service not available after initialization');
          }
        } else {
          capabilities['errorDetails'].add('Speech recognition initialization returned false');
        }
      } catch (e) {
        capabilities['errorDetails'].add('Initialization exception: $e');
        debugPrint('💥 Initialization exception: $e');
      }
      
    } catch (e) {
      capabilities['errorDetails'].add('General error: $e');
      debugPrint('💥 General error in capabilities check: $e');
    }

    debugPrint('🔍 === CAPABILITIES CHECK COMPLETE ===');
    return capabilities;
  }

  /// Check if speech recognition is available
  static bool get isAvailable => _isInitialized && _speechToText.isAvailable;

  /// Check if currently listening
  static bool get isListening => _speechToText.isListening;

  /// Get available locales
  static Future<List<LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) return [];
    return await _speechToText.locales();
  }

  /// Start listening for speech
  static Future<bool> startListening({
    required String languageCode,
    required Function(String) onResult,
    Function(bool)? onListening,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    debugPrint('🎯 === STARTING SPEECH RECOGNITION ===');
    debugPrint('🎯 Language: $languageCode');
    debugPrint('🎯 Timeout: ${timeout.inSeconds}s');
    
    // Step 1: Check initialization
    debugPrint('🔍 Step 1: Checking initialization...');
    debugPrint('🔍 _isInitialized: $_isInitialized');
    if (!_isInitialized) {
      debugPrint('❌ Speech recognition not initialized');
      return false;
    }
    
    // Step 2: Check availability
    debugPrint('🔍 Step 2: Checking availability...');
    final isAvailable = _speechToText.isAvailable;
    debugPrint('🔍 isAvailable: $isAvailable');
    if (!isAvailable) {
      debugPrint('❌ Speech recognition service not available');
      return false;
    }

    // Step 3: Check current listening state
    debugPrint('🔍 Step 3: Checking current state...');
    final currentlyListening = _speechToText.isListening;
    debugPrint('🔍 Currently listening: $currentlyListening');
    if (currentlyListening) {
      debugPrint('🛑 Already listening, stopping first');
      try {
        await _speechToText.stop();
        debugPrint('✅ Stopped previous listening session');
      } catch (e) {
        debugPrint('⚠️ Error stopping previous session: $e');
      }
    }

    try {
      // Step 4: Get locale
      debugPrint('🔍 Step 4: Getting locale...');
      final locale = _getLocaleForLanguage(languageCode);
      debugPrint('🌍 Mapped locale: $locale for language: $languageCode');
      
      // Step 5: Check locale support
      debugPrint('🔍 Step 5: Checking locale support...');
      final availableLocales = await _speechToText.locales();
      debugPrint('🌍 Available locales count: ${availableLocales.length}');
      
      // Print all available locales for debugging
      for (var locale in availableLocales) {
        debugPrint('🌍 Available: ${locale.localeId} (${locale.name})');
      }
      
      var isLocaleSupported = availableLocales.any((l) => l.localeId == locale);
      debugPrint('🌍 Is locale $locale supported: $isLocaleSupported');
      
      String finalLocale = locale;
      
      if (!isLocaleSupported) {
        debugPrint('⚠️ Locale $locale not supported');
        
        // Priority fallback order for Indian languages
        final fallbackOrder = ['hi-IN', 'en-IN', 'en-US', 'en-AU', 'en-GB'];
        
        String? foundFallback;
        for (final fallback in fallbackOrder) {
          if (availableLocales.any((l) => l.localeId == fallback)) {
            foundFallback = fallback;
            break;
          }
        }
        
        if (foundFallback != null) {
          finalLocale = foundFallback;
          debugPrint('🔄 Using priority fallback: $finalLocale');
        } else {
          // Try to find any English variant
          final englishLocales = availableLocales.where((l) => l.localeId.startsWith('en')).toList();
          if (englishLocales.isNotEmpty) {
            finalLocale = englishLocales.first.localeId;
            debugPrint('🔄 Using English variant: $finalLocale');
          } else {
            // Use the first available locale as last resort
            if (availableLocales.isNotEmpty) {
              finalLocale = availableLocales.first.localeId;
              debugPrint('🔄 Using first available locale: $finalLocale');
            }
          }
        }
      }
      debugPrint('🎯 Using final locale: $finalLocale');
      
      // Step 6: Start listening
      debugPrint('🔍 Step 6: Starting to listen with locale: $finalLocale');
      
      bool actualSuccess = false;
      
      try {
        // Try with full parameters first
        debugPrint('🎤 Attempting full parameter listen...');
        final success = await _speechToText.listen(
          onResult: (result) {
            final recognizedWords = result.recognizedWords;
            final confidence = result.confidence;
            debugPrint('🎤 Speech result: "$recognizedWords" (confidence: $confidence, final: ${result.finalResult})');
            onResult(recognizedWords);
            
            if (result.finalResult) {
              debugPrint('✅ Final speech result: "$recognizedWords"');
            }
          },
          listenFor: timeout,
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          localeId: finalLocale,
          onSoundLevelChange: (level) {
            debugPrint('🔊 Sound level: $level');
            if (onListening != null) {
              onListening(level > 0);
            }
          },
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
        );
        
        actualSuccess = success ?? false;
        debugPrint('🎤 Full parameter result: $success (treated as: $actualSuccess)');
        
      } catch (e) {
        debugPrint('⚠️ Full parameter listen failed: $e');
        actualSuccess = false;
      }
      
      // If full parameter method failed, try simplified approach
      if (!actualSuccess) {
        try {
          debugPrint('🎤 Attempting simplified listen...');
          final simpleSuccess = await _speechToText.listen(
            onResult: (result) {
              debugPrint('🎤 Simple result: "${result.recognizedWords}"');
              onResult(result.recognizedWords);
            },
            localeId: finalLocale,
          );
          
          actualSuccess = simpleSuccess ?? false;
          debugPrint('� Simplified result: $simpleSuccess (treated as: $actualSuccess)');
          
        } catch (e) {
          debugPrint('⚠️ Simplified listen failed: $e');
        }
      }
      
      // If still failed, try with default locale
      if (!actualSuccess && finalLocale != 'en-US') {
        try {
          debugPrint('🎤 Attempting with en-US...');
          final enSuccess = await _speechToText.listen(
            onResult: (result) {
              debugPrint('🎤 EN result: "${result.recognizedWords}"');
              onResult(result.recognizedWords);
            },
            localeId: 'en-US',
          );
          
          actualSuccess = enSuccess ?? false;
          debugPrint('🎤 EN-US result: $enSuccess (treated as: $actualSuccess)');
          
        } catch (e) {
          debugPrint('⚠️ EN-US listen failed: $e');
        }
      }
      
      debugPrint('🎯 Final speech listening result: $actualSuccess');
      debugPrint('🎯 === SPEECH RECOGNITION START COMPLETE ===');
      return actualSuccess;
    } catch (e) {
      debugPrint('💥 Error starting speech recognition: $e');
      debugPrint('💥 Error type: ${e.runtimeType}');
      return false;
    }
  }

  /// Stop listening
  static Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  /// Cancel listening
  static Future<void> cancelListening() async {
    if (_speechToText.isListening) {
      await _speechToText.cancel();
    }
  }

  /// Check pronunciation accuracy
  static PronunciationResult checkPronunciation({
    required String expectedText,
    required String recognizedText,
    double threshold = 0.7,
  }) {
    if (recognizedText.isEmpty) {
      return PronunciationResult(
        expectedText: expectedText,
        recognizedText: recognizedText,
        accuracy: 0.0,
        isCorrect: false,
        feedback: 'No speech detected. Please try again.',
      );
    }

    // Clean and normalize text for comparison
    final cleanExpected = _cleanText(expectedText);
    final cleanRecognized = _cleanText(recognizedText);

    // Calculate similarity using multiple algorithms
    final jaccardSimilarity = cleanExpected.similarityTo(cleanRecognized);
    final levenshteinSimilarity = _calculateLevenshteinSimilarity(cleanExpected, cleanRecognized);
    
    // Weighted average of different similarity measures
    final accuracy = (jaccardSimilarity * 0.6 + levenshteinSimilarity * 0.4);
    final isCorrect = accuracy >= threshold;

    String feedback;
    if (accuracy >= 0.9) {
      feedback = 'Excellent pronunciation! 🎉';
    } else if (accuracy >= 0.8) {
      feedback = 'Very good pronunciation! 👍';
    } else if (accuracy >= 0.7) {
      feedback = 'Good attempt! Keep practicing! 😊';
    } else if (accuracy >= 0.5) {
      feedback = 'Getting there! Try again! 💪';
    } else {
      feedback = 'Keep practicing! You can do it! 🌟';
    }

    return PronunciationResult(
      expectedText: expectedText,
      recognizedText: recognizedText,
      accuracy: accuracy,
      isCorrect: isCorrect,
      feedback: feedback,
    );
  }

  /// Get locale for language
  static String _getLocaleForLanguage(String languageCode) {
    return _languageLocales[languageCode.toLowerCase()] ?? 'en-US';
  }

  /// Clean text for comparison
  static String _cleanText(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' '); // Normalize whitespace
  }

  /// Calculate Levenshtein similarity
  static double _calculateLevenshteinSimilarity(String a, String b) {
    if (a.isEmpty && b.isEmpty) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;

    final distance = _levenshteinDistance(a, b);
    final maxLength = a.length > b.length ? a.length : b.length;
    return 1.0 - (distance / maxLength);
  }

  /// Calculate Levenshtein distance
  static int _levenshteinDistance(String a, String b) {
    final aLength = a.length;
    final bLength = b.length;
    
    if (aLength == 0) return bLength;
    if (bLength == 0) return aLength;

    final matrix = List.generate(
      aLength + 1,
      (i) => List.generate(bLength + 1, (j) => 0),
    );

    for (int i = 0; i <= aLength; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= bLength; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= aLength; i++) {
      for (int j = 1; j <= bLength; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[aLength][bLength];
  }

  /// Get supported languages
  static List<String> getSupportedLanguages() {
    return _languageLocales.keys.toList();
  }

  /// Check if language is supported
  static bool isLanguageSupported(String languageCode) {
    return _languageLocales.containsKey(languageCode.toLowerCase());
  }

  /// Dispose resources
  static void dispose() {
    // Clean up resources if needed
    debugPrint('Speech recognition service disposed');
  }
}