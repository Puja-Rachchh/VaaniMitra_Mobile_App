# Letter Tracing Module for VaaniMitra

## Overview
This module provides an interactive letter tracing feature for learning Indian language scripts. Users can trace letters using touch input, receive real-time feedback, and track their progress as they learn to write characters in different Indian languages.

## Features Implemented

### ✅ Core Features
- **Interactive Letter Tracing**: Touch-based drawing on canvas using GestureDetector
- **Visual Guide**: Dotted/faint reference paths showing correct letter strokes
- **Stroke Validation**: Real-time comparison of user strokes with reference paths
- **Accuracy Scoring**: Based on coverage and direction similarity
- **Progress Tracking**: Persistent storage using SharedPreferences
- **Multi-Language Support**: Extensible architecture for Hindi, Gujarati, Tamil, and more
- **Audio Pronunciation**: Text-to-speech for each letter
- **Visual Feedback**: Green for correct, red for incorrect tracing

### ✅ Architecture Components

#### 1. **Models** (`lib/models/letter_tracing_models.dart`)
- `StrokePoint`: Individual point in a stroke path
- `Stroke`: Complete stroke with start/end times
- `ReferencePathSegment`: Predefined path for letter strokes
- `TraceableLetter`: Letter data with reference paths and metadata
- `TracingValidationResult`: Validation results with scores
- `LetterProgress`: User progress for each letter

#### 2. **Validation Logic** (`lib/utils/tracing_validator.dart`)
- `TracingValidator`: Validates user strokes against reference paths
  - Coverage Score: Measures how much of the reference path is traced
  - Direction Score: Measures stroke direction accuracy using cosine similarity
  - Overall Accuracy: Weighted combination (70% coverage + 30% direction)
  - Default threshold: 80% accuracy for successful completion
  - Configurable tolerance and distance parameters

#### 3. **Progress Management** (`lib/services/letter_progress_manager.dart`)
- `LetterProgressManager`: Manages letter completion and persistence
  - Save/load progress for individual letters
  - Track attempts, best scores, completion status
  - Automatic progression to next letter
  - Statistics: completion rate, average score, total attempts
  - Import/export functionality for backup

#### 4. **UI Widgets** (`lib/widgets/tracing_canvas.dart`)
- `TracingPainter`: CustomPainter for rendering reference paths and strokes
  - Draws dotted reference guides
  - Shows start (green) and end (red) indicators
  - Renders user strokes with color feedback
  - Supports visual highlights for correct/incorrect tracing
  
- `TracingCanvas`: Interactive canvas widget
  - Captures touch input via GestureDetector
  - Tracks current and completed strokes
  - Provides real-time visual feedback
  - Exposes methods: `clearStrokes()`, `showSuccessFeedback()`, `showErrorFeedback()`

#### 5. **Main Screen** (`lib/screens/letter_tracing_screen.dart`)
- `LetterTracingScreen`: Complete UI for letter tracing
  - Progress bar showing completion percentage
  - Letter display with audio playback
  - Interactive tracing canvas
  - Control buttons: Reset, Check, Next
  - Feedback display with accuracy scores
  - Statistics dialog with progress summary
  - Reset confirmation dialog

#### 6. **Helper Utilities** (`lib/utils/letter_data_helper.dart`)
- `LetterDataHelper`: Letter data generation for all supported languages
  - Path generation utilities (circular, straight, curved, S-curve)
  - Pre-built letter sets for Hindi, Gujarati, Tamil, Telugu, Kannada
  - Language support checking
  - Extensible for adding more languages

## Usage

### Basic Navigation
```dart
// Navigate to letter tracing screen from any screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => LetterTracingScreen(
      language: 'hi',        // Language code (hi, gu, ta, etc.)
      languageName: 'Hindi', // Display name
    ),
  ),
);
```

### Example Integration in Level Selection
```dart
// Add a button to level selection screen
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LetterTracingScreen(
          language: selectedLanguage,
          languageName: languageName,
        ),
      ),
    );
  },
  child: Text('Practice Letter Writing'),
)
```

## Data Structure

### Hindi Vowels Example
The module includes 10 Hindi vowels (स्वर) with predefined tracing paths:
- अ (a), आ (aa), इ (i), ई (ee), उ (u), ऊ (oo), ए (e), ऐ (ai), ओ (o), औ (au)

Each letter has:
- **Character**: The actual letter
- **Pronunciation**: How it sounds
- **Transliteration**: Roman script equivalent
- **Reference Segments**: Ordered stroke paths for tracing

### Adding New Letters
To add letters for a new language:

```dart
// In letter_data_helper.dart
static List<TraceableLetter> getNewLanguageVowels() {
  return [
    TraceableLetter(
      character: 'X',
      language: 'xx',
      pronunciation: 'ex',
      transliteration: 'x',
      referenceSegments: [
        ReferencePathSegment(
          points: LetterDataHelper.generateStraightPath(
            start: Offset(100, 100),
            end: Offset(200, 200),
          ),
          order: 1,
          strokeDirection: 'top-to-bottom',
        ),
      ],
    ),
  ];
}
```

## Validation Algorithm

### Coverage Score Calculation
1. Collect all reference points from letter segments
2. Collect all user stroke points
3. For each reference point, check if any user point is within `maxDistanceFromPath` (default: 30px)
4. Coverage Score = (Covered Points / Total Reference Points)

### Direction Score Calculation
1. For each user stroke, find the closest reference segment
2. Calculate direction vectors (start to end point)
3. Compute cosine similarity between vectors
4. Apply direction tolerance threshold (default: 0.7)
5. Direction Score = Average similarity across all strokes

### Overall Accuracy
- Accuracy = (Coverage × 0.7) + (Direction × 0.3)
- Success = Accuracy >= Threshold (default: 0.80 or 80%)

## Customization

### Adjust Validation Thresholds
```dart
// In tracing_validator.dart
static const double defaultAccuracyThreshold = 0.80;  // 80%
static const double maxDistanceFromPath = 30.0;       // pixels
static const double directionTolerance = 0.7;         // cosine similarity
```

### Customize Visual Appearance
```dart
// In tracing_canvas.dart - TracingPainter class

// Reference path style
final paint = Paint()
  ..color = Colors.grey.withOpacity(0.5)  // Change color/opacity
  ..strokeWidth = 20.0                     // Change thickness
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round;

// User stroke style
final paint = Paint()
  ..color = strokeColor                    // Dynamic color
  ..strokeWidth = 8.0                      // Change thickness
  ..style = PaintingStyle.stroke;
```

### Add New Languages
1. Add language entry to `LetterDataHelper.getSupportedLanguages()`
2. Create vowel/consonant methods in `LetterDataHelper`
3. Update `getLettersForLanguage()` switch case
4. Add TTS language mapping in `LetterTracingScreen._setTtsLanguage()`

## File Structure
```
lib/
├── models/
│   └── letter_tracing_models.dart       # Data models
├── services/
│   └── letter_progress_manager.dart     # Progress persistence
├── utils/
│   ├── tracing_validator.dart           # Validation logic
│   └── letter_data_helper.dart          # Letter data generation
├── widgets/
│   └── tracing_canvas.dart              # Canvas widget & painter
└── screens/
    └── letter_tracing_screen.dart       # Main UI screen
```

## Key Methods Reference

### TracingCanvas
```dart
void clearStrokes()              // Clear all drawn strokes
void showSuccessFeedback()       // Show green highlight
void showErrorFeedback()         // Show red highlight
void toggleReference()           // Show/hide reference path
List<Stroke> get strokes        // Get current strokes
```

### LetterProgressManager
```dart
Future<bool> saveProgress(LetterProgress progress)
LetterProgress? getProgress(String letterId)
Future<bool> updateProgress({letterId, score, completed})
Future<int> moveToNextLetter(List<TraceableLetter> letters)
Map<String, dynamic> getStatistics(List<TraceableLetter> letters)
```

### TracingValidator
```dart
static TracingValidationResult validate({
  required List<Stroke> userStrokes,
  required List<ReferencePathSegment> referenceSegments,
  double accuracyThreshold = defaultAccuracyThreshold,
})
```

## Performance Considerations

- **Stroke Sampling**: Reduce points in reference paths for better performance
- **Real-time Validation**: Can be disabled via `enableRealTimeFeedback: false`
- **Path Optimization**: Use appropriate number of points (20-50) for smooth paths
- **Memory**: Progress data is stored locally, manageable for hundreds of letters

## Future Enhancements

### Potential Improvements
1. **Advanced Strokes**: Support for compound letters and conjuncts
2. **Stroke Order Validation**: Enforce correct stroke sequence
3. **Pressure Sensitivity**: Use stroke pressure for better validation
4. **Animations**: Show animated letter formation
5. **Handwriting Recognition**: ML-based character recognition
6. **Practice Modes**: Guided mode, timed mode, challenge mode
7. **Achievements**: Badges for milestones (10 letters, perfect scores, etc.)
8. **Cloud Sync**: Sync progress across devices

### Extending to Other Scripts
The architecture is designed to support:
- **Consonants**: Add consonant sets for each language
- **Conjuncts**: Multi-stroke complex characters
- **Numbers**: Indian language numerals
- **Special Characters**: Anusvara, visarga, etc.

## Dependencies

Required packages (already in pubspec.yaml):
```yaml
dependencies:
  flutter_tts: ^latest          # Text-to-speech
  shared_preferences: ^latest   # Local storage
```

## Testing

### Manual Testing Checklist
- [ ] Trace a letter successfully (green feedback)
- [ ] Trace incorrectly (red feedback, retry)
- [ ] Complete a letter (marked as completed)
- [ ] Progress to next letter automatically
- [ ] Check progress statistics
- [ ] Reset progress (confirmation dialog)
- [ ] Audio pronunciation works
- [ ] Canvas reset clears strokes
- [ ] Progress persists after app restart

### Test Coverage Areas
- Validation algorithm accuracy
- Progress persistence
- Canvas rendering
- Touch input handling
- Multi-language support

## Troubleshooting

### Common Issues

**Issue**: Validation always fails
- Check `maxDistanceFromPath` - may need to increase
- Verify reference path points are correctly defined
- Lower accuracy threshold temporarily for testing

**Issue**: Strokes don't appear on canvas
- Ensure GestureDetector is wrapping CustomPaint
- Check paint color is not transparent
- Verify stroke points are being collected

**Issue**: Progress not saving
- Check SharedPreferences initialization
- Verify JSON serialization/deserialization
- Check for async/await issues

**Issue**: TTS not working
- Verify flutter_tts is initialized
- Check language code mapping
- Ensure device TTS engine supports the language

## Contributing

To add support for new languages:
1. Research proper stroke order for the script
2. Define reference paths using helper methods
3. Add letter data to `LetterDataHelper`
4. Test validation thresholds
5. Update documentation

## License
Part of VaaniMitra - Multilingual Learning App

---

**Created by**: GitHub Copilot  
**Date**: January 2026  
**Version**: 1.0.0
