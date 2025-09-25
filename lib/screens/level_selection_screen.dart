import 'package:flutter/material.dart';
import '../services/user_preferences.dart';
import '../services/translation_service.dart';

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  String? knownLanguage;
  String? targetLanguage;
  String? selectedLevel;

  @override
  void initState() {
    super.initState();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    final known = await UserPreferences.getKnownLanguage();
    final target = await UserPreferences.getTargetLanguage();
    setState(() {
      knownLanguage = known;
      targetLanguage = target;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Level'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2C3E50),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/language-selection'),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFC2E9FB), Color(0xFFA1C4FD)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                if (knownLanguage != null && targetLanguage != null) ...[
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                TranslationService.getLanguageFlag(knownLanguage!),
                                style: const TextStyle(fontSize: 30),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                TranslationService.getSupportedLanguages()[knownLanguage!] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const Text(
                                'Known',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6C5CE7),
                                ),
                              ),
                            ],
                          ),
                          const Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF6C5CE7),
                            size: 30,
                          ),
                          Column(
                            children: [
                              Text(
                                TranslationService.getLanguageFlag(targetLanguage!),
                                style: const TextStyle(fontSize: 30),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                TranslationService.getSupportedLanguages()[targetLanguage!] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const Text(
                                'Learning',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6C5CE7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
                const Text(
                  'Select Your Learning Level',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                      _buildLevelCard(
                        'Beginner',
                        'Learn basic letters and sounds',
                        Icons.school,
                        const Color(0xFF4CAF50),
                        'beginner',
                      ),
                      const SizedBox(height: 20),
                      _buildLevelCard(
                        'Intermediate',
                        'Form words and simple sentences',
                        Icons.book,
                        const Color(0xFF2196F3),
                        'intermediate',
                      ),
                      const SizedBox(height: 20),
                      _buildLevelCard(
                        'Advanced',
                        'Complex grammar and conversations',
                        Icons.psychology,
                        const Color(0xFF9C27B0),
                        'advanced',
                      ),
                    ],
                  ),
                const SizedBox(height: 30),
                if (selectedLevel != null)
                  ElevatedButton(
                    onPressed: _startLearning,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Start Learning!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(String title, String description, IconData icon, Color color, String level) {
    final bool isSelected = selectedLevel == level;
    
    return Card(
      elevation: isSelected ? 10 : 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isSelected 
          ? BorderSide(color: color, width: 3)
          : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          setState(() {
            selectedLevel = level;
          });
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? color : const Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 30,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startLearning() async {
    if (selectedLevel != null) {
      await UserPreferences.setCurrentLevel(selectedLevel!);
      
      if (!mounted) return;
      
      // Navigate to the appropriate learning screen based on level
      switch (selectedLevel) {
        case 'beginner':
          Navigator.pushNamed(context, '/beginner-learning');
          break;
        case 'intermediate':
          Navigator.pushNamed(context, '/intermediate-learning');
          break;
        case 'advanced':
          Navigator.pushNamed(context, '/advanced-learning');
          break;
        default:
          Navigator.pushNamed(context, '/beginner-learning');
      }
    }
  }
}