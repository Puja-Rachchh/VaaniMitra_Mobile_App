import 'package:flutter/material.dart';
import '../models/letter_tracing_models.dart';
import 'dart:math' as math;

/// Helper class to generate letter data for different Indian languages
/// This makes it easy to add support for new languages
class LetterDataHelper {
  
  /// Get all available languages with letter tracing support
  static List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'hi', 'name': 'Hindi'},
      {'code': 'gu', 'name': 'Gujarati'},
      {'code': 'ta', 'name': 'Tamil'},
      {'code': 'te', 'name': 'Telugu'},
      {'code': 'kn', 'name': 'Kannada'},
      {'code': 'ml', 'name': 'Malayalam'},
      {'code': 'mr', 'name': 'Marathi'},
      {'code': 'bn', 'name': 'Bengali'},
      {'code': 'pa', 'name': 'Punjabi'},
    ];
  }

  /// Generate circular path for letters with circular strokes
  static List<Offset> generateCircularPath({
    required Offset center,
    required double radius,
    double startAngle = 0,
    double endAngle = 2 * math.pi,
    int points = 50,
  }) {
    final List<Offset> pathPoints = [];
    final angleStep = (endAngle - startAngle) / points;
    
    for (int i = 0; i <= points; i++) {
      final angle = startAngle + (angleStep * i);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      pathPoints.add(Offset(x, y));
    }
    
    return pathPoints;
  }

  /// Generate straight line path
  static List<Offset> generateStraightPath({
    required Offset start,
    required Offset end,
    int points = 20,
  }) {
    final List<Offset> pathPoints = [];
    final dx = (end.dx - start.dx) / points;
    final dy = (end.dy - start.dy) / points;
    
    for (int i = 0; i <= points; i++) {
      pathPoints.add(Offset(
        start.dx + (dx * i),
        start.dy + (dy * i),
      ));
    }
    
    return pathPoints;
  }

  /// Generate curved path (Bezier curve)
  static List<Offset> generateCurvedPath({
    required Offset start,
    required Offset control,
    required Offset end,
    int points = 30,
  }) {
    final List<Offset> pathPoints = [];
    
    for (int i = 0; i <= points; i++) {
      final t = i / points;
      final x = math.pow(1 - t, 2) * start.dx +
          2 * (1 - t) * t * control.dx +
          math.pow(t, 2) * end.dx;
      final y = math.pow(1 - t, 2) * start.dy +
          2 * (1 - t) * t * control.dy +
          math.pow(t, 2) * end.dy;
      pathPoints.add(Offset(x.toDouble(), y.toDouble()));
    }
    
    return pathPoints;
  }

  /// Generate S-curve path (cubic Bezier)
  static List<Offset> generateSCurvePath({
    required Offset start,
    required Offset control1,
    required Offset control2,
    required Offset end,
    int points = 40,
  }) {
    final List<Offset> pathPoints = [];
    
    for (int i = 0; i <= points; i++) {
      final t = i / points;
      final x = math.pow(1 - t, 3) * start.dx +
          3 * math.pow(1 - t, 2) * t * control1.dx +
          3 * (1 - t) * math.pow(t, 2) * control2.dx +
          math.pow(t, 3) * end.dx;
      final y = math.pow(1 - t, 3) * start.dy +
          3 * math.pow(1 - t, 2) * t * control1.dy +
          3 * (1 - t) * math.pow(t, 2) * control2.dy +
          math.pow(t, 3) * end.dy;
      pathPoints.add(Offset(x.toDouble(), y.toDouble()));
    }
    
    return pathPoints;
  }

  // ========== HINDI LETTERS ==========

  /// Get complete set of Hindi letters (vowels and consonants)
  static List<TraceableLetter> getHindiLetters({bool vowelsOnly = true}) {
    if (vowelsOnly) {
      return getHindiVowels();
    }
    // Can extend to include consonants
    return [...getHindiVowels()];
  }

  /// Hindi vowels (स्वर)
  static List<TraceableLetter> getHindiVowels() {
    return [
      _createSimpleLetter('अ', 'hi', 'a', 'a'),
      _createSimpleLetter('आ', 'hi', 'aa', 'aa'),
      _createSimpleLetter('इ', 'hi', 'i', 'i'),
      _createSimpleLetter('ई', 'hi', 'ee', 'ee'),
      _createSimpleLetter('उ', 'hi', 'u', 'u'),
      _createSimpleLetter('ऊ', 'hi', 'oo', 'oo'),
      _createSimpleLetter('ए', 'hi', 'e', 'e'),
      _createSimpleLetter('ऐ', 'hi', 'ai', 'ai'),
      _createSimpleLetter('ओ', 'hi', 'o', 'o'),
      _createSimpleLetter('औ', 'hi', 'au', 'au'),
      _createSimpleLetter('अं', 'hi', 'am', 'am'),
      _createSimpleLetter('अः', 'hi', 'ah', 'ah'),
    ];
  }

  // ========== GUJARATI LETTERS ==========

  /// Get complete set of Gujarati letters
  static List<TraceableLetter> getGujaratiLetters({bool vowelsOnly = true}) {
    if (vowelsOnly) {
      return getGujaratiVowels();
    }
    return [...getGujaratiVowels()];
  }

  /// Gujarati vowels (સ્વર)
  static List<TraceableLetter> getGujaratiVowels() {
    return [
      _createSimpleLetter('અ', 'gu', 'a', 'a'),
      _createSimpleLetter('આ', 'gu', 'aa', 'aa'),
      _createSimpleLetter('ઇ', 'gu', 'i', 'i'),
      _createSimpleLetter('ઈ', 'gu', 'ee', 'ee'),
      _createSimpleLetter('ઉ', 'gu', 'u', 'u'),
      _createSimpleLetter('ઊ', 'gu', 'oo', 'oo'),
      _createSimpleLetter('એ', 'gu', 'e', 'e'),
      _createSimpleLetter('ઐ', 'gu', 'ai', 'ai'),
      _createSimpleLetter('ઓ', 'gu', 'o', 'o'),
      _createSimpleLetter('ઔ', 'gu', 'au', 'au'),
    ];
  }

  // ========== TAMIL LETTERS ==========

  /// Get complete set of Tamil letters
  static List<TraceableLetter> getTamilLetters({bool vowelsOnly = true}) {
    if (vowelsOnly) {
      return getTamilVowels();
    }
    return [...getTamilVowels()];
  }

  /// Tamil vowels (உயிர் எழுத்துகள்)
  static List<TraceableLetter> getTamilVowels() {
    return [
      _createSimpleLetter('அ', 'ta', 'a', 'a'),
      _createSimpleLetter('ஆ', 'ta', 'aa', 'aa'),
      _createSimpleLetter('இ', 'ta', 'i', 'i'),
      _createSimpleLetter('ஈ', 'ta', 'ee', 'ee'),
      _createSimpleLetter('உ', 'ta', 'u', 'u'),
      _createSimpleLetter('ஊ', 'ta', 'oo', 'oo'),
      _createSimpleLetter('எ', 'ta', 'e', 'e'),
      _createSimpleLetter('ஏ', 'ta', 'ae', 'ae'),
      _createSimpleLetter('ஐ', 'ta', 'ai', 'ai'),
      _createSimpleLetter('ஒ', 'ta', 'o', 'o'),
      _createSimpleLetter('ஓ', 'ta', 'oo', 'oo'),
      _createSimpleLetter('ஔ', 'ta', 'au', 'au'),
    ];
  }

  // ========== TELUGU LETTERS ==========

  /// Get complete set of Telugu letters
  static List<TraceableLetter> getTeluguLetters({bool vowelsOnly = true}) {
    if (vowelsOnly) {
      return getTeluguVowels();
    }
    return [...getTeluguVowels()];
  }

  /// Telugu vowels (అచ్చులు)
  static List<TraceableLetter> getTeluguVowels() {
    return [
      _createSimpleLetter('అ', 'te', 'a', 'a'),
      _createSimpleLetter('ఆ', 'te', 'aa', 'aa'),
      _createSimpleLetter('ఇ', 'te', 'i', 'i'),
      _createSimpleLetter('ఈ', 'te', 'ee', 'ee'),
      _createSimpleLetter('ఉ', 'te', 'u', 'u'),
      _createSimpleLetter('ఊ', 'te', 'oo', 'oo'),
      _createSimpleLetter('ఎ', 'te', 'e', 'e'),
      _createSimpleLetter('ఏ', 'te', 'ae', 'ae'),
      _createSimpleLetter('ఐ', 'te', 'ai', 'ai'),
      _createSimpleLetter('ఒ', 'te', 'o', 'o'),
      _createSimpleLetter('ఓ', 'te', 'oo', 'oo'),
      _createSimpleLetter('ఔ', 'te', 'au', 'au'),
    ];
  }

  // ========== KANNADA LETTERS ==========

  /// Get complete set of Kannada letters
  static List<TraceableLetter> getKannadaLetters({bool vowelsOnly = true}) {
    if (vowelsOnly) {
      return getKannadaVowels();
    }
    return [...getKannadaVowels()];
  }

  /// Kannada vowels (ಸ್ವರಗಳು)
  static List<TraceableLetter> getKannadaVowels() {
    return [
      _createSimpleLetter('ಅ', 'kn', 'a', 'a'),
      _createSimpleLetter('ಆ', 'kn', 'aa', 'aa'),
      _createSimpleLetter('ಇ', 'kn', 'i', 'i'),
      _createSimpleLetter('ಈ', 'kn', 'ee', 'ee'),
      _createSimpleLetter('ಉ', 'kn', 'u', 'u'),
      _createSimpleLetter('ಊ', 'kn', 'oo', 'oo'),
      _createSimpleLetter('ಎ', 'kn', 'e', 'e'),
      _createSimpleLetter('ಏ', 'kn', 'ae', 'ae'),
      _createSimpleLetter('ಐ', 'kn', 'ai', 'ai'),
      _createSimpleLetter('ಒ', 'kn', 'o', 'o'),
      _createSimpleLetter('ಓ', 'kn', 'oo', 'oo'),
      _createSimpleLetter('ಔ', 'kn', 'au', 'au'),
    ];
  }

  // ========== HELPER METHODS ==========

  /// Create a simple letter with generic path
  /// This creates a basic vertical + horizontal stroke pattern
  static TraceableLetter _createSimpleLetter(
    String character,
    String language,
    String pronunciation,
    String transliteration,
  ) {
    return TraceableLetter(
      character: character,
      language: language,
      pronunciation: pronunciation,
      transliteration: transliteration,
      referenceSegments: [
        // Vertical stroke
        ReferencePathSegment(
          points: generateStraightPath(
            start: const Offset(150, 100),
            end: const Offset(150, 200),
          ),
          order: 1,
          strokeDirection: 'top-to-bottom',
        ),
        // Horizontal stroke
        ReferencePathSegment(
          points: generateStraightPath(
            start: const Offset(120, 150),
            end: const Offset(180, 150),
          ),
          order: 2,
          strokeDirection: 'left-to-right',
        ),
      ],
    );
  }

  /// Get letters for any supported language
  static List<TraceableLetter> getLettersForLanguage(
    String languageCode, {
    bool vowelsOnly = true,
  }) {
    switch (languageCode) {
      case 'hi':
        return getHindiLetters(vowelsOnly: vowelsOnly);
      case 'gu':
        return getGujaratiLetters(vowelsOnly: vowelsOnly);
      case 'ta':
        return getTamilLetters(vowelsOnly: vowelsOnly);
      case 'te':
        return getTeluguLetters(vowelsOnly: vowelsOnly);
      case 'kn':
        return getKannadaLetters(vowelsOnly: vowelsOnly);
      default:
        return getHindiLetters(vowelsOnly: vowelsOnly); // Default to Hindi
    }
  }

  /// Check if a language is supported
  static bool isLanguageSupported(String languageCode) {
    final supportedCodes = getSupportedLanguages()
        .map((lang) => lang['code'])
        .toList();
    return supportedCodes.contains(languageCode);
  }

  /// Get language name from code
  static String getLanguageName(String languageCode) {
    final language = getSupportedLanguages().firstWhere(
      (lang) => lang['code'] == languageCode,
      orElse: () => {'code': languageCode, 'name': 'Unknown'},
    );
    return language['name'] ?? 'Unknown';
  }
}
