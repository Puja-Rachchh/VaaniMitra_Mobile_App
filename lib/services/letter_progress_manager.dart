import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/letter_tracing_models.dart';
import 'package:flutter/material.dart';

/// Service to manage letter tracing progress and persistence
class LetterProgressManager {
  static const String _progressKeyPrefix = 'letter_progress_';
  static const String _currentLetterKey = 'current_letter_index_';

  final SharedPreferences _prefs;
  final String language;

  LetterProgressManager({
    required SharedPreferences prefs,
    required this.language,
  }) : _prefs = prefs;

  /// Factory method to create instance with initialized SharedPreferences
  static Future<LetterProgressManager> create(String language) async {
    final prefs = await SharedPreferences.getInstance();
    return LetterProgressManager(prefs: prefs, language: language);
  }

  // ========== PROGRESS PERSISTENCE ==========

  /// Save progress for a specific letter
  Future<bool> saveProgress(LetterProgress progress) async {
    final key = _getProgressKey(progress.letterId);
    final json = jsonEncode(progress.toJson());
    return await _prefs.setString(key, json);
  }

  /// Get progress for a specific letter
  LetterProgress? getProgress(String letterId) {
    final key = _getProgressKey(letterId);
    final json = _prefs.getString(key);
    if (json == null) return null;
    
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return LetterProgress.fromJson(map);
    } catch (e) {
      debugPrint('Error loading progress for $letterId: $e');
      return null;
    }
  }

  /// Get or create progress for a letter
  LetterProgress getOrCreateProgress(String letterId) {
    return getProgress(letterId) ?? LetterProgress.initial(letterId);
  }

  /// Update progress after a tracing attempt
  Future<bool> updateProgress({
    required String letterId,
    required double score,
    required bool completed,
  }) async {
    final currentProgress = getOrCreateProgress(letterId);
    final updatedProgress = currentProgress.updateWithAttempt(
      score,
      completed: completed,
    );
    return await saveProgress(updatedProgress);
  }

  /// Clear all progress for current language
  Future<bool> clearAllProgress() async {
    final keys = _prefs.getKeys();
    final progressKeys = keys.where((key) => 
      key.startsWith(_getProgressKey(''))).toList();
    
    for (var key in progressKeys) {
      await _prefs.remove(key);
    }
    
    return await _prefs.remove(_getCurrentLetterKey());
  }

  /// Get all saved progress entries for current language
  List<LetterProgress> getAllProgress() {
    final keys = _prefs.getKeys();
    final progressKeys = keys.where((key) => 
      key.startsWith(_getProgressKey(''))).toList();
    
    final List<LetterProgress> progressList = [];
    for (var key in progressKeys) {
      final json = _prefs.getString(key);
      if (json != null) {
        try {
          final map = jsonDecode(json) as Map<String, dynamic>;
          progressList.add(LetterProgress.fromJson(map));
        } catch (e) {
          debugPrint('Error loading progress from $key: $e');
        }
      }
    }
    
    return progressList;
  }

  // ========== LETTER PROGRESSION ==========

  /// Get the current letter index for the learning sequence
  int getCurrentLetterIndex() {
    return _prefs.getInt(_getCurrentLetterKey()) ?? 0;
  }

  /// Set the current letter index
  Future<bool> setCurrentLetterIndex(int index) async {
    return await _prefs.setInt(_getCurrentLetterKey(), index);
  }

  /// Move to the next letter in the sequence
  Future<int> moveToNextLetter(List<TraceableLetter> letters) async {
    final currentIndex = getCurrentLetterIndex();
    final nextIndex = (currentIndex + 1) % letters.length;
    await setCurrentLetterIndex(nextIndex);
    return nextIndex;
  }

  /// Get the current letter from a list
  TraceableLetter? getCurrentLetter(List<TraceableLetter> letters) {
    if (letters.isEmpty) return null;
    final index = getCurrentLetterIndex();
    return index < letters.length ? letters[index] : letters[0];
  }

  /// Get the next uncompleted letter
  TraceableLetter? getNextUncompletedLetter(List<TraceableLetter> letters) {
    if (letters.isEmpty) return null;
    
    // First, try to find any uncompleted letter
    for (var letter in letters) {
      final progress = getProgress(letter.id);
      if (progress == null || !progress.isCompleted) {
        return letter;
      }
    }
    
    // If all are completed, return the first one (for review)
    return letters.first;
  }

  /// Reset to the first letter
  Future<bool> resetToFirstLetter() async {
    return await setCurrentLetterIndex(0);
  }

  // ========== STATISTICS ==========

  /// Get completion statistics for the current language
  Map<String, dynamic> getStatistics(List<TraceableLetter> letters) {
    final allProgress = getAllProgress();
    final completedCount = allProgress.where((p) => p.isCompleted).length;
    final totalCount = letters.length;
    final totalAttempts = allProgress.fold<int>(
      0,
      (sum, p) => sum + p.attemptCount,
    );
    final averageScore = allProgress.isEmpty
        ? 0.0
        : allProgress.fold<double>(
              0.0,
              (sum, p) => sum + p.bestScore,
            ) /
            allProgress.length;

    return {
      'completedCount': completedCount,
      'totalCount': totalCount,
      'completionPercentage': totalCount > 0 
          ? (completedCount / totalCount * 100).toStringAsFixed(1)
          : '0.0',
      'totalAttempts': totalAttempts,
      'averageScore': (averageScore * 100).toStringAsFixed(1),
    };
  }

  /// Check if all letters are completed
  bool areAllLettersCompleted(List<TraceableLetter> letters) {
    for (var letter in letters) {
      final progress = getProgress(letter.id);
      if (progress == null || !progress.isCompleted) {
        return false;
      }
    }
    return true;
  }

  /// Get list of completed letter IDs
  List<String> getCompletedLetterIds() {
    final allProgress = getAllProgress();
    return allProgress
        .where((p) => p.isCompleted)
        .map((p) => p.letterId)
        .toList();
  }

  /// Get list of uncompleted letter IDs
  List<String> getUncompletedLetterIds(List<TraceableLetter> letters) {
    final completedIds = getCompletedLetterIds().toSet();
    return letters
        .where((letter) => !completedIds.contains(letter.id))
        .map((letter) => letter.id)
        .toList();
  }

  // ========== HELPER METHODS ==========

  /// Generate key for storing letter progress
  String _getProgressKey(String letterId) {
    return '$_progressKeyPrefix${language}_$letterId';
  }

  /// Generate key for storing current letter index
  String _getCurrentLetterKey() {
    return '$_currentLetterKey$language';
  }

  /// Export all progress data (useful for backup/debugging)
  Map<String, dynamic> exportProgressData() {
    final allProgress = getAllProgress();
    final currentIndex = getCurrentLetterIndex();
    
    return {
      'language': language,
      'currentLetterIndex': currentIndex,
      'progress': allProgress.map((p) => p.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Import progress data (useful for restore)
  Future<bool> importProgressData(Map<String, dynamic> data) async {
    try {
      if (data['language'] != language) {
        debugPrint('Language mismatch in import data');
        return false;
      }

      // Clear existing progress
      await clearAllProgress();

      // Import current index
      final currentIndex = data['currentLetterIndex'] as int?;
      if (currentIndex != null) {
        await setCurrentLetterIndex(currentIndex);
      }

      // Import progress entries
      final progressList = data['progress'] as List?;
      if (progressList != null) {
        for (var progressData in progressList) {
          final progress = LetterProgress.fromJson(
            progressData as Map<String, dynamic>,
          );
          await saveProgress(progress);
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error importing progress data: $e');
      return false;
    }
  }
}
