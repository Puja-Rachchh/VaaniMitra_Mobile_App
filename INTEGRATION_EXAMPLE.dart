// INTEGRATION EXAMPLE: Adding Letter Tracing Button to Level Selection Screen
// Location: lib/screens/level_selection_screen.dart

// 1. Add import at the top of the file:
import '../screens/letter_tracing_screen.dart';

// 2. Add this method inside _LevelSelectionScreenState class:
void _navigateToLetterTracing(BuildContext context) {
  if (targetLanguage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select a target language first'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => LetterTracingScreen(
        language: targetLanguage!,
        languageName: TranslationService.getSupportedLanguages()[targetLanguage!] ?? 'Unknown',
      ),
    ),
  );
}

// 3. Add this widget after the level selection cards in the build method:
// (Add this after the Beginner/Intermediate/Advanced cards)

const SizedBox(height: 30),
const Divider(thickness: 2),
const SizedBox(height: 10),

// Letter Tracing Practice Section
Text(
  '✏️ Practice Writing',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFF2C3E50),
  ),
),
const SizedBox(height: 20),

// Letter Tracing Card
Card(
  elevation: 8,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  child: InkWell(
    onTap: () => _navigateToLetterTracing(context),
    borderRadius: BorderRadius.circular(20),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFB06AB3), Color(0xFF4568DC)],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.draw,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Letter Tracing',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  targetLanguage != null
                      ? 'Learn to write ${TranslationService.getSupportedLanguages()[targetLanguage!]} letters'
                      : 'Learn to write letters',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 24,
          ),
        ],
      ),
    ),
  ),
),

/* ==================================================================================
   ALTERNATIVE: SIMPLER BUTTON VERSION
   ================================================================================== */

// If you prefer a simpler button instead of the fancy card, use this:

ElevatedButton.icon(
  onPressed: () => _navigateToLetterTracing(context),
  icon: const Icon(Icons.draw, size: 24),
  label: const Text(
    'Practice Letter Writing',
    style: TextStyle(fontSize: 18),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF6C5CE7),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25),
    ),
    elevation: 5,
  ),
),

/* ==================================================================================
   COMPLETE EXAMPLE: Full Level Selection Screen with Letter Tracing Integration
   ================================================================================== */

/*
import 'package:flutter/material.dart';
import '../services/user_preferences.dart';
import '../services/translation_service.dart';
import '../screens/letter_tracing_screen.dart';

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

  void _navigateToLetterTracing(BuildContext context) {
    if (targetLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a target language first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LetterTracingScreen(
          language: targetLanguage!,
          languageName: TranslationService.getSupportedLanguages()[targetLanguage!] ?? 'Unknown',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Level'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2C3E50),
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
                // Language display cards
                if (knownLanguage != null && targetLanguage != null)
                  _buildLanguageInfoCard(),

                const SizedBox(height: 30),

                // Title
                const Text(
                  '📚 Choose Your Learning Path',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),

                const SizedBox(height: 30),

                // Level selection cards (Beginner, Intermediate, Advanced)
                _buildLevelCard(
                  context,
                  level: 'beginner',
                  title: 'Beginner',
                  description: 'Start your journey',
                  icon: Icons.school,
                  color: const Color(0xFF00C9FF),
                ),

                const SizedBox(height: 20),

                _buildLevelCard(
                  context,
                  level: 'intermediate',
                  title: 'Intermediate',
                  description: 'Build your skills',
                  icon: Icons.trending_up,
                  color: const Color(0xFFF7971E),
                ),

                const SizedBox(height: 20),

                _buildLevelCard(
                  context,
                  level: 'advanced',
                  title: 'Advanced',
                  description: 'Master the language',
                  icon: Icons.emoji_events,
                  color: const Color(0xFF6C5CE7),
                ),

                // Letter Tracing Section
                const SizedBox(height: 40),
                const Divider(thickness: 2),
                const SizedBox(height: 20),

                const Text(
                  '✏️ Practice Writing',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),

                const SizedBox(height: 20),

                // Letter Tracing Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InkWell(
                    onTap: () => _navigateToLetterTracing(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB06AB3), Color(0xFF4568DC)],
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.draw,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Letter Tracing',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  targetLanguage != null
                                      ? 'Learn to write ${TranslationService.getSupportedLanguages()[targetLanguage!]} letters'
                                      : 'Learn to write letters',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageInfoCard() {
    return Card(
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
    );
  }

  Widget _buildLevelCard(
    BuildContext context, {
    required String level,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          setState(() => selectedLevel = level);
          // Navigate to appropriate screen
          Navigator.pushNamed(context, '/$level-learning');
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/
