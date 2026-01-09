// ignore_for_file: deprecated_member_use
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:string_similarity/string_similarity.dart';

/// Result class for pronunciation checking used by SpeechRecognitionService
class SpeechPronunciationResult {
  final String expectedText;
  final String? recognizedText;
  final double accuracy;
  final bool isCorrect;
  final String feedback;

  SpeechPronunciationResult({
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
  // Note: permission state is checked on demand; removed unused field to
  // satisfy analyzer.

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
      
      // Request microphone permission FIRST
      debugPrint('🎤 Requesting microphone permission...');
      var permissionStatus = await Permission.microphone.status;
      debugPrint('🎤 Initial permission status: $permissionStatus');
      
      if (!permissionStatus.isGranted) {
        debugPrint('🎤 Permission not granted, requesting...');
        permissionStatus = await Permission.microphone.request();
        debugPrint('🎤 Permission after request: $permissionStatus');
      }
      
      if (!permissionStatus.isGranted) {
        debugPrint('❌ Microphone permission denied. Status: $permissionStatus');
        
        if (permissionStatus.isPermanentlyDenied) {
          debugPrint('❌ Permission permanently denied. User must enable in settings.');
          debugPrint('💡 Go to: Settings > Apps > VaaniMitra > Permissions > Microphone');
        } else if (permissionStatus.isDenied) {
          debugPrint('❌ Permission denied this time. User can try again.');
        }
        return false;
      }

      debugPrint('✅ Microphone permission granted');

      // Wait for permission to be processed
      await Future.delayed(const Duration(milliseconds: 1000));

      // Try initialization
      debugPrint('🎤 Attempting speech recognition initialization...');
      try {
        _isInitialized = await _speechToText.initialize(
          onError: (error) => debugPrint('❌ Speech error: ${error.errorMsg}'),
          onStatus: (status) => debugPrint('🎤 Status: $status'),
        );
        debugPrint('🎤 Initialization result: $_isInitialized');
      } catch (e) {
        debugPrint('⚠️ Initialization failed: $e');
        _isInitialized = false;
      }

      if (_isInitialized) {
        final isAvailable = _speechToText.isAvailable;
        debugPrint('🎤 Speech recognition available: $isAvailable');
        
        if (!isAvailable) {
          debugPrint('❌ Speech service initialized but not available');
          debugPrint('💡 Possible causes:');
          debugPrint('   - Device does not support speech recognition');
          debugPrint('   - Google services not installed');
          debugPrint('   - Internet connection required');
          _isInitialized = false;
          return false;
        }

        // Log available locales
        try {
          final locales = await _speechToText.locales();
          debugPrint('🌍 Available locales (${locales.length}): ${locales.take(3).map((l) => l.localeId).join(', ')}...');
        } catch (e) {
          debugPrint('⚠️ Error getting locales: $e');
        }
        
        debugPrint('✅ Speech recognition fully initialized and ready!');
      } else {
        debugPrint('❌ Speech recognition initialization failed');
        debugPrint('💡 Troubleshooting steps:');
        debugPrint('   1. Check if Google app is installed and updated');
        debugPrint('   2. Ensure internet connection is active');
        debugPrint('   3. Try restarting the app');
        debugPrint('   4. Check device supports speech recognition');
      }
      
      return _isInitialized;
    } catch (e) {
      debugPrint('💥 Error initializing speech recognition: $e');
      debugPrint('💥 Error type: ${e.runtimeType}');
      _isInitialized = false;
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
    Function(String)? onError,
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
      // Ensure microphone permission is granted before starting
      final perm = await Permission.microphone.status;
      if (!perm.isGranted) {
        debugPrint('🎤 startListening: Microphone permission not granted, requesting...');
        final res = await Permission.microphone.request();
        if (!res.isGranted) {
          debugPrint('❌ startListening: Microphone permission denied by user');
          return false;
        }
        debugPrint('✅ startListening: Microphone permission granted after request');
      }
      // Step 4: Get locale
      debugPrint('🔍 Step 4: Getting locale...');
      final locale = _getLocaleForLanguage(languageCode);
      debugPrint('🌍 Mapped locale: $locale for language: $languageCode');
      
      // Step 5: Check locale support
      debugPrint('🔍 Step 5: Checking locale support...');
      final availableLocales = await _speechToText.locales();
      debugPrint('🌍 Available locales count: ${availableLocales.length}');
      
      // Print all available locales for debugging
      for (var loc in availableLocales) {
        debugPrint('🌍 Available: ${loc.localeId} (${loc.name})');
      }
      
      // Find the actual locale format used by the device
      // Device may use "hi_IN" (underscore) while we use "hi-IN" (hyphen)
      final matchingLocale = availableLocales.where((l) => 
        l.localeId == locale || 
        l.localeId.replaceAll('_', '-') == locale ||
        l.localeId == locale.replaceAll('-', '_')
      ).firstOrNull;
      
      bool isLocaleSupported = matchingLocale != null;
      String actualLocale = matchingLocale?.localeId ?? locale;
      
      if (matchingLocale != null && matchingLocale.localeId != locale) {
        debugPrint('🔄 Found locale with different format: ${matchingLocale.localeId} (requested: $locale)');
      }
      
      debugPrint('🌍 Is locale $locale supported: $isLocaleSupported (using: $actualLocale)');
      
      String finalLocale = actualLocale;
      String? unsupportedMessage;
      
      if (!isLocaleSupported) {
        debugPrint('⚠️ Locale $locale not supported');
        unsupportedMessage = 'Your device does not support $languageCode speech recognition.';
        
        // Check if Hindi is available as a fallback for Indian languages
        final hindiLocale = availableLocales.where((l) => 
          l.localeId == 'hi-IN' || l.localeId == 'hi_IN'
        ).firstOrNull;
        
        if (hindiLocale != null && languageCode != 'hi' && languageCode != 'en') {
          unsupportedMessage += ' Using Hindi instead.';
          finalLocale = hindiLocale.localeId;
          debugPrint('🔄 Using Hindi (${hindiLocale.localeId}) as fallback for $languageCode');
        } else {
          // Priority fallback order
          final fallbackOrder = ['hi-IN', 'hi_IN', 'en-IN', 'en_IN', 'en-US', 'en_US', 'en-AU', 'en_AU', 'en-GB', 'en_GB'];
        
          String? foundFallback;
          for (final fallback in fallbackOrder) {
            final matchingLocale = availableLocales.where((l) => 
              l.localeId == fallback || 
              l.localeId.replaceAll('_', '-') == fallback ||
              l.localeId == fallback.replaceAll('-', '_')
            ).firstOrNull;
            
            if (matchingLocale != null) {
              foundFallback = matchingLocale.localeId;
              break;
            }
          }
          
          if (foundFallback != null) {
            finalLocale = foundFallback;
            unsupportedMessage += ' Using ${_getLanguageName(foundFallback)} instead.';
            debugPrint('🔄 Using priority fallback: $finalLocale');
          } else {
            // Try to find any English variant
            final englishLocales = availableLocales.where((l) => l.localeId.startsWith('en')).toList();
            if (englishLocales.isNotEmpty) {
              finalLocale = englishLocales.first.localeId;
              unsupportedMessage += ' Using English instead.';
              debugPrint('🔄 Using English variant: $finalLocale');
            } else {
              // Use the first available locale as last resort
              if (availableLocales.isNotEmpty) {
                finalLocale = availableLocales.first.localeId;
                unsupportedMessage += ' Using available language instead.';
                debugPrint('🔄 Using first available locale: $finalLocale');
              } else {
                onError?.call('No speech recognition languages available on this device.');
                return false;
              }
            }
          }
        }
      }
      
      // Notify user if locale was changed
      if (unsupportedMessage != null && onError != null) {
        onError(unsupportedMessage);
      }
      debugPrint('🎯 Using final locale: $finalLocale');
      
      // Step 6: Start listening
      debugPrint('🔍 Step 6: Starting to listen with locale: $finalLocale');
      
      bool actualSuccess = false;
      int maxRetries = 1;  // Reduced retries since we have better error handling
      
      for (int attempt = 1; attempt <= maxRetries && !actualSuccess; attempt++) {
        try {
          if (attempt > 1) {
            debugPrint('🔁 Retry attempt $attempt/$maxRetries...');
            await Future.delayed(const Duration(milliseconds: 500));
          }
          
          // Try with full parameters first
          debugPrint('🎤 Attempting full parameter listen...');
          // The speech_to_text package has deprecated some named params in
          // older versions; keep the current call but ignore deprecation
          // analyzer hints here until the package can be upgraded and the
          // newer SpeechListenOptions-based API used.
          bool _lastNotifiedListeningState = true;  // Track last notified state to prevent flickering
          
          // Listen for status changes
          _speechToText.statusListener = (status) {
            debugPrint('🎤 Status: $status');
            if (onListening != null) {
              // Only update on meaningful status changes
              if (status == 'done' || status == 'notListening') {
                if (_lastNotifiedListeningState) {
                  _lastNotifiedListeningState = false;
                  onListening(false);
                }
              } else if (status == 'listening') {
                if (!_lastNotifiedListeningState) {
                  _lastNotifiedListeningState = true;
                  onListening(true);
                }
              }
            }
          };
          
          final success = await _speechToText.listen(
            onResult: (result) {
              final recognizedWords = result.recognizedWords;
              final confidence = result.confidence;
              debugPrint('🎤 Speech result: "$recognizedWords" (confidence: $confidence, final: ${result.finalResult})');
              onResult(recognizedWords);

              if (result.finalResult) {
                debugPrint('✅ Final speech result: "$recognizedWords"');
                // Notify that listening stopped when final result is received
                if (onListening != null && _lastNotifiedListeningState) {
                  _lastNotifiedListeningState = false;
                  onListening(false);
                }
              }
            },
            listenFor: timeout,
            pauseFor: const Duration(seconds: 3),
            partialResults: true,
            localeId: finalLocale,
            onSoundLevelChange: (level) {
              // Don't use sound level for listening state - causes flickering
            },
            cancelOnError: false,  // Don't cancel on error_no_match
            listenMode: ListenMode.confirmation,
          );
          
          actualSuccess = success ?? false;
          debugPrint('🎤 Listen call result: $success (treated as: $actualSuccess)');
          
          // Verify listening actually started - trust the isListening state more than return value
          await Future.delayed(const Duration(milliseconds: 300));
          final isActuallyListening = _speechToText.isListening;
          debugPrint('🎤 Verification check - isListening: $isActuallyListening');
          
          // IMPORTANT: If speech recognition is actually listening, consider it successful
          // even if listen() returned null/false (known issue with speech_to_text package)
          if (isActuallyListening) {
            debugPrint('✅ Speech recognition is actively listening - success!');
            actualSuccess = true;
          } else if (actualSuccess) {
            debugPrint('⚠️ Listen returned true but not actually listening!');
            actualSuccess = false;
          }
        } catch (e) {
          debugPrint('⚠️ Listen attempt $attempt failed: $e');
          actualSuccess = false;
          
          if (attempt < maxRetries) {
            debugPrint('🔄 Will retry after delay...');
          }
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
  static SpeechPronunciationResult checkPronunciation({
    required String expectedText,
    required String recognizedText,
    double threshold = 0.7,
  }) {
    if (recognizedText.isEmpty) {
      return SpeechPronunciationResult(
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

    return SpeechPronunciationResult(
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

  /// Get friendly language name from locale code
  static String _getLanguageName(String localeId) {
    // Normalize to hyphen format for lookup
    final normalizedId = localeId.replaceAll('_', '-');
    
    const Map<String, String> localeNames = {
      'hi-IN': 'Hindi',
      'en-IN': 'English (India)',
      'en-US': 'English (US)',
      'en-AU': 'English (Australia)',
      'en-GB': 'English (UK)',
      'gu-IN': 'Gujarati',
      'bn-IN': 'Bengali',
      'ta-IN': 'Tamil',
      'te-IN': 'Telugu',
      'mr-IN': 'Marathi',
      'kn-IN': 'Kannada',
      'ml-IN': 'Malayalam',
      'pa-IN': 'Punjabi',
    };
    return localeNames[normalizedId] ?? localeId;
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