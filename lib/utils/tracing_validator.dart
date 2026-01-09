import 'dart:math';
import 'package:flutter/material.dart';
import '../models/letter_tracing_models.dart';

/// Utility class to validate user's traced strokes against reference paths
class TracingValidator {
  // Minimum accuracy threshold for successful tracing
  static const double defaultAccuracyThreshold = 0.60; // 60% - more forgiving
  
  // Maximum distance (in logical pixels) for a point to be considered "on path"
  static const double maxDistanceFromPath = 60.0; // Increased tolerance
  
  // Tolerance for direction matching (cosine similarity threshold)
  static const double directionTolerance = 0.7;

  /// Main validation function - compares user strokes with reference segments
  static TracingValidationResult validate({
    required List<Stroke> userStrokes,
    required List<ReferencePathSegment> referenceSegments,
    double accuracyThreshold = defaultAccuracyThreshold,
    Size? canvasSize, // Canvas size for scaling normalized coordinates
  }) {
    if (userStrokes.isEmpty) {
      return TracingValidationResult(
        isValid: false,
        accuracyScore: 0.0,
        coverageScore: 0.0,
        directionScore: 0.0,
        feedback: ['Please trace the letter'],
      );
    }

    // Calculate coverage score (how much of reference path is covered)
    final coverageScore = _calculateCoverageScore(
      userStrokes: userStrokes,
      referenceSegments: referenceSegments,
      canvasSize: canvasSize,
    );

    // Calculate direction score (how well the strokes follow the direction)
    final directionScore = _calculateDirectionScore(
      userStrokes: userStrokes,
      referenceSegments: referenceSegments,
      canvasSize: canvasSize,
    );

    // Calculate overall accuracy (weighted combination)
    final accuracyScore = (coverageScore * 0.7) + (directionScore * 0.3);

    // Generate feedback
    final feedback = _generateFeedback(
      accuracyScore: accuracyScore,
      coverageScore: coverageScore,
      directionScore: directionScore,
      threshold: accuracyThreshold,
    );

    return TracingValidationResult(
      isValid: accuracyScore >= accuracyThreshold,
      accuracyScore: accuracyScore,
      coverageScore: coverageScore,
      directionScore: directionScore,
      feedback: feedback,
    );
  }

  /// Calculate how much of the reference path is covered by user strokes
  static double _calculateCoverageScore({
    required List<Stroke> userStrokes,
    required List<ReferencePathSegment> referenceSegments,
    Size? canvasSize,
  }) {
    // Collect all reference points and scale them if canvas size is provided
    final List<Offset> allReferencePoints = [];
    for (var segment in referenceSegments) {
      for (var point in segment.points) {
        // If canvas size provided and coordinates are normalized (0-1 range),
        // scale them to actual canvas coordinates
        if (canvasSize != null && point.dx <= 1.0 && point.dy <= 1.0) {
          allReferencePoints.add(Offset(
            point.dx * canvasSize.width,
            point.dy * canvasSize.height,
          ));
        } else {
          allReferencePoints.add(point);
        }
      }
    }

    if (allReferencePoints.isEmpty) return 0.0;

    // Collect all user points
    final List<Offset> allUserPoints = [];
    for (var stroke in userStrokes) {
      allUserPoints.addAll(stroke.points.map((p) => p.position));
    }

    if (allUserPoints.isEmpty) return 0.0;

    // Count how many reference points are covered by user strokes
    int coveredPoints = 0;
    for (var refPoint in allReferencePoints) {
      if (_isPointCoveredByStrokes(refPoint, allUserPoints)) {
        coveredPoints++;
      }
    }

    return coveredPoints / allReferencePoints.length;
  }

  /// Check if a reference point is covered by any user stroke point
  static bool _isPointCoveredByStrokes(
    Offset refPoint,
    List<Offset> userPoints,
  ) {
    for (var userPoint in userPoints) {
      final distance = _calculateDistance(refPoint, userPoint);
      if (distance <= maxDistanceFromPath) {
        return true;
      }
    }
    return false;
  }

  /// Calculate direction similarity between user strokes and reference segments
  static double _calculateDirectionScore({
    required List<Stroke> userStrokes,
    required List<ReferencePathSegment> referenceSegments,
    Size? canvasSize,
  }) {
    if (userStrokes.isEmpty || referenceSegments.isEmpty) return 0.0;

    double totalScore = 0.0;
    int comparisonCount = 0;

    // Compare each user stroke with the most relevant reference segment
    for (var userStroke in userStrokes) {
      if (userStroke.points.length < 2) continue;

      // Find the closest reference segment
      final closestSegment = _findClosestSegment(
        stroke: userStroke,
        segments: referenceSegments,
        canvasSize: canvasSize,
      );

      if (closestSegment != null) {
        final directionSimilarity = _calculateDirectionSimilarity(
          userStroke: userStroke,
          referenceSegment: closestSegment,
          canvasSize: canvasSize,
        );
        totalScore += directionSimilarity;
        comparisonCount++;
      }
    }

    return comparisonCount > 0 ? totalScore / comparisonCount : 0.0;
  }

  /// Find the reference segment closest to a given user stroke
  static ReferencePathSegment? _findClosestSegment({
    required Stroke stroke,
    required List<ReferencePathSegment> segments,
    Size? canvasSize,
  }) {
    if (segments.isEmpty || stroke.points.isEmpty) return null;

    final strokeCenter = _calculateCenter(
      stroke.points.map((p) => p.position).toList(),
    );

    ReferencePathSegment? closestSegment;
    double minDistance = double.infinity;

    for (var segment in segments) {
      // Scale segment center if needed
      Offset segmentCenter = segment.center;
      if (canvasSize != null && segmentCenter.dx <= 1.0 && segmentCenter.dy <= 1.0) {
        segmentCenter = Offset(
          segmentCenter.dx * canvasSize.width,
          segmentCenter.dy * canvasSize.height,
        );
      }
      
      final distance = _calculateDistance(strokeCenter, segmentCenter);

      if (distance < minDistance) {
        minDistance = distance;
        closestSegment = segment;
      }
    }

    return closestSegment;
  }

  /// Calculate direction similarity using cosine similarity
  static double _calculateDirectionSimilarity({
    required Stroke userStroke,
    required ReferencePathSegment referenceSegment,
    Size? canvasSize,
  }) {
    if (userStroke.points.length < 2 || referenceSegment.points.length < 2) {
      return 0.0;
    }

    // Calculate user stroke direction
    final userStart = userStroke.points.first.position;
    final userEnd = userStroke.points.last.position;
    final userVector = Offset(
      userEnd.dx - userStart.dx,
      userEnd.dy - userStart.dy,
    );

    // Calculate reference segment direction (scale if needed)
    Offset refStart = referenceSegment.points.first;
    Offset refEnd = referenceSegment.points.last;
    
    if (canvasSize != null && refStart.dx <= 1.0 && refStart.dy <= 1.0) {
      refStart = Offset(
        refStart.dx * canvasSize.width,
        refStart.dy * canvasSize.height,
      );
      refEnd = Offset(
        refEnd.dx * canvasSize.width,
        refEnd.dy * canvasSize.height,
      );
    }
    
    final refVector = Offset(
      refEnd.dx - refStart.dx,
      refEnd.dy - refStart.dy,
    );

    // Normalize vectors
    final userMagnitude = sqrt(
      userVector.dx * userVector.dx + userVector.dy * userVector.dy,
    );
    final refMagnitude = sqrt(
      refVector.dx * refVector.dx + refVector.dy * refVector.dy,
    );

    if (userMagnitude == 0 || refMagnitude == 0) return 0.0;

    final userNormalized = Offset(
      userVector.dx / userMagnitude,
      userVector.dy / userMagnitude,
    );
    final refNormalized = Offset(
      refVector.dx / refMagnitude,
      refVector.dy / refMagnitude,
    );

    // Calculate cosine similarity
    final dotProduct = userNormalized.dx * refNormalized.dx +
        userNormalized.dy * refNormalized.dy;

    // Convert from [-1, 1] to [0, 1] and apply tolerance
    final similarity = (dotProduct + 1) / 2;
    return similarity >= directionTolerance ? similarity : 0.0;
  }

  /// Calculate Euclidean distance between two points
  static double _calculateDistance(Offset p1, Offset p2) {
    final dx = p1.dx - p2.dx;
    final dy = p1.dy - p2.dy;
    return sqrt(dx * dx + dy * dy);
  }

  /// Calculate center point of a list of offsets
  static Offset _calculateCenter(List<Offset> points) {
    if (points.isEmpty) return Offset.zero;

    double sumX = 0;
    double sumY = 0;
    for (var point in points) {
      sumX += point.dx;
      sumY += point.dy;
    }

    return Offset(sumX / points.length, sumY / points.length);
  }

  /// Generate user-friendly feedback based on scores
  static List<String> _generateFeedback({
    required double accuracyScore,
    required double coverageScore,
    required double directionScore,
    required double threshold,
  }) {
    final List<String> feedback = [];

    if (accuracyScore >= threshold) {
      feedback.add('Excellent! You traced the letter correctly! ✓');
    } else {
      if (coverageScore < 0.6) {
        feedback.add('Try to cover more of the letter path');
      }
      if (directionScore < 0.6) {
        feedback.add('Follow the stroke direction more carefully');
      }
      if (accuracyScore >= threshold * 0.7) {
        feedback.add('Almost there! Keep practicing');
      } else if (accuracyScore >= threshold * 0.5) {
        feedback.add('Good effort! Try to trace more carefully');
      } else {
        feedback.add('Keep trying! Follow the dotted guide');
      }
    }

    return feedback;
  }

  /// Helper method to validate single stroke (useful for real-time feedback)
  static bool isStrokeOnPath({
    required Stroke stroke,
    required List<ReferencePathSegment> referenceSegments,
  }) {
    if (stroke.points.isEmpty || referenceSegments.isEmpty) return false;

    // Check if stroke points are generally near the reference path
    int pointsOnPath = 0;
    final List<Offset> allReferencePoints = [];
    
    for (var segment in referenceSegments) {
      allReferencePoints.addAll(segment.points);
    }

    for (var point in stroke.points) {
      if (_isPointCoveredByStrokes(
        point.position,
        allReferencePoints,
      )) {
        pointsOnPath++;
      }
    }

    // At least 50% of points should be on the path
    return (pointsOnPath / stroke.points.length) >= 0.5;
  }
}
