import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/quiz_models.dart';
import '../services/translation_service.dart';
import '../services/user_preferences.dart';

/// Service for managing quiz functionality
class QuizService {
  static final Random _random = Random();
  
  /// Base quiz questions in English
  static final Map<String, List<Map<String, dynamic>>> _baseQuestions = {
    'letters': [
      {
        'id': 'letters_1',
        'questionText': 'What is this letter?',
        'imageAsset': '', // No letter images available
        'correctAnswer': 'A',
        'options': ['A', 'B', 'C', 'D'],
      },
      {
        'id': 'letters_2',
        'questionText': 'Which letter comes after B?',
        'imageAsset': '',
        'correctAnswer': 'C',
        'options': ['A', 'C', 'D', 'E'],
      },
      {
        'id': 'letters_3',
        'questionText': 'What letter is the third letter of the alphabet?',
        'imageAsset': '',
        'correctAnswer': 'C',
        'options': ['B', 'C', 'D', 'E'],
      },
      {
        'id': 'letters_4',
        'questionText': 'Which letter comes before D?',
        'imageAsset': '',
        'correctAnswer': 'C',
        'options': ['B', 'C', 'E', 'F'],
      },
      {
        'id': 'letters_5',
        'questionText': 'What is the fifth letter of the alphabet?',
        'imageAsset': '',
        'correctAnswer': 'E',
        'options': ['D', 'E', 'F', 'G'],
      },
      {
        'id': 'letters_6',
        'questionText': 'Which letter comes after H?',
        'imageAsset': '',
        'correctAnswer': 'I',
        'options': ['G', 'H', 'I', 'J'],
      },
      {
        'id': 'letters_7',
        'questionText': 'What is the tenth letter of the alphabet?',
        'imageAsset': '',
        'correctAnswer': 'J',
        'options': ['I', 'J', 'K', 'L'],
      },
      {
        'id': 'letters_8',
        'questionText': 'Which letter comes before M?',
        'imageAsset': '',
        'correctAnswer': 'L',
        'options': ['K', 'L', 'N', 'O'],
      },
    ],
    'animals': [
      {
        'id': 'animals_1',
        'questionText': 'What animal is this?',
        'imageAsset': 'assets/animals/dog.jpg',
        'correctAnswer': 'Dog',
        'options': ['Cat', 'Dog', 'Horse', 'Cow'],
      },
      {
        'id': 'animals_2',
        'questionText': 'Which animal barks?',
        'imageAsset': 'assets/animals/dog.jpg',
        'correctAnswer': 'Dog',
        'options': ['Cat', 'Dog', 'Horse', 'Cow'],
      },
      {
        'id': 'animals_3',
        'questionText': 'What animal is this?',
        'imageAsset': 'assets/animals/cat.jpg',
        'correctAnswer': 'Cat',
        'options': ['Cat', 'Dog', 'Horse', 'Cow'],
      },
      {
        'id': 'animals_4',
        'questionText': 'Which animal gives milk?',
        'imageAsset': 'assets/animals/cow.jpg',
        'correctAnswer': 'Cow',
        'options': ['Cat', 'Dog', 'Horse', 'Cow'],
      },
      {
        'id': 'animals_5',
        'questionText': 'What animal is this?',
        'imageAsset': 'assets/animals/elephant.jpg',
        'correctAnswer': 'Elephant',
        'options': ['Lion', 'Tiger', 'Elephant', 'Bear'],
      },
      {
        'id': 'animals_6',
        'questionText': 'Which animal is the king of the jungle?',
        'imageAsset': 'assets/animals/lion.jpg',
        'correctAnswer': 'Lion',
        'options': ['Lion', 'Tiger', 'Elephant', 'Bear'],
      },
      {
        'id': 'animals_7',
        'questionText': 'What animal is this?',
        'imageAsset': 'assets/animals/fish.jpeg',
        'correctAnswer': 'Fish',
        'options': ['Bird', 'Fish', 'Frog', 'Snake'],
      },
      {
        'id': 'animals_8',
        'questionText': 'Which animal lives in water?',
        'imageAsset': 'assets/animals/fish.jpeg',
        'correctAnswer': 'Fish',
        'options': ['Bird', 'Fish', 'Frog', 'Snake'],
      },
    ],
    'fruits': [
      {
        'id': 'fruits_1',
        'questionText': 'What fruit is this?',
        'imageAsset': 'assets/fruits/apple.jpeg',
        'correctAnswer': 'Apple',
        'options': ['Apple', 'Banana', 'Orange', 'Grapes'],
      },
      {
        'id': 'fruits_2',
        'questionText': 'Which fruit is yellow?',
        'imageAsset': 'assets/fruits/banana.jpg',
        'correctAnswer': 'Banana',
        'options': ['Apple', 'Banana', 'Orange', 'Grapes'],
      },
      {
        'id': 'fruits_3',
        'questionText': 'What fruit is this?',
        'imageAsset': 'assets/fruits/orange.jpeg',
        'correctAnswer': 'Orange',
        'options': ['Apple', 'Banana', 'Orange', 'Grapes'],
      },
      {
        'id': 'fruits_4',
        'questionText': 'Which fruit is purple?',
        'imageAsset': 'assets/fruits/grapes.jpeg',
        'correctAnswer': 'Grapes',
        'options': ['Apple', 'Banana', 'Orange', 'Grapes'],
      },
      {
        'id': 'fruits_5',
        'questionText': 'What fruit is this?',
        'imageAsset': 'assets/fruits/mango.jpg',
        'correctAnswer': 'Mango',
        'options': ['Orange', 'Mango', 'Pear', 'Papaya'],
      },
      {
        'id': 'fruits_6',
        'questionText': 'Which fruit is red?',
        'imageAsset': 'assets/fruits/strawberry.jpeg',
        'correctAnswer': 'Strawberry',
        'options': ['Banana', 'Grapes', 'Strawberry', 'Orange'],
      },
      {
        'id': 'fruits_7',
        'questionText': 'What fruit is this?',
        'imageAsset': 'assets/fruits/watermelon.jpeg',
        'correctAnswer': 'Watermelon',
        'options': ['Mango', 'Papaya', 'Watermelon', 'Pineapple'],
      },
      {
        'id': 'fruits_8',
        'questionText': 'Which fruit has spikes?',
        'imageAsset': 'assets/fruits/pineapple.jpeg',
        'correctAnswer': 'Pineapple',
        'options': ['Mango', 'Banana', 'Pineapple', 'Orange'],
      },
    ],
    'vegetables': [
      {
        'id': 'vegetables_1',
        'questionText': 'What vegetable is this?',
        'imageAsset': 'assets/vegetables/potato.jpg',
        'correctAnswer': 'Potato',
        'options': ['Potato', 'Onion', 'Tomato', 'Cabbage'],
      },
      {
        'id': 'vegetables_2',
        'questionText': 'Which vegetable is red?',
        'imageAsset': 'assets/vegetables/tomato.jpeg',
        'correctAnswer': 'Tomato',
        'options': ['Potato', 'Onion', 'Tomato', 'Cabbage'],
      },
      {
        'id': 'vegetables_3',
        'questionText': 'What vegetable is this?',
        'imageAsset': 'assets/vegetables/onion.jpeg',
        'correctAnswer': 'Onion',
        'options': ['Potato', 'Onion', 'Tomato', 'Cabbage'],
      },
      {
        'id': 'vegetables_4',
        'questionText': 'Which vegetable is green?',
        'imageAsset': 'assets/vegetables/cabbage.jpeg',
        'correctAnswer': 'Cabbage',
        'options': ['Potato', 'Onion', 'Tomato', 'Cabbage'],
      },
      {
        'id': 'vegetables_5',
        'questionText': 'What vegetable is this?',
        'imageAsset': 'assets/vegetables/carrot.jpeg',
        'correctAnswer': 'Carrot',
        'options': ['Carrot', 'Radish', 'Brinjal', 'Capsicum'],
      },
      {
        'id': 'vegetables_6',
        'questionText': 'Which vegetable is orange?',
        'imageAsset': 'assets/vegetables/carrot.jpeg',
        'correctAnswer': 'Carrot',
        'options': ['Carrot', 'Radish', 'Brinjal', 'Capsicum'],
      },
      {
        'id': 'vegetables_7',
        'questionText': 'What vegetable is this?',
        'imageAsset': 'assets/vegetables/brinjal.jpeg',
        'correctAnswer': 'Brinjal',
        'options': ['Carrot', 'Radish', 'Brinjal', 'Capsicum'],
      },
      {
        'id': 'vegetables_8',
        'questionText': 'Which vegetable is purple?',
        'imageAsset': 'assets/vegetables/brinjal.jpeg',
        'correctAnswer': 'Brinjal',
        'options': ['Carrot', 'Radish', 'Brinjal', 'Capsicum'],
      },
    ],
    'furniture': [
      {
        'id': 'furniture_1',
        'questionText': 'What furniture is this?',
        'imageAsset': 'assets/furniture/chair.jpg',
        'correctAnswer': 'Chair',
        'options': ['Chair', 'Table', 'Bed', 'Sofa'],
      },
      {
        'id': 'furniture_2',
        'questionText': 'Where do you sit?',
        'imageAsset': 'assets/furniture/chair.jpg',
        'correctAnswer': 'Chair',
        'options': ['Chair', 'Table', 'Bed', 'Sofa'],
      },
      {
        'id': 'furniture_3',
        'questionText': 'What furniture is this?',
        'imageAsset': 'assets/furniture/table.jpg',
        'correctAnswer': 'Table',
        'options': ['Chair', 'Table', 'Bed', 'Sofa'],
      },
      {
        'id': 'furniture_4',
        'questionText': 'Where do you eat?',
        'imageAsset': 'assets/furniture/table.jpg',
        'correctAnswer': 'Table',
        'options': ['Chair', 'Table', 'Bed', 'Sofa'],
      },
      {
        'id': 'furniture_5',
        'questionText': 'What furniture is this?',
        'imageAsset': 'assets/furniture/bed.jpg',
        'correctAnswer': 'Bed',
        'options': ['Chair', 'Table', 'Bed', 'Sofa'],
      },
      {
        'id': 'furniture_6',
        'questionText': 'Where do you sleep?',
        'imageAsset': 'assets/furniture/bed.jpg',
        'correctAnswer': 'Bed',
        'options': ['Chair', 'Table', 'Bed', 'Sofa'],
      },
      {
        'id': 'furniture_7',
        'questionText': 'What furniture is this?',
        'imageAsset': 'assets/furniture/sofa.jpg',
        'correctAnswer': 'Sofa',
        'options': ['Chair', 'Table', 'Bed', 'Sofa'],
      },
      {
        'id': 'furniture_8',
        'questionText': 'Where do you relax?',
        'imageAsset': 'assets/furniture/sofa.jpg',
        'correctAnswer': 'Sofa',
        'options': ['Chair', 'Table', 'Bed', 'Sofa'],
      },
    ],
    'places': [
      {
        'id': 'places_1',
        'questionText': 'What place is this?',
        'imageAsset': 'assets/places/home.jpg',
        'correctAnswer': 'Home',
        'options': ['Home', 'School', 'Hospital', 'Market'],
      },
      {
        'id': 'places_2',
        'questionText': 'Where do you live?',
        'imageAsset': 'assets/places/home.jpg',
        'correctAnswer': 'Home',
        'options': ['Home', 'School', 'Hospital', 'Market'],
      },
      {
        'id': 'places_3',
        'questionText': 'What place is this?',
        'imageAsset': 'assets/places/school.jpg',
        'correctAnswer': 'School',
        'options': ['Home', 'School', 'Hospital', 'Market'],
      },
      {
        'id': 'places_4',
        'questionText': 'Where do you study?',
        'imageAsset': 'assets/places/school.jpg',
        'correctAnswer': 'School',
        'options': ['Home', 'School', 'Hospital', 'Market'],
      },
      {
        'id': 'places_5',
        'questionText': 'What place is this?',
        'imageAsset': 'assets/places/hospital.jpg',
        'correctAnswer': 'Hospital',
        'options': ['Home', 'School', 'Hospital', 'Market'],
      },
      {
        'id': 'places_6',
        'questionText': 'Where do you go when sick?',
        'imageAsset': 'assets/places/hospital.jpg',
        'correctAnswer': 'Hospital',
        'options': ['Home', 'School', 'Hospital', 'Market'],
      },
      {
        'id': 'places_7',
        'questionText': 'What place is this?',
        'imageAsset': 'assets/places/market.jpg',
        'correctAnswer': 'Market',
        'options': ['Home', 'School', 'Hospital', 'Market'],
      },
      {
        'id': 'places_8',
        'questionText': 'Where do you buy things?',
        'imageAsset': 'assets/places/market.jpg',
        'correctAnswer': 'Market',
        'options': ['Home', 'School', 'Hospital', 'Market'],
      },
    ],
    'professionals': [
      {
        'id': 'professionals_1',
        'questionText': 'What is this profession?',
        'imageAsset': 'assets/professionals/doctor.jpg',
        'correctAnswer': 'Doctor',
        'options': ['Doctor', 'Teacher', 'Engineer', 'Farmer'],
      },
      {
        'id': 'professionals_2',
        'questionText': 'Who treats patients?',
        'imageAsset': 'assets/professionals/doctor.jpg',
        'correctAnswer': 'Doctor',
        'options': ['Doctor', 'Teacher', 'Engineer', 'Farmer'],
      },
      {
        'id': 'professionals_3',
        'questionText': 'What is this profession?',
        'imageAsset': 'assets/professionals/teacher.jpg',
        'correctAnswer': 'Teacher',
        'options': ['Doctor', 'Teacher', 'Engineer', 'Farmer'],
      },
      {
        'id': 'professionals_4',
        'questionText': 'Who teaches students?',
        'imageAsset': 'assets/professionals/teacher.jpg',
        'correctAnswer': 'Teacher',
        'options': ['Doctor', 'Teacher', 'Engineer', 'Farmer'],
      },
      {
        'id': 'professionals_5',
        'questionText': 'What is this profession?',
        'imageAsset': 'assets/professionals/engineer.jpg',
        'correctAnswer': 'Engineer',
        'options': ['Doctor', 'Teacher', 'Engineer', 'Farmer'],
      },
      {
        'id': 'professionals_6',
        'questionText': 'Who builds bridges?',
        'imageAsset': 'assets/professionals/engineer.jpg',
        'correctAnswer': 'Engineer',
        'options': ['Doctor', 'Teacher', 'Engineer', 'Farmer'],
      },
      {
        'id': 'professionals_7',
        'questionText': 'What is this profession?',
        'imageAsset': 'assets/professionals/farmer.jpg',
        'correctAnswer': 'Farmer',
        'options': ['Doctor', 'Teacher', 'Engineer', 'Farmer'],
      },
      {
        'id': 'professionals_8',
        'questionText': 'Who grows crops?',
        'imageAsset': 'assets/professionals/farmer.jpg',
        'correctAnswer': 'Farmer',
        'options': ['Doctor', 'Teacher', 'Engineer', 'Farmer'],
      },
    ],
    'relations': [
      {
        'id': 'relations_1',
        'questionText': 'What relation is this?',
        'imageAsset': 'assets/relations/father.jpg',
        'correctAnswer': 'Father',
        'options': ['Father', 'Mother', 'Brother', 'Sister'],
      },
      {
        'id': 'relations_2',
        'questionText': 'Who is the male parent?',
        'imageAsset': 'assets/relations/father.jpg',
        'correctAnswer': 'Father',
        'options': ['Father', 'Mother', 'Brother', 'Sister'],
      },
      {
        'id': 'relations_3',
        'questionText': 'What relation is this?',
        'imageAsset': 'assets/relations/mother.jpg',
        'correctAnswer': 'Mother',
        'options': ['Father', 'Mother', 'Brother', 'Sister'],
      },
      {
        'id': 'relations_4',
        'questionText': 'Who is the female parent?',
        'imageAsset': 'assets/relations/mother.jpg',
        'correctAnswer': 'Mother',
        'options': ['Father', 'Mother', 'Brother', 'Sister'],
      },
      {
        'id': 'relations_5',
        'questionText': 'What relation is this?',
        'imageAsset': 'assets/relations/brother.jpg',
        'correctAnswer': 'Brother',
        'options': ['Father', 'Mother', 'Brother', 'Sister'],
      },
      {
        'id': 'relations_6',
        'questionText': 'Who is your male sibling?',
        'imageAsset': 'assets/relations/brother.jpg',
        'correctAnswer': 'Brother',
        'options': ['Father', 'Mother', 'Brother', 'Sister'],
      },
      {
        'id': 'relations_7',
        'questionText': 'What relation is this?',
        'imageAsset': 'assets/relations/sister.jpg',
        'correctAnswer': 'Sister',
        'options': ['Father', 'Mother', 'Brother', 'Sister'],
      },
      {
        'id': 'relations_8',
        'questionText': 'Who is your female sibling?',
        'imageAsset': 'assets/relations/sister.jpg',
        'correctAnswer': 'Sister',
        'options': ['Father', 'Mother', 'Brother', 'Sister'],
      },
    ],
  };

  static Future<List<QuizQuestion>> generateQuiz({
    required String category,
    required String level,
    int questionCount = 5,
  }) async {
    try {
      debugPrint('🎯 Generating quiz for category: $category, level: $level');
      
      final categoryQuestions = _baseQuestions[category];
      if (categoryQuestions == null || categoryQuestions.isEmpty) {
        debugPrint('❌ No questions found for category: $category');
        return [];
      }

      // Get target language for answer options (keep questions in English)
      final targetLanguage = await UserPreferences.getTargetLanguage();
      debugPrint('🌍 Target language: $targetLanguage');

      // Shuffle and select random questions
      final shuffledQuestions = List<Map<String, dynamic>>.from(categoryQuestions);
      shuffledQuestions.shuffle(_random);
      
      final selectedQuestions = shuffledQuestions.take(questionCount).toList();
      debugPrint('📝 Selected ${selectedQuestions.length} questions');

      // Convert to QuizQuestion objects and translate only answer options
      final List<QuizQuestion> quizQuestions = [];
      
      for (final questionData in selectedQuestions) {
        try {
          // Keep question text in English
          final questionText = questionData['questionText'] as String;

          // Translate answer options to target language ONLY (no English mixing)
          final originalOptions = List<String>.from(questionData['options'] as List);
          final List<String> translatedOptions = [];
          
          for (final option in originalOptions) {
            if (targetLanguage != null && targetLanguage != 'en') {
              final translatedOption = await TranslationService.translateText(option, targetLanguage, 'en');
              translatedOptions.add(translatedOption);
            } else {
              translatedOptions.add(option);
            }
          }

          // Translate correct answer to target language ONLY (no English mixing)
          final String translatedCorrectAnswer;
          if (targetLanguage != null && targetLanguage != 'en') {
            translatedCorrectAnswer = await TranslationService.translateText(
              questionData['correctAnswer'] as String,
              targetLanguage,
              'en',
            );
          } else {
            translatedCorrectAnswer = questionData['correctAnswer'] as String;
          }

          final quizQuestion = QuizQuestion(
            id: questionData['id'] as String,
            questionText: questionText, // Keep in English
            imageAsset: questionData['imageAsset'] as String,
            correctAnswer: translatedCorrectAnswer, // Translate to target language
            options: translatedOptions, // Translate to target language
            category: category,
            level: level,
          );

          quizQuestions.add(quizQuestion);
          debugPrint('✅ Created question: ${quizQuestion.id}');
          
        } catch (e) {
          debugPrint('⚠️ Error creating question ${questionData['id']}: $e');
          // Skip questions that fail to translate to maintain target language consistency
          continue;
        }
      }

      debugPrint('🎯 Generated ${quizQuestions.length} quiz questions');
      return quizQuestions;
      
    } catch (e) {
      debugPrint('❌ Error generating quiz: $e');
      return [];
    }
  }

  /// Calculate quiz score
  static double calculateScore(List<QuizResult> results) {
    if (results.isEmpty) return 0.0;
    
    final correctAnswers = results.where((r) => r.isCorrect).length;
    return (correctAnswers / results.length) * 100;
  }

  /// Get quiz categories based on available screens
  static List<String> getAvailableCategories() {
    return _baseQuestions.keys.toList();
  }

  /// Check if a category has questions
  static bool hasQuestionsForCategory(String category) {
    return _baseQuestions.containsKey(category) && 
           _baseQuestions[category]!.isNotEmpty;
  }

  /// Get total number of questions for a category
  static int getTotalQuestionsForCategory(String category) {
    return _baseQuestions[category]?.length ?? 0;
  }
}