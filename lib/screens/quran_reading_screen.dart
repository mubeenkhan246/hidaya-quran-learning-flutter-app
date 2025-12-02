import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i_app/utils/translation_helper.dart';
import 'package:i_app/utils/responsive_helper.dart';
import 'package:i_app/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'package:quran/quran.dart' as quran;
import 'package:share_plus/share_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:ui';
import 'package:glassmorphism/glassmorphism.dart';
import '../providers/app_provider.dart';
import '../constants/app_theme.dart';
import '../widgets/prayer_calendar_widget.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/quran_flashes_widget.dart';
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
  
  // Name of the Day (using a small curated list of Names of Allah)
  Map<String, String> get nameOfTheDay {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final names = [
      {
        'arabic': 'الرَّحْمَنُ',
        'transliteration': 'Ar-Rahman',
        'meaning': 'The Most Compassionate',
      },
      {
        'arabic': 'الرَّحِيمُ',
        'transliteration': 'Ar-Rahim',
        'meaning': 'The Most Merciful',
      },
      {
        'arabic': 'الْمَلِكُ',
        'transliteration': 'Al-Malik',
        'meaning': 'The King and Owner of Dominion',
      },
      {
        'arabic': 'السَّلاَمُ',
        'transliteration': 'As-Salam',
        'meaning': 'The Source of Peace and Safety',
      },
      {
        'arabic': 'الْمُؤْمِنُ',
        'transliteration': 'Al-Mu’min',
        'meaning': 'The Giver of Faith and Security',
      },
      {
        'arabic': 'الْغَفَّارُ',
        'transliteration': 'Al-Ghaffar',
        'meaning': 'The Constantly Forgiving',
      },
      {
        'arabic': 'الرَّزَّاقُ',
        'transliteration': 'Ar-Razzaq',
        'meaning': 'The Provider and Sustainer',
      },
    ];
    return names[dayOfYear % names.length];
  }

  // Hadith of the Day (short, inspiring ahadith)
  Map<String, String> get hadithOfTheDay {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    final hadiths = [
      {
        'text': 'Actions are but by intentions, and every man shall have only that which he intended.',
        'source': 'Sahih al-Bukhari & Sahih Muslim',
        'number': '', // e.g. "Bukhari 1, Muslim 1907"
      },
      {
        'text': 'The strong person is not the one who can wrestle, but the strong person is the one who controls himself when angry.',
        'source': 'Sahih al-Bukhari & Sahih Muslim',
        'number': '',
      },
      {
        'text': 'Allah is more merciful to His servants than a mother is to her child.',
        'source': 'Sahih al-Bukhari & Sahih Muslim',
        'number': '',
      },
      {
        'text': 'Whoever follows a path in pursuit of knowledge, Allah will make easy for him a path to Paradise.',
        'source': 'Sahih Muslim',
        'number': '',
      },
      {
        'text': 'The best of you are those who learn the Qur’an and teach it.',
        'source': 'Sahih al-Bukhari',
        'number': '',
      },
      {
        'text': 'Spread peace between yourselves, feed the hungry, and pray at night while others sleep, and you will enter Paradise in peace.',
        'source': 'Jami` at-Tirmidhi (graded Sahih)',
        'number': '',
      },
      {
        'text': 'Make things easy and do not make things difficult, give glad tidings and do not drive people away.',
        'source': 'Sahih al-Bukhari & Sahih Muslim',
        'number': '',
      },
    ];
    return hadiths[dayOfYear % hadiths.length];
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
                    // ⚠️ Note: PrayerCalendarWidget must be made translucent 
                    // and wrapped in GlassContainer inside its own file.
                    const PrayerCalendarWidget(), 
                    SizedBox(height: responsive.spacing),
                    // Quick Actions
                    // ⚠️ Note: QuickActionsWidget must be made translucent 
                    // and wrapped in GlassContainer inside its own file.
                    const QuickActionsWidget(),
                    SizedBox(height: responsive.spacing),
                    _buildSalawatSection(appProvider, responsive),
                    SizedBox(height: responsive.spacing),
                    _buildDailyTabs(appProvider, responsive),
                    SizedBox(height: responsive.spacing),
                    _buildFeaturedSurahs(appProvider, responsive),
                    SizedBox(height: responsive.spacing),
                    // Quran Flashes (limited)
                    // ⚠️ Note: QuranFlashesWidget must be made translucent 
                    // and wrapped in GlassContainer inside its own file.
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
             Text('Copied to clipboard', style: TextStyle(color:
             context.read<AppProvider>().isDarkMode 
            ?  Colors.white : AppTheme.secondaryDeep,
            )),
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
    SharePlus.instance.share(ShareParams(text: text));
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required AppProvider appProvider,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: appProvider.accentColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: appProvider.accentColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: appProvider.accentColor,
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // 3. SALAWAT CARD - Updated with Glassmorphism
  // -----------------------------------------------------------------------

  Widget _buildSalawatSection(AppProvider appProvider, ResponsiveHelper responsive) {
    final isDark = appProvider.isDarkMode;
    
    const arabicText = 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ';
    const transliteration = 'Allahumma salli \'ala Muhammad wa \'ala ali Muhammad';
    const translation = 'O Allah, bless Muhammad and the family of Muhammad.';
    const hadith = 'It was narrated that Musa bin Talha said: I asked Zaid bin Kharijah who said: "I asked the Messenger of Allah (ﷺ) and he said: Send salah upon me and strive hard in supplication." - Sunan An-Nasai 1293';
    
    final fullText = 'Salawat upon Prophet Muhammad ﷺ:\n$arabicText\n\n$transliteration\n\n$translation\n\nSource: $hadith';
    
    return Padding(
      padding: responsive.screenPadding,
      child: GlassCard(
        width: double.infinity,
        // height: 250,
        borderRadius: 24,
        // blur: 25,
        // alignment: Alignment.center,
        // border: 2,
        // linearGradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: isDark 
        //     ? [
        //         Colors.white.withOpacity(0.1),
        //         Colors.white.withOpacity(0.05),
        //       ]
        //     : [
        //         Colors.white.withOpacity(0.25),
        //         Colors.white.withOpacity(0.15),
        //       ],
        // ),
        // borderGradient: LinearGradient(
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        //   colors: [
        //     appProvider.accentColor.withOpacity(0.5),
        //     appProvider.accentColor.withOpacity(0.2),
        //   ],
        // ),
        child: Padding(
          padding: responsive.cardPadding,
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
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
                      color: appProvider.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          size: 16,
                          color: appProvider.accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Salawat',
                          style: TextStyle(
                            color: appProvider.accentColor,
                            fontWeight: FontWeight.w700,
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
                      _buildGlassIconButton(
                        icon: Icons.copy_rounded,
                        onPressed: () => _copyToClipboard(fullText),
                        appProvider: appProvider,
                      ),
                      const SizedBox(width: 8),
                      _buildGlassIconButton(
                        icon: Icons.share_rounded,
                        onPressed: () => _shareText(fullText),
                        appProvider: appProvider,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Arabic Text - Right aligned
              Text(
                arabicText,
                style: AppTheme.arabicTextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color.fromARGB(255, 73, 51, 51) : AppTheme.textDark,
                  height: 2.2,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 16),
              
              // Decorative divider
              Container(
                width: double.infinity,
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      appProvider.accentColor.withOpacity(0.4),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: appProvider.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: appProvider.accentColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _showSalawatTranslation ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        size: 20,
                        // color: Colors.white,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _showSalawatTranslation ? 'Hide Translation' : 'Show Translation',
                        style: const TextStyle(
                          // color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _showSalawatTranslation ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        // color: Colors.white,
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
                          const SizedBox(height: 16),
                          // Transliteration
                          Text(
                            transliteration,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              height: 1.7,
                              fontSize: 15,
                              color: isDark ? AppTheme.textLight.withOpacity(0.85) : AppTheme.textDark.withOpacity(0.85),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Translation
                          Text(
                            translation,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.7,
                              fontSize: 15,
                              color: isDark ? AppTheme.textLight : AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Hadith reference
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: appProvider.accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: appProvider.accentColor.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              hadith,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                height: 1.7,
                                fontStyle: FontStyle.italic,
                                fontSize: 13,
                                color: isDark ? AppTheme.textLight.withOpacity(0.75) : AppTheme.textDark.withOpacity(0.75),
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

  // -----------------------------------------------------------------------
  // 1. SELECTORS - Updated to use GlassContainer
  // -----------------------------------------------------------------------

  Widget _buildHeader(AppProvider appProvider, ResponsiveHelper responsive) {
    // Note: Removed the unused isTinted/glassStyle variables
    
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
  }) {
    final isDark = appProvider.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        width: double.infinity,
        height: 70,
        borderRadius: 18,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [
                Colors.white.withOpacity(0.12),
                Colors.white.withOpacity(0.06),
              ]
            : [
                Colors.white.withOpacity(0.3),
                Colors.white.withOpacity(0.18),
              ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            appProvider.accentColor.withOpacity(0.5),
            appProvider.accentColor.withOpacity(0.25),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 17,
                    color: appProvider.accentColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.textLight.withOpacity(0.75)
                          : AppTheme.textDark.withOpacity(0.75),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: appProvider.accentColor,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppTheme.textLight : AppTheme.textDark,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
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
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.7,
          borderRadius: 32,
          blur: 30,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.08),
                ]
              : [
                  Colors.white.withOpacity(0.35),
                  Colors.white.withOpacity(0.22),
                ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              appProvider.accentColor.withOpacity(0.6),
              appProvider.accentColor.withOpacity(0.3),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: appProvider.accentColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: appProvider.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.translate_rounded,
                        color: appProvider.accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Select Translation',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.textLight : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Language list
                Expanded(
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
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? appProvider.accentColor.withOpacity(0.25)
                                : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? appProvider.accentColor.withOpacity(0.6)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: appProvider.accentColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              if (isSelected) const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  lang['name']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.7,
          borderRadius: 32,
          blur: 30,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.08),
                ]
              : [
                  Colors.white.withOpacity(0.35),
                  Colors.white.withOpacity(0.22),
                ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              appProvider.accentColor.withOpacity(0.6),
              appProvider.accentColor.withOpacity(0.3),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: appProvider.accentColor.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: appProvider.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.record_voice_over_rounded,
                        color: appProvider.accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Select Reciter',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.textLight : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Reciter list
                Expanded(
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
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? appProvider.accentColor.withOpacity(0.25)
                                : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? appProvider.accentColor.withOpacity(0.6)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: appProvider.accentColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              if (isSelected) const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  reciter['name']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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

  // -----------------------------------------------------------------------
  // 4. DAILY TABS: VERSE / NAME / HADITH OF DAY
  // -----------------------------------------------------------------------

  Widget _buildDailyTabs(AppProvider appProvider, ResponsiveHelper responsive) {
    final isDark = appProvider.isDarkMode;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        responsive.responsiveValue(phone: 24, tablet: 40, largeTablet: 60),
        16,
        responsive.responsiveValue(phone: 24, tablet: 40, largeTablet: 60),
        0,
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TabBar(
                labelPadding: const EdgeInsets.symmetric(horizontal: 10),
                indicatorColor: Colors.transparent,
                // indicatorPadding: EdgeInsets.only(left:0, right: 0),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: appProvider.accentColor,
                ),
                
                    labelColor: Colors.white,
          unselectedLabelColor: appProvider.isDarkMode
              ? AppTheme.textLight.withOpacity(0.6)
              : AppTheme.textDark.withOpacity(0.6),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
                tabs: const [
                  Tab(text: 'Verse of Day'),
                  Tab(text: 'Name of Day'),
                  Tab(text: 'Hadith of Day'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: responsive.responsiveValue(phone: 320, tablet: 340, largeTablet: 360),
              child: TabBarView(
                children: [
                  _buildVerseOfTheDay(appProvider, responsive),
                  _buildNameOfDayTab(appProvider, responsive),
                  _buildHadithOfDayTab(appProvider, responsive),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseOfTheDay(AppProvider appProvider, ResponsiveHelper responsive) {
    final isDark = appProvider.isDarkMode;
    final verse = verseOfTheDay;
    final verseText = quran.getVerse(verse['surah'], verse['verse'], verseEndSymbol: true);
    final verseTranslationText = _getTranslation(verse['surah'], verse['verse'], appProvider.selectedTranslation);
    final name = nameOfTheDay;

    return GlassCard(
      width: double.infinity,
      borderRadius: 26,
      child: Padding(
        padding: responsive.cardPadding,
        child: SingleChildScrollView(
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
                    color: appProvider.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 16,
                        color: appProvider.accentColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Verse of Day',
                        style: TextStyle(
                          color: appProvider.accentColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Container(
                    //   width: 44,
                    //   height: 44,
                    //   decoration: BoxDecoration(
                    //     gradient: LinearGradient(
                    //       colors: [
                    //         appProvider.accentColor,
                    //         appProvider.accentColor.withOpacity(0.8),
                    //       ],
                    //     ),
                    //     shape: BoxShape.circle,
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: appProvider.accentColor.withOpacity(0.3),
                    //         blurRadius: 12,
                    //         offset: const Offset(0, 4),
                    //       ),
                    //     ],
                    //   ),
                    //   child: IconButton(
                    //     onPressed: _isLoadingVerseOfDay ? null : _playVerseOfDay,
                    //     icon: _isLoadingVerseOfDay
                    //         ? const SizedBox(
                    //             width: 22,
                    //             height: 22,
                    //             child: CircularProgressIndicator(
                    //               strokeWidth: 2.5,
                    //               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    //             ),
                    //           )
                    //         : Icon(
                    //             _isPlayingVerseOfDay ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    //             size: 26,
                    //             color: Colors.white,
                    //           ),
                    //     padding: EdgeInsets.zero,
                    //     constraints: const BoxConstraints(),
                    //   ),
                    // ),
                    // const SizedBox(width: 8),
                    _buildGlassIconButton(
                      icon: Icons.copy_rounded,
                      onPressed: () {
                        final text = '$verseText\n\n$verseTranslationText\n\nQuran ${verse['surah']}:${verse['verse']}';
                        _copyToClipboard(text);
                      },
                      appProvider: appProvider,
                    ),
                    const SizedBox(width: 8),
                    _buildGlassIconButton(
                      icon: Icons.share_rounded,
                      onPressed: () {
                        final text = '$verseText\n\n$verseTranslationText\n\nQuran ${verse['surah']}:${verse['verse']}';
                        SharePlus.instance.share(ShareParams(text: text));
                      },
                      appProvider: appProvider,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Text(
            //   verseText,
            //   style: AppTheme.arabicTextStyle(
            //     fontSize: 22,
            //     fontWeight: FontWeight.w600,
            //     color: isDark ? AppTheme.textLight : AppTheme.textDark,
            //     height: 2.0,
            //   ),
            //   textAlign: TextAlign.right,
            // ),
            // const SizedBox(height: 12),
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
                fontSize: 15,
                color: isDark ? AppTheme.textLight : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 14,
                  color: isDark
                      ? AppTheme.textLight.withOpacity(0.9)
                      : AppTheme.textDark.withOpacity(0.8),
                ),
                const SizedBox(width: 6),
                Text(
                  quran.getSurahNameArabic(verse['surah']),
                  style: AppTheme.arabicTextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '• ${verse['surah']}:${verse['verse']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
              // ],
              // const SizedBox(height: 12),
              // Text(
              //   name['meaning'] ?? '',
              //   style: TextStyle(
              //     fontSize: 13,
              //     height: 1.6,
              //     color: isDark
              //         ? AppTheme.textLight.withOpacity(0.85)
              //         : AppTheme.textDark.withOpacity(0.9),
              //   ),
              // ),
            ],
          ),
          ]
        ),
      ),
    ));
  }

  Widget _buildNameOfDayTab(AppProvider appProvider, ResponsiveHelper responsive) {
    final isDark = appProvider.isDarkMode;
    final name = nameOfTheDay;

    final fullText = '${name['arabic'] ?? ''}\n${name['transliteration'] ?? ''}\n\n${name['meaning'] ?? ''}';

    return GlassCard(
      width: double.infinity,
      borderRadius: 26,
      child: Padding(
        padding: responsive.cardPadding,
        child: SingleChildScrollView(
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
                      color: appProvider.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 16,
                          color: appProvider.accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Name of Day',
                          style: TextStyle(
                            color: appProvider.accentColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildGlassIconButton(
                        icon: Icons.copy_rounded,
                        onPressed: () => _copyToClipboard(fullText),
                        appProvider: appProvider,
                      ),
                      const SizedBox(width: 8),
                      _buildGlassIconButton(
                        icon: Icons.share_rounded,
                        onPressed: () => _shareText(fullText),
                        appProvider: appProvider,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  name['arabic'] ?? '',
                  style: AppTheme.arabicTextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    height: 2.0,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name['transliteration'] ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.7,
                  fontSize: 15,
                  color: isDark
                      ? AppTheme.textLight.withOpacity(0.9)
                      : AppTheme.textDark.withOpacity(0.9),
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
                      appProvider.accentColor.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name['meaning'] ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.7,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppTheme.textLight.withOpacity(0.9)
                      : AppTheme.textDark.withOpacity(0.95),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHadithOfDayTab(AppProvider appProvider, ResponsiveHelper responsive) {
    final isDark = appProvider.isDarkMode;
    final hadith = hadithOfTheDay;

    final hadithText = hadith['text'] ?? '';
    final hadithSource = hadith['source'] ?? '';
    final hadithNumber = hadith['number'] ?? '';

    final referenceParts = <String>[];
    if (hadithSource.isNotEmpty) {
      referenceParts.add(hadithSource);
    }
    if (hadithNumber.isNotEmpty) {
      referenceParts.add('Hadith no. $hadithNumber');
    }
    final referenceText = referenceParts.join(' • ');

    final fullText = referenceText.isEmpty
        ? hadithText
        : '$hadithText\n\n$referenceText';

    return GlassCard(
      width: double.infinity,
      borderRadius: 26,
      child: Padding(
        padding: responsive.cardPadding,
        child: SingleChildScrollView(
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
                      color: appProvider.accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 16,
                          color: appProvider.accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Hadith of Day',
                          style: TextStyle(
                            color: appProvider.accentColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildGlassIconButton(
                        icon: Icons.copy_rounded,
                        onPressed: () => _copyToClipboard(fullText),
                        appProvider: appProvider,
                      ),
                      const SizedBox(width: 8),
                      _buildGlassIconButton(
                        icon: Icons.share_rounded,
                        onPressed: () => _shareText(fullText),
                        appProvider: appProvider,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                hadithText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.7,
                  fontSize: 15,
                  color: isDark ? AppTheme.textLight : AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),
              if (referenceText.isNotEmpty)
                Text(
                  referenceText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                    fontSize: 13,
                    color: isDark
                        ? AppTheme.textLight.withOpacity(0.8)
                        : AppTheme.textDark.withOpacity(0.8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------------------------
  // 5. FEATURED SURAHS - Updated to use GlassContainer
  // -----------------------------------------------------------------------

  Widget _buildFeaturedSurahs(AppProvider appProvider, ResponsiveHelper responsive) {
    final isDark = appProvider.isDarkMode;
    
    return Padding(
      padding: responsive.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          // Row(
          //   children: [
          //     Container(
          //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          //       decoration: BoxDecoration(
          //         color: appProvider.accentColor.withOpacity(0.15),
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //       child: Row(
          //         children: [
          //           Icon(
          //             Icons.stars_rounded,
          //             size: 16,
          //             color: appProvider.accentColor,
          //           ),
          //           const SizedBox(width: 6),
          //           Text(
          //             '',
          //             style: TextStyle(
          //               color: appProvider.accentColor,
          //               fontWeight: FontWeight.w700,
          //               fontSize: 13,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 16),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      appProvider.accentColor.withOpacity(0.2),
                      appProvider.accentColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.stars_rounded,
                  color: appProvider.accentColor,
                  size: 20,
                ),
              ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The 4 Quls',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.textLight : AppTheme.textDark,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 320,
                    child: Text(
                      'The "Four Quls" are four short chapters (surahs) of the Quran that all begin with the word "Qul" (meaning "Say")',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppTheme.textLight.withOpacity(0.6)
                            : AppTheme.textDark.withOpacity(0.6),
                      ),
                    ),
                  ),
                  // Text(
                  //   ' • ${appProvider.selectedLanguage}',
                  //   style: TextStyle(
                  //     fontSize: 11,
                  //     fontWeight: FontWeight.w600,
                  //     color: appProvider.accentColor.withOpacity(0.8),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
          // Verses count
          // Text(
          //   '25 verses',
          //   style: TextStyle(
          //     fontSize: 12,
          //     fontWeight: FontWeight.w600,
          //     color: appProvider.accentColor,
          //   ),
          // ),
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
              childAspectRatio: responsive.isTabletOrLarger ? 2/2 : 2/1.6,
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
                child: GlassmorphicContainer(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 22,
                  blur: 22,
                  alignment: Alignment.center,
                  border: 2,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark 
                      ? [
                          Colors.white.withOpacity(0.12),
                          Colors.white.withOpacity(0.06),
                        ]
                      : [
                          Colors.white.withOpacity(0.28),
                          Colors.white.withOpacity(0.18),
                        ],
                  ),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      appProvider.accentColor.withOpacity(0.5),
                      appProvider.accentColor.withOpacity(0.25),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Arabic Name
                        Text(
                          surahNameArabic,
                          style: AppTheme.arabicTextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: appProvider.accentColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        
                        // English Name
                        Text(
                          surahName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: isDark ? AppTheme.textLight : AppTheme.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        
                        // Verses count
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: appProvider.accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$versesCount Verses',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: appProvider.accentColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        // const Spacer(),
                        
                        // Play button
                        // Container(
                        //   width: double.infinity,
                        //   height: 40,
                        //   decoration: BoxDecoration(
                        //     gradient: LinearGradient(
                        //       colors: [
                        //         appProvider.accentColor,
                        //         appProvider.accentColor.withOpacity(0.85),
                        //       ],
                        //     ),
                        //     borderRadius: BorderRadius.circular(12),
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: appProvider.accentColor.withOpacity(0.25),
                        //         blurRadius: 10,
                        //         offset: const Offset(0, 4),
                        //       ),
                        //     ],
                        //   ),
                        //   child: ElevatedButton.icon(
                        //     onPressed: () => _playSurah(surahNum),
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: Colors.transparent,
                        //       foregroundColor: Colors.white,
                        //       elevation: 0,
                        //       shadowColor: Colors.transparent,
                        //       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(12),
                        //       ),
                        //     ),
                        //     icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        //     label: const Text(
                        //       'Play',
                        //       style: TextStyle(
                        //         fontWeight: FontWeight.w700,
                        //         fontSize: 13,
                        //       ),
                        //     ),
                        //   ),
                        // ),
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

  // -----------------------------------------------------------------------
  // 6. VIEW MORE BUTTON - Updated to use GlassContainer
  // -----------------------------------------------------------------------

  Widget _buildViewMoreFlashesButton(AppProvider appProvider, ResponsiveHelper responsive) {
    final isDark = appProvider.isDarkMode;

    return Padding(
      padding: responsive.screenPadding,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QuranFlashesScreen(showBackButton: true),
            ),
          );
        },
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 65,
          borderRadius: 20,
          blur: 25,
          alignment: Alignment.center,
          border: 2,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [
                  Colors.white.withOpacity(0.12),
                  Colors.white.withOpacity(0.06),
                ]
              : [
                  Colors.white.withOpacity(0.28),
                  Colors.white.withOpacity(0.18),
                ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              appProvider.accentColor.withOpacity(0.5),
              appProvider.accentColor.withOpacity(0.25),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.cardPadding.horizontal / 2,
              vertical: responsive.spacing * 0.75,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: appProvider.accentColor,
                  size: 22,
                ),
                SizedBox(width: responsive.smallSpacing),
                Text(
                  'View More Flashes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: appProvider.accentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: responsive.smallSpacing * 0.75),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: appProvider.accentColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}