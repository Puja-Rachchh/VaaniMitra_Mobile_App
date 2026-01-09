import 'package:flutter/foundation.dart';

/// Helper to convert between ISO language codes and your database format
class LanguageMapper {
  // Map ISO 639-1 codes (hi, ta, te, etc.) to your database format (hindi, tamil, etc.)
  static final Map<String, String> _isoToDbLanguage = {
    'en': 'english',
    'hi': 'hindi',
    'ta': 'tamil',
    'te': 'telugu',
    'mr': 'marathi',
    'bn': 'bengali',
    'gu': 'gujarati',
    'kn': 'kannada',
    'ml': 'malayalam',
    'pa': 'punjabi',
    'or': 'odia',
    'as': 'assamese',
    'ur': 'urdu',
    'ne': 'nepali',
  };

  // Reverse mapping
  static final Map<String, String> _dbToIsoLanguage = {
    'english': 'en',
    'hindi': 'hi',
    'tamil': 'ta',
    'telugu': 'te',
    'marathi': 'mr',
    'bengali': 'bn',
    'gujarati': 'gu',
    'kannada': 'kn',
    'malayalam': 'ml',
    'punjabi': 'pa',
    'odia': 'or',
    'assamese': 'as',
    'urdu': 'ur',
    'nepali': 'ne',
  };

  /// Convert ISO code (hi) to database format (hindi)
  static String isoToDb(String isoCode) {
    final dbLang = _isoToDbLanguage[isoCode.toLowerCase()];
    if (dbLang == null) {
      debugPrint('⚠️ Unknown language code: $isoCode, using as-is');
      return isoCode.toLowerCase();
    }
    return dbLang;
  }

  /// Convert database format (hindi) to ISO code (hi)
  static String dbToIso(String dbLanguage) {
    final isoCode = _dbToIsoLanguage[dbLanguage.toLowerCase()];
    if (isoCode == null) {
      debugPrint('⚠️ Unknown database language: $dbLanguage, using as-is');
      return dbLanguage.toLowerCase();
    }
    return isoCode;
  }

  /// Check if a language code is valid
  static bool isValidIsoCode(String code) {
    return _isoToDbLanguage.containsKey(code.toLowerCase());
  }

  /// Check if a database language name is valid
  static bool isValidDbLanguage(String language) {
    return _dbToIsoLanguage.containsKey(language.toLowerCase());
  }
}
