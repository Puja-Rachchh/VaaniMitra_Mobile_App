import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _knownLanguageKey = 'known_language';
  static const String _targetLanguageKey = 'target_language';
  static const String _currentLevelKey = 'current_level';

  static Future<void> setKnownLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_knownLanguageKey, languageCode);
  }

  static Future<String?> getKnownLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_knownLanguageKey);
  }

  static Future<void> setTargetLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_targetLanguageKey, languageCode);
  }

  static Future<String?> getTargetLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_targetLanguageKey);
  }

  static Future<void> setCurrentLevel(String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentLevelKey, level);
  }

  static Future<String?> getCurrentLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentLevelKey);
  }

  static Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}