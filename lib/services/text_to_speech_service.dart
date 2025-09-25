import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TextToSpeechService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure TTS settings
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(0.5); // Slower rate for better learning
      await _flutterTts.setPitch(1.0);

      // Set completion handlers
      _flutterTts.setCompletionHandler(() {
        if (kDebugMode) {
          print('TTS: Speech completed');
        }
      });

      _flutterTts.setErrorHandler((message) {
        if (kDebugMode) {
          print('TTS Error: $message');
        }
      });

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('TTS Initialization Error: $e');
      }
    }
  }

  static String _getLanguageCode(String languageCode) {
    // Map our language codes to TTS language codes
    const languageMapping = {
      'hi': 'hi-IN', // Hindi (India)
      'en': 'en-US', // English (US)
      'ta': 'ta-IN', // Tamil (India)
      'te': 'te-IN', // Telugu (India)
      'mr': 'mr-IN', // Marathi (India)
      'bn': 'bn-IN', // Bengali (India)
      'gu': 'gu-IN', // Gujarati (India)
      'kn': 'kn-IN', // Kannada (India)
      'ml': 'ml-IN', // Malayalam (India)
      'pa': 'pa-IN', // Punjabi (India)
      'or': 'or-IN', // Odia (India)
      'as': 'as-IN', // Assamese (India)
      'ur': 'ur-PK', // Urdu (Pakistan)
      'sa': 'hi-IN', // Sanskrit (use Hindi voice as fallback)
    };

    return languageMapping[languageCode] ?? 'en-US';
  }

  static Future<bool> isLanguageSupported(String languageCode) async {
    try {
      await initialize();
      final languages = await _flutterTts.getLanguages;
      final ttsLanguageCode = _getLanguageCode(languageCode);
      
      if (languages != null) {
        return languages.contains(ttsLanguageCode);
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking language support: $e');
      }
      return false;
    }
  }

  static Future<void> speakLetter(String letter, String languageCode) async {
    try {
      await initialize();
      
      final ttsLanguageCode = _getLanguageCode(languageCode);
      
      // Set language for TTS
      await _flutterTts.setLanguage(ttsLanguageCode);
      
      // Check if the language is supported
      final isSupported = await isLanguageSupported(languageCode);
      
      if (!isSupported) {
        // Fallback to English pronunciation if language not supported
        await _flutterTts.setLanguage('en-US');
        // Use phonetic representation for better pronunciation
        final phoneticText = _getPhoneticText(letter, languageCode);
        await _flutterTts.speak(phoneticText);
      } else {
        // Speak the actual letter in the native language
        await _flutterTts.speak(letter);
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('TTS Speak Error: $e');
      }
      // Fallback: try speaking with English
      try {
        await _flutterTts.setLanguage('en-US');
        final phoneticText = _getPhoneticText(letter, languageCode);
        await _flutterTts.speak(phoneticText);
      } catch (fallbackError) {
        if (kDebugMode) {
          print('TTS Fallback Error: $fallbackError');
        }
      }
    }
  }

  static String _getPhoneticText(String letter, String languageCode) {
    // Enhanced phonetic representations for better pronunciation
    const phoneticMap = {
      // Hindi/Devanagari
      'अ': 'uh', 'आ': 'aa', 'इ': 'ee', 'ई': 'eee', 'उ': 'oo', 'ऊ': 'ooo',
      'ए': 'ay', 'ऐ': 'ai', 'ओ': 'oh', 'औ': 'ow',
      'क': 'ka', 'ख': 'kha', 'ग': 'ga', 'घ': 'gha', 'च': 'cha',
      
      // Tamil
      'அ': 'a', 'ஆ': 'aa', 'இ': 'i', 'ஈ': 'ee', 'உ': 'u', 'ஊ': 'oo',
      'எ': 'e', 'ஏ': 'ay', 'ஐ': 'ai', 'ஒ': 'o', 'ஓ': 'oh',
      'க': 'ka', 'ங': 'nga', 'ச': 'cha', 'ஞ': 'nya',
      
      // Telugu
      'అ': 'a', 'ఆ': 'aa', 'ఇ': 'i', 'ఈ': 'ee', 'ఉ': 'u', 'ఊ': 'oo',
      'ఎ': 'e', 'ఏ': 'ay', 'ఐ': 'ai', 'ఒ': 'o', 'ఓ': 'oh',
      'క': 'ka', 'ఖ': 'kha', 'గ': 'ga', 'ఘ': 'gha',
      
      // Bengali
      'অ': 'o', 'আ': 'aa', 'ই': 'i', 'ঈ': 'ee', 'উ': 'u', 'ঊ': 'oo',
      'এ': 'e', 'ঐ': 'oi', 'ও': 'o', 'ঔ': 'ou',
      'ক': 'ka', 'খ': 'kha', 'গ': 'ga', 'ঘ': 'gha', 'চ': 'cha',
      
      // Gujarati
      'અ': 'a', 'આ': 'aa', 'ઇ': 'i', 'ઈ': 'ee', 'ઉ': 'u', 'ઊ': 'oo',
      'એ': 'e', 'ઐ': 'ai', 'ઓ': 'o', 'ઔ': 'au',
      'ક': 'ka', 'ખ': 'kha', 'ગ': 'ga', 'ઘ': 'gha', 'ચ': 'cha',
      
      // Add more as needed...
    };
    
    return phoneticMap[letter] ?? letter;
  }

  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      if (kDebugMode) {
        print('TTS Stop Error: $e');
      }
    }
  }

  static Future<List<String>> getAvailableLanguages() async {
    try {
      await initialize();
      final languages = await _flutterTts.getLanguages;
      return languages?.cast<String>() ?? [];
    } catch (e) {
      if (kDebugMode) {
        print('Error getting available languages: $e');
      }
      return [];
    }
  }
}