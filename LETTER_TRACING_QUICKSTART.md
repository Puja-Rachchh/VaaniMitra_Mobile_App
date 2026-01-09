# Letter Tracing Module - Quick Start Guide

## Integration Steps

### 1. Add Navigation Button to Your App

You can add the letter tracing feature to any existing screen in your app. Here's how:

#### Option A: Add to Level Selection Screen

In `level_selection_screen.dart`, add a button:

```dart
ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LetterTracingScreen(
          language: selectedLanguageCode,    // e.g., 'hi', 'gu', 'ta'
          languageName: selectedLanguageName, // e.g., 'Hindi', 'Gujarati'
        ),
      ),
    );
  },
  icon: Icon(Icons.edit),
  label: Text('Practice Letter Writing'),
)
```

#### Option B: Add to Beginner Learning Screen

In `beginner_learning_screen.dart`, add a card or button:

```dart
Card(
  child: ListTile(
    leading: Icon(Icons.draw, color: Colors.blue),
    title: Text('Letter Tracing'),
    subtitle: Text('Learn to write letters'),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LetterTracingScreen(
            language: widget.selectedLanguage,
            languageName: widget.languageName,
          ),
        ),
      );
    },
  ),
)
```

### 2. Required Imports

Make sure to import the screen where you're adding the button:

```dart
import 'screens/letter_tracing_screen.dart';
```

### 3. Supported Languages

Current supported languages (more can be added):

| Language Code | Language Name | Status |
|--------------|---------------|---------|
| `hi` | Hindi | ✅ Complete (10 vowels) |
| `gu` | Gujarati | ⚠️ Placeholder (ready to add) |
| `ta` | Tamil | ⚠️ Placeholder (ready to add) |
| `te` | Telugu | ⚠️ Placeholder (ready to add) |
| `kn` | Kannada | ⚠️ Placeholder (ready to add) |
| `ml` | Malayalam | ⚠️ Placeholder (ready to add) |
| `mr` | Marathi | ⚠️ Placeholder (ready to add) |
| `bn` | Bengali | ⚠️ Placeholder (ready to add) |
| `pa` | Punjabi | ⚠️ Placeholder (ready to add) |

### 4. User Flow

```
User selects language → Letter Tracing Screen opens
    ↓
Shows first uncompleted letter with dotted guide
    ↓
User traces the letter on canvas
    ↓
User clicks "Check" button
    ↓
System validates tracing (80% accuracy required)
    ↓
    ├─ Success: Green feedback + "Next" button enabled
    │     ↓
    │   Click "Next" → Move to next letter
    │
    └─ Fail: Red feedback + suggestions
          ↓
        Click "Reset" → Try again
```

### 5. Testing the Module

1. **Run the app**:
   ```bash
   flutter run
   ```

2. **Navigate to the letter tracing screen** using your integration button

3. **Test basic functionality**:
   - Trace a letter following the dotted guide
   - Click "Check" to validate
   - Click "Reset" to clear and retry
   - Complete a letter to enable "Next"
   - Check statistics in the top-right menu

### 6. Customization Options

#### Change Accuracy Threshold

In `tracing_validator.dart`:
```dart
static const double defaultAccuracyThreshold = 0.80; // 80% (adjust as needed)
```

#### Change Stroke Detection Distance

In `tracing_validator.dart`:
```dart
static const double maxDistanceFromPath = 30.0; // pixels (increase for easier tracing)
```

#### Customize Visual Colors

In `tracing_canvas.dart`:
```dart
// Reference path color (dotted guide)
..color = Colors.grey.withOpacity(0.5)  // Change to your preference

// Success color
strokeColor = Colors.green;  // Change to your brand color

// Error color
strokeColor = Colors.red;    // Change to your brand color
```

### 7. Adding More Letters

To add consonants or more letters for Hindi:

1. Open `lib/screens/letter_tracing_screen.dart`
2. Find the `_getHindiVowels()` method
3. Add more letters:

```dart
TraceableLetter(
  character: 'क',  // Your letter
  language: 'hi',
  pronunciation: 'ka',
  transliteration: 'ka',
  referenceSegments: [
    ReferencePathSegment(
      points: _generateStraightPath(
        start: const Offset(100, 100),
        end: const Offset(200, 100),
      ),
      order: 1,
    ),
    // Add more stroke segments as needed
  ],
),
```

### 8. Adding a New Language

Example: Adding Malayalam letters

1. Open `lib/utils/letter_data_helper.dart`

2. Add language to supported list:
```dart
static List<Map<String, String>> getSupportedLanguages() {
  return [
    // ... existing languages
    {'code': 'ml', 'name': 'Malayalam'},
  ];
}
```

3. Create letter data:
```dart
static List<TraceableLetter> getMalayalamVowels() {
  return [
    _createSimpleLetter('അ', 'ml', 'a', 'a'),
    _createSimpleLetter('ആ', 'ml', 'aa', 'aa'),
    // Add more letters...
  ];
}
```

4. Add to switch case:
```dart
static List<TraceableLetter> getLettersForLanguage(String languageCode, {bool vowelsOnly = true}) {
  switch (languageCode) {
    // ... existing cases
    case 'ml':
      return getMalayalamLetters(vowelsOnly: vowelsOnly);
    // ...
  }
}
```

5. Update TTS language mapping in `letter_tracing_screen.dart`:
```dart
final languageMap = {
  // ... existing mappings
  'ml': 'ml-IN',
};
```

### 9. Example: Complete Integration in Beginner Screen

```dart
import 'package:flutter/material.dart';
import 'letter_tracing_screen.dart';

class BeginnerLearningScreen extends StatelessWidget {
  final String selectedLanguage;
  final String languageName;

  const BeginnerLearningScreen({
    Key? key,
    required this.selectedLanguage,
    required this.languageName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$languageName - Beginner Level'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16),
        children: [
          // Existing learning cards...
          
          // Add Letter Tracing Card
          _buildLearningCard(
            context,
            icon: Icons.draw,
            title: 'Letter Tracing',
            subtitle: 'Write letters',
            color: Colors.purple,
            onTap: () {
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
          ),
        ],
      ),
    );
  }

  Widget _buildLearningCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 10. Troubleshooting

**Problem**: Letter paths don't look correct
- **Solution**: Adjust the Offset coordinates in the referenceSegments
- Use a canvas size reference of approximately 300x300 logical pixels
- Center should be around Offset(150, 150)

**Problem**: Validation is too strict/lenient
- **Solution**: Adjust `maxDistanceFromPath` in `tracing_validator.dart`
- Increase for easier validation (e.g., 40.0)
- Decrease for stricter validation (e.g., 20.0)

**Problem**: TTS not working for a language
- **Solution**: Verify the language code in `_setTtsLanguage()` method
- Check if device has TTS support for that language
- Test with `flutter_tts` example

**Problem**: Progress not saving
- **Solution**: Ensure `SharedPreferences` is initialized
- Check for async/await issues
- Clear app data and try again

### 11. Performance Tips

- Keep reference path points between 20-50 for smooth performance
- Use `enableRealTimeFeedback: false` if experiencing lag
- Consider reducing canvas refresh rate for lower-end devices

### 12. Next Steps

After basic integration:

1. ✅ Test with multiple users for UX feedback
2. ✅ Add more letters (consonants, conjuncts)
3. ✅ Implement additional languages
4. ✅ Add achievements/gamification
5. ✅ Consider adding stroke order enforcement
6. ✅ Add difficulty levels (larger/smaller letters)

## Support

For issues or questions:
- Check [LETTER_TRACING_MODULE.md](LETTER_TRACING_MODULE.md) for detailed documentation
- Review code comments in each file
- Test with the provided Hindi vowels example

---

**Happy Coding!** 🎉

The module is production-ready and can be extended to support all Indian languages with proper letter paths.
