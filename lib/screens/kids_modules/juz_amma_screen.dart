import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:just_audio/just_audio.dart';
import '../../providers/app_provider.dart';
import '../../constants/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../utils/translation_helper.dart';

class JuzAmmaScreen extends StatefulWidget {
  const JuzAmmaScreen({super.key});

  @override
  State<JuzAmmaScreen> createState() => _JuzAmmaScreenState();
}

class _JuzAmmaScreenState extends State<JuzAmmaScreen> {
  // Juz Amma - Last section of Quran (Surah 78-114)
  final List<int> juzAmmaSurahs = List.generate(37, (index) => 78 + index);
  
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
          title: const Text('Juz Amma - Short Surahs'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Header Card
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green, Colors.green.shade700],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
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
                              'Learn Short Surahs',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.textLight : AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Easy to memorize for kids',
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
              
              // Surahs List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: juzAmmaSurahs.length,
                  itemBuilder: (context, index) {
                    final surahNumber = juzAmmaSurahs[index];
                    return _buildSurahCard(surahNumber, appProvider, isDark);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahCard(int surahNumber, AppProvider appProvider, bool isDark) {
    final surahName = quran.getSurahName(surahNumber);
    final surahNameArabic = quran.getSurahNameArabic(surahNumber);
    final versesCount = quran.getVerseCount(surahNumber);
    
    // Color based on position
    final colors = [Colors.green, Colors.blue, Colors.purple, Colors.orange, Colors.teal];
    final color = colors[surahNumber % colors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurahLearningDetailScreen(surahNumber: surahNumber),
            ),
          );
        },
        child: GlassCard(
          child: Row(
            children: [
              // Surah Number Badge
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '$surahNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Surah Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surahName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.textLight : AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      surahNameArabic,
                      style: AppTheme.arabicTextStyle(
                        fontSize: 14,
                        color: appProvider.accentColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$versesCount Verses',
                      style: TextStyle(
                        fontSize: 12,
                        color: (isDark ? AppTheme.textLight : AppTheme.textDark).withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: appProvider.accentColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Detailed Surah Learning Screen
class SurahLearningDetailScreen extends StatefulWidget {
  final int surahNumber;

  const SurahLearningDetailScreen({super.key, required this.surahNumber});

  @override
  State<SurahLearningDetailScreen> createState() => _SurahLearningDetailScreenState();
}

class _SurahLearningDetailScreenState extends State<SurahLearningDetailScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _currentVerse = 1;
  int _repetitionCount = 3;
  bool _isPlaying = false;
  bool _showTranslation = true;
  bool _wordByWord = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playVerse(int verseNumber, {int repetitions = 1}) async {
    try {
      final appProvider = context.read<AppProvider>();
      final audioUrl = TranslationHelper.getVerseAudioUrl(
        widget.surahNumber,
        verseNumber,
        appProvider.selectedReciter,
      );

      setState(() => _isPlaying = true);

      for (int i = 0; i < repetitions; i++) {
        await _audioPlayer.setUrl(audioUrl);
        await _audioPlayer.play();
        await _audioPlayer.playerStateStream
            .firstWhere((state) => state.processingState == ProcessingState.completed);
        
        // Pause between repetitions
        if (i < repetitions - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      setState(() => _isPlaying = false);
    } catch (e) {
      setState(() => _isPlaying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to play audio: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isDark = appProvider.isDarkMode;
    final surahName = quran.getSurahName(widget.surahNumber);
    final surahNameArabic = quran.getSurahNameArabic(widget.surahNumber);
    final versesCount = quran.getVerseCount(widget.surahNumber);

    return Container(
      decoration: AppTheme.gradientBackground(appProvider.themeMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            children: [
              Text(surahName),
              Text(
                surahNameArabic,
                style: AppTheme.arabicTextStyle(
                  fontSize: 14,
                  color: isDark ? AppTheme.textLight : AppTheme.textDark,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Controls
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  child: Column(
                    children: [
                      // Repetition Selector
                      Row(
                        children: [
                          Icon(Icons.repeat_rounded, color: appProvider.accentColor),
                          const SizedBox(width: 12),
                          Text(
                            'Repeat:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.textLight : AppTheme.textDark,
                            ),
                          ),
                          const Spacer(),
                          _buildRepeatButton(1, appProvider),
                          _buildRepeatButton(3, appProvider),
                          _buildRepeatButton(5, appProvider),
                          _buildRepeatButton(7, appProvider),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Toggle Options
                      Row(
                        children: [
                          Expanded(
                            child: _buildToggleButton(
                              'Translation',
                              _showTranslation,
                              Icons.translate_rounded,
                              () => setState(() => _showTranslation = !_showTranslation),
                              appProvider,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildToggleButton(
                              'Word by Word',
                              _wordByWord,
                              Icons.text_fields_rounded,
                              () => setState(() => _wordByWord = !_wordByWord),
                              appProvider,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Verses
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: versesCount,
                  itemBuilder: (context, index) {
                    final verseNumber = index + 1;
                    return _buildVerseCard(verseNumber, appProvider, isDark);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatButton(int count, AppProvider appProvider) {
    final isSelected = _repetitionCount == count;
    return GestureDetector(
      onTap: () => setState(() => _repetitionCount = count),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? appProvider.accentColor : appProvider.accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$count×',
          style: TextStyle(
            color: isSelected ? Colors.white : appProvider.accentColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isActive, IconData icon, VoidCallback onTap, AppProvider appProvider) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? appProvider.accentColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: appProvider.accentColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: appProvider.accentColor),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: appProvider.accentColor,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseCard(int verseNumber, AppProvider appProvider, bool isDark) {
    final verseText = quran.getVerse(widget.surahNumber, verseNumber, verseEndSymbol: true);
    final translation = TranslationHelper.getTranslation(
      widget.surahNumber,
      verseNumber,
      appProvider.selectedTranslation,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Verse Header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [appProvider.accentColor, appProvider.accentColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$verseNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: appProvider.accentColor,
                  ),
                  onPressed: () => _playVerse(verseNumber, repetitions: _repetitionCount),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Arabic Text
            SelectableText(
              verseText,
              style: AppTheme.arabicTextStyle(
                fontSize: appProvider.arabicTextSize,
                color: isDark ? AppTheme.textLight : AppTheme.textDark,
                height: 2.0,
              ),
              textAlign: TextAlign.right,
            ),
            
            // Translation
            if (_showTranslation) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: appProvider.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  translation,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
