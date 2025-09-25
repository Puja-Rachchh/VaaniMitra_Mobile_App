import 'package:flutter/material.dart';
import '../services/translation_service.dart';
import '../services/user_preferences.dart';

class NewLanguageSelectionScreen extends StatefulWidget {
  const NewLanguageSelectionScreen({super.key});

  @override
  State<NewLanguageSelectionScreen> createState() => _NewLanguageSelectionScreenState();
}

class _NewLanguageSelectionScreenState extends State<NewLanguageSelectionScreen> {
  String? selectedKnownLanguage;
  String? selectedTargetLanguage;
  bool isSelectingKnown = true;
  final languages = TranslationService.getSupportedLanguages();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFC2E9FB), Color(0xFFA1C4FD)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                const SizedBox(height: 20),
                Text(
                  isSelectingKnown 
                    ? 'What language do you know?' 
                    : 'What language do you want to learn?',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                if (selectedKnownLanguage != null && isSelectingKnown)
                  Text(
                    'Known: ${TranslationService.getLanguageFlag(selectedKnownLanguage!)} ${languages[selectedKnownLanguage!]}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6C5CE7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (selectedTargetLanguage != null && !isSelectingKnown)
                  Text(
                    'Learning: ${TranslationService.getLanguageFlag(selectedTargetLanguage!)} ${languages[selectedTargetLanguage!]}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF6C5CE7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 20),
                ...languages.entries
                    .where((entry) {
                      final languageCode = entry.key;
                      // Don't show the already selected language in the opposite selection
                      if (isSelectingKnown && selectedTargetLanguage == languageCode) {
                        return false;
                      }
                      if (!isSelectingKnown && selectedKnownLanguage == languageCode) {
                        return false;
                      }
                      return true;
                    })
                    .map((entry) {
                      final languageCode = entry.key;
                      final languageName = entry.value;
                      final isSelected = isSelectingKnown 
                        ? selectedKnownLanguage == languageCode
                        : selectedTargetLanguage == languageCode;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Card(
                          elevation: isSelected ? 10 : 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: isSelected 
                              ? const BorderSide(color: Color(0xFF6C5CE7), width: 3)
                              : BorderSide.none,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(15),
                            onTap: () => _selectLanguage(languageCode),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                        ? const Color(0xFF6C5CE7).withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Center(
                                      child: Text(
                                        TranslationService.getLanguageFlag(languageCode),
                                        style: const TextStyle(fontSize: 30),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          languageName,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected 
                                              ? const Color(0xFF6C5CE7)
                                              : const Color(0xFF2C3E50),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          _getLanguageScript(languageCode),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontFamily: _getLanguageFont(languageCode),
                                            color: isSelected 
                                              ? const Color(0xFF6C5CE7)
                                              : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF6C5CE7),
                                      size: 30,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                    .toList(),
                const SizedBox(height: 30),
                // Button Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      if (isSelectingKnown && selectedKnownLanguage != null)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isSelectingKnown = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text(
                            'Next: Choose Learning Language',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      if (!isSelectingKnown && selectedTargetLanguage != null) ...[
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    isSelectingKnown = true;
                                    selectedTargetLanguage = null;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text('Back'),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _saveLanguagesAndContinue,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: const Text('Continue'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectLanguage(String languageCode) {
    setState(() {
      if (isSelectingKnown) {
        selectedKnownLanguage = languageCode;
      } else {
        selectedTargetLanguage = languageCode;
      }
    });
  }

  String _getLanguageScript(String languageCode) {
    const scripts = {
      'hi': 'हिंदी भाषा',
      'en': 'English Language',
      'ta': 'தமிழ் மொழி',
      'te': 'తెలుగు భాష',
      'mr': 'मराठी भाषा',
      'bn': 'বাংলা ভাষা',
      'gu': 'ગુજરાતી ભાષા',
      'kn': 'ಕನ್ನಡ ಭಾಷೆ',
      'ml': 'മലയാളം ഭാഷ',
      'pa': 'ਪੰਜਾਬੀ ਭਾਸ਼ਾ',
      'or': 'ଓଡ଼ିଆ ଭାଷା',
      'as': 'অসমীয়া ভাষা',
      'ur': 'اردو زبان',
      'sa': 'संस्कृत भाषा',
    };
    return scripts[languageCode] ?? 'Language';
  }

  String? _getLanguageFont(String languageCode) {
    // Return null to use system fonts which handle Indian languages better
    return null;
  }

  Future<void> _saveLanguagesAndContinue() async {
    if (selectedKnownLanguage != null && selectedTargetLanguage != null) {
      await UserPreferences.setKnownLanguage(selectedKnownLanguage!);
      await UserPreferences.setTargetLanguage(selectedTargetLanguage!);
      
      if (!mounted) return;
      Navigator.pushNamed(context, '/level-selection');
    }
  }
}