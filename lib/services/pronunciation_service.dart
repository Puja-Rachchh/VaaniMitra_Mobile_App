// Simple pronunciation evaluation service
// Scoring is based on normalized Levenshtein similarity between
// expected text and recognized text returned by speech-to-text.

class PronunciationResult {
  final double score; // 0.0 - 1.0
  final bool isCorrect;
  final String feedback;
  final String expectedNormalized;
  final String recognizedNormalized;

  PronunciationResult({
    required this.score,
    required this.isCorrect,
    required this.feedback,
    required this.expectedNormalized,
    required this.recognizedNormalized,
  });
}

class PronunciationService {
  /// Evaluate pronunciation by comparing [expected] and [recognized].
  /// Returns a [PronunciationResult] with a score between 0.0 and 1.0.
  ///
  /// Notes:
  /// - This is a lightweight on-device comparator and not a phonetic engine.
  /// - For production-grade scoring consider cloud pronunciation APIs or
  ///   using acoustic models that return confidence/phoneme-level scores.
  static PronunciationResult evaluate(String expected, String recognized) {
    final e = _normalize(expected);
    final r = _normalize(recognized);

    final maxLen = e.length > r.length ? e.length : r.length;
    final distance = _levenshteinDistance(e, r);
    final similarity = maxLen == 0 ? 1.0 : 1.0 - (distance / maxLen);
    // clamp
    final score = similarity.clamp(0.0, 1.0);

    String feedback;
    bool isCorrect;
    if (score >= 0.85) {
      feedback = 'Excellent pronunciation';
      isCorrect = true;
    } else if (score >= 0.65) {
      feedback = 'Good — a little improvement needed';
      isCorrect = true;
    } else if (score >= 0.40) {
      feedback = 'Fair — try again with clearer pronunciation';
      isCorrect = false;
    } else {
      feedback = 'Not recognized well — speak more clearly or try again';
      isCorrect = false;
    }

    return PronunciationResult(
      score: double.parse(score.toStringAsFixed(3)),
      isCorrect: isCorrect,
      feedback: feedback,
      expectedNormalized: e,
      recognizedNormalized: r,
    );
  }

  // Basic normalization: trim whitespace, normalize spaces
  // Preserves all Unicode characters (Indian language scripts, etc.)
  static String _normalize(String s) {
    var out = s.trim();
    // Normalize multiple spaces to single space
    out = out.replaceAll(RegExp(r"\s+"), ' ');
    // Remove common punctuation but preserve language-specific characters
    out = out.replaceAll(RegExp(r'[।॥,.!?;:"()\-]+'), '');
    return out.trim();
  }

  // Levenshtein distance (iterative, memory efficient)
  static int _levenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    final v0 = List<int>.generate(t.length + 1, (i) => i);
    final v1 = List<int>.filled(t.length + 1, 0);

    for (var i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (var j = 0; j < t.length; j++) {
        final cost = s[i] == t[j] ? 0 : 1;
        v1[j + 1] = [
          v1[j] + 1, // insertion
          v0[j + 1] + 1, // deletion
          v0[j] + cost // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
      for (var j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    return v1[t.length];
  }
}

// End of file
