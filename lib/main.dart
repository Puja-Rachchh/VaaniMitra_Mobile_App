import 'package:flutter/material.dart';
import 'screens/language_selection_screen.dart';
import 'screens/level_selection_screen.dart';
import 'screens/beginner_learning_screen.dart';
import 'screens/fruits_learning_screen.dart';
import 'screens/vegetables_learning_screen.dart';

void main() {
  runApp(const VaaniMitraApp());
}

class VaaniMitraApp extends StatelessWidget {
  const VaaniMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaaniMitra - Hindi Learning App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF6C5CE7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          primary: const Color(0xFF6C5CE7),
          secondary: const Color(0xFFA1C4FD),
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E50),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF2C3E50),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C5CE7),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/language-selection': (context) => const NewLanguageSelectionScreen(),
        '/level-selection': (context) => const LevelSelectionScreen(),
        '/beginner-learning': (context) => const BeginnerLearningScreen(),
        '/intermediate-learning': (context) => const IntermediateScreen(),
        '/advanced-learning': (context) => const BeginnerScreen(),
        '/home': (context) => const HomeScreen(),
        '/beginner': (context) => const BeginnerScreen(),
        '/intermediate': (context) => const IntermediateScreen(),
        '/fruits-learning': (context) => const FruitsLearningScreen(),
        '/vegetables-learning': (context) => const VegetablesLearningScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school,
                size: 100,
                color: Color(0xFF6C5CE7),
              ),
              SizedBox(height: 20),
              Text(
                'VaaniMitra',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Learn Hindi with Fun!',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF2C3E50),
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.school,
                          size: 80,
                          color: Color(0xFF6C5CE7),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Welcome to VaaniMitra',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.pushReplacementNamed(context, '/language-selection');
                              }
                            },
                            child: const Text('Login', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: const Text(
                            'Don\'t have an account? Sign Up',
                            style: TextStyle(color: Color(0xFF6C5CE7)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Sign Up Screen
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.pushReplacementNamed(context, '/language-selection');
                              }
                            },
                            child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Language Selection Screen
class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Choose Your Learning Language',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        child: const Column(
                          children: [
                            Text(
                              '🇮🇳',
                              style: TextStyle(fontSize: 80),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Hindi',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'हिंदी सीखें',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF6C5CE7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'More languages coming soon!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2C3E50),
                      fontStyle: FontStyle.italic,
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
}

// Home Screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VaaniMitra'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Profile functionality
            },
          ),
        ],
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to Learn all Indian Languages!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Choose your learning level to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 30),
                _buildLevelCard(
                  context,
                  'Beginner',
                  'Start with basics - Letters, Numbers, and Simple Words',
                  Icons.child_care,
                  Colors.green,
                  '/beginner',
                ),
                const SizedBox(height: 20),
                _buildLevelCard(
                  context,
                  'Intermediate',
                  'Learn Fruits, Vegetables, and Common Objects',
                  Icons.school,
                  Colors.orange,
                  '/intermediate',
                ),
                const SizedBox(height: 20),
                _buildLevelCard(
                  context,
                  'Advanced',
                  'Complex Sentences and Conversations (Coming Soon)',
                  Icons.psychology,
                  Colors.red,
                  null,
                ),
                const SizedBox(height: 30),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'Your Progress',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildProgressItem('Beginner Level', 0.8, Colors.green),
                        const SizedBox(height: 10),
                        _buildProgressItem('Intermediate Level', 0.3, Colors.orange),
                        const SizedBox(height: 10),
                        _buildProgressItem('Advanced Level', 0.0, Colors.red),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, String title, String description,
      IconData icon, Color color, String? route) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: route != null
            ? () {
                Navigator.pushNamed(context, route);
              }
            : null,
        child: Container(
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
              if (route != null)
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFF6C5CE7),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressItem(String title, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}

// Beginner Screen
class BeginnerScreen extends StatelessWidget {
  const BeginnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beginner Level'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Beginner Lessons',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLessonCard(
                  'Hindi Letters',
                  'Learn Devanagari script and pronunciation',
                  Icons.text_fields,
                  Colors.blue,
                  () {},
                ),
                const SizedBox(height: 15),
                _buildLessonCard(
                  'Numbers',
                  'Count from 1 to 100 in Hindi',
                  Icons.numbers,
                  Colors.green,
                  () {},
                ),
                const SizedBox(height: 15),
                _buildLessonCard(
                  'Basic Words',
                  'Common everyday words and phrases',
                  Icons.chat_bubble,
                  Colors.orange,
                  () {},
                ),
                const SizedBox(height: 15),
                _buildLessonCard(
                  'Colors',
                  'Learn colors in Hindi',
                  Icons.palette,
                  Colors.purple,
                  () {},
                ),
                const SizedBox(height: 15),
                _buildLessonCard(
                  'Family Members',
                  'Words for family relationships',
                  Icons.family_restroom,
                  Colors.red,
                  () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCard(String title, String description, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 30,
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF6C5CE7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Intermediate Screen
class IntermediateScreen extends StatelessWidget {
  const IntermediateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intermediate Level'),
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Intermediate Lessons',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLessonCard(
                  'Fruits',
                  'Learn names of various fruits',
                  Icons.apple,
                  Colors.red,
                  () {
                    Navigator.pushNamed(context, '/fruits-learning');
                  },
                ),
                const SizedBox(height: 15),
                _buildLessonCard(
                  'Vegetables',
                  'Learn names of various vegetables',
                  Icons.eco,
                  Colors.green,
                  () {
                    Navigator.pushNamed(context, '/vegetables-learning');
                  },
                ),
                const SizedBox(height: 15),
                _buildLessonCard(
                  'Animals',
                  'Learn names of various animals',
                  Icons.pets,
                  Colors.brown,
                  () {},
                ),
                const SizedBox(height: 15),
                _buildLessonCard(
                  'Body Parts',
                  'Human body parts and their names',
                  Icons.accessibility,
                  Colors.blue,
                  () {},
                ),
                const SizedBox(height: 15),
                _buildLessonCard(
                  'Weather',
                  'Weather conditions and seasons',
                  Icons.wb_sunny,
                  Colors.orange,
                  () {},
                ),
                const SizedBox(height: 15),
                _buildLessonCard(
                  'Common Objects',
                  'Learn names of various objects',
                  Icons.home,
                  Colors.purple,
                  () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonCard(String title, String description, IconData icon,
      Color color, VoidCallback onTap) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 30,
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF6C5CE7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
