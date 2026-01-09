import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/letter_tracing_models.dart';

/// Custom painter to draw the reference letter path and user strokes
class TracingPainter extends CustomPainter {
  final List<ReferencePathSegment> referenceSegments;
  final List<Stroke> userStrokes;
  final bool showReference;
  final bool highlightCorrect;
  final bool highlightIncorrect;
  final Stroke? currentStroke;
  final String letterCharacter; // Add the actual letter character
  final bool showHints; // Show directional hints
  final double animationValue; // For animated hints

  TracingPainter({
    required this.referenceSegments,
    required this.userStrokes,
    required this.letterCharacter,
    this.showReference = true,
    this.highlightCorrect = false,
    this.highlightIncorrect = false,
    this.currentStroke,
    this.showHints = true,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the actual letter character as a large semi-transparent guide
    if (showReference) {
      _drawLetterGuide(canvas, size);
    }

    // Draw directional hints if enabled and no strokes yet
    if (showHints && userStrokes.isEmpty && currentStroke == null) {
      _drawTracingHints(canvas, size);
    }

    // Debug: Draw reference area to verify coordinate alignment
    // _drawDebugReferenceArea(canvas, size);

    // Draw completed user strokes
    for (int i = 0; i < userStrokes.length; i++) {
      _drawUserStroke(
        canvas,
        userStrokes[i],
        isCorrect: highlightCorrect,
        isIncorrect: highlightIncorrect,
      );
    }

    // Draw current stroke being drawn
    if (currentStroke != null) {
      _drawUserStroke(
        canvas,
        currentStroke!,
        isCurrent: true,
      );
    }
  }

  /// Debug: Draw reference area to visualize where tracing is expected
  void _drawDebugReferenceArea(Canvas canvas, Size size) {
    if (referenceSegments.isEmpty) return;
    
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    
    // Draw small circles at each reference point (scaled to canvas size)
    for (var segment in referenceSegments) {
      for (var point in segment.points) {
        // Scale normalized coordinates to actual canvas size
        final scaledPoint = Offset(
          point.dx <= 1.0 ? point.dx * size.width : point.dx,
          point.dy <= 1.0 ? point.dy * size.height : point.dy,
        );
        canvas.drawCircle(scaledPoint, 3, paint);
      }
    }
  }

  /// Draw tracing hints - starting point and directional guidance
  void _drawTracingHints(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Draw animated pulsing starting point
    final startPointPaint = Paint()
      ..color = Colors.green.withOpacity(0.7 + 0.3 * math.sin(animationValue * 2 * math.pi))
      ..style = PaintingStyle.fill;
    
    final startPointBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    // Pulsing circle at center as starting hint
    final pulseRadius = 15 + 5 * math.sin(animationValue * 2 * math.pi);
    canvas.drawCircle(Offset(centerX, centerY), pulseRadius, startPointPaint);
    canvas.drawCircle(Offset(centerX, centerY), pulseRadius, startPointBorderPaint);
    
    // Draw "Start Here" text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '✓ Start',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.green[800],
          backgroundColor: Colors.white.withOpacity(0.9),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2, centerY - 50),
    );
    
    // Draw directional arrows indicating tracing path
    _drawDirectionalArrows(canvas, size);
    
    // Draw instructional text
    final instructionPainter = TextPainter(
      text: TextSpan(
        text: 'Trace the letter with your finger',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    instructionPainter.layout(maxWidth: size.width * 0.8);
    instructionPainter.paint(
      canvas,
      Offset((size.width - instructionPainter.width) / 2, size.height - 40),
    );
  }
  
  /// Draw directional arrows to guide tracing
  void _drawDirectionalArrows(Canvas canvas, Size size) {
    final arrowPaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    // Draw 4 curved arrows around the letter indicating circular/free-form tracing
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.25;
    
    // Top-left to top-right
    _drawCurvedArrow(
      canvas,
      Offset(centerX - radius, centerY - radius * 0.7),
      Offset(centerX + radius, centerY - radius * 0.7),
      arrowPaint,
    );
    
    // Top-right to bottom-right
    _drawCurvedArrow(
      canvas,
      Offset(centerX + radius * 0.7, centerY - radius),
      Offset(centerX + radius * 0.7, centerY + radius),
      arrowPaint,
    );
  }
  
  /// Draw a curved arrow from start to end
  void _drawCurvedArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    
    // Create a gentle curve
    final controlPoint = Offset(
      (start.dx + end.dx) / 2 + (end.dy - start.dy) * 0.2,
      (start.dy + end.dy) / 2 - (end.dx - start.dx) * 0.2,
    );
    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      end.dx,
      end.dy,
    );
    
    canvas.drawPath(path, paint);
    
    // Draw arrowhead at the end
    final arrowSize = 10.0;
    final angle = math.atan2(end.dy - controlPoint.dy, end.dx - controlPoint.dx);
    
    final arrowPath = Path();
    arrowPath.moveTo(end.dx, end.dy);
    arrowPath.lineTo(
      end.dx - arrowSize * math.cos(angle - math.pi / 6),
      end.dy - arrowSize * math.sin(angle - math.pi / 6),
    );
    arrowPath.moveTo(end.dx, end.dy);
    arrowPath.lineTo(
      end.dx - arrowSize * math.cos(angle + math.pi / 6),
      end.dy - arrowSize * math.sin(angle + math.pi / 6),
    );
    
    canvas.drawPath(arrowPath, paint);
  }

  /// Draw the actual letter character as a large guide
  void _drawLetterGuide(Canvas canvas, Size size) {
    // Make font size responsive - 50% of canvas width
    final fontSize = size.width * 0.5;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: letterCharacter,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.grey.withOpacity(0.3),
          fontFamily: 'NotoSans', // Support for multiple scripts
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Center the letter in the canvas
    final xOffset = (size.width - textPainter.width) / 2;
    final yOffset = (size.height - textPainter.height) / 2;

    textPainter.paint(canvas, Offset(xOffset, yOffset));
  }

  /// Draw the reference path as a dotted/dashed guide (now hidden in favor of letter)
  void _drawReferencePath(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 20.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw each segment
    for (var segment in referenceSegments) {
      if (segment.points.length < 2) continue;

      final path = Path();
      path.moveTo(segment.points[0].dx, segment.points[0].dy);

      for (int i = 1; i < segment.points.length; i++) {
        path.lineTo(segment.points[i].dx, segment.points[i].dy);
      }

      // Draw as dashed line
      _drawDashedPath(canvas, path, paint);
    }

    // Draw start and end indicators
    _drawStartEndIndicators(canvas);
  }

  /// Draw a dashed path
  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 10.0;
    const dashSpace = 8.0;

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final start = metric.getTangentForOffset(distance);
        final end = metric.getTangentForOffset(
          math.min(distance + dashWidth, metric.length),
        );

        if (start != null && end != null) {
          canvas.drawLine(start.position, end.position, paint);
        }

        distance += dashWidth + dashSpace;
      }
    }
  }

  /// Draw start and end indicators for the reference path
  void _drawStartEndIndicators(Canvas canvas) {
    if (referenceSegments.isEmpty) return;

    // Draw start point (green circle)
    final firstSegment = referenceSegments
        .reduce((a, b) => a.order < b.order ? a : b);
    if (firstSegment.points.isNotEmpty) {
      final startPoint = firstSegment.points.first;
      final startPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill;

      canvas.drawCircle(startPoint, 12.0, startPaint);
      
      // White border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(startPoint, 12.0, borderPaint);
    }

    // Draw end point (red circle)
    final lastSegment = referenceSegments
        .reduce((a, b) => a.order > b.order ? a : b);
    if (lastSegment.points.isNotEmpty) {
      final endPoint = lastSegment.points.last;
      final endPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;

      canvas.drawCircle(endPoint, 12.0, endPaint);
      
      // White border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(endPoint, 12.0, borderPaint);
    }
  }

  /// Draw a user's stroke
  void _drawUserStroke(
    Canvas canvas,
    Stroke stroke, {
    bool isCorrect = false,
    bool isIncorrect = false,
    bool isCurrent = false,
  }) {
    if (stroke.points.length < 2) return;

    Color strokeColor;
    if (isCurrent) {
      strokeColor = Colors.blue;
    } else if (isCorrect) {
      strokeColor = Colors.green;
    } else if (isIncorrect) {
      strokeColor = Colors.red;
    } else {
      strokeColor = Colors.black87;
    }

    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(
      stroke.points[0].position.dx,
      stroke.points[0].position.dy,
    );

    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(
        stroke.points[i].position.dx,
        stroke.points[i].position.dy,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(TracingPainter oldDelegate) {
    return oldDelegate.userStrokes.length != userStrokes.length ||
        oldDelegate.currentStroke != currentStroke ||
        oldDelegate.showReference != showReference ||
        oldDelegate.highlightCorrect != highlightCorrect ||
        oldDelegate.highlightIncorrect != highlightIncorrect ||
        oldDelegate.letterCharacter != letterCharacter ||
        oldDelegate.showHints != showHints ||
        oldDelegate.animationValue != animationValue;
  }
}

/// Interactive canvas widget for letter tracing
class TracingCanvas extends StatefulWidget {
  final TraceableLetter letter;
  final Function(List<Stroke>) onTracingComplete;
  final Function(bool)? onStrokeValidation;
  final bool enableRealTimeFeedback;
  final bool showHints; // Control hint visibility

  const TracingCanvas({
    Key? key,
    required this.letter,
    required this.onTracingComplete,
    this.onStrokeValidation,
    this.enableRealTimeFeedback = true,
    this.showHints = true, // Default to showing hints
  }) : super(key: key);

  @override
  State<TracingCanvas> createState() => TracingCanvasState();
}

class TracingCanvasState extends State<TracingCanvas> with SingleTickerProviderStateMixin {
  final List<Stroke> _completedStrokes = [];
  List<StrokePoint> _currentStrokePoints = [];
  DateTime? _currentStrokeStartTime;
  Size _canvasSize = Size.zero; // Track canvas size
  
  bool _showReference = true;
  bool _highlightCorrect = false;
  bool _highlightIncorrect = false;
  
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Setup animation for pulsing hints
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            // Update canvas size
            _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
            
            return GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: CustomPaint(
                painter: TracingPainter(
                  referenceSegments: widget.letter.referenceSegments,
                  userStrokes: _completedStrokes,
                  letterCharacter: widget.letter.character,
                  showReference: _showReference,
                  highlightCorrect: _highlightCorrect,
                  highlightIncorrect: _highlightIncorrect,
                  showHints: widget.showHints && _completedStrokes.isEmpty && _currentStrokePoints.isEmpty,
                  animationValue: _animationController.value,
                  currentStroke: _currentStrokePoints.isNotEmpty
                      ? Stroke(
                          points: _currentStrokePoints,
                          startTime: _currentStrokeStartTime ?? DateTime.now(),
                          endTime: DateTime.now(),
                        )
                      : null,
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Handle touch/pan start
  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentStrokePoints = [
        StrokePoint(
          position: details.localPosition,
          timestamp: DateTime.now(),
        ),
      ];
      _currentStrokeStartTime = DateTime.now();
      _highlightCorrect = false;
      _highlightIncorrect = false;
    });
  }

  /// Handle touch/pan update (drawing)
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentStrokePoints.add(
        StrokePoint(
          position: details.localPosition,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  /// Handle touch/pan end (stroke complete)
  void _onPanEnd(DragEndDetails details) {
    if (_currentStrokePoints.length < 2) {
      setState(() {
        _currentStrokePoints = [];
        _currentStrokeStartTime = null;
      });
      return;
    }

    final completedStroke = Stroke(
      points: _currentStrokePoints,
      startTime: _currentStrokeStartTime ?? DateTime.now(),
      endTime: DateTime.now(),
    );

    setState(() {
      _completedStrokes.add(completedStroke);
      _currentStrokePoints = [];
      _currentStrokeStartTime = null;
    });

    // Validate stroke in real-time if enabled
    if (widget.enableRealTimeFeedback) {
      _validateCurrentStroke(completedStroke);
    }

    // Notify parent about completion
    widget.onTracingComplete(_completedStrokes);
  }

  /// Validate a single stroke (for real-time feedback)
  void _validateCurrentStroke(Stroke stroke) {
    // Import validator for validation
    // For now, just provide basic feedback
    // This will be enhanced with actual validation in the screen
    if (widget.onStrokeValidation != null) {
      widget.onStrokeValidation!(true);
    }
  }

  /// Clear all strokes
  void clearStrokes() {
    setState(() {
      _completedStrokes.clear();
      _currentStrokePoints.clear();
      _currentStrokeStartTime = null;
      _highlightCorrect = false;
      _highlightIncorrect = false;
    });
  }

  /// Show success feedback
  void showSuccessFeedback() {
    setState(() {
      _highlightCorrect = true;
      _highlightIncorrect = false;
    });
  }

  /// Show error feedback
  void showErrorFeedback() {
    setState(() {
      _highlightCorrect = false;
      _highlightIncorrect = true;
    });
  }

  /// Toggle reference visibility
  void toggleReference() {
    setState(() {
      _showReference = !_showReference;
    });
  }

  /// Get current strokes
  List<Stroke> get strokes => List.unmodifiable(_completedStrokes);
  
  /// Get canvas size for coordinate scaling
  Size get canvasSize => _canvasSize;
}
