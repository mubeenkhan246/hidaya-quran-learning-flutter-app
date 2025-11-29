import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../constants/app_theme.dart';
import '../../widgets/glass_card.dart';

class GamesQuizzesScreen extends StatefulWidget {
  const GamesQuizzesScreen({super.key});

  @override
  State<GamesQuizzesScreen> createState() => _GamesQuizzesScreenState();
}

class _GamesQuizzesScreenState extends State<GamesQuizzesScreen> {
  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;

    return Container(
      decoration: AppTheme.gradientBackground(appProvider.themeMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Games & Quizzes'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              GlassCard(
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple, Colors.purple.shade700],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.gamepad_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Learn Through Play!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.textLight : AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fun games to learn Quran',
                            style: TextStyle(
                              fontSize: 12,
                              color: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Game Cards
              _buildGameCard(
                context,
                title: 'Letter Matching',
                description: 'Match Arabic letters with their names',
                icon: Icons.abc_rounded,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LetterMatchingGame(),
                    ),
                  );
                },
                appProvider: appProvider,
                isDark: isDark,
              ),
              
              const SizedBox(height: 12),
              
              _buildGameCard(
                context,
                title: 'Memory Game',
                description: 'Find matching pairs of Quranic words',
                icon: Icons.psychology_rounded,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MemoryGame(),
                    ),
                  );
                },
                appProvider: appProvider,
                isDark: isDark,
              ),
              
              const SizedBox(height: 12),
              
              _buildGameCard(
                context,
                title: 'Fill in the Blank',
                description: 'Complete the missing words in verses',
                icon: Icons.edit_rounded,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FillInBlankGame(),
                    ),
                  );
                },
                appProvider: appProvider,
                isDark: isDark,
              ),
              
              const SizedBox(height: 12),
              
              _buildGameCard(
                context,
                title: 'Surah Quiz',
                description: 'Test your knowledge of Surahs',
                icon: Icons.quiz_rounded,
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SurahQuizGame(),
                    ),
                  );
                },
                appProvider: appProvider,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required AppProvider appProvider,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_arrow_rounded, color: appProvider.accentColor, size: 28),
          ],
        ),
      ),
    );
  }
}

// Letter Matching Game
class LetterMatchingGame extends StatefulWidget {
  const LetterMatchingGame({super.key});

  @override
  State<LetterMatchingGame> createState() => _LetterMatchingGameState();
}

class _LetterMatchingGameState extends State<LetterMatchingGame> {
  final List<Map<String, String>> letters = [
    {'letter': 'ا', 'name': 'Alif'},
    {'letter': 'ب', 'name': 'Ba'},
    {'letter': 'ت', 'name': 'Ta'},
    {'letter': 'ج', 'name': 'Jeem'},
    {'letter': 'ح', 'name': 'Ha'},
    {'letter': 'د', 'name': 'Dal'},
  ];
  
  int score = 0;
  String? selectedLetter;
  String? selectedName;
  List<String> matchedPairs = [];

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;
    
    List<String> shuffledLetters = letters.map((e) => e['letter']!).toList()..shuffle();
    List<String> shuffledNames = letters.map((e) => e['name']!).toList()..shuffle();

    return Container(
      decoration: AppTheme.gradientBackground(appProvider.themeMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Letter Matching'),
          centerTitle: true,
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  'Score: $score',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: appProvider.accentColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GlassCard(
                  child: Text(
                    'Match the Arabic letters with their names!',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Row(
                    children: [
                      // Letters Column
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: shuffledLetters.map((letter) {
                            final isMatched = matchedPairs.contains(letter);
                            final isSelected = selectedLetter == letter;
                            return _buildLetterCard(
                              letter,
                              isSelected,
                              isMatched,
                              () {
                                if (!isMatched) {
                                  setState(() {
                                    selectedLetter = letter;
                                    _checkMatch();
                                  });
                                }
                              },
                              appProvider,
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Names Column
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: shuffledNames.map((name) {
                            final isMatched = matchedPairs.any((pair) => 
                              letters.firstWhere((l) => l['letter'] == pair)['name'] == name
                            );
                            final isSelected = selectedName == name;
                            return _buildNameCard(
                              name,
                              isSelected,
                              isMatched,
                              () {
                                if (!isMatched) {
                                  setState(() {
                                    selectedName = name;
                                    _checkMatch();
                                  });
                                }
                              },
                              appProvider,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _checkMatch() {
    if (selectedLetter != null && selectedName != null) {
      final letterData = letters.firstWhere(
        (l) => l['letter'] == selectedLetter,
        orElse: () => {'letter': '', 'name': ''},
      );
      
      if (letterData['name'] == selectedName) {
        // Correct match!
        setState(() {
          matchedPairs.add(selectedLetter!);
          score += 10;
          selectedLetter = null;
          selectedName = null;
        });
        
        if (matchedPairs.length == letters.length) {
          _showWinDialog();
        }
      } else {
        // Wrong match
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            selectedLetter = null;
            selectedName = null;
          });
        });
      }
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Congratulations!'),
        content: Text('You matched all letters!\nYour score: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                score = 0;
                matchedPairs.clear();
                selectedLetter = null;
                selectedName = null;
              });
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterCard(String letter, bool isSelected, bool isMatched, VoidCallback onTap, AppProvider appProvider) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: isMatched
              ? LinearGradient(colors: [Colors.green, Colors.green.shade700])
              : isSelected
                  ? LinearGradient(colors: [appProvider.accentColor, appProvider.accentColor.withOpacity(0.7)])
                  : null,
          color: !isMatched && !isSelected ? appProvider.accentColor.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: appProvider.accentColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            letter,
            style: AppTheme.arabicTextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isMatched || isSelected ? Colors.white : appProvider.accentColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameCard(String name, bool isSelected, bool isMatched, VoidCallback onTap, AppProvider appProvider) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: isMatched
              ? LinearGradient(colors: [Colors.green, Colors.green.shade700])
              : isSelected
                  ? LinearGradient(colors: [appProvider.accentColor, appProvider.accentColor.withOpacity(0.7)])
                  : null,
          color: !isMatched && !isSelected ? appProvider.accentColor.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: appProvider.accentColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isMatched || isSelected ? Colors.white : appProvider.accentColor,
            ),
          ),
        ),
      ),
    );
  }
}

// Memory Game
class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  final List<String> words = ['الله', 'محمد', 'قرآن', 'صلاة', 'زكاة', 'صوم', 'حج', 'إيمان'];
  List<String> gameCards = [];
  List<int> flippedIndices = [];
  List<int> matchedIndices = [];
  int moves = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    gameCards = [...words, ...words]..shuffle();
    flippedIndices.clear();
    matchedIndices.clear();
    moves = 0;
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;

    return Container(
      decoration: AppTheme.gradientBackground(appProvider.themeMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Memory Game'),
          centerTitle: true,
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  'Moves: $moves',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: appProvider.accentColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GlassCard(
                  child: Text(
                    'Find matching pairs of words!',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: gameCards.length,
                    itemBuilder: (context, index) {
                      final isFlipped = flippedIndices.contains(index);
                      final isMatched = matchedIndices.contains(index);
                      
                      return GestureDetector(
                        onTap: () => _onCardTap(index),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isMatched
                                ? LinearGradient(colors: [Colors.green, Colors.green.shade700])
                                : isFlipped
                                    ? LinearGradient(colors: [appProvider.accentColor, appProvider.accentColor.withOpacity(0.7)])
                                    : LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              isFlipped || isMatched ? gameCards[index] : '?',
                              style: AppTheme.arabicTextStyle(
                                fontSize: isFlipped || isMatched ? 20 : 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onCardTap(int index) {
    if (flippedIndices.length >= 2 || matchedIndices.contains(index) || flippedIndices.contains(index)) {
      return;
    }

    setState(() {
      flippedIndices.add(index);
    });

    if (flippedIndices.length == 2) {
      moves++;
      
      if (gameCards[flippedIndices[0]] == gameCards[flippedIndices[1]]) {
        // Match found!
        setState(() {
          matchedIndices.addAll(flippedIndices);
          flippedIndices.clear();
        });
        
        if (matchedIndices.length == gameCards.length) {
          Future.delayed(const Duration(milliseconds: 500), _showWinDialog);
        }
      } else {
        // No match
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            flippedIndices.clear();
          });
        });
      }
    }
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Well Done!'),
        content: Text('You completed the game in $moves moves!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(_initializeGame);
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

// Fill in the Blank Game & Surah Quiz - Placeholder screens
class FillInBlankGame extends StatelessWidget {
  const FillInBlankGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fill in the Blank')),
      body: const Center(child: Text('Coming Soon!')),
    );
  }
}

class SurahQuizGame extends StatelessWidget {
  const SurahQuizGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Surah Quiz')),
      body: const Center(child: Text('Coming Soon!')),
    );
  }
}
