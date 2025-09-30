/// Quiz data models for the VaaniMitra app

/// Represents a single quiz question
class QuizQuestion {
  final String id;
  final String questionText;
  final String imageAsset;
  final String correctAnswer;
  final List<String> options;
  final String category;
  final String level;

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.imageAsset,
    required this.correctAnswer,
    required this.options,
    required this.category,
    required this.level,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      questionText: json['questionText'] as String,
      imageAsset: json['imageAsset'] as String,
      correctAnswer: json['correctAnswer'] as String,
      options: List<String>.from(json['options'] as List),
      category: json['category'] as String,
      level: json['level'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionText': questionText,
      'imageAsset': imageAsset,
      'correctAnswer': correctAnswer,
      'options': options,
      'category': category,
      'level': level,
    };
  }
}

/// Represents a quiz attempt/result
class QuizResult {
  final String questionId;
  final String selectedAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final DateTime timestamp;

  QuizResult({
    required this.questionId,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.timestamp,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      questionId: json['questionId'] as String,
      selectedAnswer: json['selectedAnswer'] as String,
      correctAnswer: json['correctAnswer'] as String,
      isCorrect: json['isCorrect'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedAnswer': selectedAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Represents a complete quiz session
class QuizSession {
  final String level;
  final String category;
  final List<QuizResult> results;
  final DateTime startTime;
  final DateTime? endTime;
  final double score;

  QuizSession({
    required this.level,
    required this.category,
    required this.results,
    required this.startTime,
    this.endTime,
    required this.score,
  });

  int get correctAnswers => results.where((r) => r.isCorrect).length;
  int get totalQuestions => results.length;
  bool get isCompleted => endTime != null;

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      level: json['level'] as String,
      category: json['category'] as String,
      results: (json['results'] as List)
          .map((r) => QuizResult.fromJson(r as Map<String, dynamic>))
          .toList(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String) 
          : null,
      score: (json['score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'category': category,
      'results': results.map((r) => r.toJson()).toList(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'score': score,
    };
  }
}

/// Quiz difficulty levels
enum QuizLevel {
  beginner,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case QuizLevel.beginner:
        return 'Beginner';
      case QuizLevel.intermediate:
        return 'Intermediate';
      case QuizLevel.advanced:
        return 'Advanced';
    }
  }
}

/// Quiz categories matching the app's learning sections
enum QuizCategory {
  letters,
  animals,
  fruits,
  vegetables,
  furniture,
  places,
  relations,
  professionals;

  String get displayName {
    switch (this) {
      case QuizCategory.letters:
        return 'Letters';
      case QuizCategory.animals:
        return 'Animals';
      case QuizCategory.fruits:
        return 'Fruits';
      case QuizCategory.vegetables:
        return 'Vegetables';
      case QuizCategory.furniture:
        return 'Furniture';
      case QuizCategory.places:
        return 'Places';
      case QuizCategory.relations:
        return 'Relations';
      case QuizCategory.professionals:
        return 'Professionals';
    }
  }
}