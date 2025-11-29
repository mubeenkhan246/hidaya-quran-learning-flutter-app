import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_app/utils/translation_helper.dart';
import 'package:i_app/utils/responsive_helper.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:share_plus/share_plus.dart';
import 'package:just_audio/just_audio.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/prayer_calendar_widget.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/quran_flashes_widget.dart';
import '../widgets/glass_card.dart';
import 'surah_detail_screen.dart';
import 'full_surah_player_screen.dart';
import 'quran_flashes_screen.dart';

class QuranReadingScreen extends StatefulWidget {
  const QuranReadingScreen({super.key});

  @override
  State<QuranReadingScreen> createState() => QuranReadingScreenState();
}

class QuranReadingScreenState extends State<QuranReadingScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showVerseTranslation = false;
  bool _showSalawatTranslation = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingVerseOfDay = false;
  bool _isLoadingVerseOfDay = false;
  
  // Get verse of the day (changes daily)
  Map<String, dynamic> get verseOfTheDay {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    // Cycle through some beautiful verses
    final verses = [
      {'surah': 2, 'verse': 255, 'name': 'Ayat Al-Kursi'}, // Throne Verse
      {'surah': 55, 'verse': 13, 'name': 'Ar-Rahman'},
      {'surah': 3, 'verse': 185, 'name': 'Ali Imran'},
      {'surah': 94, 'verse': 5, 'name': 'Ash-Sharh'},
      {'surah': 2, 'verse': 286, 'name': 'Al-Baqarah'},
      {'surah': 49, 'verse': 13, 'name': 'Al-Hujurat'},
      {'surah': 39, 'verse': 53, 'name': 'Az-Zumar'},
    ];
    return verses[dayOfYear % verses.length];
  }
  
  // Featured Surahs - The 4 Quls
  List<int> get featuredSurahs => [109, 112, 113, 114]; // Al-Kafirun, Al-Ikhlas, Al-Falaq, An-Nas
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Listen to audio player state changes to update UI
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          // Update play/pause button based on actual player state
          _isPlayingVerseOfDay = state.playing;
          
          // Reset when completed
          if (state.processingState == ProcessingState.completed) {
            _isPlayingVerseOfDay = false;
          }
        });
      }
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Stop audio when app is paused or inactive
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _audioPlayer.stop();
      if (mounted) {
        setState(() {
          _isPlayingVerseOfDay = false;
          _isLoadingVerseOfDay = false;
        });
      }
    }
  }
  
  void _playSurah(int surahNumber) {
    // Stop verse of the day audio before navigating
    _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _isPlayingVerseOfDay = false;
        _isLoadingVerseOfDay = false;
      });
    }
    
    // Navigate to full surah player screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullSurahPlayerScreen(
          surahNumber: surahNumber,
        ),
      ),
    );
  }

  // Public method to stop audio (called from parent widget)
  void stopAudio() {
    _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _isPlayingVerseOfDay = false;
        _isLoadingVerseOfDay = false;
      });
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    // Stop and dispose audio player
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }
  
  Future<void> _playVerseOfDay() async {
    final verse = verseOfTheDay;
    final appProvider = context.read<AppProvider>();
    final reciterKey = appProvider.selectedReciter;
    
    try {
      // If currently playing, pause it
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
        setState(() {
          _isPlayingVerseOfDay = false;
        });
        return;
      }
      
      // If paused (has audio loaded), resume it
      if (_audioPlayer.processingState == ProcessingState.ready && !_audioPlayer.playing) {
        await _audioPlayer.play();
        setState(() {
          _isPlayingVerseOfDay = true;
        });
        return;
      }
      
      // Otherwise, load and play new audio
      setState(() {
        _isLoadingVerseOfDay = true;
      });
      
      // Get audio URL
      final audioUrl = TranslationHelper.getVerseAudioUrl(
        verse['surah'],
        verse['verse'],
        reciterKey,
      );
      
      // Load and play audio
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
      
      setState(() {
        _isPlayingVerseOfDay = true;
        _isLoadingVerseOfDay = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingVerseOfDay = false;
        _isPlayingVerseOfDay = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Container(
          decoration: AppTheme.gradientBackground(appProvider.themeMode),
          child: SafeArea(
            child: SingleChildScrollView(
              child: responsive.constrainWidth(
                Column(
                  children: [
                    _buildHeader(appProvider, responsive),
                    SizedBox(height: responsive.spacing),
                    // Prayer Times & Calendar
                    const PrayerCalendarWidget(),
                    SizedBox(height: responsive.spacing),
                    // Quick Actions
                    const QuickActionsWidget(),
                    SizedBox(height: responsive.spacing),
                    _buildSalawatSection(appProvider, responsive),
                    SizedBox(height: responsive.spacing),
                    _buildVerseOfTheDay(appProvider, responsive),
                    SizedBox(height: responsive.spacing),
                    _buildFeaturedSurahs(appProvider, responsive),
                    SizedBox(height: responsive.spacing),
                    // Quran Flashes (limited)
                    const QuranFlashesWidget(maxVerses: 4),
                    SizedBox(height: responsive.spacing),
                    // View More Flashes Button
                    _buildViewMoreFlashesButton(appProvider, responsive),
                    SizedBox(height: responsive.spacing),
                    // _buildSearchBar(),
                    // const SizedBox(height: 16),
                    // _buildSurahList(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _copyToClipboard(String text) {
    final appProvider = context.read<AppProvider>();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: appProvider.accentColor),
            const SizedBox(width: 12),
            const Text('Copied to clipboard'),
          ],
        ),
        backgroundColor: appProvider.isDarkMode 
            ? AppTheme.secondaryDeep 
            : Colors.white,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _shareText(String text) {
    // Share.share(text, subject: 'Salawat upon Prophet Muhammad ﷺ');
    SharePlus.instance.share(ShareParams(text: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ'));
  }

  Widget _buildSalawatSection(AppProvider appProvider, ResponsiveHelper responsive) {
    final glassStyle = appProvider.glassStyle;
    final isTinted = glassStyle == AppTheme.glassStyleTinted;
    final isDark = appProvider.isDarkMode;
    
    const arabicText = 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ';
    const transliteration = 'Allahumma salli \'ala Muhammad wa \'ala ali Muhammad';
    const translation = 'O Allah, bless Muhammad and the family of Muhammad.';
    const hadith = 'It was narrated that Musa bin Talha said: I asked Zaid bin Kharijah who said: "I asked the Messenger of Allah (ﷺ) and he said: Send salah upon me and strive hard in supplication." - Sunan An-Nasai 1293';
    
    final fullText = '$arabicText\n\n$transliteration\n\n$translation\n\n$hadith';
    
    return Padding(
      padding: responsive.screenPadding,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isTinted 
                ? appProvider.accentColor.withOpacity(isDark ? 0.15 : 0.12)
                : (isDark ? AppTheme.glassClear : const Color(0x50FFFFFF)),
              isTinted
                ? appProvider.accentColor.withOpacity(isDark ? 0.05 : 0.03)
                : (isDark ? AppTheme.glassClear : const Color(0x30FFFFFF)),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isTinted
                ? appProvider.accentColor.withOpacity(0.3)
                : (isDark ? AppTheme.glassStroke : AppTheme.textDark.withOpacity(0.08)),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isTinted
                  ? appProvider.accentColor.withOpacity(0.2)
                  : Colors.black.withOpacity(isDark ? 0.15 : 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: responsive.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with badge and icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.smallSpacing * 1.5,
                      vertical: responsive.smallSpacing * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isTinted
                          ? appProvider.accentColor.withOpacity(0.15)
                          : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          size: 16,
                          color: appProvider.accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Salawat upon Prophet Muhammad',
                          style: TextStyle(
                            color: appProvider.accentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Icons at top right
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _copyToClipboard(fullText),
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 20,
                          color: appProvider.accentColor,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 0),
                      IconButton(
                        onPressed: () => _shareText(fullText),
                        icon: Icon(
                          Icons.share_rounded,
                          size: 20,
                          color: appProvider.accentColor,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Arabic Text - Right aligned
              Container(
                width: double.infinity,
                child: Text(
                  arabicText,
                  style: AppTheme.arabicTextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    height: 2.2,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 12),
              
              // Decorative divider
              Container(
                width: double.infinity,
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      appProvider.accentColor.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Translation toggle button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showSalawatTranslation = !_showSalawatTranslation;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isTinted
                        ? (isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.5))
                        : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isTinted
                          ? appProvider.accentColor.withOpacity(0.3)
                          : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08)),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showSalawatTranslation ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        size: 18,
                        color: appProvider.accentColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _showSalawatTranslation ? 'Hide Translation' : 'Show Translation',
                        style: TextStyle(
                          color: appProvider.accentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showSalawatTranslation ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: appProvider.accentColor,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Translation text (collapsible)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _showSalawatTranslation
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          // Transliteration
                          Text(
                            transliteration,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Translation
                          Text(
                            translation,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Hadith reference
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: appProvider.accentColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              hadith,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                height: 1.6,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppProvider appProvider, ResponsiveHelper responsive) {
    final isDark = appProvider.isDarkMode;
    
    return Padding(
      padding: EdgeInsets.fromLTRB(
        responsive.responsiveValue(phone: 20, tablet: 30, largeTablet: 60),
        15,
        responsive.responsiveValue(phone: 20, tablet: 30, largeTablet: 60),
        10,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Translation Language Selector
              Expanded(
                child: _buildSelectorButton(
                  icon: Icons.translate_rounded,
                  label: 'Translation',
                  value: _getLanguageDisplayName(appProvider.selectedTranslation),
                  onTap: () => _showLanguageSelector(context),
                  appProvider: appProvider,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              // Reciter Selector
              Expanded(
                child: _buildSelectorButton(
                  icon: Icons.record_voice_over_rounded,
                  label: 'Reciter',
                  value: TranslationHelper.getReciterName(appProvider.selectedReciter),
                  onTap: () => _showReciterSelector(context),
                  appProvider: appProvider,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorButton({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required AppProvider appProvider,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appProvider.accentColor.withOpacity(isDark ? 0.15 : 0.12),
              appProvider.accentColor.withOpacity(isDark ? 0.08 : 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: appProvider.accentColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: appProvider.accentColor,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppTheme.textLight.withOpacity(0.7)
                        : AppTheme.textDark.withOpacity(0.7),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: appProvider.accentColor,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.textLight : AppTheme.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageDisplayName(String key) {
    final languages = TranslationHelper.getLanguages();
    final language = languages.firstWhere(
      (lang) => lang['key'] == key,
      orElse: () => {'name': 'English'},
    );
    return language['name']!.replaceAll(RegExp(r'\s*\([^)]*\)'), ''); // Remove parentheses
  }

  void _showLanguageSelector(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final isDark = appProvider.isDarkMode;
    final languages = TranslationHelper.getLanguages();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                : [const Color(0xFFf0f4f8), const Color(0xFFe8eef5)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: appProvider.accentColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Row(
              children: [
                Icon(Icons.translate_rounded, color: appProvider.accentColor),
                const SizedBox(width: 12),
                Text(
                  'Select Translation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Language list
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final lang = languages[index];
                  final isSelected = appProvider.selectedTranslation == lang['key'];
                  
                  return GestureDetector(
                    onTap: () {
                      appProvider.setLanguage(lang['name']!, lang['key']!);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? appProvider.accentColor.withOpacity(0.2)
                            : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? appProvider.accentColor
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: appProvider.accentColor,
                              size: 20,
                            ),
                          if (isSelected) const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              lang['name']!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isDark ? AppTheme.textLight : AppTheme.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReciterSelector(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final isDark = appProvider.isDarkMode;
    final reciters = TranslationHelper.getReciters();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                : [const Color(0xFFf0f4f8), const Color(0xFFe8eef5)],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: appProvider.accentColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Row(
              children: [
                Icon(Icons.record_voice_over_rounded, color: appProvider.accentColor),
                const SizedBox(width: 12),
                Text(
                  'Select Reciter',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Reciter list
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: reciters.length,
                itemBuilder: (context, index) {
                  final reciter = reciters[index];
                  final isSelected = appProvider.selectedReciter == reciter['key'];
                  
                  return GestureDetector(
                    onTap: () {
                      appProvider.setReciter(reciter['key']!);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? appProvider.accentColor.withOpacity(0.2)
                            : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? appProvider.accentColor
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: appProvider.accentColor,
                              size: 20,
                            ),
                          if (isSelected) const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              reciter['name']!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isDark ? AppTheme.textLight : AppTheme.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

    String _getTranslation(int surahNumber, int verseNumber, String translationKey) {
    return TranslationHelper.getTranslation(
      surahNumber,
      verseNumber,
      translationKey,
    );
  }

  Widget _buildVerseOfTheDay(AppProvider appProvider, ResponsiveHelper responsive) {
    final glassStyle = appProvider.glassStyle;
    final isTinted = glassStyle == AppTheme.glassStyleTinted;
    final isDark = appProvider.isDarkMode;
    final verse = verseOfTheDay;
    final verseText = quran.getVerse(verse['surah'], verse['verse'],  verseEndSymbol: true);
    final verseTranslationText = _getTranslation(verse['surah'], verse['verse'], appProvider.selectedTranslation);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        responsive.responsiveValue(phone: 24, tablet: 40, largeTablet: 60),
        16,
        responsive.responsiveValue(phone: 24, tablet: 40, largeTablet: 60),
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isTinted
                  ? appProvider.accentColor.withOpacity(isDark ? 0.08 : 0.06)
                  : (isDark ? AppTheme.glassClear : const Color(0x40FFFFFF)),
              isTinted
                  ? appProvider.accentColor.withOpacity(isDark ? 0.03 : 0.02)
                  : (isDark ? AppTheme.glassClear : const Color(0x20FFFFFF)),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isTinted
                ? appProvider.accentColor.withOpacity(0.2)
                : (isDark ? AppTheme.glassStroke : AppTheme.textDark.withOpacity(0.08)),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: responsive.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.smallSpacing * 1.5,
                      vertical: responsive.smallSpacing * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isTinted
                          ? appProvider.accentColor.withOpacity(0.15)
                          : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: appProvider.accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Verse of the Day - ${verse['surah']}:${verse['verse']}',
                          style: TextStyle(
                            color: appProvider.accentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(width: 8),
                  // Text(
                  //   '${verse['surah']}:${verse['verse']}',
                  //   style: TextStyle(
                  //     color: appProvider.accentColor,
                  //     fontWeight: FontWeight.w600,
                  //     fontSize: 14,
                  //   ),
                  // ),
                  // const Spacer(),
                  // Icons at top right
                  Row(
                    children: [
                      IconButton(
                        onPressed: _isLoadingVerseOfDay ? null : _playVerseOfDay,
                        icon: _isLoadingVerseOfDay
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(appProvider.accentColor),
                                ),
                              )
                            : Icon(
                                _isPlayingVerseOfDay ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                size: 20,
                                color: appProvider.accentColor,
                              ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      // const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          final text = '$verseText\n\n$verseTranslationText\n\nQuran ${verse['surah']}:${verse['verse']}';
                          _copyToClipboard(text);
                        },
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 20,
                          color: appProvider.accentColor,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      // const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          final text = '$verseText\n\n$verseTranslationText\n\nQuran ${verse['surah']}:${verse['verse']}';
                          SharePlus.instance.share(ShareParams(text: text));
                        },
                        icon: Icon(
                          Icons.share_rounded,
                          size: 20,
                          color: appProvider.accentColor,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: Text(
                  verseText,
                  style: AppTheme.arabicTextStyle(
                    fontSize: responsive.arabicBodySize,
                    fontWeight: FontWeight.w600,
                    color: appProvider.isDarkMode ? AppTheme.textLight : AppTheme.textDark,
                    height: 2.2,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      appProvider.accentColor.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Translation toggle button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showVerseTranslation = !_showVerseTranslation;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isTinted
                        ? (isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.5))
                        : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isTinted
                          ? appProvider.accentColor.withOpacity(0.3)
                          : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08)),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showVerseTranslation ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        size: 18,
                        color: appProvider.accentColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _showVerseTranslation ? 'Hide Translation' : 'Show Translation',
                        style: TextStyle(
                          color: appProvider.accentColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _showVerseTranslation ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: appProvider.accentColor,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Translation text (collapsible)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _showVerseTranslation
                    ? Column(
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            verseTranslationText,
                            textDirection: TranslationHelper.isRTLLanguage(appProvider.selectedTranslation)
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            textAlign: TranslationHelper.isRTLLanguage(appProvider.selectedTranslation)
                                ? TextAlign.right
                                : TextAlign.left,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSurahs(AppProvider appProvider, ResponsiveHelper responsive) {
    final glassStyle = appProvider.glassStyle;
    final isTinted = glassStyle == AppTheme.glassStyleTinted;
    final isDark = appProvider.isDarkMode;
    
    return Padding(
      padding: responsive.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isTinted
                      ? appProvider.accentColor.withOpacity(0.15)
                      : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.stars_rounded,
                      size: 16,
                      color: appProvider.accentColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'The 4 Quls',
                      style: TextStyle(
                        color: appProvider.accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 2-Column Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: responsive.gridColumns,
              crossAxisSpacing: responsive.smallSpacing,
              mainAxisSpacing: responsive.smallSpacing,
              childAspectRatio: responsive.isTabletOrLarger ? 2/2.5 : 2/2.2,
            ),
            itemCount: featuredSurahs.length,
            itemBuilder: (context, index) {
              final surahNum = featuredSurahs[index];
              final surahName = quran.getSurahName(surahNum);
              final surahNameArabic = quran.getSurahNameArabic(surahNum);
              final versesCount = quran.getVerseCount(surahNum);
              
              // Get icon for each Qul
              IconData getIcon() {
                switch (surahNum) {
                  case 109: return Icons.block_rounded; // Al-Kafirun
                  case 112: return Icons.filter_1_rounded; // Al-Ikhlas (Oneness)
                  case 113: return Icons.wb_sunny_rounded; // Al-Falaq (Daybreak)
                  case 114: return Icons.people_rounded; // An-Nas (Mankind)
                  default: return Icons.menu_book_rounded;
                }
              }
              
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SurahDetailScreen(surahNumber: surahNum),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        isTinted
                            ? appProvider.accentColor.withOpacity(isDark ? 0.15 : 0.12)
                            : (isDark ? AppTheme.glassClear : const Color(0x40FFFFFF)),
                        isTinted
                            ? appProvider.accentColor.withOpacity(isDark ? 0.05 : 0.03)
                            : (isDark ? AppTheme.glassClear : const Color(0x20FFFFFF)),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isTinted
                          ? appProvider.accentColor.withOpacity(0.3)
                          : (isDark ? AppTheme.glassStroke : AppTheme.textDark.withOpacity(0.08)),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icon
                        // Container(
                        //   width: 60,
                        //   height: 60,
                        //   decoration: BoxDecoration(
                        //     gradient: LinearGradient(
                        //       begin: Alignment.topLeft,
                        //       end: Alignment.bottomRight,
                        //       colors: [
                        //         appProvider.accentColor,
                        //         appProvider.accentColor.withOpacity(0.7),
                        //       ],
                        //     ),
                        //     borderRadius: BorderRadius.circular(16),
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: appProvider.accentColor.withOpacity(0.3),
                        //         blurRadius: 12,
                        //         spreadRadius: 0,
                        //       ),
                        //     ],
                        //   ),
                        //   child: Icon(
                        //     getIcon(),
                        //     color: Colors.white,
                        //     size: 32,
                        //   ),
                        // ),
                        const SizedBox(height: 12),
                        
                        // Arabic Name
                        Text(
                          surahNameArabic,
                          style: AppTheme.arabicTextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: appProvider.accentColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        
                        // English Name
                        Text(
                          surahName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        
                        // Verses count
                        Text(
                          '$versesCount Verses',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        
                        const Spacer(),
                        
                        // Play button
                        ElevatedButton.icon(
                          onPressed: () => _playSurah(surahNum),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appProvider.accentColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            minimumSize: const Size(double.infinity, 36),
                          ),
                          icon: const Icon(Icons.play_arrow_rounded, size: 20),
                          label: const Text(
                            'Play',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewMoreFlashesButton(AppProvider appProvider, ResponsiveHelper responsive) {
    return Padding(
      padding: responsive.screenPadding,
      child: GlassCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QuranFlashesScreen(showBackButton: true),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.cardPadding.horizontal / 2,
            vertical: responsive.spacing,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: appProvider.accentColor,
                size: responsive.iconSize * 0.85,
              ),
              SizedBox(width: responsive.smallSpacing),
              Text(
                'View More Flashes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: appProvider.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: responsive.smallSpacing * 0.75),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: appProvider.accentColor,
                size: responsive.smallIconSize * 0.8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final appProvider = context.watch<AppProvider>();
    final glassStyle = appProvider.glassStyle;
    final isTinted = glassStyle == AppTheme.glassStyleTinted;
    final isDark = appProvider.isDarkMode;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        decoration: BoxDecoration(
          color: isTinted
              ? appProvider.accentColor.withOpacity(isDark ? 0.08 : 0.06)
              : (isDark ? AppTheme.glassClear : const Color(0x40FFFFFF)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isTinted
                ? appProvider.accentColor.withOpacity(0.2)
                : (isDark ? AppTheme.glassStroke : AppTheme.textDark.withOpacity(0.1)),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isTinted
                  ? appProvider.accentColor.withOpacity(0.1)
                  : Colors.black.withOpacity(isDark ? 0.1 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: _searchController,
            style: TextStyle(
              color: appProvider.isDarkMode ? AppTheme.textLight : AppTheme.textDark,
            ),
            decoration: InputDecoration(
              hintText: 'Search by Surah Name or Number...',
              hintStyle: TextStyle(
                fontSize: 14,
                color: appProvider.isDarkMode 
                    ? AppTheme.textLight.withOpacity(0.5)
                    : AppTheme.textDark.withOpacity(0.5),
              ),
              border: InputBorder.none,
              icon: Icon(
                Icons.search_rounded,
                color: appProvider.accentColor,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: appProvider.accentColor,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
      ),
    );
  }

  // Widget _buildSurahList() {
  //   final appProvider = context.watch<AppProvider>();
  //   final glassStyle = appProvider.glassStyle;
  //   final isTinted = glassStyle == AppTheme.glassStyleTinted;
  //   final isDark = appProvider.isDarkMode;
    
  //   // Filter surahs based on search
  //   final filteredSurahs = <int>[];
  //   for (int i = 1; i <= quran.totalSurahCount; i++) {
  //     final surahName = quran.getSurahName(i);
  //     if (_searchQuery.isEmpty ||
  //         surahName.toLowerCase().contains(_searchQuery) ||
  //         i.toString().contains(_searchQuery)) {
  //       filteredSurahs.add(i);
  //     }
  //   }
    
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 24),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           'All Surahs (${filteredSurahs.length})',
  //           style: Theme.of(context).textTheme.titleLarge?.copyWith(
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         ListView.builder(
  //           shrinkWrap: true,
  //           physics: const NeverScrollableScrollPhysics(),
  //           itemCount: filteredSurahs.length,
  //           itemBuilder: (context, index) {
  //             final surahNumber = filteredSurahs[index];
  //             final surahName = quran.getSurahName(surahNumber);
  //             final surahNameArabic = quran.getSurahNameArabic(surahNumber);
  //             final versesCount = quran.getVerseCount(surahNumber);
  //             final revelationType = quran.getPlaceOfRevelation(surahNumber);
        
  //             return GestureDetector(
  //               onTap: () {
  //                 Navigator.push(
  //                   context,
  //                   MaterialPageRoute(
  //                     builder: (context) => SurahDetailScreen(
  //                       surahNumber: surahNumber,
  //                     ),
  //                   ),
  //                 );
  //               },
  //               child: Container(
  //                 margin: const EdgeInsets.only(bottom: 12),
  //                 padding: const EdgeInsets.all(16),
  //                 decoration: BoxDecoration(
  //                   gradient: LinearGradient(
  //                     begin: Alignment.topLeft,
  //                     end: Alignment.bottomRight,
  //                     colors: [
  //                       isTinted
  //                           ? appProvider.accentColor.withOpacity(isDark ? 0.06 : 0.05)
  //                           : (isDark ? AppTheme.glassClear : const Color(0x30FFFFFF)),
  //                       isTinted
  //                           ? appProvider.accentColor.withOpacity(isDark ? 0.02 : 0.01)
  //                           : (isDark ? AppTheme.glassClear : const Color(0x10FFFFFF)),
  //                     ],
  //                   ),
  //                   borderRadius: BorderRadius.circular(16),
  //                   border: Border.all(
  //                     color: isTinted
  //                         ? appProvider.accentColor.withOpacity(0.15)
  //                         : (isDark ? AppTheme.glassStroke : AppTheme.textDark.withOpacity(0.06)),
  //                     width: 1,
  //                   ),
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     // Surah Number Badge
  //                     Container(
  //                       width: 50,
  //                       height: 50,
  //                       decoration: BoxDecoration(
  //                         gradient: LinearGradient(
  //                           colors: [
  //                             appProvider.accentColor,
  //                             appProvider.accentColor.withOpacity(0.7),
  //                           ],
  //                         ),
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                       child: Center(
  //                         child: Text(
  //                           surahNumber.toString(),
  //                           style: const TextStyle(
  //                             color: Colors.white,
  //                             fontWeight: FontWeight.bold,
  //                             fontSize: 18,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     const SizedBox(width: 16),
                      
  //                     // Surah Info
  //                     Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             surahName,
  //                             style: Theme.of(context).textTheme.titleLarge,
  //                           ),
  //                           const SizedBox(height: 4),
  //                           Text(
  //                             '$revelationType • $versesCount Verses',
  //                             style: Theme.of(context).textTheme.bodySmall,
  //                           ),
  //                         ],
  //                       ),
  //                     ),
                      
  //                     // Arabic Name
  //                     Expanded(
  //                       child: Text(
  //                         surahNameArabic,
  //                         style: AppTheme.arabicTextStyle(
  //                           fontSize: 22,
  //                           fontWeight: FontWeight.bold,
  //                           color: appProvider.accentColor,
  //                         ),
  //                         textAlign: TextAlign.right,
  //                       ),
  //                     ),
                      
  //                     const SizedBox(width: 12),
                      
  //                     // Play button
  //                     GestureDetector(
  //                       onTap: () => _playSurah(surahNumber),
  //                       child: Container(
  //                         width: 40,
  //                         height: 40,
  //                         decoration: BoxDecoration(
  //                           color: appProvider.accentColor,
  //                           borderRadius: BorderRadius.circular(10),
  //                           boxShadow: [
  //                             BoxShadow(
  //                               color: appProvider.accentColor.withOpacity(0.3),
  //                               blurRadius: 8,
  //                               spreadRadius: 0,
  //                             ),
  //                           ],
  //                         ),
  //                         child: const Icon(
  //                           Icons.play_arrow_rounded,
  //                           color: Colors.white,
  //                           size: 24,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
