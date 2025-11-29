import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../constants/app_theme.dart';
import '../../widgets/glass_card.dart';

class WritingPracticeScreen extends StatefulWidget {
  const WritingPracticeScreen({super.key});

  @override
  State<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}

class _WritingPracticeScreenState extends State<WritingPracticeScreen> {
  int _selectedCategory = 0;

  final List<Map<String, String>> letters = [
    {'letter': 'ا', 'name': 'Alif'},
    {'letter': 'ب', 'name': 'Ba'},
    {'letter': 'ت', 'name': 'Ta'},
    {'letter': 'ث', 'name': 'Tha'},
    {'letter': 'ج', 'name': 'Jeem'},
    {'letter': 'ح', 'name': 'Ha'},
  ];

  final List<Map<String, String>> islamicPhrases = [
    {'arabic': 'بِسْمِ اللَّهِ', 'translation': 'Bismillah (In the name of Allah)'},
    {'arabic': 'الْحَمْدُ لِلَّهِ', 'translation': 'Alhamdulillah (All praise to Allah)'},
    {'arabic': 'سُبْحَانَ اللَّهِ', 'translation': 'SubhanAllah (Glory be to Allah)'},
    {'arabic': 'اللَّهُ أَكْبَرُ', 'translation': 'Allahu Akbar (Allah is the Greatest)'},
    {'arabic': 'لَا إِلَٰهَ إِلَّا اللَّهُ', 'translation': 'La ilaha illallah (There is no god but Allah)'},
    {'arabic': 'مَا شَاءَ اللَّهُ', 'translation': 'MashaAllah (As Allah wills)'},
  ];

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
          title: const Text('Writing Practice'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Category Tabs
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        'Arabic Letters',
                        _selectedCategory == 0,
                        () => setState(() => _selectedCategory = 0),
                        appProvider,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTabButton(
                        'Islamic Phrases',
                        _selectedCategory == 1,
                        () => setState(() => _selectedCategory = 1),
                        appProvider,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Header Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassCard(
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange, Colors.orange.shade700],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.draw_rounded,
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
                              'Practice Writing',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.textLight : AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Trace and write Arabic',
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
              ),
              
              const SizedBox(height: 16),
              
              // Content
              Expanded(
                child: _selectedCategory == 0
                    ? _buildLettersList(appProvider, isDark)
                    : _buildPhrasesList(appProvider, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isSelected, VoidCallback onTap, AppProvider appProvider) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    appProvider.accentColor,
                    appProvider.accentColor.withOpacity(0.8),
                  ],
                )
              : null,
          color: !isSelected ? appProvider.accentColor.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: appProvider.accentColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : appProvider.accentColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildLettersList(AppProvider appProvider, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: letters.length,
      itemBuilder: (context, index) {
        final letter = letters[index];
        return GestureDetector(
          onTap: () {
            _showWritingCanvas(letter['letter']!, letter['name']!, appProvider, isDark);
          },
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  letter['letter']!,
                  style: AppTheme.arabicTextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: appProvider.accentColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  letter['name']!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Practice',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhrasesList(AppProvider appProvider, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: islamicPhrases.length,
      itemBuilder: (context, index) {
        final phrase = islamicPhrases[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              _showWritingCanvas(phrase['arabic']!, phrase['translation']!, appProvider, isDark);
            },
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    phrase['arabic']!,
                    style: AppTheme.arabicTextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: appProvider.accentColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    phrase['translation']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Practice Writing',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showWritingCanvas(String text, String name, AppProvider appProvider, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.primaryDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Practice: $name',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Text to trace
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: appProvider.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: appProvider.accentColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      text,
                      style: AppTheme.arabicTextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: appProvider.accentColor.withOpacity(0.3),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Drawing Canvas Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: appProvider.accentColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.gesture_rounded,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Draw with your finger',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Writing canvas feature coming soon!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Canvas cleared!')),
                        );
                      },
                      icon: const Icon(Icons.clear_rounded),
                      label: const Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Great job! ⭐')),
                        );
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Done'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
