import 'package:flutter/material.dart';

/// Represents a single point in a stroke path
class StrokePoint {
  final Offset position;
  final DateTime timestamp;

  StrokePoint({
    required this.position,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'x': position.dx,
        'y': position.dy,
        'timestamp': timestamp.toIso8601String(),
      };

  factory StrokePoint.fromJson(Map<String, dynamic> json) => StrokePoint(
        position: Offset(json['x'], json['y']),
        timestamp: DateTime.parse(json['timestamp']),
      );
}

/// Represents a complete stroke (continuous line drawn by user)
class Stroke {
  final List<StrokePoint> points;
  final DateTime startTime;
  final DateTime endTime;

  Stroke({
    required this.points,
    required this.startTime,
    required this.endTime,
  });

  /// Calculate the direction vector of this stroke
  Offset get direction {
    if (points.length < 2) return Offset.zero;
    final start = points.first.position;
    final end = points.last.position;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final magnitude = (dx * dx + dy * dy);
    if (magnitude == 0) return Offset.zero;
    return Offset(dx / magnitude, dy / magnitude);
  }

  /// Get the bounding box of this stroke
  Rect get bounds {
    if (points.isEmpty) return Rect.zero;
    double minX = points.first.position.dx;
    double maxX = points.first.position.dx;
    double minY = points.first.position.dy;
    double maxY = points.first.position.dy;

    for (var point in points) {
      minX = minX < point.position.dx ? minX : point.position.dx;
      maxX = maxX > point.position.dx ? maxX : point.position.dx;
      minY = minY < point.position.dy ? minY : point.position.dy;
      maxY = maxY > point.position.dy ? maxY : point.position.dy;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

/// Represents a reference path segment for a letter
class ReferencePathSegment {
  final List<Offset> points;
  final int order; // The order in which this segment should be drawn
  final String? strokeDirection; // Optional: 'left-to-right', 'top-to-bottom', etc.

  ReferencePathSegment({
    required this.points,
    required this.order,
    this.strokeDirection,
  });

  /// Calculate the center point of this segment
  Offset get center {
    if (points.isEmpty) return Offset.zero;
    double sumX = 0;
    double sumY = 0;
    for (var point in points) {
      sumX += point.dx;
      sumY += point.dy;
    }
    return Offset(sumX / points.length, sumY / points.length);
  }

  /// Get the bounding box of this segment
  Rect get bounds {
    if (points.isEmpty) return Rect.zero;
    double minX = points.first.dx;
    double maxX = points.first.dx;
    double minY = points.first.dy;
    double maxY = points.first.dy;

    for (var point in points) {
      minX = minX < point.dx ? minX : point.dx;
      maxX = maxX > point.dx ? maxX : point.dx;
      minY = minY < point.dy ? minY : point.dy;
      maxY = maxY > point.dy ? maxY : point.dy;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  Map<String, dynamic> toJson() => {
        'points': points
            .map((p) => {'x': p.dx, 'y': p.dy})
            .toList(),
        'order': order,
        'strokeDirection': strokeDirection,
      };

  factory ReferencePathSegment.fromJson(Map<String, dynamic> json) =>
      ReferencePathSegment(
        points: (json['points'] as List)
            .map((p) => Offset(p['x'], p['y']))
            .toList(),
        order: json['order'],
        strokeDirection: json['strokeDirection'],
      );
}

/// Represents a traceable letter with its reference paths
class TraceableLetter {
  final String character; // The actual character (e.g., 'अ', 'आ')
  final String language; // Language code (e.g., 'hi', 'gu', 'ta')
  final List<ReferencePathSegment> referenceSegments;
  final String? pronunciation; // Optional: how to pronounce this letter
  final String? transliteration; // Optional: romanized version

  TraceableLetter({
    required this.character,
    required this.language,
    required this.referenceSegments,
    this.pronunciation,
    this.transliteration,
  });

  /// Get unique identifier for this letter
  String get id => '${language}_$character';

  Map<String, dynamic> toJson() => {
        'character': character,
        'language': language,
        'referenceSegments':
            referenceSegments.map((s) => s.toJson()).toList(),
        'pronunciation': pronunciation,
        'transliteration': transliteration,
      };

  factory TraceableLetter.fromJson(Map<String, dynamic> json) =>
      TraceableLetter(
        character: json['character'],
        language: json['language'],
        referenceSegments: (json['referenceSegments'] as List)
            .map((s) => ReferencePathSegment.fromJson(s))
            .toList(),
        pronunciation: json['pronunciation'],
        transliteration: json['transliteration'],
      );
}

/// Represents the validation result of a tracing attempt
class TracingValidationResult {
  final bool isValid;
  final double accuracyScore; // 0.0 to 1.0
  final double coverageScore; // How much of the reference path was covered
  final double directionScore; // How well the direction matches
  final List<String> feedback; // User-friendly feedback messages

  TracingValidationResult({
    required this.isValid,
    required this.accuracyScore,
    required this.coverageScore,
    required this.directionScore,
    required this.feedback,
  });

  /// Get overall percentage accuracy
  double get percentageAccuracy => accuracyScore * 100;

  /// Check if meets minimum threshold
  bool meetsThreshold(double threshold) => accuracyScore >= threshold;
}

/// Represents user's progress for a specific letter
class LetterProgress {
  final String letterId;
  final int attemptCount;
  final double bestScore;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime lastAttemptAt;

  LetterProgress({
    required this.letterId,
    required this.attemptCount,
    required this.bestScore,
    required this.isCompleted,
    this.completedAt,
    required this.lastAttemptAt,
  });

  Map<String, dynamic> toJson() => {
        'letterId': letterId,
        'attemptCount': attemptCount,
        'bestScore': bestScore,
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'lastAttemptAt': lastAttemptAt.toIso8601String(),
      };

  factory LetterProgress.fromJson(Map<String, dynamic> json) => LetterProgress(
        letterId: json['letterId'],
        attemptCount: json['attemptCount'],
        bestScore: json['bestScore'],
        isCompleted: json['isCompleted'],
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        lastAttemptAt: DateTime.parse(json['lastAttemptAt']),
      );

  /// Create a new progress entry
  factory LetterProgress.initial(String letterId) => LetterProgress(
        letterId: letterId,
        attemptCount: 0,
        bestScore: 0.0,
        isCompleted: false,
        lastAttemptAt: DateTime.now(),
      );

  /// Update progress with a new attempt
  LetterProgress updateWithAttempt(double score, {bool completed = false}) {
    return LetterProgress(
      letterId: letterId,
      attemptCount: attemptCount + 1,
      bestScore: score > bestScore ? score : bestScore,
      isCompleted: completed || isCompleted,
      completedAt: completed ? DateTime.now() : completedAt,
      lastAttemptAt: DateTime.now(),
    );
  }
}
