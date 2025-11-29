import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:share_plus/share_plus.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_card.dart';
import '../utils/translation_helper.dart';
import 'full_surah_player_screen.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final int? initialVerse;

  const SurahDetailScreen({
    super.key,
    required this.surahNumber,
    this.initialVerse,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  bool _showTranslation = true;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _currentlyPlayingVerse;
  bool _isLoading = false;
  final Map<int, GlobalKey> _verseKeys = {};
  
  @override
  void initState() {
    super.initState();
    // Start tracking study session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().startStudySession();
      
      // Scroll to initial verse if specified
      if (widget.initialVerse != null) {
        _scrollToVerse(widget.initialVerse!);
      }
    });
    
    // Listen to audio player state to update UI
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          // UI will rebuild showing correct play/pause icon
        });
        
        // Clear currently playing when completed
        if (state.processingState == ProcessingState.completed) {
          setState(() {
            _currentlyPlayingVerse = null;
          });
        }
      }
    });
  }
  
  void _scrollToVerse(int verseNumber) {
    Future.delayed(const Duration(milliseconds: 500), () {
      final key = _verseKeys[verseNumber];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.2,
        );
      }
    });
  }
  
  @override
  void dispose() {
    // Stop audio when disposing
    _audioPlayer.stop();
    // End study session and save time
    context.read<AppProvider>().endStudySession();
    _audioPlayer.dispose();
    super.dispose();
  }
  
  Future<void> _playVerseAudio(int verseNumber, int surahNumber) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final appProvider = context.read<AppProvider>();
      final reciterKey = appProvider.selectedReciter;
      
      // Get audio URL from translation helper using selected reciter
      final audioUrl = TranslationHelper.getVerseAudioUrl(
        surahNumber,
        verseNumber,
        reciterKey,
      );
      
      if (_currentlyPlayingVerse == verseNumber) {
        // Toggle play/pause
        if (_audioPlayer.playing) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.play();
        }
      } else {
        // Play new verse
        await _audioPlayer.stop();
        await _audioPlayer.setUrl(audioUrl);
        await _audioPlayer.play();
        setState(() {
          _currentlyPlayingVerse = verseNumber;
        });
        
        // State listener in initState will handle completion
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to play audio: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _copyVerse(int verseNumber, String arabicText) {
    final translationText = _showTranslation 
        ? '\n\n${_getTranslation(verseNumber)}'
        : '';
    
    final text = '$arabicText$translationText\n\n[${quran.getSurahName(widget.surahNumber)} ${widget.surahNumber}:$verseNumber]';
    Clipboard.setData(ClipboardData(text: text));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verse copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _shareVerse(int verseNumber, String arabicText) {
    final translationText = _showTranslation 
        ? '\n\n${_getTranslation(verseNumber)}'
        : '';
    
    final text = '$arabicText$translationText\n\n[${quran.getSurahName(widget.surahNumber)} ${widget.surahNumber}:$verseNumber]';
    // Share.share(text);
    SharePlus.instance.share(ShareParams(text:text),
    );
  }
  
  String _getTranslation(int verseNumber) {
    final appProvider = context.read<AppProvider>();
    final translationKey = appProvider.selectedTranslation;
    
    return TranslationHelper.getTranslation(
      widget.surahNumber,
      verseNumber,
      translationKey,
    );
  }
   String _getTranslationBismillah(int surahNumber, int verseNumber) {
    final appProvider = context.read<AppProvider>();
    final translationKey = appProvider.selectedTranslation;
    
    return TranslationHelper.getTranslation(
      surahNumber,
      verseNumber,
      translationKey,
    );
  }

  
  
  // Get verse text without Bismillah
  String _getVerseWithoutBismillah(int surahNumber, int verseNumber) {
    // For verse 1, remove Bismillah from all surahs EXCEPT:
    // - Surah 1 (Al-Fatihah) where verse 1 IS the Bismillah
    // - Surah 9 (At-Tawbah) which has no Bismillah
    if (verseNumber == 1 && surahNumber != 1 && surahNumber != 9) {
      // Get the full verse with symbol
      String fullVerse = quran.getVerse(surahNumber, verseNumber, verseEndSymbol: true);
      
      // Debug: print original verse
      print('DEBUG: Original verse $surahNumber:$verseNumber = "$fullVerse"');
      
      // Check if verse starts with بِسْمِ (the start of Bismillah)
      if (fullVerse.startsWith('بِسْمِ')) {
        // Find where الرَّحِيمِ ends (last word of Bismillah)
        // Try many variations with different diacritics and Unicode forms
        List<String> endPatterns = [
          'الرَّحِيمِ',  // With regular alif
          'ٱلرَّحِيمِ',  // With alif wasla
          'الرَّحِيْمِ', // Different kasra
          'ٱلرَّحِيْمِ',
        ];
        
        bool removed = false;
        for (var pattern in endPatterns) {
          if (fullVerse.contains(pattern)) {
            int endIndex = fullVerse.indexOf(pattern) + pattern.length;
            fullVerse = fullVerse.substring(endIndex).trim();
            removed = true;
            print('DEBUG: Removed Bismillah using pattern "$pattern", result = "$fullVerse"');
            break;
          }
        }
        
        if (!removed) {
          // If still not removed, find "حيم" which should be in any form of الرَّحِيمِ
          if (fullVerse.contains('حِيمِ')) {
            int endIndex = fullVerse.indexOf('حِيمِ') + 'حِيمِ'.length;
            fullVerse = fullVerse.substring(endIndex).trim();
            print('DEBUG: Removed Bismillah using fallback pattern, result = "$fullVerse"');
          } else if (fullVerse.contains('حِيْمِ')) {
            int endIndex = fullVerse.indexOf('حِيْمِ') + 'حِيْمِ'.length;
            fullVerse = fullVerse.substring(endIndex).trim();
            print('DEBUG: Removed Bismillah using fallback pattern 2, result = "$fullVerse"');
          }
        }
      }
      
      return fullVerse;
    }
    
    // For other verses and special cases, return as-is
    return quran.getVerse(surahNumber, verseNumber, verseEndSymbol: true);
  }
  
  bool _isVerseMemorized(int verseNumber) {
    final appProvider = context.read<AppProvider>();
    final key = '${widget.surahNumber}:$verseNumber';
    return appProvider.userProgress?.memorizedVerses.containsKey(key) ?? false;
  }
  
  void _showFontSizeControl(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final isDark = appProvider.isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? AppTheme.primaryDark : Colors.white,
                isDark ? AppTheme.secondaryDeep : const Color(0xFFF5F5F5),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: appProvider.accentColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: appProvider.accentColor.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        appProvider.accentColor.withOpacity(0.1),
                        appProvider.accentColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.text_fields_rounded,
                        size: 48,
                        color: appProvider.accentColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Text Size',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: appProvider.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                StatefulBuilder(
                  builder: (context, setState) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Arabic Text Size
                          Text(
                            'Arabic Text Size',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'A',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: appProvider.accentColor,
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value: appProvider.arabicTextSize,
                                  min: 16.0,
                                  max: 40.0,
                                  divisions: 24,
                                  activeColor: appProvider.accentColor,
                                  inactiveColor: appProvider.accentColor.withOpacity(0.3),
                                  onChanged: (value) {
                                    appProvider.setArabicTextSize(value);
                                    setState(() {});
                                  },
                                ),
                              ),
                              Text(
                                'A',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: appProvider.accentColor,
                                ),
                              ),
                            ],
                          ),
                          Center(
                            child: Text(
                              '${appProvider.arabicTextSize.toInt()}px',
                              style: TextStyle(
                                fontSize: 12,
                                color: appProvider.accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Translation Text Size
                          Text(
                            'Translation Text Size',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'A',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: appProvider.accentColor,
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  value: appProvider.translationFontSize,
                                  min: 12.0,
                                  max: 24.0,
                                  divisions: 12,
                                  activeColor: appProvider.accentColor,
                                  inactiveColor: appProvider.accentColor.withOpacity(0.3),
                                  onChanged: (value) {
                                    appProvider.setTranslationFontSize(value);
                                    setState(() {});
                                  },
                                ),
                              ),
                              Text(
                                'A',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: appProvider.accentColor,
                                ),
                              ),
                            ],
                          ),
                          Center(
                            child: Text(
                              '${appProvider.translationFontSize.toInt()}px',
                              style: TextStyle(
                                fontSize: 12,
                                color: appProvider.accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Close button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appProvider.accentColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showSurahInfo(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final isDark = appProvider.isDarkMode;
    final surahName = quran.getSurahName(widget.surahNumber);
    final surahNameArabic = quran.getSurahNameArabic(widget.surahNumber);
    final totalVerses = quran.getVerseCount(widget.surahNumber);
    final placeOfRevelation = quran.getPlaceOfRevelation(widget.surahNumber);
    final revelationType = placeOfRevelation == 'Makkah' ? 'Makki' : 'Madani';
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDark ? AppTheme.primaryDark : Colors.white,
                isDark ? AppTheme.secondaryDeep : const Color(0xFFF5F5F5),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: appProvider.accentColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: appProvider.accentColor.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      appProvider.accentColor.withOpacity(0.1),
                      appProvider.accentColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 48,
                      color: appProvider.accentColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      surahNameArabic,
                      style: AppTheme.arabicTextStyle(
                        fontSize: appProvider.arabicTextSize * 1.3,
                        fontWeight: FontWeight.bold,
                        color: appProvider.accentColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      surahName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: appProvider.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Surah number
                    _buildInfoRow(
                      context,
                      Icons.numbers_rounded,
                      'Surah Number',
                      widget.surahNumber.toString(),
                      appProvider,
                    ),
                    const SizedBox(height: 16),
                    
                    // Total verses
                    _buildInfoRow(
                      context,
                      Icons.format_list_numbered_rounded,
                      'Total Verses',
                      totalVerses.toString(),
                      appProvider,
                    ),
                    const SizedBox(height: 16),
                    
                    // Place of revelation
                    _buildInfoRow(
                      context,
                      Icons.place_rounded,
                      'Revelation',
                      '$placeOfRevelation ($revelationType)',
                      appProvider,
                    ),
                    const SizedBox(height: 16),
                    
                    // Juz/Para info
                    _buildInfoRow(
                      context,
                      Icons.bookmark_rounded,
                      'Location',
                      'Juz ${quran.getJuzNumber(widget.surahNumber, 1)}',
                      appProvider,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appProvider.accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
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
      ),
    );
  }
  
  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    AppProvider appProvider,
  ) {
    final isDark = appProvider.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appProvider.accentColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: appProvider.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: appProvider.accentColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppTheme.textLight.withOpacity(0.7)
                        : AppTheme.textDark.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _showQariSelector() {
    final appProvider = context.read<AppProvider>();
    final reciters = TranslationHelper.getReciters();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: appProvider.isDarkMode ? AppTheme.primaryDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: appProvider.isDarkMode ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Select Reciter',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: reciters.length,
                itemBuilder: (context, index) {
                  final reciter = reciters[index];
                  final reciterKey = reciter['key'] ?? '';
                  final reciterName = reciter['name'] ?? '';
                  final isSelected = appProvider.selectedReciter == reciterKey;
                  return ListTile(
                    leading: Icon(
                      Icons.record_voice_over_rounded,
                      color: isSelected ? appProvider.accentColor : null,
                    ),
                    title: Text(
                      reciterName,
                      style: TextStyle(
                        color: isSelected ? appProvider.accentColor : null,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: appProvider.accentColor)
                        : null,
                    onTap: () {
                      appProvider.setReciter(reciterKey);
                      Navigator.pop(context);
                      setState(() {}); // Refresh UI
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  void _showLanguageSelector() {
    final appProvider = context.read<AppProvider>();
    final languages = TranslationHelper.getLanguages();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: appProvider.isDarkMode ? AppTheme.primaryDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: appProvider.isDarkMode ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Select Translation',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  final languageKey = language['key'] ?? '';
                  final languageName = language['name'] ?? '';
                  final isSelected = appProvider.selectedTranslation == languageKey;
                  return ListTile(
                    leading: Icon(
                      Icons.translate_rounded,
                      color: isSelected ? appProvider.accentColor : null,
                    ),
                    title: Text(
                      languageName,
                      style: TextStyle(
                        color: isSelected ? appProvider.accentColor : null,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: appProvider.accentColor)
                        : null,
                    onTap: () {
                      appProvider.setLanguage(languageName, languageKey);
                      Navigator.pop(context);
                      setState(() {}); // Refresh UI
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  void _toggleMemorization(int verseNumber) {
    final appProvider = context.read<AppProvider>();
    final isMemorized = _isVerseMemorized(verseNumber);
    
    if (isMemorized) {
      // Remove from memorization
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: appProvider.isDarkMode 
              ? AppTheme.primaryDark 
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Remove from Memorization'),
          content: Text(
            'Remove ${quran.getSurahName(widget.surahNumber)} ${widget.surahNumber}:$verseNumber from memorization list?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Set proficiency to 0 to remove
                appProvider.updateMemorization(
                  widget.surahNumber,
                  verseNumber,
                  0, // 0 = remove from memorization
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Removed from memorization!'),
                    duration: Duration(seconds: 2),
                  ),
                );
                setState(() {}); // Refresh UI
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Remove'),
            ),
          ],
        ),
      );
    } else {
      // Add to memorization
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: appProvider.isDarkMode 
              ? AppTheme.primaryDark 
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text('Add to Memorization'),
          content: Text(
            'Add ${quran.getSurahName(widget.surahNumber)} ${widget.surahNumber}:$verseNumber to memorization list?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                appProvider.updateMemorization(
                  widget.surahNumber,
                  verseNumber,
                  1, // Start with proficiency 1
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to memorization!'),
                    duration: Duration(seconds: 2),
                  ),
                );
                setState(() {}); // Refresh UI
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
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
                  fontSize: appProvider.arabicTextSize * 0.7,
                  color: isDark ? AppTheme.textLight : AppTheme.textDark,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            // Font size control
            IconButton(
              icon: const Icon(Icons.text_fields_rounded),
              tooltip: 'Text Size',
              onPressed: () => _showFontSizeControl(context),
            ),
            // Surah info button
            IconButton(
              icon: const Icon(Icons.info_outline_rounded),
              tooltip: 'Surah Info',
              onPressed: () => _showSurahInfo(context),
            ),
          ],
        ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Surah header info
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: GlassCard(
                child: Column(
                  children: [
                    Text(
                      surahNameArabic,
                      style: AppTheme.arabicTextStyle(
                        fontSize: appProvider.arabicTextSize,
                        fontWeight: FontWeight.bold,
                        color: appProvider.accentColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$surahName • $versesCount Verses • ${quran.getPlaceOfRevelation(widget.surahNumber)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    // Controls row - Reciter, Translation, Show/Hide
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 8,
                      children: [
                        // Qari/Reciter selector
                        GestureDetector(
                          onTap: () => _showQariSelector(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: appProvider.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: appProvider.accentColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.record_voice_over_rounded, size: 16, color: appProvider.accentColor),
                                const SizedBox(width: 6),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 80),
                                  child: Text(
                                    TranslationHelper.getReciterName(appProvider.selectedReciter),
                                    style: TextStyle(
                                      color: appProvider.accentColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(Icons.arrow_drop_down_rounded, size: 16, color: appProvider.accentColor),
                              ],
                            ),
                          ),
                        ),
                        
                        // Translation Language selector
                        GestureDetector(
                          onTap: () => _showLanguageSelector(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: appProvider.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: appProvider.accentColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.translate_rounded, size: 16, color: appProvider.accentColor),
                                const SizedBox(width: 6),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 70),
                                  child: Text(
                                    appProvider.selectedLanguage.split('(')[0].trim(),
                                    style: TextStyle(
                                      color: appProvider.accentColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(Icons.arrow_drop_down_rounded, size: 16, color: appProvider.accentColor),
                              ],
                            ),
                          ),
                        ),
                        
                        // Toggle translation visibility
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showTranslation = !_showTranslation;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: appProvider.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: appProvider.accentColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _showTranslation 
                                      ? Icons.visibility_rounded 
                                      : Icons.visibility_off_rounded,
                                  color: appProvider.accentColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _showTranslation ? 'Hide' : 'Show',
                                  style: TextStyle(
                                    color: appProvider.accentColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Two play mode buttons
                    Row(
                      children: [
                        // Play Continuous with Display button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullSurahPlayerScreen(
                                    surahNumber: widget.surahNumber,
                                    playMode: SurahPlayMode.continuousWithDisplay,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    appProvider.accentColor,
                                    appProvider.accentColor.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: appProvider.accentColor.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.play_circle_filled,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Continuous Play',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Play Verse by Verse button
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullSurahPlayerScreen(
                                    surahNumber: widget.surahNumber,
                                    playMode: SurahPlayMode.verseByVerse,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    appProvider.accentColor.withOpacity(0.7),
                                    appProvider.accentColor.withOpacity(0.5),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: appProvider.accentColor,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: appProvider.accentColor.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.skip_next_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Verse by Verse',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ],
                  ),
                ),
              ),


              if (widget.surahNumber == 1)
              
                  
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassCard(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Auzu label
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    appProvider.accentColor,
                                    appProvider.accentColor.withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '',
                              style: TextStyle(
                                color: appProvider.accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const Spacer(),
                            
                            // Play audio button
                            // if (_isLoading && _currentlyPlayingVerse == 1)
                            //    SizedBox(
                            //     width: 24,
                            //     height: 24,
                            //     child: CircularProgressIndicator(
                            //       strokeWidth: 2,
                            //       valueColor: AlwaysStoppedAnimation<Color>(appProvider.accentColor),
                            //     ),
                            //   )
                            // else
                            //   IconButton(
                            //     icon: Icon(
                            //       _audioPlayer.playing
                            //           ? Icons.pause_rounded
                            //           : Icons.play_arrow_rounded,
                            //       color: appProvider.accentColor,
                            //     ),
                            //     onPressed: () => _playVerseAudio(1),
                            //     // tooltip: _audioPlayer.playing  'Play',
                            //   ),
                            
                           
                            
                            // More options
                            PopupMenuButton<String>(
                              icon:  Icon(
                                Icons.more_vert_rounded,
                                color: appProvider.accentColor,
                              ),
                              onSelected: (value) {
                                switch (value) {
                                  case 'copy':
                                    _copyVerse(1, 'أعوذُ بِٱللَّهِ مِنَ ٱلشَّيۡطَٰنِ ٱلرَّجِيمِ');
                                    break;
                                  case 'share':
                                    _shareVerse(1, 'أعوذُ بِٱللَّهِ مِنَ ٱلشَّيۡطَٰنِ ٱلرَّجِيمِ');
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'copy',
                                  child: Row(
                                    children: [
                                      Icon(Icons.copy_rounded),
                                      SizedBox(width: 12),
                                      Text('Copy'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'share',
                                  child: Row(
                                    children: [
                                      Icon(Icons.share_rounded),
                                      SizedBox(width: 12),
                                      Text('Share'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SelectableText(
                          'أعوذُ بِٱللَّهِ مِنَ ٱلشَّيۡطَٰنِ ٱلرَّجِيمِ',
                          style: AppTheme.arabicTextStyle(
                            fontSize: appProvider.arabicTextSize,
                            color: isDark ? AppTheme.textLight : AppTheme.textDark,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        if (_showTranslation) ...[
                          const SizedBox(height: 16),
                          Divider(
                            color: isDark 
                                ? AppTheme.textLight.withOpacity(0.2)
                                : AppTheme.textDark.withOpacity(0.2),
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            'I seek refuge in Allah from the accursed Shaytan (Satan).',
                            textDirection: TranslationHelper.isRTLLanguage(appProvider.selectedTranslation)
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            textAlign: TranslationHelper.isRTLLanguage(appProvider.selectedTranslation)
                                ? TextAlign.right
                                : TextAlign.left,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              
              // Basmala (except for Surah 1 and Surah 9) - Verse-like UI
              // Surah 1's first verse IS the Bismillah, Surah 9 has no Bismillah
              if (widget.surahNumber != 1 && widget.surahNumber != 9)
              
                  
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassCard(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Bismillah label
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    appProvider.accentColor,
                                    appProvider.accentColor.withOpacity(0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '',
                              style: TextStyle(
                                color: appProvider.accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const Spacer(),
                            
                            // Play audio button
                            if (_isLoading && _currentlyPlayingVerse == 1)
                               SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(appProvider.accentColor),
                                ),
                              )
                            else
                              IconButton(
                                icon: Icon(
                                  _audioPlayer.playing
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: appProvider.accentColor,
                                ),
                                onPressed: () => _playVerseAudio(1, 1),
                                // tooltip: _audioPlayer.playing  'Play',
                              ),
                            
                           
                            
                            // More options
                            PopupMenuButton<String>(
                              icon:  Icon(
                                Icons.more_vert_rounded,
                                color: appProvider.accentColor,
                              ),
                              onSelected: (value) {
                                switch (value) {
                                  case 'copy':
                                    _copyVerse(1, quran.getVerse(1, 1));
                                    break;
                                  case 'share':
                                    _shareVerse(1, quran.getVerse(1, 1));
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'copy',
                                  child: Row(
                                    children: [
                                      Icon(Icons.copy_rounded),
                                      SizedBox(width: 12),
                                      Text('Copy'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'share',
                                  child: Row(
                                    children: [
                                      Icon(Icons.share_rounded),
                                      SizedBox(width: 12),
                                      Text('Share'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SelectableText(
                          quran.basmala,
                          style: AppTheme.arabicTextStyle(
                            fontSize: appProvider.arabicTextSize,
                            color: isDark ? AppTheme.textLight : AppTheme.textDark,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        if (_showTranslation) ...[
                          const SizedBox(height: 16),
                          Divider(
                            color: isDark 
                                ? AppTheme.textLight.withOpacity(0.2)
                                : AppTheme.textDark.withOpacity(0.2),
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            _getTranslationBismillah(1, 1),
                            textDirection: TranslationHelper.isRTLLanguage(appProvider.selectedTranslation)
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            textAlign: TranslationHelper.isRTLLanguage(appProvider.selectedTranslation)
                                ? TextAlign.right
                                : TextAlign.left,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              
              // Verses list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemCount: versesCount,
                itemBuilder: (context, index) {
                  final verseNumber = index + 1;
                  final verseText = _getVerseWithoutBismillah(widget.surahNumber, verseNumber);
                  final isPlaying = _currentlyPlayingVerse == verseNumber;
                  
                  // Create key for this verse for scrolling
                  if (!_verseKeys.containsKey(verseNumber)) {
                    _verseKeys[verseNumber] = GlobalKey();
                  }
                  
                  return GlassCard(
                    key: _verseKeys[verseNumber],
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Verse number and controls
                        Row(
                          children: [
                            // Verse number badge
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: appProvider.accentColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  verseNumber.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            
                            const Spacer(),
                            
                            // Play audio button
                            if (_isLoading && _currentlyPlayingVerse == verseNumber)
                               SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(appProvider.accentColor),
                                ),
                              )
                            else
                              IconButton(
                                icon: Icon(
                                  isPlaying && _audioPlayer.playing
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: appProvider.accentColor,
                                ),
                                onPressed: () {
                                   _playVerseAudio(verseNumber, widget.surahNumber);
                                   setState(() {
                                    isPlaying;
                                    _audioPlayer.playing;
                                   });
                                },
                                tooltip: isPlaying && _audioPlayer.playing ? 'Pause' : 'Play',
                              ),
                            
                            // Add to Memorize button (toggles with green when memorized)
                            IconButton(
                              icon: Icon(
                                _isVerseMemorized(verseNumber)
                                    ? Icons.psychology_rounded
                                    : Icons.psychology_rounded,
                                color: _isVerseMemorized(verseNumber)
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                _toggleMemorization(verseNumber);
                              },
                              tooltip: _isVerseMemorized(verseNumber)
                                  ? 'Remove from Memorization'
                                  : 'Add to Memorization',
                            ),
                            
                            // More options
                            PopupMenuButton<String>(
                              icon:  Icon(
                                Icons.more_vert_rounded,
                                color: appProvider.accentColor,
                              ),
                              onSelected: (value) {
                                switch (value) {
                                  case 'copy':
                                    _copyVerse(verseNumber, verseText);
                                    break;
                                  case 'share':
                                    _shareVerse(verseNumber, verseText);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'copy',
                                  child: Row(
                                    children: [
                                      Icon(Icons.copy_rounded),
                                      SizedBox(width: 12),
                                      Text('Copy'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'share',
                                  child: Row(
                                    children: [
                                      Icon(Icons.share_rounded),
                                      SizedBox(width: 12),
                                      Text('Share'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Arabic verse text (RTL)
                        SelectableText(
                          verseText,
                          style: AppTheme.arabicTextStyle(
                            fontSize: appProvider.arabicTextSize,
                            color: isDark ? AppTheme.textLight : AppTheme.textDark,
                            height: 1.9,
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                        
                        // Translation
                        if (_showTranslation) ...[
                          const SizedBox(height: 16),
                          Divider(
                            color: isDark 
                                ? AppTheme.textLight.withOpacity(0.2)
                                : AppTheme.textDark.withOpacity(0.2),
                          ),
                          const SizedBox(height: 12),
                          SelectableText(
                            _getTranslation(verseNumber),
                            textDirection: TranslationHelper.isRTLLanguage(appProvider.selectedTranslation)
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            textAlign: TranslationHelper.isRTLLanguage(appProvider.selectedTranslation)
                                ? TextAlign.right
                                : TextAlign.left,
                            style: TextStyle(
                              fontSize: appProvider.translationFontSize,
                              color: isDark ? AppTheme.textLight : AppTheme.textDark,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
